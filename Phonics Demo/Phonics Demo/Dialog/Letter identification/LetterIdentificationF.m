//
//  LetterIdentification_A.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-27.
//  Copyright 2013年 USTB. All rights reserved.
//

#import "LetterIdentificationF.h"
#import "CCAnimation+Helper.h"
#import "AnimatedSprite.h"

@implementation LetterIdentificationF
{
    // objects , weak ref
    
    CCSprite *sticker;
    
    
    CCSprite * stickerForAnimation;
    CCLabelBMFont * word;
    CCLabelBMFont * wordDummy;
    
    
    
    
    CCSprite * background;
    
    
    
    
    NSMutableArray *path;
    // static objects,weak ref
    
    CCSprite *whiteboard;
    CCSprite *guideboard;
    int                     currAnimIdx;
    
    CCSprite *egg;
    NSArray *frameNames;
    NSDictionary *framePositions;
    
}
BOOL validDrawing;

NSMutableArray  * path;
NSMutableArray *allPath;
CCLabelBMFont *label_A;
CCTexture2D *bigLetter;
CCTexture2D *littleLetter;
CCSprite * bigLetterPic;
CCSprite * littleLetterPic;
CCSprite * bigLetterPicWriting;
CCSprite * littleLetterPicWriting;
// on "init" you need to initialize your instance
-(void)moveComplete{
    
    
    
}
- (void) update:(ccTime)delta
{
    
    [super update:delta];
    
    if ( currAnimIdx == -1 )
        return;
    if ( [animStartTime count] && [animStartTime count] > currAnimIdx ) {
        NSString *currPosString = (NSString *)[animStartTime objectAtIndex:currAnimIdx];
        float currPos = [currPosString floatValue];
        
        
        if (_audioSource.audioSourcePlayer.currentTime > currPos ){
            
            NSLog(@"%f %f %d",currPos,_audioSource.audioSourcePlayer.currentTime,currAnimIdx);
            id obj = [animSprites objectAtIndex:currAnimIdx];
            if ( [obj isKindOfClass:[AnimatedSprite class]])
            {
                AnimatedSprite * sprite = (AnimatedSprite*) obj;
                sprite.visible = YES;
                if (currAnimIdx == 0 )
                {
                    [sprite startAnimation:@"swim"];
                    
                    id moveAction = [CCMoveTo actionWithDuration:3 position:CCMP(0.15,0.5)];
                    [sprite runAction:moveAction];
                }
                
                currAnimIdx++;
            }
            else
            {
                switch (currAnimIdx) {
                    case 1: //show whiteboard
                    {
                        whiteboard.visible = YES;
                        id moveAction = [CCMoveTo actionWithDuration:1 position:CCMP(0.5,0.5)];
                        [whiteboard runAction:moveAction];
                        currAnimIdx++;
                        break;
                    }
                    case 2: // flashing the first letter
                    {
                        CCSprite *charSprite = (CCSprite *)[[word children] objectAtIndex:0];
                        id scaleUpAction =  [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:1 scaleX:1.0 scaleY:1.0] rate:2.0];
                        
                        id scaleDownAction = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scaleX:0.8 scaleY:0.8] rate:2.0];
                        CCSequence *scaleSeq = [CCSequence actions:scaleUpAction, scaleDownAction, nil];
                        [charSprite runAction:[CCRepeatForever actionWithAction:scaleSeq]];
                        currAnimIdx++;
                        break;
                    }
                    case 3: // move letter to sticker
                    {
                        CCSequence *seq = [CCSequence actions:
                                           
                                           [CCMoveTo actionWithDuration:2 position:ccp(sticker.position.x-15,sticker.position.y)],
                                           
                                           [CCCallFunc actionWithTarget:self selector:@selector(moveComplete)], nil];
                        [wordDummy runAction:seq];
                        currAnimIdx++;
                        break;
                    }
                    case 4 :
                    {
                        //how to write Big B
                        AnimatedSprite * currSprite =(AnimatedSprite *)obj;
                        currSprite.visible = YES;
                        NSString * animationName = (NSString *)[animSpritesNames objectAtIndex:currAnimIdx];
                        NSLog(@"animation name %@ %d",animationName, currAnimIdx);
                        
                        [currSprite startAnimation:animationName];
                        currAnimIdx++;
                        break;
                    }
                    case 5: // move letter to sticker
                    {
                        
                        currAnimIdx++;
                        break;
                    }
                    case 6:
                    {
                        AnimatedSprite * currSprite =(AnimatedSprite *)obj;
                        currSprite.visible = YES;
                        NSString * animationName = (NSString *)[animSpritesNames objectAtIndex:currAnimIdx];
                        NSLog(@"animation name %@ %d",animationName, currAnimIdx);
                        
                        [currSprite startAnimation:animationName];
                        currAnimIdx++;
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }
}

-(void) showClue
{
    
}
-(BOOL) fileExistsInProject:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileInResourcesFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    return [fileManager fileExistsAtPath:fileInResourcesFolder];
}

