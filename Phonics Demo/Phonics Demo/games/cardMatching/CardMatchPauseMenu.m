//
//  PauseMenu.m
//  phonics matching cards HD
//
//  Created by USTB on 12-12-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchPauseMenu.h"
#import "CardMatching.h"
#import "Button.h"

@implementation CardMatchPauseMenu

+ (CCScene*) sceneWithScene:(CCScene *)_scene
{
    return [[[self alloc] initWithScene:_scene]autorelease];
}

- (id) initWithScene:(CCScene *)_scene
{
    if (self = [super init])
    {
        sourceScene = _scene;
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGPoint topRight = ccpFromSize(size);
        
        if (sourceScene)
        {
            CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(0,0,0,125)];
            [self addChild:background];
        }
        
        CCSprite *board = [CCSprite spriteWithSpriteFrameName:@"pauseLayerBoard.png"];
        board.position = ccpMult(topRight, 0.5);
        [self addChild:board];
        
        CGPoint boardTopRight = ccpFromSize(board.contentSize);
        
        //title
        CCSprite *pauseTitle = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
        pauseTitle.position = ccpCompMult(boardTopRight, ccp(0.5,1));
        [board addChild:pauseTitle];
        /*
        OrangeButton *musicOn = [OrangeButton orangeButtonWithString:@"PRONOUCE      " block:^(id sender) {
            //do nothing
        }];
        CCSprite *musicIcon = [CCSprite spriteWithSpriteFrameName:@"sound.png"];
        musicIcon.position = ccpCompMult(ccpFromSize(musicOn.contentSize), ccp(0.8,0.5));
        [musicOn addChild:musicIcon];
        
        OrangeButton *musicOff = [OrangeButton orangeButtonWithString:@"PRONOUCE      " block:^(id sender) {
            //do nothing
        }];
        CCSprite *musicOffIcon1 = [CCSprite spriteWithSpriteFrameName:@"sound.png"];
        CCSprite *musicOffIcon2 = [CCSprite spriteWithSpriteFrameName:@"turn_off.png"];
        musicOffIcon1.position = ccpCompMult(ccpFromSize(musicOff.contentSize), ccp(0.8,0.5));
        musicOffIcon2.position = ccpCompMult(ccpFromSize(musicOff.contentSize), ccp(0.8,0.5));
        [musicOff addChild:musicOffIcon1];
        [musicOff addChild:musicOffIcon2];
        
        CCMenuItemToggle *music = [CCMenuItemToggle itemWithItems:[NSArray arrayWithObjects:musicOn,musicOff, nil] block:^(id sender) {
            [[GameManager sharedGameManager] SE_button_click];
            
            if (((CCMenuItemToggle*)sender).selectedIndex == 1)
                [[GameManager sharedGameManager] turnMusicOff];
            else [[GameManager sharedGameManager] turnMusicOn];
        }];
        
        if (![GameManager sharedGameManager].isMusicOn)
            music.selectedIndex = 1;
        
        music.position = ccpCompMult(boardTopRight, ccp(0.3,0.8));
        */
        OrangeButton *soundOn = [OrangeButton orangeButtonWithString:@"SOUND   " block:^(id sender) {
            //do nothing
        }];
        CCSprite *soundIcon = [CCSprite spriteWithSpriteFrameName:@"sound.png"];
        soundIcon.position = ccpCompMult(ccpFromSize(soundOn.contentSize), ccp(0.8,0.5));
        [soundOn addChild:soundIcon];
        
        OrangeButton *soundOff = [OrangeButton orangeButtonWithString:@"SOUND   " block:^(id sender) {
            //do nothing
        }];
        CCSprite *soundOffIcon1 = [CCSprite spriteWithSpriteFrameName:@"sound.png"];
        CCSprite *soundOffIcon2 = [CCSprite spriteWithSpriteFrameName:@"turn_off.png"];
        soundOffIcon1.position = ccpCompMult(ccpFromSize(soundOff.contentSize), ccp(0.8,0.5));
        soundOffIcon2.position = ccpCompMult(ccpFromSize(soundOff.contentSize), ccp(0.8,0.5));
        [soundOff addChild:soundOffIcon1];
        [soundOff addChild:soundOffIcon2];
        
        OrangeButton *restart = [OrangeButton orangeButtonWithString:@"RESTART" block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
            [(CardMatching*)sourceScene playAgain];
        }];
        restart.position = ccpCompMult(boardTopRight, ccp(0.3,0.35));
        
        OrangeButton *resume = [OrangeButton orangeButtonWithString:@"RESUME" block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
        }];
        resume.position = ccpCompMult(boardTopRight, ccp(0.7,0.65));
        
        OrangeButton *quit = [OrangeButton orangeButtonWithString:@"QUIT" block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
            //[[CCDirector sharedDirector] replaceScene:[TransitionPage sceneWithTargetScene:TargetSceneStageSelect]];
            [(CardMatching*)sourceScene backToMainMenu];
        }];
        quit.position = ccpCompMult(boardTopRight, ccp(0.7,0.35));
        
        CCMenu *pauseMenu = [CCMenu menuWithItems:restart,resume,quit, nil];
        pauseMenu.position = ccp(0, 0);
        //[pauseMenu alignItemsVerticallyWithPadding:10];
        [board addChild:pauseMenu];
        
    }
    return self;
}

- (void) draw
{
    if(sourceScene) [sourceScene visit];
    [super draw];
}

- (void) dealloc
{
    [super dealloc];
}

@end
