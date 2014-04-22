//
//  GameOverLayer.m
//  bubble
//
//  Created by yiplee on 13-5-8.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "BubbleGameOverLayer.h"
#import "BubbleGameLayer.h"

@implementation BubbleGameOverLayer
{
    CCScene *backScene;
}

+ (CCScene *) sceneWithBackScene:(CCScene *)_scene
{
    CCScene *scene = [CCScene node];
    BubbleGameOverLayer *layer = [[[BubbleGameOverLayer alloc] initWithBackScene:_scene] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithBackScene:(CCScene*)scene
{
    if (self = [super init])
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_texture.plist"];
        
        backScene = scene;
        
        if (backScene)
        {
            CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 153)];
            [self addChild:bgLayer];
        }
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint size = ccpFromSize(screenSize);
        
        CCSprite *backBoard = [CCSprite spriteWithFile:@"failed_bg.png"];
        backBoard.position = ccpMult(size, 0.5);
        [self addChild:backBoard];
        
        CGPoint boardSize = ccpFromSize(backBoard.boundingBox.size);
        
        // title
        CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"failed_title.png"];
        title.position = ccpCompMult(boardSize, ccp(0.45, 0.780));
        [backBoard addChild:title];
        
        // buttons
        CCSprite *stage_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_stage.png"];
        CCSprite *stage_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_stage_pressed.png"];
        CCMenuItemSprite *stage_button = [CCMenuItemSprite itemWithNormalSprite:stage_button_normal selectedSprite:stage_button_select block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
            [(BubbleGameLayer*)backScene backToMenu];
            
            [BubbleGameLayer cleanCaches];
        }];
        stage_button.position = ccpCompMult(boardSize, ccp(0.465,0.2665));
        
        CCSprite *replay_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_replay.png"];
        CCSprite *replay_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_replay_pressed.png"];
        CCMenuItemSprite *replay_button = [CCMenuItemSprite itemWithNormalSprite:replay_button_normal selectedSprite:replay_button_select  block:^(id sender) {
            CCLOG(@"replay");
            [[CCDirector sharedDirector] popScene];
            
        }];
        replay_button.position = ccpCompMult(boardSize, ccp(0.690,0.2665));
        
        CCMenu *menu = [CCMenu menuWithItems:stage_button,replay_button, nil];
        menu.position = CGPointZero;
        
        [backBoard addChild:menu];
        
        //cat & fan
        CCSprite *fan = [CCSprite spriteWithSpriteFrameName:@"failed_fan.png"];
        fan.position = ccpCompMult(boardSize, ccp(0.60, 0.50));
        [backBoard addChild:fan];
        
        CCSprite *cat = [CCSprite spriteWithSpriteFrameName:@"failed_cat.png"];
        cat.position = ccpCompMult(boardSize, ccp(0.65, 0.545));
        [backBoard addChild:cat];
    }
    return self;
}

- (void) draw
{
    [super draw];
    
    if (backScene) [backScene visit];
}

@end
