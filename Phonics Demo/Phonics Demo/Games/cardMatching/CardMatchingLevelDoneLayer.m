//
//  CardMatchingLevelDoneLayer.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchingLevelDoneLayer.h"
#import "CardMatching.h"
#import "SimpleAudioEngine.h"

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
        CCSprite *nextLevelButton = [CCSprite spriteWithSpriteFrameName:@"button.png"];
        CCSprite *nextLevelButtonPressed = [CCSprite spriteWithSpriteFrameName:@"buttonPressed.png"];
        CCSprite *nextLevellabel1 = [CCSprite spriteWithSpriteFrameName:@"nextLevel.png"];
        CCSprite *nextLevelLabel2 = [CCSprite spriteWithSpriteFrameName:@"nextLevel.png"];
        CGPoint nextLevelButtonCenter = ccp(nextLevelButton.contentSize.width*0.5f, nextLevelButton.contentSize.height*0.5f);
        CGPoint nextLevelButtonPressedCenter = ccp(nextLevelButtonPressed.contentSize.width*0.5f,nextLevelButtonPressed.contentSize.height*0.5f);
        nextLevellabel1.position = nextLevelButtonCenter;
        [nextLevelButton addChild:nextLevellabel1];
        nextLevelLabel2.position = nextLevelButtonPressedCenter;
        [nextLevelButtonPressed addChild:nextLevelLabel2];
        
        CCSprite *mainMenuButton = [CCSprite spriteWithSpriteFrameName:@"button.png"];
        CCSprite *mainMenuButtonPressed = [CCSprite spriteWithSpriteFrameName:@"buttonPressed.png"];
        CCSprite *mainMenuLabel1 = [CCSprite spriteWithSpriteFrameName:@"mainMenu.png"];
        CCSprite *mainMenuLabel2 = [CCSprite spriteWithSpriteFrameName:@"mainMenu.png"];
        mainMenuLabel1.position = nextLevelButtonCenter;
        [mainMenuButton addChild:mainMenuLabel1];
        mainMenuLabel2.position = nextLevelButtonPressedCenter;
        [mainMenuButtonPressed addChild:mainMenuLabel2];
        
        CCMenuItemSprite *nextLevel = [CCMenuItemSprite itemWithNormalSprite:nextLevelButton
                                                              selectedSprite:nextLevelButtonPressed
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(nextLevelButtonPressed)];
        CCMenuItemSprite *mainMenu = [CCMenuItemSprite itemWithNormalSprite:mainMenuButton
                                                             selectedSprite:mainMenuButtonPressed
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(mainMenuButtonPressed)];
        CCMenu *menu = [CCMenu menuWithItems:mainMenu,nextLevel, nil];
        [menu alignItemsHorizontallyWithPadding:60];
        menu.position = ccp(boardWidth*0.5f, 0);
        
        [backBoard addChild:menu];
        
        remainTime = 0;
        timeReduceRate = 0;
        displayScore = 0;
    }
    return self;
}

- (void) nextLevelButtonPressed
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
    
    [(CardMatching*)self.parent.parent nextLevel];
}

- (void) mainMenuButtonPressed
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
    
    [(CardMatching*)self.parent.parent backToMainMenu];
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
    displayScore += MIN(timeReduceRate,remainTime) * 10;
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
