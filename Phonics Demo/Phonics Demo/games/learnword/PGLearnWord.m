//
//  PGLearnWord.m
//  Phonics Games
//
//  Created by yiplee on 14-4-1.
//  Copyright 2014年 yiplee. All rights reserved.
//

enum Z_LAYERS {
	Z_BACKGROUND = -1,
    Z_WORD,
	Z_BLOCKS,
	Z_PHYSICS_DEBUG,
	Z_MENU,
};

enum LETTER_STATE{
    LetterWaked = 0,
    LetterSleep = 1
};

static const cpLayers PhysicsBlockBit = 1<<31;

// These are the layer bitmasks used for bubble and edges.
static const cpLayers PhysicsEdgeLayers = ~PhysicsBlockBit;
static const cpLayers PhysicsBlockLayers = CP_ALL_LAYERS;


#import "PGLearnWord.h"

#import "UtilsMacro.h"
#import "LetterBlock.h"

#import "PGColor.h"
#import "PGTimer.h"

#import "PGManager.h"

@interface PGLearnWord ()
{
    // physic
    cpSpace *_space;
    cpShape *_walls[4];
    
    CCArray *blocks;
    
    CCLabelBMFont *wordLabel;
    CCProgressTimer *gradientProgress;
    NSMutableDictionary *wordResults;
    
    LetterBlock *blockInTouch;
    
    ccTime _time;
    CCLabelBMFont *timelabel;
    
    CDLongAudioSource *audioPlayer;
    
    PGTimer *timer;
    
    CCSprite *pinwheel1,*pinwheel2;
}

@property (nonatomic,assign) NSUInteger currentIndex;

@end

@implementation PGLearnWord

+ (instancetype) gameWithWords:(NSArray *)words
{
    return [[[[self class] alloc] initWithWords:words] autorelease];
}

- (id) initWithWords:(NSArray *)words
{
    self = [super init];
    
    NSAssert(words.count > 0, @"words can't be empty or nil");
    _gameName = [@"LearnWord" copy];
    self.words = words;
    _currentIndex = NSNotFound;
    
    // background
    RGB565
    CCSprite *bg = [CCSprite spriteWithFile:@"learn_word_bg.pvr.ccz"];
    PIXEL_FORMAT_DEFAULT
    bg.position = CMP(0.5);
    bg.zOrder = Z_BACKGROUND;
    
    bg.scaleX = SCREEN_WIDTH/bg.contentSize.width;
    bg.scaleY = SCREEN_HEIGHT/bg.contentSize.height;
    [self addChild:bg];
    
    RGBA4444
    {
        pinwheel1 = [CCSprite spriteWithFile:@"pinwheel.pvr.ccz"];
        pinwheel1.position = CCMP(0.197, 0.802);
        [self addChild:pinwheel1];
//        [pinwheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5 angle:360]]];
    }
    {
        pinwheel2 = [CCSprite spriteWithFile:@"pinwheel.pvr.ccz"];
        pinwheel2.position = CCMP(0.805, 0.802);
        [self addChild:pinwheel2];
//        [pinwheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:5 angle:360]]];
    }
    PIXEL_FORMAT_DEFAULT
    
    blocks = [[CCArray alloc] init];
    wordResults = [[NSMutableDictionary alloc] initWithCapacity:[words count]];
    
    audioPlayer = [[CDLongAudioSource alloc] init];
    audioPlayer.delegate = self;
    
    timer = [[PGTimer alloc] init];
    
    //menu
    CCMenuItemImage *back = [CCMenuItemImage itemWithNormalImage:@"back_button_N.png" selectedImage:@"back_button_P.png" block:^(id sender){
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"pinwheel.pvr.ccz"];
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"learn_word_bg.pvr.ccz"];
        [[CCDirector sharedDirector] popScene];
    }];
    back.position = CCMP(0.1, 0.9);
    
    __block PGLearnWord *self_copy = self;
    CCMenuItemImage *restart = [CCMenuItemImage itemWithNormalImage:@"restart_button_N.png" selectedImage:@"restart_button_P.png" block:^(id sender){
//        for (LetterBlock *block in self_copy->blocks)
//        {
//            if (block.visible)
//                [block removeFromSpace:self_copy->_space];
//            [block removeFromParentAndCleanup:YES];
//        }
        
//        [self_copy->blocks removeAllObjects];
        [self_copy setGameLevel:self_copy->_gameLevel];
        
        self_copy.currentIndex = 0;
        [self_copy startGame];
    }];
    restart.position = CMP(0.9);
    
    CCMenu *menu = [CCMenu menuWithItems:back,restart, nil];
    menu.zOrder = Z_MENU;
    menu.position = CMP(0);
    [self addChild:menu];
    
    _space = cpSpaceNew();
    cpSpaceSetGravity(_space, cpv(0, -800.0f));

    //wall & ground
    {
        cpFloat radius = 5.f;
        
        // four corner
        cpVect leftDown = cpv(0, 0);
        cpVect leftUp = cpv(0,SCREEN_SIZE.height + 100);
        cpVect rightDown = cpv(SCREEN_SIZE.width, 0);
        cpVect rightUp = cpv(SCREEN_SIZE.width, SCREEN_SIZE.height+100);
        
        cpBody *groundBody = cpBodyNewStatic();
        
        _walls[0] = cpSegmentShapeNew( groundBody, leftDown, leftUp, radius);
        _walls[1] = cpSegmentShapeNew( groundBody, leftUp, rightUp, radius);
        _walls[2] = cpSegmentShapeNew( groundBody, rightUp, rightDown, radius);
        _walls[3] = cpSegmentShapeNew( groundBody, rightDown,leftDown, radius);
        
        for( int i=0;i<4;i++) {
            cpShapeSetElasticity(_walls[i], 1.0f );
            cpShapeSetFriction(_walls[i], 1.0f );
            cpShapeSetLayers(_walls[i], PhysicsEdgeLayers);
            cpSpaceAddStaticShape(_space, _walls[i]);
        }
    }
    
    // set debug draw
    CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForCPSpace:_space];
    debugNode.visible = NO;
    [self addChild:debugNode z:Z_PHYSICS_DEBUG];
    
    self.currentIndex = 0;
    
    [self scheduleUpdate];
    [self setTouchEnabled:YES];
    
    return self;
}

