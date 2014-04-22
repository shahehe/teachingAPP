//
//  CardMatchingGamePrepareLayer.m
//  Letter Games HD
//
//  Created by USTB on 12-12-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchingGamePrepareLayer.h"
#import "CardMatching.h"

@implementation CardMatchingGamePrepareLayer

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    CardMatchingGamePrepareLayer *layer = [CardMatchingGamePrepareLayer node];
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
        
        backBoard = [CCSprite spriteWithSpriteFrameName:@"levelDoneBackground.png"];
        backBoard.position = ccp(winWidth*0.5f, winHeight*0.5f);
        [self addChild:backBoard];
        
        CGSize boardSize = backBoard.contentSize;
        CGFloat boardWidth = boardSize.width;
        CGFloat boardHeight = boardSize.height;
        
        //cat
        CCSprite *cat = [CCSprite spriteWithSpriteFrameName:@"catSmile.png"];
        cat.position = ccp(boardWidth*0.3f, boardHeight*0.5f);
        [backBoard addChild:cat];
        
        //title
        CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"title.png"];
        title.position = ccp(boardWidth*0.5f, boardHeight);
        [backBoard addChild:title];
        
        //menu
        CCSprite *playButton = [CCSprite spriteWithSpriteFrameName:@"button.png"];
        CCSprite *playButtonPressed = [CCSprite spriteWithSpriteFrameName:@"buttonPressed.png"];
        CCSprite *playlabel1 = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        CCSprite *playLabel2 = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        CGPoint playButtonCenter = ccp(playButton.contentSize.width*0.5f, playButton.contentSize.height*0.5f);
        CGPoint playButtonPressedCenter = ccp(playButtonPressed.contentSize.width*0.5f,playButtonPressed.contentSize.height*0.5f);
        playlabel1.position = playButtonCenter;
        [playButton addChild:playlabel1];
        playLabel2.position = playButtonPressedCenter;
        [playButtonPressed addChild:playLabel2];
        
        CCSprite *mainMenuButton = [CCSprite spriteWithSpriteFrameName:@"button.png"];
        CCSprite *mainMenuButtonPressed = [CCSprite spriteWithSpriteFrameName:@"buttonPressed.png"];
        CCSprite *mainMenuLabel1 = [CCSprite spriteWithSpriteFrameName:@"mainMenu.png"];
        CCSprite *mainMenuLabel2 = [CCSprite spriteWithSpriteFrameName:@"mainMenu.png"];
        mainMenuLabel1.position = playButtonCenter;
        [mainMenuButton addChild:mainMenuLabel1];
        mainMenuLabel2.position = playButtonPressedCenter;
        [mainMenuButtonPressed addChild:mainMenuLabel2];
        
        CCMenuItemSprite *play = [CCMenuItemSprite itemWithNormalSprite:playButton
                                                         selectedSprite:playButtonPressed
                                                         disabledSprite:nil
                                                                 target:self
                                                               selector:@selector(playButtonTouched)];
        
        CCMenuItemSprite *mainMenu = [CCMenuItemSprite itemWithNormalSprite:mainMenuButton
                                                             selectedSprite:mainMenuButtonPressed
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(mainMenuButtonTouched)];
        
        CCMenu *menu = [CCMenu menuWithItems:mainMenu,play,nil];
        menu.position = ccp(boardWidth*0.7f, boardHeight*0.5f);
        [menu alignItemsVerticallyWithPadding:40];
        [backBoard addChild:menu];
    }
    return self;
}

- (void) playButtonTouched
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
}

- (void) mainMenuButtonTouched
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
    [(CardMatching*)self.parent.parent backToMainMenu];
}

- (void) onEnter
{
    [super onEnter];
}

- (void) showWithDuration:(ccTime)_duration
{
    // do nothing
}

- (void) hideWithDuration:(ccTime)_duration
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCMoveBy *move = [CCMoveBy actionWithDuration:_duration position:ccp(0, -size.height)];
    CCEaseIn *ease = [CCEaseIn actionWithAction:move rate:1];
    [backBoard runAction:ease];
}


- (void) dealloc
{
    [super dealloc];
}

@end