-(void) initLetterPic
{
    NSString * littlePic = [[@"littleLetterPic" stringByAppendingString:self.lessonLetter] stringByAppendingString:@".png"];
    NSString * littleWriting = [[@"littleLetterPicWriting" stringByAppendingString:self.lessonLetter] stringByAppendingString:@".png"];
    NSString * bigPic = [[@"bigLetterPic" stringByAppendingString:self.lessonLetter] stringByAppendingString:@".png"];
    NSString * bigWriting = [[@"bigLetterPicWriting" stringByAppendingString:self.lessonLetter] stringByAppendingString:@".png"];
    
    if ([self fileExistsInProject:littlePic] && ([self fileExistsInProject:littleWriting]))
    {
        littleLetterPic = [CCSprite spriteWithFile:littlePic];
        littleLetterPicWriting = [CCSprite spriteWithFile:littleWriting];
        littleLetterPic.position = CCMP(0.4,0.4);
        littleLetterPicWriting.position = CCMP(0.4,0.4);
        [whiteboard addChild:littleLetterPic z:88];
        [whiteboard addChild:littleLetterPicWriting z:88];
        littleLetterPic.visible = NO;
        littleLetterPicWriting.visible = NO;
        
    }
    if ([self fileExistsInProject:bigPic] && ([self fileExistsInProject:bigWriting]))
    {
        bigLetterPic = [CCSprite spriteWithFile:bigPic];
        bigLetterPicWriting = [CCSprite spriteWithFile:bigWriting];
        bigLetterPic.position = CCMP(0.4,0.4);
        bigLetterPicWriting.position = CCMP(0.4,0.4);
        [whiteboard addChild:bigLetterPic z:88];
        [whiteboard addChild:bigLetterPicWriting z:88];
        bigLetterPic.visible = NO;
        bigLetterPicWriting.visible = NO;
        
    }
}



-(void) setFrame2
{
    CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"2.png"];
    egg.displayFrame = f;
}