- (void) dealloc
{
    SLLog(@"learn word:dealloc");
    
    for( int i=0;i<4;i++) {
		cpShapeFree( _walls[i] );
	}
    
    cpSpaceFree(_space);
    
    [_gameName release];
    [_words release];
    
    [blocks release];
    [wordResults release];
    
    [audioPlayer release];
    [timer release];
    
    [super dealloc];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self playWordAtIndex:_currentIndex];
}

- (void) update:(ccTime)delta
{
    // make chipmunk run
    int steps = 2;
	CGFloat dt = [[CCDirector sharedDirector] animationInterval]/(CGFloat)steps;
    
	for(int i=0; i<steps; i++){
		cpSpaceStep(_space, dt);
	}
    
    // game logic
    static int tap = 0;
    if (tap > 8)
    {
        for (LetterBlock *block in blocks)
        {
            if (block.parent)
                continue;
            
            block.position = ccp(SCREEN_WIDTH*CCRANDOM_0_1(), SCREEN_HEIGHT+50*CCRANDOM_0_1());
            [self addChild:block];
            [block addToSpace:_space];
            
            break;
        }
        
        tap = 0;
    }
    
    tap += 1;
}

- (NSString *) currentWord
{
    if (_currentIndex < _words.count)
        return [[_words objectAtIndex:_currentIndex] uppercaseString];
    
    return nil;
}

- (void) setGameLevel:(LearnWordLevel)gameLevel
{
    _gameLevel = gameLevel;
    
    for (LetterBlock *block in blocks)
    {
        if (block.parent && block.visible)
        {
            [block removeFromSpace:_space];
        }
        [block removeFromParentAndCleanup:YES];
    }
    
    [blocks removeAllObjects];
    
    ccColor3B color = [PGColor randomBrightColor];
    for (NSString *word in self.words)
    {
        char letter = [[word uppercaseString] characterAtIndex:0];
        LetterBlock *block = [LetterBlock blockWithSize:CGSizeMake(60, 60) letter:letter];
        block.color = color;
        block.zOrder = Z_BLOCKS;
        
        cpShapeSetLayers(block.shape, PhysicsBlockLayers);
        [blocks addObject:block];
    }
    
    NSInteger count = _gameLevel * 10;
    while ((count--) >= 0) {
        char l = arc4random_uniform('Z'-'A'+1) + 'A';
        LetterBlock *block = [LetterBlock blockWithSize:CGSizeMake(60, 60) letter:l];
        block.color = color;
        block.zOrder = Z_BLOCKS;
        
        cpShapeSetLayers(block.shape, PhysicsBlockLayers);
        [blocks addObject:block];
    }
}

- (void) startGame
{
    [self playWordAtIndex:_currentIndex];
}

- (void) playWordAtIndex:(NSUInteger)idx
{
    @autoreleasepool {
        [wordLabel removeFromParentAndCleanup:YES];
        [gradientProgress removeFromParentAndCleanup:YES];
    }
    
    wordLabel = [CCLabelBMFont labelWithString:self.currentWord fntFile:@"GungSeo.fnt"];
    wordLabel.position = CCMP(0.5, 0.55);
    wordLabel.zOrder = Z_WORD;
    [self addChild:wordLabel];
    
    // gradient label
    CGSize texSize = wordLabel.boundingBox.size;
    CCRenderTexture *texRender = [CCRenderTexture renderTextureWithWidth:texSize.width height:texSize.height];
    [texRender begin];
    [wordLabel draw];
    [texRender end];
    [[texRender sprite] setBlendFunc:(ccBlendFunc){GL_ONE,GL_ONE_MINUS_SRC_ALPHA}];
    
    ccColor3B color = [PGColor randomBrightColor];
    wordLabel.color = color;
    
    for (CCSprite *letter in wordLabel.children)
    {
        letter.tag = LetterWaked;
    }
    
    CCSprite *sleepLetter = [[wordLabel children] objectAtIndex:0];
    sleepLetter.tag = LetterSleep;
    sleepLetter.color = ccGRAY;
    
    [timer startTimer];
    
    gradientProgress = [CCProgressTimer progressWithSprite:texRender.sprite];
    gradientProgress.sprite.flipY = YES;
    gradientProgress.type = kCCProgressTimerTypeBar;
    gradientProgress.barChangeRate = ccp(1, 0);
    gradientProgress.midpoint = ccp(0, 0.5);
    gradientProgress.position = wordLabel.position;
    gradientProgress.sprite.color = [PGColor randomBrightColor];
    gradientProgress.zOrder = wordLabel.zOrder + 1;
    gradientProgress.percentage = 0;
    [self addChild:gradientProgress];
    
    // audio
    [audioPlayer load:[self audioFileForWord:self.currentWord]];
    [audioPlayer stop];
    [audioPlayer rewind];
}

