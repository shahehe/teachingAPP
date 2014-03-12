//
//  CardMatching.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatching.h"

@implementation CardMatching

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    CardMatching *layer = [CardMatching node];
    [scene addChild:layer];
    return scene;
}

- (id) initWithGameData:(NSDictionary *)data
{
    if (self = [super initWithGameData:data])
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cardMatching.plist"];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"applause.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"button.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"buuu.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"select2.caf"];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGPoint centerScreen = ccp(width*0.5f, height*0.5f);
        
        //backgrond
        CGRect screenRect = CGRectMake(0, 0, width, height);
        CCSprite *background = [CCSprite spriteWithFile:@"CMsige.png" rect:screenRect];
        ccTexParams params =
        {
            GL_LINEAR,
            GL_LINEAR,
            GL_REPEAT,
            GL_REPEAT
        };
        [background.texture setTexParameters:&params];
        background.position = centerScreen;
        [self addChild:background z:-1];
        
        CCSprite *backgroundHead = [CCSprite spriteWithSpriteFrameName:@"biaotou.png"];
        backgroundHead.anchorPoint = ccp(0.5, 1);
        backgroundHead.position = ccp(width*0.5f, height);
        [self addChild:backgroundHead z:-1];
        
        CCSprite *backgroundFlower = [CCSprite spriteWithSpriteFrameName:@"hua.png"];
        backgroundFlower.anchorPoint = ccp(0.5, 0);
        backgroundFlower.position = ccp(width*0.5f, 0);
        [self addChild:backgroundFlower z:-1];
        
        CCSprite *backgroundSlideLeft = [CCSprite spriteWithSpriteFrameName:@"huangbian.png"];
        backgroundSlideLeft.anchorPoint = ccp(0, 0.5);
        backgroundSlideLeft.position = ccp(0, height*0.5f - 30);
        [self addChild:backgroundSlideLeft z:-1];
        
        CCSprite *backgroundSlideRight = [CCSprite spriteWithSpriteFrameName:@"huangbian.png"];
        [backgroundSlideRight setFlipX:YES];
        backgroundSlideRight.anchorPoint = ccp(1, 0.5);
        backgroundSlideRight.position = ccp(width, height*0.5f - 30);
        [self addChild:backgroundSlideRight z:-1];
        
        //game layers
        gamePrepareLayer = [CardMatchingGamePrepareLayer node];
        gameLayer = [[[CardMatchingGameLayer alloc] \
                      initWithGameData:self.gameData] autorelease];
        levelDoneLayer = [CardMatchingLevelDoneLayer node];
        gameDoneLayer = [CardMatchingGameDoneLayer node];
        gameOverLayer = [CardMatchingGameOverLayer node];
        mpLayer = [CCLayerMultiplex layerWithLayers:gamePrepareLayer,gameLayer,levelDoneLayer,gameDoneLayer,gameOverLayer, nil];

        [self addChild:mpLayer z:0];
        
        [gameLayer prepareLayer];
        [mpLayer switchToAndReleaseMe:GameLayer];
        [gameLayer showWithDuration:0.4f];
    }
    return self;
}

- (void) gameStart
{
    CCCallBlock *block1 = [CCCallBlock actionWithBlock:^{
        [gamePrepareLayer hideWithDuration:0.5f];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.55f];
    CCCallBlock *block2 = [CCCallBlock actionWithBlock:^{
        [gameLayer prepareLayer];
        [mpLayer switchToAndReleaseMe:GameLayer];
        [gameLayer showWithDuration:0.4f];
    }];
    
    CCSequence *seq = [CCSequence actions:block1,delay,block2, nil];
    [self runAction:seq];
}

- (void) levelDone
{
    [levelDoneLayer preareWithLevelIndex:gameLayer.currentLevel-1 andScore:gameLayer.score andTime:gameLayer.time];
    [mpLayer switchTo:LevelDoneLayer];
    [levelDoneLayer showWithDuration:0.4f];
}

- (void) nextLevel
{
    CCCallBlock *hideLevelDoneLayer = [CCCallBlock actionWithBlock:^{
        [levelDoneLayer hideWithDuration:0.4f];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.45f];
    CCCallBlock *showGameLayer = [CCCallBlock actionWithBlock:^{
        [gameLayer prepareLayer];
        [mpLayer switchTo:GameLayer];
        [gameLayer showWithDuration:0.4f];
    }];
    
    CCSequence *seq = [CCSequence actions:hideLevelDoneLayer,delay,showGameLayer, nil];
    [self runAction:seq];
}

- (void) playAgain
{
    [gameLayer reset];
    [gameLayer prepareLayer];
    [mpLayer switchTo:GameLayer];
    [gameLayer showWithDuration:0.4f];
}

- (void) gameOver
{
    [gameOverLayer prepareWithScore:gameLayer.score];
    [mpLayer switchTo:GameOverLayer];
    [gameOverLayer showWithDuration:0.4f];
}

- (void) gameDone
{
    [gameDoneLayer prepareWithScore:gameLayer.score andTime:gameLayer.time];
    [mpLayer switchTo:GameDoneLayer];
    [gameDoneLayer showWithDuration:0.4f];
}

- (void) backToMainMenu
{
    [[NSNotificationCenter defaultCenter] \
     postNotificationName:@"PhonicsGameExit" object:self];
}

- (void) onEnter
{
    [super onEnter];
    //[mpLayer switchTo:GameOverLayer];
    //[[CCDirector sharedDirector] setProjection:kCCDirectorProjection3D];
}

- (void) onExit
{
    [super onExit];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"cardMatching.plist"];
    
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"applause.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"button.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"buuu.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"select1.caf"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"select2.caf"];
}

- (void) dealloc
{
    [super dealloc];
}

@end