-(void) setFrame3
{
    CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"3.png"];
    egg.displayFrame = f;
}
- (id) initWithInitOptions:(NSDictionary *)options
{
    if (self = [super initWithInitOptions:options])
    {
        
        
        
        CCSprite *fish1 = [CCSprite spriteWithFile:@"1.png"];
        fish1.position = CCMP(0.2,0.8);
        [self addChild:fish1 z:-2];
        
        CCSprite *fish2 = [CCSprite spriteWithFile:@"2.png"];
        fish2.position = CCMP(0.8,0.6);
        [self addChild:fish2 z:-2];
        
        CCSprite *fish3 = [CCSprite spriteWithFile:@"3.png"];
        fish3.position = CCMP(0.8,0.8);
        [self addChild:fish3 z:-2];
        
        
        
        allPath = [[NSMutableArray alloc] init];
        self.touchEnabled = YES;
        self.touchMode = kCCTouchesOneByOne;
        [self setTouchEnabled:YES];
        
        
        [self setTouchEnabled:YES];
        
        
        
        
        
        
        
        
        _rtDetection = [[CCRenderTexture renderTextureWithWidth:1 height:1] retain];
        
        littleLetter = [[CCTextureCache sharedTextureCache] addImage:
                        [NSString stringWithFormat:@"Little_%@.png",[self.lessonLetter lowercaseString]]];
        bigLetter    = [[CCTextureCache sharedTextureCache] addImage:
                        [NSString stringWithFormat:@"Big_%@.png",[self.lessonLetter uppercaseString]]];
        _tool = [CCSprite spriteWithTexture:bigLetter];
        _tool.position = CCMP(0.6,0.465);
        [self addChild:_tool z:-1];
        whiteboard = [CCSprite spriteWithSpriteFrameName:@"id_whiteboard.png"];
        whiteboard.visible = NO;
        whiteboard.position = CCMP(-0.1, 0.5);
        
        
        
        // firstLetterOfWord is a duplicated of word
        // the purpuse is to align with the word easily and then move first letter to sticker
        
        
        sticker = [CCSprite spriteWithSpriteFrameName:@"id_paper.png"];
        
        [sticker setPosition:CCMP(0.2,0.4)];
        [sticker setRotation:-10];
        [whiteboard addChild:sticker];
        
        stickerForAnimation = [CCSprite spriteWithFile:@"write_bg.png"];
        stickerForAnimation.position = CCMP(0.21,0.21);
        [whiteboard addChild:stickerForAnimation];
        
        
        [self addChild:whiteboard z:-2];
        
        [self initLetterPic];
        
        
        
        word = [CCLabelBMFont labelWithString:[self.soundNameWord uppercaseString] fntFile:@"ComicSansMS.fnt" width:400 alignment:kCCTextAlignmentLeft];
        [word setPosition:CCMP(0.2,0.55)];
        [word setRotation:-10];
        word.anchorPoint = ccp(0.0f,0.5f);
        CCSprite * colorFirstLetter = (CCSprite *)[[word children] objectAtIndex:0];
        colorFirstLetter.color = ccc3(255,0,0);
        NSString * wordDummyString = [NSString stringWithFormat:@"%@",self.lessonLetter ];
        
        
        wordDummy = [CCLabelBMFont
                     labelWithString:[wordDummyString uppercaseString]
                     fntFile:@"ComicSansMS.fnt"
                     width:400 alignment:kCCTextAlignmentLeft];
        wordDummy.position = word.position;
        wordDummy.rotation = word.rotation;
        wordDummy.visible = YES;
        wordDummy.anchorPoint=ccp(0.0f,0.5f);
        
        
        [whiteboard addChild:wordDummy ];
        [whiteboard addChild:word];
        
        
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"letter_identification_a.plist"];
        // scene blocks
        
        
        _numberOfScenes = 8;
        int currSceneIdx = 0;
        
        sceneBlocks = calloc(sizeof(SceneBlock)*_numberOfScenes, 1);
        
        // if we refer self.lessonLetter inside the block, it will crash
        // for now, create a string copy as a workaround.
        
        
        SceneBlock scene1 = ^(){
            
            id obj = [animSprites objectAtIndex:0];
            if ( [obj isKindOfClass:[AnimatedSprite class]])
            {
                AnimatedSprite * sprite = (AnimatedSprite*) obj;
                sprite.visible = YES;
                [sprite stopCurrentAnimation];
                
            }
            
        };
        sceneBlocks[currSceneIdx++] = Block_copy(scene1);
        if (_numberOfScenes == 8 ) // has the sentence "here is a clue"
        {
            
            
            SceneBlock scene2 = ^(){
                
                
            };
            
            sceneBlocks[currSceneIdx++] = Block_copy(scene2);
        }
        
        
        
        
        SceneBlock scene3 = ^(){
            
            id obj = [animSprites objectAtIndex:0];
            if ( [obj isKindOfClass:[AnimatedSprite class]])
            {
                AnimatedSprite * sprite = (AnimatedSprite*) obj;
                sprite.visible = YES;
                id moveAction = [CCMoveTo actionWithDuration:3 position:CCMP(0.6,0.5)];
                [sprite runAction:moveAction];
                sprite.flipX = YES;
            }
        };
        sceneBlocks[currSceneIdx++] = Block_copy(scene3);
        
        
        SceneBlock scene4 = ^(){
            //  “Do you know what letter car starts with”
            
            bigLetterPic.visible = YES;
            bigLetterPicWriting.visible = YES;
            id obj = [animSprites objectAtIndex:0];
            if ( [obj isKindOfClass:[AnimatedSprite class]])
            {
                AnimatedSprite * sprite = (AnimatedSprite*) obj;
                sprite.visible = YES;
                id moveAction = [CCMoveTo actionWithDuration:1 position:CCMP(1.2,0.5)];
                [sprite runAction:moveAction];
                
            }            id action1 = [CCFadeIn actionWithDuration:1];
            id action2 = [CCDelayTime actionWithDuration:1.5];
            id action3 = [CCFadeOut actionWithDuration:1];
            id action4 = [CCDelayTime actionWithDuration:1.5];
            id seq = [CCSequence actions:action1,action2,action3,action4,nil];
            id repeat = [CCRepeatForever actionWithAction:seq];
            
            [bigLetterPicWriting runAction:repeat];
            
        };
        sceneBlocks[currSceneIdx++] = Block_copy(scene4);
        
        
        SceneBlock scene5 = ^(){
            //Yes, car starts with the letter C!  (Clear screen and show the correct way to write a big C).  This is a big C.  Can you say C?”
            
            [word setString:[word.string uppercaseString]];
            
            bigLetterPic.visible = YES;
            bigLetterPicWriting.visible = YES;
            
        };
        sceneBlocks[currSceneIdx++] = Block_copy(scene5);;
        
        
        SceneBlock scene6 = ^(){
            //C!  Now this is how we write a big C.  (Screen shows C being written correctly).  Can you try to write a big C using your finger?”
            NSLog(@"scene 7");
            
            
            [word setString:[word.string uppercaseString]];
            [wordDummy setString:[wordDummy.string uppercaseString]];
            _tool.visible = YES;
            _tool.texture = bigLetter;
            
            
            
        };
        
        sceneBlocks[currSceneIdx++] = Block_copy(scene6);
        //[scene7 release];
        
        SceneBlock scene7 = ^(){
            // “Now this is a little c.  (Show little c next to big c).  Can you say c again?”
            littleLetterPic.visible = YES;
            littleLetterPicWriting.visible = YES;
            
            id action1 = [CCFadeIn actionWithDuration:1.5];
            id action2 = [CCDelayTime actionWithDuration:1.5];
            id action3 = [CCFadeOut actionWithDuration:1.5];
            id action4 = [CCDelayTime actionWithDuration:1.5];
            id seq = [CCSequence actions:action1,action2,action3,action4,nil];
            id repeat = [CCRepeatForever actionWithAction:seq];
            
            [littleLetterPicWriting runAction:repeat];
            [word setString:[word.string lowercaseString]];
            [wordDummy setString:[wordDummy.string lowercaseString]];
            
        };
        sceneBlocks[currSceneIdx++] = Block_copy(scene7);
        
        
        SceneBlock scene8 = ^(){
            //"C!  The little c is written the same way as the big C, just smaller."
            _tool.visible = YES;
            _tool.texture = littleLetter;
            
            
            
        };
        sceneBlocks[currSceneIdx++] = Block_copy(scene8);
        
        
        _indexOfCurrentScene = 0;
        
    }
    return self;
}