- (void) playNextWord
{
    if (_currentIndex >= self.words.count - 1)
    {
        [self finishGame];
        return;
    }
    
    _currentIndex++;
    [self playWordAtIndex:_currentIndex];
}

- (void) finishWordAtIndex:(NSUInteger)idx
{
    if (idx >= self.words.count)
        return;
    
    [timer stopTimer];
    CGFloat time = [timer timeElapsedInSeconds];
    NSDictionary *result = @{@"time": [NSNumber numberWithFloat:time]};
    NSString *word = [_words objectAtIndex:idx];
    [wordResults setValue:result forKey:word];
    
    [audioPlayer play];
    
    __block PGLearnWord *self_copy = self;
    CCProgressFromTo *p = [CCProgressFromTo actionWithDuration:1 from:0 to:100];
    CCCallBlock *p_done = [CCCallBlock actionWithBlock:^{
        [self_copy playNextWord];
    }];
    CCSequence *seq = [CCSequence actions:p,p_done, nil];
    [gradientProgress runAction:seq];
    
    [pinwheel1 stopAllActions];
    [pinwheel2 stopAllActions];
    [pinwheel1 runAction:[CCRotateBy actionWithDuration:2 angle:360]];
    [pinwheel2 runAction:[CCRotateBy actionWithDuration:2 angle:360]];
}

- (void) finishGame
{
    SLLog(@"finish game");
    [[PGManager sharedManager] finishGame:self.gameName];
}

- (NSString *) audioFileForWord:(NSString*)word
{
    return [[word lowercaseString] stringByAppendingPathExtension:@"caf"];
}

#pragma mark --touch

- (LetterBlock*) touchAtPosition:(CGPoint)position
{
    cpFloat radius = 10.f;
    cpShape *shape = cpSpaceNearestPointQueryNearest(_space, position, radius, PhysicsBlockLayers, CP_NO_GROUP, NULL);
    if (shape)
    {
        return (LetterBlock*)cpShapeGetUserData(shape);
    }
    return nil;
}

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    
    blockInTouch = [self touchAtPosition:pos];
    [blockInTouch removeFromSpace:_space];
    blockInTouch.rotation = 0;
    blockInTouch.color = [PGColor reverseColor:blockInTouch.color];
    blockInTouch.zOrder++;
    return blockInTouch ? YES:NO;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    
    blockInTouch.position = pos;
    
    int count = self.currentWord.length;
    for (int i=0;i<count;i++)
    {
        CCSprite *letter = [wordLabel.children objectAtIndex:i];
        if (letter.tag == LetterWaked)
            continue;
        
        //letter.tag == LetterSleep
        char l = [wordLabel.string characterAtIndex:i];
        if (CGRectContainsPoint(letter.boundingBox, [wordLabel convertToNodeSpace:pos]) && blockInTouch.letter == l)
        {
            CCSprite *block_copy = blockInTouch;
            __block PGLearnWord *self_copy = self;
            CGPoint targetPos = ccpAdd(letter.position, wordLabel.boundingBox.origin);
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:targetPos];
            CCCallBlock *done = [CCCallBlock actionWithBlock:^{
                block_copy.visible = NO;
                letter.color = wordLabel.color;
                letter.tag = LetterWaked;
                [self_copy finishWordAtIndex:_currentIndex];
            }];
            [blockInTouch runAction:[CCSequence actions:move,done, nil]];
            
            blockInTouch = nil;
            return;
        }
    }
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (blockInTouch)
    {
        [blockInTouch addToSpace:_space];
        cpBodyApplyForce(blockInTouch.CPBody, cpv(0, -100), cpv(1, 1));
        blockInTouch.color = [PGColor reverseColor:blockInTouch.color];
        blockInTouch.zOrder--;
    }
    blockInTouch = nil;
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [blockInTouch addToSpace:_space];
    blockInTouch.color = [PGColor reverseColor:blockInTouch.color];
    blockInTouch.zOrder--;
    blockInTouch = nil;
}

#pragma mark --CDLongAudioSourceDelegate

- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource
{
    SLLog(@"audio finish playing");
}

@end
