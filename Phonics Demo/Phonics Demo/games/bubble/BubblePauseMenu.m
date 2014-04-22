//
//  PauseMenu.m
//  bubble
//
//  Created by yiplee on 13-4-16.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "BubblePauseMenu.h"

#import "BubbleGameLayer.h"

@interface BubblePauseMenu ()
{
    CCScene *_sourceScene;
}

@end

@implementation BubblePauseMenu

+ (CCScene*) sceneWithScene:(CCScene *)sourceScene
{
    return [[[self alloc] initWithScene:sourceScene] autorelease];
}

- (id) initWithScene:(CCScene *)sourceScene
{
    if (self = [super init])
    {
        _sourceScene = sourceScene;

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_texture.plist"];
        
        if (_sourceScene)
        {
            CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 153)];
            [self addChild:bgLayer];
        }
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGPoint size_p = ccpFromSize(size);
        
        CCSprite *menu_bg = [CCSprite spriteWithFile:@"pause_menu_bg.png"];
        menu_bg.position = ccpCompMult(size_p, ccp(0.523,0.5));
        [self addChild:menu_bg];
            
        CCSprite *stage_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_stage.png"];
        CCSprite *stage_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_stage_pressed.png"];
        CCMenuItemSprite *stage_button = [CCMenuItemSprite itemWithNormalSprite:stage_button_normal selectedSprite:stage_button_select block:^(id sender) {

            [[CCDirector sharedDirector] popScene];
            
            [(BubbleGameLayer*)_sourceScene backToMenu];
            
            
            [BubbleGameLayer cleanCaches];
        }];
            
        stage_button.position = ccpCompMult(size_p, ccp(0.5,0.344));
            
        CCSprite *replay_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_replay.png"];
        CCSprite *replay_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_replay_pressed.png"];
        CCMenuItemSprite *replay_button = [CCMenuItemSprite itemWithNormalSprite:replay_button_normal selectedSprite:replay_button_select  block:^(id sender) {
            CCLOG(@"replay");
            [[CCDirector sharedDirector] popScene];
            
        }];
        replay_button.position = ccpCompMult(size_p, ccp(0.5,0.43));

        CCSprite *resume_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_resume.png"];
        CCSprite *resume_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_resume_pressed.png"];
        CCMenuItemSprite *resume_button = [CCMenuItemSprite itemWithNormalSprite:resume_button_normal selectedSprite:resume_button_select block:^(id sender){
            CCLOG(@"resume");
            [[CCDirector sharedDirector] popScene];
        }];
        resume_button.position = ccpCompMult(size_p, ccp(0.5,0.515));
            
        CCSprite *music_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_music_on.png"];
        CCMenuItemSprite *music_normal = [CCMenuItemSprite itemWithNormalSprite:music_button_normal selectedSprite:nil];
        CCSprite *music_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_music_off.png"];
        CCMenuItemSprite *music_select = [CCMenuItemSprite itemWithNormalSprite:music_button_select selectedSprite:nil];
        CCMenuItemToggle *musicButton = [CCMenuItemToggle itemWithItems:[NSArray arrayWithObjects:music_normal,music_select, nil] block:^(id sender) {
            
        }];
        musicButton.position = ccpCompMult(size_p, ccp(0.441,0.6));
        bool _music = YES;
        if (!_music) musicButton.selectedIndex = 1;
        
        CCSprite *sound_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_sound_on.png"];
        CCMenuItemSprite *sound_normal = [CCMenuItemSprite itemWithNormalSprite:sound_button_normal selectedSprite:nil];
        CCSprite *sound_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_sound_off.png"];
        CCMenuItemSprite *sound_select = [CCMenuItemSprite itemWithNormalSprite:sound_button_select selectedSprite:nil];
        CCMenuItemToggle *soundButton = [CCMenuItemToggle itemWithItems:[NSArray arrayWithObjects:sound_normal,sound_select, nil] block:^(id sender) {
            
        }];
        soundButton.position = ccpCompMult(size_p, ccp(0.545,0.6));
        bool _sound = YES;
        if (!_sound) soundButton.selectedIndex = 1;
        
        CCMenu *menu = [CCMenu menuWithItems:stage_button,resume_button,replay_button,musicButton,soundButton, nil];
        menu.position = CGPointZero;
            
        [self addChild:menu];
            
        [self setTouchEnabled:YES];
    }
    return self;
}

- (void) draw
{
    [super draw];
    
    if (_sourceScene)
        [_sourceScene visit];
}

- (void) dealloc
{
    CCLOG(@"pause menu:dealloc");
    [super dealloc];
}

@end
