//
//  SideOption.m
//  Phonics Demo
//
//  Created by yiplee on 13-8-20.
//  Copyright 2013年 USTB. All rights reserved.
//

#import "SlidePauseMenuLayer.h"

#import "AppManager.h"

typedef void(^pauseMenuItemBlock)(id sender);

@implementation SlidePauseMenuLayer
{
    CCScene     *_sourceScene;   // weak ref
    
    CCMenu      *_menu;
    
    CCSprite    *_cat;
}

+ (CCScene *) slidePauseMenuWithSourceScene:(CCScene *)s_scene
{
    CCScene *scene = [CCScene node];
    SlidePauseMenuLayer *slidePauseMenu = [[[[self class] alloc] initWithSourceScene:s_scene] autorelease];
    [scene addChild:slidePauseMenu];
    return scene;
}

+ (CCScene *) slidePauseMenu
{
    return [[self class] slidePauseMenuWithSourceScene:nil];
}

- (id) initWithSourceScene:(CCScene *)s_source
{
    self = [super init];
    if (!self) return self;
    
    _sourceScene = s_source;
    if (_sourceScene)
    {
        CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 153)];
        [self addChild:bgLayer z:0];
    }
    
    PIXEL_FORMAT_DEFAULT
    CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:@"setting.plist"];
    
    CCSprite *background;
    background = [CCSprite spriteWithSpriteFrameName:@"setting_bg"];
    [background setHeight:SCREEN_HEIGHT];
    background.anchorPoint = ccp(0, 0.5);
    background.position = CCMP(0, 0.5);
    [self addChild:background z:0];
    
    CCSprite *decorativeUp;
    decorativeUp = [CCSprite spriteWithSpriteFrameName:@"setting_d_up"];
    decorativeUp.anchorPoint = ccp(0, 1);
    decorativeUp.position = CCMP(0, 1);
    [self addChild:decorativeUp z:1];
    
    CCSprite *decorativeDown;
    decorativeDown = [CCSprite spriteWithSpriteFrameName:@"setting_d_down"];
    decorativeDown.anchorPoint = ccp(0, 0);
    decorativeDown.position = CCMP(0, 0);
    [self addChild:decorativeDown z:1];
    
    CCMenu *pauseMenu = [CCMenu node];
    _menu = pauseMenu;
    pauseMenu.position = CGPointZero;
    pauseMenu.touchSwallow = YES;
    [self addChild:pauseMenu z:2];
    
    NSString *const itemImage[] = {
        @"button_rec_continue",
        @"button_rec_restart",
        @"button_rec_menu",
        @"button_help",
    };
    
    NSString *const itemSelectedImage[] = {
        @"button_rec_continue_c",
        @"button_rec_restart_c",
        @"button_rec_menu_c",
        @"button_help_c",
    };
    
    NSString *const itemBackground[] = {
        @"button_rectangle_bg",
        @"button_rectangle_bg",
        @"button_rectangle_bg",
        @"button_wood_bg",
    };
    
    CGPoint const positions[] = {
        ccp(210.0/2/1024,1-370.0/2/768),
        ccp(210.0/2/1024,1-526.0/2/768),
        ccp(210.0/2/1024,1-682.0/2/768),
        ccp(196.0/2/1024,1-1082.0/2/768),
    };
    
    typedef void (^itemBlock)(id sender);
    itemBlock b_continue = ^(id sender){
        [[CCDirector sharedDirector] popScene];
    };
    itemBlock b_restart = nil;
    itemBlock b_menu = nil;
    itemBlock b_help = nil;
    itemBlock blocks[] = {
        b_continue,
        b_restart,
        b_menu,
        b_help,
    };
    
    for (int i=0;i < 4;i++)
    {
        CCSprite *normalSprite;
        normalSprite = [CCSprite spriteWithSpriteFrameName:itemImage[i]];
        CCSprite *selectedSprite;
        selectedSprite = [CCSprite spriteWithSpriteFrameName:itemSelectedImage[i]];
        CCMenuItemSprite *item;
        item = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite];
        [item setBlock:blocks[i]];
        
        item.position = CCMP(positions[i].x,positions[i].y);
        [pauseMenu addChild:item z:0 tag:i];
        
        CCSprite *buttonBg;
        buttonBg = [CCSprite spriteWithSpriteFrameName:itemBackground[i]];
        buttonBg.position = item.position;
        [self addChild:buttonBg z:1];
    }
    
    NSString *musicNomal = @"button_music";
    NSString *musicSelected = @"button_music_c";
    NSString *musicOff = @"button_music_off";
    NSString *musicBackground = @"button_wood_bg";
    CGPoint buttonPosition = ccp(196.0/2/1024,1-932.0/2/768);
    
    CCSprite *buttonNormal;
    buttonNormal = [CCSprite spriteWithSpriteFrameName:musicNomal];
    CCSprite *buttonSelected;
    buttonSelected = [CCSprite spriteWithSpriteFrameName:musicSelected];
    
    CCMenuItemSprite *music_on;
    music_on = [CCMenuItemSprite itemWithNormalSprite:buttonNormal selectedSprite:buttonSelected];
    
    CCSprite *buttonOff;
    buttonOff = [CCSprite spriteWithSpriteFrameName:musicOff];
    
    CCMenuItemSprite *music_off;
    music_off = [CCMenuItemSprite itemWithNormalSprite:buttonOff selectedSprite:nil];
    
    CCMenuItemToggle *music;
    music = [CCMenuItemToggle itemWithItems:@[music_on,music_off] block:^(id sender) {
        NSUInteger index = ((CCMenuItemToggle*)sender).selectedIndex;
        if (index == 0)
        {
            SLLog(@"music on");
        }
        else
        {
            SLLog(@"music off");
        }
    }];
    
    music.position = CCMP(buttonPosition.x, buttonPosition.y);
    [pauseMenu addChild:music z:2 tag:4];
    
    CCSprite *musicBg;
    musicBg = [CCSprite spriteWithSpriteFrameName:musicBackground];
    musicBg.position = music.position;
    [self addChild:musicBg z:1];
    
    [self performSelector:@selector(showCat) withObject:nil afterDelay:CCRANDOM_0_1()*4];
    return self;
}

