//
//  GooseGame.m
//  LetterE
//
//  Created by yiplee on 14-3-25.
//  Copyright (c) 2014年 USTB. All rights reserved.
//

#import "GooseGame.h"
#import "config.h"

@interface Goose : CCSprite
{
    CGPoint _attachPosition;
    CGPoint _speed;
    
    CGPoint _startPosition;
    
    CGFloat _delay;
}

@property (nonatomic,readonly) CGPoint attachPosition;
@property (nonatomic,readonly) CGPoint speed;

- (id) flyGoose;
- (id) swimGoose;

- (void) resetPosition;

@end

@implementation Goose
@synthesize attachPosition = _attachPosition,speed = _speed;

- (id) flyGoose
{
    self = [super initWithSpriteFrameName:@"goose1"];
    NSArray *frameNames = @[@"goose1",@"goose2",@"goose3",@"goose4",@"goose5",@"goose6"];
    NSMutableArray *frames = [NSMutableArray array];
    [frameNames enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:obj];
        [frames insertObject:frame atIndex:0];
    }];
    
    CGFloat delay = CCRANDOM_0_1() * 0.3 + 0.05;
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:delay];
    CCAnimate *fly = [CCAnimate actionWithAnimation:animation];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:fly];
    [self runAction:r];
    
    _speed = ccp(-1/delay*30, 0);
    _attachPosition = ccp(43.7*2, 133.4*2);
    _startPosition= ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(1.225, 0.675));
    
    return self;
}

- (id) swimGoose
{
    self = [super initWithSpriteFrameName:@"goose0"];
    
    _speed = ccp(-(CCRANDOM_0_1()*100+100), 0);
    _attachPosition = ccp(61*2, 64*2);
    _startPosition = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(1.115, 0.334));
    
    return self;
}

- (void) resetPosition
{
    self.position = _startPosition;
}

- (void) dealloc
{
    [self stopAllActions];
    [super dealloc];
}

@end

NSString *const searchPath = @"Assets/Goose";

@interface GooseGame ()
{
    CCSprite *egg;
    
    NSMutableArray *gooses;
    NSMutableArray *letters;
    
    NSUInteger currentCountOfEggs;
    CCArray *nests;
}

@end

@implementation GooseGame

+ (CCScene *) gameScene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [GooseGame node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    self = [super init];
    NSAssert(self, @"game failed init");
    
    [self setSearchPath];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"goose.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"G.plist"];
    
    CCSprite *bg = [CCSprite spriteWithFile:@"background.png"];
    bg.anchorPoint = CGPointZero;
    bg.position = CGPointZero;
    bg.scaleX = SCREEN_WIDTH/bg.contentSize.width;
    bg.scaleY = SCREEN_HEIGHT/bg.contentSize.height;
    bg.zOrder = 0;
    [self addChild:bg];
    
    CCSprite *fg = [CCSprite spriteWithFile:@"foreground.png"];
    fg.anchorPoint = ccp(0.5, 0);
    fg.position = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.5, 0));
    fg.zOrder = 10;
    [self addChild:fg];
    
    egg = [CCSprite spriteWithFile:@"egg.png"];
    egg.position = CCMP(0.5, 0.5);
    egg.zOrder = 1;
    [self addChild:egg];
    
    NSString *buttons[] = {@"MENU",@"RESTART",@"START"};
    CGPoint pos[] = {ccp(0.1, 0.95),ccp(0.9, 0.95),ccp(0.5, 0.35)};
    CGPoint scale[] = {ccp(1, 1),ccp(1, 1),ccp(1, 1)};
    
    NSMutableArray *blocks = [NSMutableArray array];
    void (^_menu)(id sender) = ^(id sender){
        [[CCDirector sharedDirector] popScene];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"goose.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"G.plist"];
    };
    [blocks addObject:Block_copy(_menu)];
    Block_release(_menu);
    
    void (^_restart)(id sender) = ^(id sender){
        [[CCDirector sharedDirector] replaceScene:[GooseGame gameScene]];
    };
    [blocks addObject:Block_copy(_restart)];
    Block_release(_restart);
    
    __block id self_copy = self;
    void (^_start)(id sender) = ^(id sender){
        [self_copy startGame];
        [sender removeFromParentAndCleanup:YES];
        [egg removeFromParentAndCleanup:YES];
    };
    [blocks addObject:Block_copy(_start)];
    Block_release(_start);
    
    NSMutableArray *items = [NSMutableArray array];
    for (int idx =0;idx < 3;idx++)
    {
        CCSprite *normal = [CCSprite spriteWithFile:@"ccbButtonNormal.png"];
        CCSprite *highlighted = [CCSprite spriteWithFile:@"ccbButtonHighlighted.png"];
        void (^block)(id sender) = [blocks objectAtIndex:idx];
        CCMenuItemSprite *item = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:highlighted block:block];
        
        item.position = ccpCompMult(SCREEN_SIZE_AS_POINT, pos[idx]);
        item.scaleX = scale[idx].x;
        item.scaleY = scale[idx].y;
        
        NSString *str = buttons[idx];
        CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"GillSans" fontSize:16];
        label.color = ccWHITE;
        
        label.position = ccpMult(ccpFromSize(item.boundingBox.size), 0.5);
        [item addChild:label];
        label.scale = 1;
        label.anchorPoint = ccp(0.5, 0.5);
        [items addObject:item];
    };
    
    for (int i=blocks.count-1;i>=0;i--)
    {
        void (^block)(id sender) = [blocks objectAtIndex:i];
        Block_release(block);
        [blocks removeObjectAtIndex:i];
    }
    
    CCMenu *menu = [CCMenu menuWithArray:items];
    menu.zOrder = 20;
    menu.position = CGPointZero;
    [self addChild:menu];
    
    //goose
    gooses = [[NSMutableArray array] retain];
    [gooses addObject:[[[Goose alloc] flyGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] flyGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] flyGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] flyGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] flyGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] swimGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] swimGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] swimGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] swimGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] swimGoose] autorelease]];
    [gooses addObject:[[[Goose alloc] swimGoose] autorelease]];
    
    NSArray *letterFiles = @[@"g_right1.png",@"g_right2.png",@"g_wrong1.png",@"g_wrong2.png",@"g_wrong3.png",@"g_wrong4.png",@"g_wrong5.png"];
    NSUInteger count = letterFiles.count;
    letters = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0 ;i < count;i++)
    {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:letterFiles[i]];
        CCSprite *letter = [CCSprite spriteWithSpriteFrame:frame];
        if (i < 2)
        {
            letter.tag = 1;
        }
        else
        {
            letter.tag = 0;
        }
        [letters addObject:letter];
    }

    //nests
    
    nests = [[CCArray array] retain];
    CGPoint _startPoint = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(1, 0));
    for (int i=0;i<8;i++)
    {
        CCSprite *nest = [CCSprite spriteWithFile:@"nest.png"];
        nest.anchorPoint = ccp(1, 0);
        nest.position = _startPoint;
        [nests addObject:nest];
        [self addChild:nest z:30];
        _startPoint = ccpAdd(_startPoint, ccp(-nest.boundingBox.size.width+30, 0));
    }
    
    currentCountOfEggs = 3;
    [self refreshNests];
    
    return self;
}

