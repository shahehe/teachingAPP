//
//  CardMatching.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatching.h"

#import "PGManager.h"

@implementation CardMatching

+ (CCScene*) gameWithWords:(NSArray *)words
{
    CCScene *scene = [CCScene node];
    CardMatching *layer = [[[CardMatching alloc] initWithWords:words] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithWords:(NSArray*)words
{
    if (self = [super init])
    {
        _gameName = [@"CardMatch" copy];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cardMatching.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cardMatching2.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cardsSheet.plist"];
        
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
        gameLayer = [CardMatchingGameLayer layerWithWords:words];
        levelDoneLayer = [CardMatchingLevelDoneLayer node];
        gameDoneLayer = [CardMatchingGameDoneLayer node];
        gameOverLayer = [CardMatchingGameOverLayer node];
        mpLayer = [CCLayerMultiplex layerWithLayers:gameLayer,levelDoneLayer,gameDoneLayer,gameOverLayer, nil];
        [self addChild:mpLayer z:0];
        
        [gameLayer prepareLayer];
        [gameLayer showWithDuration:0.5f];
    }
    return self;
}

- (void) pause
{
    CCScene *pauseScene = [CardMatchPauseMenu sceneWithScene:(CCScene*)self];
    [pauseScene setVertexZ:1024];
    [[CCDirector sharedDirector] pushScene:pauseScene];
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

// replay current level when game over
- (void) retry
{
    [self playAgain];
}

- (void) gameOver
{
    [gameOverLayer prepareWithScore:gameLayer.score];
    [mpLayer switchTo:GameOverLayer];
    [gameOverLayer showWithDuration:0.4f];
}

- (void) gameDone
{
//    NSUInteger score = gameLayer.totalScore;

    [gameDoneLayer prepareWithScore:gameLayer.score andTime:gameLayer.time];
    [mpLayer switchTo:GameDoneLayer];
    [gameDoneLayer showWithDuration:0.4f];
    
    [[PGManager sharedManager] finishGame:self.gameName];
}

- (void) backToMainMenu
{
    [self removeChild:mpLayer cleanup:YES];
    
    [[CCDirector sharedDirector] popScene];
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
    //[[CCDirector sharedDirector] setProjection:kCCDirectorProjection2D];
}

- (void) dealloc
{
    CCLOG(@"card match:dealloc");
    [_gameName release];
    [super dealloc];
}

@end