//- (void) sceneReset
- (void) resetScene
{
    
    _tool.visible = NO;
    littleLetterPicWriting.visible = NO;
    littleLetterPic.visible = NO;
    bigLetterPicWriting.visible = NO;
    bigLetterPic.visible = NO;
    [allPath removeAllObjects];
    [[self children] makeObjectsPerformSelector:@selector(stopAllActions)];
    
    for (id obj in animSprites)
    {
        if ( [obj  isKindOfClass:[AnimatedSprite class]] )
        {
            AnimatedSprite * sprite = (AnimatedSprite*) obj;
            sprite.visible = NO;
            
        }
    }
    currAnimIdx = [firstAnimIdxOfScene[_indexOfCurrentScene] integerValue];
    if ( _indexOfCurrentScene == 1 ) {
        whiteboard.position = CCMP(-0.1, 0.5);
        
    }
    NSLog(@"curr anim idx %d index of current scene %d", currAnimIdx,_indexOfCurrentScene);
    
}

- (void) dealloc
{
    SLLog(@"dealloc");
    
    [super dealloc];
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}
- (void) drawCurPoint:(CGPoint)curPoint PrevPoint:(CGPoint)prevPoint
{
    // load hand-writting outline
    
    float lineWidth = 20.0;
    ccColor4F red = ccc4f(209.0/255.0, 75.0/255.0, 75.0/255.0, 2.0);
    
    //These lines will calculate 4 new points, depending on the width of the line and the saved points
    CGPoint dir = ccpSub(curPoint, prevPoint);
    CGPoint perpendicular = ccpNormalize(ccpPerp(dir));
    CGPoint A = ccpAdd(prevPoint, ccpMult(perpendicular, lineWidth / 2));
    CGPoint B = ccpSub(prevPoint, ccpMult(perpendicular, lineWidth / 2));
    CGPoint C = ccpAdd(curPoint, ccpMult(perpendicular, lineWidth / 2));
    CGPoint D = ccpSub(curPoint, ccpMult(perpendicular, lineWidth / 2));
    
    CGPoint poly[4] = {A, C, D, B};
    
    //Then draw the poly, and a circle at the curPoint to get smooth corners
    ccDrawSolidPoly(poly, 4, red);
    ccDrawSolidCircle(curPoint, lineWidth/2.0, 20);
    
}
- (void) draw
{
    
    for (NSMutableArray* savedPath in allPath) {
        ccGLEnable(GL_LINE_STRIP);
        
        ccColor4F red = ccc4f(209.0/255.0, 75.0/255.0, 75.0/255.0, 1.0);
        ccDrawColor4F(red.r, red.g, red.b, red.a);
        
        float lineWidth = 12.0 * CC_CONTENT_SCALE_FACTOR();
        
        glLineWidth(lineWidth);
        
        int count = [savedPath count];
        
        for (int i = 0; i < (count - 1); i++){
            CGPoint pos1 = [[savedPath objectAtIndex:i] CGPointValue];
            CGPoint pos2 = [[savedPath objectAtIndex:i+1] CGPointValue];
            
            [self drawCurPoint:pos2 PrevPoint:pos1];
        }
        
    }
    [super draw];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
    
    
	if ( _tool.visible && CGRectContainsPoint(_tool.boundingBox, location))
	{
        path = [[NSMutableArray alloc]init];
        [allPath addObject:path];
        [path addObject:[NSValue valueWithCGPoint:location]];
        validDrawing = YES;
		CGPoint localLocation = [_tool convertToNodeSpace:location];
        
		if (![self isTransparentWithSprite:_tool pointInNodeSpace:localLocation])
		{
            
			return YES;
		}
	}
	
	return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [self convertTouchToNodeSpace:touch];
    [path addObject:[NSValue valueWithCGPoint:location]];
	if (CGRectContainsPoint(_tool.boundingBox, location))
	{
        
		CGPoint localLocation = [_tool convertToNodeSpace:location];
        
		if (![self isTransparentWithSprite:_tool pointInNodeSpace:localLocation])
		{
			
			
		}
        else
        {
            validDrawing = NO;
        }
	}
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!validDrawing) {
        [allPath removeLastObject];
    }
}
- (BOOL)isTransparentWithSprite:(CCSprite *)sprite pointInNodeSpace:(CGPoint)point
{
	BOOL isTransparent = YES;
    
	// see if the point is transparent. if so, ignore it.
	// http://www.cocos2d-iphone.org/forum/topic/18522
    
	Byte buffer[4];
    
	// Draw into the RenderTexture
	[_rtDetection beginWithClear:0 g:0 b:0 a:0];
	
	// move touch point to 0,0 so it goes to the right place on the rt
	// http://www.cocos2d-iphone.org/forum/topic/18796
	// hold onto old position to move it back immediately
	CGPoint oldPos = sprite.position;
	CGPoint oldAnchor = sprite.anchorPoint;
	float oldRotation = sprite.rotation;
	sprite.anchorPoint = ccp(0, 0);
	sprite.position = ccp(-point.x, -point.y);
	sprite.rotation = 0;
	[sprite visit];
	sprite.anchorPoint = oldAnchor;
	sprite.position = oldPos;
	sprite.rotation = oldRotation;
    
	// read the pixels
	glReadPixels(0, 0, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
	[_rtDetection end];
	
	// Read buffer : if untouched, point will be (0, 0, 0, 0). if the sprite was drawn into this pixel (ie not transparent), one of those values will be altered
	if ( buffer[0] || buffer[1] || buffer[2] || buffer[3]) {
		CCLOG(@" ");
		CCLOG(@"%d %d %d %d=== > ",buffer[0],buffer[1],buffer[2],buffer[3]);
		CCLOG(@" ");
		isTransparent = NO;
	}
    
	return isTransparent;
}

#pragma mark --layer

- (void) onEnter
{
    [super onEnter];
    
    //title
    CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"identification_title.png"];
    [self.toolbar setTitleNode:title];
    
    
    [self playSceneWithIndex:_indexOfCurrentScene];
}

#pragma mark --touch

- (void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}



@end