- (void) update:(ccTime)delta
{
    for (Goose *goose in gooses)
    {
        if (!goose.parent)
            continue;
        
        if (!(CGRectGetMaxX(goose.boundingBox) < 0))
        {
            goose.position = ccpAdd(goose.position, ccpMult(goose.speed, delta));
        }
        else
        {
            [goose removeFromParentAndCleanup:NO];
            [goose removeAllChildrenWithCleanup:YES];
        }
    }
}

- (void) dealloc
{
    CCLOG(@"goose dealloc");

    [gooses release];
    [letters release];
    [nests release];
    
    [super dealloc];
}

- (void) onExit
{
    [super onExit];
    [self resetSearchPath];
    [self unscheduleUpdate];
}

- (void) startGame
{
    [self scheduleUpdate];
    
    [self setTouchEnabled:YES];
    [self releaseGoose];
    [self schedule:@selector(releaseGoose) interval:3];
}

- (void) releaseGoose
{
    NSUInteger count = [gooses count];
    NSUInteger idx = arc4random_uniform(count);
    for (int i=0;i<count;i++,idx++)
    {
        Goose *goose = [gooses objectAtIndex:idx % count];
        
        if (!goose.parent)
        {
            [goose resetPosition];
            [self addChild:goose z:4];
            
            CCSprite *letter = [self randomAvailableLetter];
            if (letter)
            {
                letter.position = goose.attachPosition;
                letter.anchorPoint = ccp(0.5, 1);
                [goose addChild:letter];
            }
            break;
        }
    }
}

- (CCSprite *) randomAvailableLetter
{
    unsigned int count = (unsigned int)letters.count;
    NSUInteger index = arc4random_uniform(count);
    
    CCSprite *letter = nil;
    for (int i=0;i < count;i++,index++)
    {
        CCSprite *_letter = [letters objectAtIndex:index % count];
        if (!_letter.parent)
        {
            letter = _letter;
            break;
        }
    }
    return letter;
}

-(void) refreshNests
{
    CCSprite *temp1 = [CCSprite spriteWithFile:@"nest.png"];
    CCSprite *temp2 = [CCSprite spriteWithFile:@"egg+nest.png"];

    CCSpriteFrame *nest_f = temp1.displayFrame;
    CCSpriteFrame *egg_nest_f = temp2.displayFrame;
    NSAssert(nest_f && egg_nest_f, @"null");
    
    for (int i=0;i < [nests count];i++)
    {
        CCSprite *_nest = [nests objectAtIndex:i];
        if (i < currentCountOfEggs)
        {
            _nest.displayFrame = egg_nest_f;
        }
        else
        {
            _nest.displayFrame = nest_f;
        }
    }

}

- (void) setSearchPath
{
    CCFileUtils *util = [CCFileUtils sharedFileUtils];
    
    NSMutableArray *paths = [util.searchPath mutableCopy];
    
    if (![[paths firstObject] isEqualToString:searchPath])
        [paths insertObject:searchPath atIndex:0];
    
    util.searchPath = paths;
    [paths release];
    
    //    CCLOG(@"set path:%@",util.searchPath.description);
}

- (void) resetSearchPath
{
    CCFileUtils *util = [CCFileUtils sharedFileUtils];
    
    NSMutableArray *paths = [util.searchPath mutableCopy];
    
    //    for (;[paths containsObject:searchPath];)
    //    {
    [paths removeObject:searchPath];
    //    }
    
    util.searchPath = paths;
    [paths release];
    
    //    CCLOG(@"reset path:%@",util.searchPath.description);
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    for (CCSprite *letter in letters)
    {
        if (!letter.parent)
            continue;
        CGPoint pos = [letter.parent convertTouchToNodeSpace:touch];
        CGRect touchRect = CGRectInset(letter.boundingBox, -30, -30);
        if (CGRectContainsPoint(touchRect, pos))
        {
            if (letter.tag == 1)
            {
                if (currentCountOfEggs < nests.count)
                    currentCountOfEggs += 1;
            }
            else if (letter.userObject == 0)
            {
                if (currentCountOfEggs > 0)
                    currentCountOfEggs -= 1;
            }
            [letter removeFromParentAndCleanup:YES];
            [self refreshNests];
        }
    }
}

@end