- (void) draw
{
    [super draw];
    
    if (_sourceScene)
        [_sourceScene visit];
}

- (void) showCat
{
    if (CCRANDOM_0_1() <= 0.6) return;
    if (!_cat)
    {
        _cat = [CCSprite spriteWithSpriteFrameName:@"option_cat_body"];
        CGPoint point = ccp(458/2/1024.0, 1-1259/2/768.0);
        _cat.position = CCMP(point.x, point.y);
    }
    
    if (!_cat.parent)
        [self addChild:_cat z:2];
    
    [_cat performSelector:@selector(removeFromParent) withObject:nil afterDelay:3];
}

- (void) dealloc
{
    [super dealloc];
    SLLog(@"dealloc");
}

// layer logic

- (void) onEnter
{
    [super onEnter];
    [[_menu children] makeObjectsPerformSelector:@selector(setScale:) withObject:[NSNumber numberWithFloat:0.4]];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    for (CCMenuItem *item in [_menu children])
    {
        CCScaleTo *scale = [CCScaleTo actionWithDuration:0.5 scale:1];
        CCEaseBounceInOut *bounch = [CCEaseBounceInOut actionWithAction:scale];
        [item runAction:bounch];
    }
}

// blocks

- (void) setMenuItemWithTag:(NSUInteger)tag block:(void (^)(id sender))block
{
    CCMenuItem *item;
    item = (CCMenuItem*)[_menu getChildByTag:tag];
    [item setBlock:block];
}

- (void) setContinueButtonBlock:(void (^)(id))block
{
    [self setMenuItemWithTag:0 block:block];
}

- (void) setRestartButtonBlock:(void (^)(id))block
{
    [self setMenuItemWithTag:1 block:block];
}

- (void) setMenuButtonBlock:(void (^)(id))block
{
    [self setMenuItemWithTag:2 block:block];
}

- (void) setHelpButtonBlock:(void (^)(id))block
{
    [self setMenuItemWithTag:3 block:block];
}

- (void) setMusicToggleBlock:(void (^)(id))block
{
    [self setMenuItemWithTag:4 block:block];
}

@end
