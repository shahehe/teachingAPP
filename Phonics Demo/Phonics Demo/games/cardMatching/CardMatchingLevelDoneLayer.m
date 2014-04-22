//
//  CardMatchingLevelDoneLayer.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchingLevelDoneLayer.h"
#import "CardMatching.h"

@implementation CardMatchingLevelDoneLayer

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    CardMatchingLevelDoneLayer *layer = [CardMatchingLevelDoneLayer node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    if (self = [super init])
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGFloat winWidth = winSize.width;
        CGFloat winHeight = winSize.height;
        
        isShow = NO;
        
        boardHidePosition = ccp(winWidth*0.5f, -winHeight*0.5f);
        boardShowPosition = ccp(winWidth*0.5f, winHeight*0.5f);
        
        backBoard = [CCSprite spriteWithSpriteFrameName:@"levelDoneBackground.png"];
        backBoard.position = boardHidePosition;
        [self addChild:backBoard];
        
        CGSize boardSize = backBoard.contentSize;
        CGFloat boardWidth = boardSize.width;
        CGFloat boardHeight = boardSize.height;
        
        //cat
        CCSprite *cat = [CCSprite spriteWithSpriteFrameName:@"catSmile.png"];
        cat.position = ccp(boardWidth*0.3f, boardHeight*0.5f);
        [backBoard addChild:cat];
        
        // labels
        levelLabel = [CCLabelBMFont labelWithString:@"LEVEL 0 -> 1" fntFile:@"DenneSketchy60.fnt"];
        levelLabel.position = ccp(boardWidth*0.5f, boardHeight*0.65f);
        levelLabel.anchorPoint = ccp(0, 0.5);
        levelLabel.color = ccGRAY;
        ((CCSprite*)[[levelLabel children] lastObject]).color = ccGREEN;
        
        scoreLabel = [CCLabelBMFont labelWithString:@"SCORE 0" fntFile:@"DenneSketchy60.fnt"];
        scoreLabel.position = ccp(boardWidth*0.5f, boardHeight*0.5f);
        scoreLabel.color = ccGRAY;
        scoreLabel.anchorPoint = ccp(0, 0.5);
        
        timeLabel = [CCLabelBMFont labelWithString:@"TIME 00:00" fntFile:@"DenneSketchy60.fnt"];
        timeLabel.anchorPoint = ccp(0, 0.5);
        timeLabel.position = ccp(boardWidth*0.5f, boardHeight*0.35f);
        timeLabel.color = ccGRAY;
        
        [backBoard addChild:levelLabel];
        [backBoard addChild:scoreLabel];
        [backBoard addChild:timeLabel];
        
        //title
        CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"levelup.png"];
        title.position = ccp(boardWidth*0.5f, boardHeight);
        [backBoard addChild:title];
        
        //menu
        __block id copy_self = self;
        OrangeButton *back = [OrangeButton orangeButtonWithString:@"SELECT STAGE" block:^(id sender) {
            [copy_self selectStagePressed];
        }];
        
        OrangeButton *next = [OrangeButton orangeButtonWithString:@"NEXT LEVEL" block:^(id sender) {
            [copy_self nextLevelPressed];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:back,next, nil];
        [menu alignItemsHorizontallyWithPadding:100];
        menu.position = ccp(boardWidth*0.5f, 0);
        
        [backBoard addChild:menu];
        
        remainTime = 0;
        timeReduceRate = 0;
        displayScore = 0;
    }
    return self;
}

- (void) selectStagePressed
{
    [(CardMatching*)self.parent.parent backToMainMenu];
}

- (void) nextLevelPressed
{
    [(CardMatching*)self.parent.parent nextLevel];
}

- (void) preareWithLevelIndex:(NSUInteger)index andScore:(NSUInteger)score andTime:(NSInteger)time
{
    NSString *levelLabelString = [NSString stringWithFormat:@"LEVEL %i -> %i",index,index+1];
    [levelLabel setString:levelLabelString];
    ((CCSprite*)[[levelLabel children] lastObject]).color = ccGREEN;
    
    NSString *scoreLabelString = [NSString stringWithFormat:@"SCORE %i",score];
    [scoreLabel setString:scoreLabelString];
    
    NSString *timelabelString = [NSString stringWithFormat:@"TIME %@",[NSString timeFromSecond:time]];
    [timeLabel setString:timelabelString];
    
    remainTime = time;
    displayScore = score;
}

- (void) hideWithDuration:(ccTime)_duration
{
    if (!isShow) return;
    isShow = NO;
    
    CGPoint moveDown = ccpSub(boardHidePosition, boardShowPosition);
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:_duration position:moveDown];
    CCEaseIn *ease = [CCEaseIn actionWithAction:move rate:1];
    
    [backBoard runAction:ease];
    
    [self unschedule:@selector(timeToScore)];
}

- (void) showWithDuration:(ccTime)_duration
{
    if (isShow) return;
    isShow = YES;
    
    CGPoint moveUp = ccpSub(boardShowPosition, boardHidePosition);
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:_duration position:moveUp];
    CCEaseOut *ease = [CCEaseOut actionWithAction:move rate:1];
    
    [backBoard runAction:ease];
    
    if (remainTime > 0)
    {
        [self unschedule:@selector(timeToScore)];
        [self schedule:@selector(timeToScore) interval:0.1 repeat:UINT_MAX-1 delay:_duration];
    }
    timeReduceRate = MAX(remainTime/20,1);
}

- (void) timeToScore
{
    displayScore += MIN(timeReduceRate,remainTime) * (20);
    NSString *scoreLabelString = [NSString stringWithFormat:@"SCORE %i",displayScore];
    [scoreLabel setString:scoreLabelString];
    
    remainTime = MAX(remainTime - timeReduceRate,0);
    NSString *timelabelString = [NSString stringWithFormat:@"TIME %@",[NSString timeFromSecond:remainTime]];
    [timeLabel setString:timelabelString];
    
    if (remainTime <= 0) [self unschedule:@selector(timeToScore)];
    
}

- (void) dealloc
{
    [super dealloc];
}

@end
