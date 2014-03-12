//
//  CardMatchingGameOverLayer.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchingGameOverLayer.h"
#import "CardMatching.h"
#import "SimpleAudioEngine.h"

@implementation CardMatchingGameOverLayer

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    CardMatchingGameOverLayer *layer = [CardMatchingGameOverLayer node];
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
        
        boardShowPoint = ccp(winWidth*0.5f, winHeight*0.6f);
        boardHidePoint = ccp(winWidth*0.5f, winHeight*1.3f);
        backBoard = [CCSprite spriteWithSpriteFrameName:@"gameDoneBackground.png"];
        backBoard.position = boardHidePoint;
        [self addChild:backBoard];
        
        CGSize boardSize = backBoard.contentSize;
        CGFloat boardWidth = boardSize.width;
        CGFloat boardHeight = boardSize.height;
        
        //cat
        CCSprite *cat = [CCSprite spriteWithSpriteFrameName:@"catSad.png"];
        cat.position = ccp(boardWidth*0.2f, boardHeight*0.5f);
        [backBoard addChild:cat];
        
        //title
        CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"gameOver.png"];
        title.position = ccp(boardWidth*0.6f, boardHeight*0.7f);
        [backBoard addChild:title];
        
        // score
        scoreLabel = [CCLabelBMFont labelWithString:@"SCORE 0" fntFile:@"DenneSketchy60.fnt"];
        scoreLabel.color = ccGRAY;
        scoreLabel.position = ccp(boardWidth*0.6f, boardHeight*0.4f);
        [backBoard addChild:scoreLabel];
        
        //menu
        CCSprite *playAgainButton = [CCSprite spriteWithSpriteFrameName:@"button.png"];
        CCSprite *playAgainButtonPressed = [CCSprite spriteWithSpriteFrameName:@"buttonPressed.png"];
        CCSprite *playAgainlabel1 = [CCSprite spriteWithSpriteFrameName:@"playAgain.png"];
        CCSprite *playAgainLabel2 = [CCSprite spriteWithSpriteFrameName:@"playAgain.png"];
        CGPoint playAgainButtonCenter = ccp(playAgainButton.contentSize.width*0.5f, playAgainButton.contentSize.height*0.5f);
        CGPoint playAgainButtonPressedCenter = ccp(playAgainButtonPressed.contentSize.width*0.5f,playAgainButtonPressed.contentSize.height*0.5f);
        playAgainlabel1.position = playAgainButtonCenter;
        [playAgainButton addChild:playAgainlabel1];
        playAgainLabel2.position = playAgainButtonPressedCenter;
        [playAgainButtonPressed addChild:playAgainLabel2];
        
        CCSprite *mainMenuButton = [CCSprite spriteWithSpriteFrameName:@"button.png"];
        CCSprite *mainMenuButtonPressed = [CCSprite spriteWithSpriteFrameName:@"buttonPressed.png"];
        CCSprite *mainMenuLabel1 = [CCSprite spriteWithSpriteFrameName:@"mainMenu.png"];
        CCSprite *mainMenuLabel2 = [CCSprite spriteWithSpriteFrameName:@"mainMenu.png"];
        mainMenuLabel1.position = playAgainButtonCenter;
        [mainMenuButton addChild:mainMenuLabel1];
        mainMenuLabel2.position = playAgainButtonPressedCenter;
        [mainMenuButtonPressed addChild:mainMenuLabel2];
        
        CCMenuItemSprite *playAgain = [CCMenuItemSprite itemWithNormalSprite:playAgainButton
                                                              selectedSprite:playAgainButtonPressed disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(playAgainButtonPressed)];
        CCMenuItemSprite *mainMenu = [CCMenuItemSprite itemWithNormalSprite:mainMenuButton
                                                             selectedSprite:mainMenuButtonPressed
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(mainMenuButtonPressed)];
        menu = [CCMenu menuWithItems:playAgain,mainMenu, nil];
        [menu alignItemsHorizontallyWithPadding:100];
        
        menuShowPoint = ccp(winWidth*0.5f, winHeight*0.20f);
        menuHidePoint = ccp(winWidth*0.5f, -winHeight*0.20f);
        menu.position = menuHidePoint;
        [self addChild:menu];
    }
    return self;
}

- (void) playAgainButtonPressed
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
    
    CCCallBlock *hide = [CCCallBlock actionWithBlock:^{
        [self hideWithDuration:0.4f];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.45f];
    CCCallBlock *playAgain = [CCCallBlock actionWithBlock:^{
        [(CardMatching*)self.parent.parent playAgain];
    }];
    
    CCSequence *seq = [CCSequence actions:hide,delay,playAgain, nil];
    [self runAction:seq];
}

- (void) mainMenuButtonPressed
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
    
    [(CardMatching*)self.parent.parent backToMainMenu];
}

- (void) prepareWithScore:(NSUInteger)score
{
    NSString *scoreLabelString = [NSString stringWithFormat:@"SCORE %i",score];
    [scoreLabel setString:scoreLabelString];
}

- (void) showWithDuration:(ccTime)_duration
{
    if (isShow) return;
    isShow = YES;
    
    CCMoveTo *boardMove = [CCMoveTo actionWithDuration:_duration position:boardShowPoint];
    CCEaseOut *boardEase = [CCEaseOut actionWithAction:boardMove rate:1];
    [backBoard runAction:boardEase];
    
    CCMoveTo *menuMove = [CCMoveTo actionWithDuration:_duration position:menuShowPoint];
    CCEaseOut *menuEase = [CCEaseOut actionWithAction:menuMove rate:1];
    [menu runAction:menuEase];
}

- (void) hideWithDuration:(ccTime)_duration
{
    if (!isShow) return;
    isShow = NO;
    
    CCMoveTo *boardMove = [CCMoveTo actionWithDuration:_duration position:boardHidePoint];
    CCEaseIn *boardEase = [CCEaseIn actionWithAction:boardMove rate:1];
    [backBoard runAction:boardEase];
    
    CCMoveTo *menuMove = [CCMoveTo actionWithDuration:_duration position:menuHidePoint];
    CCEaseIn *menuEase = [CCEaseIn actionWithAction:menuMove rate:1];
    [menu runAction:menuEase];
}

- (void) dealloc
{
    [super dealloc];
}

@end
