//
//  Dialog.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-26.
//  Copyright 2013年 USTB. All rights reserved.
//

#import "Dialog.h"
#import "ToolbarLayer.h"

#import "DialogContentLayer.h"

//#import "MainMenu.h"

#import "SlidePauseMenuLayer.h"

#import "YRecorder.h"

typedef void(^MenuItemBlock)(id sender);

typedef NS_ENUM(NSInteger, DialogLayerType)
{
    DialogContentLayerTag = 0,
    DialogToolbarLayerTag,
};

static NSString * const dialogContentNames[] = {
    @"LetterIdentification",
    @"DialogSound",
    @"Puzzle",
    @"Poem",
    
};

static NSString *dialogContentNameFormat = @"%@_%c";

@implementation Dialog

@synthesize contentlayer = _contentlayer;
@synthesize toolbarLayer = _toolbarLayer;

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    [scene addChild:[[self class] node]];
    return scene;
}

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    _contentlayer = nil;
    _toolbarLayer = nil;
    
    return self;
}

+ (CCScene *)dialogWithContentLayer:(DialogContentLayer *)contentLayer
{
    CCScene *scene = [CCScene node];
    Dialog *dialog = [[[Dialog alloc] initWithContentLayer:contentLayer] autorelease];
    [scene addChild:dialog];
    return scene;
}

+ (CCScene *)dialogWithContentLayerType:(DialogContentType)contentType letter:(char)letter
{

    NSString *contentName = dialogContentNames[contentType];
    if ( [contentName isEqualToString:@"LetterIdentification"])
    {
        contentName = [contentName stringByAppendingString:[NSString stringWithFormat:@"%c", letter]];
    }
    
    NSString *optionFileName = [[NSBundle mainBundle] pathForResource:contentName ofType:@"plist"];
    NSDictionary *option = [NSDictionary dictionaryWithContentsOfFile:optionFileName];
    Class content = NSClassFromString(contentName);
    id contentLayer = [[[content alloc] initWithInitOptions:option] autorelease];
    
    NSAssert([contentLayer isKindOfClass:[DialogContentLayer class]],
             @"dialog can only contain DialogContentLayer");
    return [self dialogWithContentLayer:(DialogContentLayer*)contentLayer];
}

- (id) initWithContentLayer:(DialogContentLayer *)contentLayer
{
    if (self = [self init])
    {
        PIXEL_FORMAT_DEFAULT
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"toolbar.plist"];
        
        RGBA4444
        [frameCache addSpriteFramesWithFile:@"toolbar-buttons-record.plist"];
        PIXEL_FORMAT_DEFAULT
        
        [self addChild:self.toolbarLayer z:DialogToolbarLayerTag];
        self.toolbarLayer.touchPriority = -1;
        _contentlayer = contentLayer;
        _contentlayer.touchPriority = 0;
        [self addChild:self.contentlayer z:DialogContentLayerTag];
    }
    return self;
}

- (ToolbarLayer *)toolbarLayer
{
    if (_toolbarLayer == nil)
    {
        _toolbarLayer = [ToolbarLayer node];
        
        _toolbarLayer.backgroundColor = ccc4f(0, 1, 1, 0);
        _toolbarLayer.autoHide = NO;
        _toolbarLayer.backgroundSpriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"toolbar_bg"];
        
        CCArray *buttons = [CCArray arrayWithCapacity:6];
        NSString *const buttonBackground[] = {
            @"button_wood_bg",
            @"button_wood_bg",
            @"button_wood_bg",
            @"button_wood_bg",
            @"button_wood_bg",
            @"button_option_bg",
            @"button_wood_bg",
            @"button_wood_bg",
            @"button_wood_bg",
        };
        
        NSString *const buttonNormal[] = {
            @"button_pause",
            @"button_continue",
            @"button_forward",
            @"button_next",
            @"button_repeat",
            @"button_option",
            @"button_audio_play",
            @"button_record",
            @"button_record_stop",
        };
        
        NSString *const buttonSelected[] = {
            @"button_pause_c",
            @"button_continue_c",
            @"button_forward_c",
            @"button_next_c",
            @"button_repeat_c",
            @"button_option_c",
            @"button_audio_play_c",
            @"button_record_c",
            @"button_record_stop_c"
        };
        
        for (int i=0;i < 9;i++)
        {
            CCSprite *bg1,*bg2,*normal,*selected;
            bg1 = [CCSprite spriteWithSpriteFrameName:buttonBackground[i]];
            bg2 = [CCSprite spriteWithSpriteFrameName:buttonBackground[i]];
            normal = [CCSprite spriteWithSpriteFrameName:buttonNormal[i]];
            selected = [CCSprite spriteWithSpriteFrameName:buttonSelected[i]];
            
            [bg1 addChild:normal];
            [normal setBoundingBoxCenterOfParent];
            [bg2 addChild:selected];
            [selected setBoundingBoxCenterOfParent];
            
            CCMenuItemSprite *item;
            item = [CCMenuItemSprite itemWithNormalSprite:bg1 selectedSprite:bg2];
            [buttons addObject:item];
        }
        
        
        CCMenuItemToggle *control;
        control = [CCMenuItemToggle itemWithItems:@[[buttons objectAtIndex:0],[buttons objectAtIndex:1]]];
        [control setBlock:^(id sender) {
            NSUInteger index = ((CCMenuItemToggle*)sender).selectedIndex;
            if (index == 1)
            {
                [_contentlayer dialogPause];
            }
            else [_contentlayer dialogResume];
        }];
        
        CCMenuItem *left;
        left = [buttons objectAtIndex:2];
        
        CCMenuItem *right;
        right = [buttons objectAtIndex:3];
        
        [left setBlock:^(id sender) {
            [_contentlayer dialogPlayPreviousScene];
        }];
        
        [right setBlock:^(id sender) {
            [_contentlayer dialogPlayNextScene];
        }];
        
        CCMenuItem *replay;
        replay = [buttons objectAtIndex:4];
        [replay setBlock:^(id sender) {
            [_contentlayer dialogReplayCurrentScene];
        }];
        
        CCMenuItemSprite *audioPlay = [buttons objectAtIndex:6];
        CCSprite *audioPlayDisable = [CCSprite spriteWithSpriteFrameName:@"button_audio_play"];
        audioPlayDisable.opacity = 255*0.6;
        CCSprite *audioPlayBg = [CCSprite spriteWithSpriteFrameName:@"button_wood_bg"];
        [audioPlayBg addChild:audioPlayDisable];
        [audioPlayDisable setBoundingBoxCenterOfParent];
        [audioPlay setDisabledImage:audioPlayBg];
        
        [audioPlay setBlock:^(id sender) {
            [[YRecorder sharedEngine] play];
        }];
        [audioPlay setIsEnabled:NO];
        
        CCMenuItemToggle *recordControl;
        recordControl = [CCMenuItemToggle itemWithItems:@[[buttons objectAtIndex:7],[buttons objectAtIndex:8]]];
        [recordControl setBlock:^(id sender) {
            NSUInteger index = ((CCMenuItemToggle*)sender).selectedIndex;
            if (index == 1)
            {
                [[YRecorder sharedEngine] record];
                audioPlay.isEnabled = NO;
            }
            else
            {
                [[YRecorder sharedEngine] stop];
                audioPlay.isEnabled = YES;
            }
        }];
        
        _toolbarLayer.leftItems = @[control,replay,left];
        _toolbarLayer.rightItems = @[right,recordControl,audioPlay];
        
        CCMenuItem *pause = [buttons objectAtIndex:5];
        pause.anchorPoint = ccp(0.1, 0.5);
        pause.position = CCMP(0, 0.5);
        
        __block id self_copy = self;
        [pause setBlock:^(id sender) {
            [_contentlayer dialogPause];
            
            SlidePauseMenuLayer *pauseMenu;
            pauseMenu = [[SlidePauseMenuLayer alloc] initWithSourceScene:(CCScene*)self];
            [pauseMenu setContinueButtonBlock:^(id sender) {
                [[CCDirector sharedDirector] popScene];
                [_contentlayer performSelector:@selector(dialogResume) withObject:nil afterDelay:0.1];
            }];
            [pauseMenu setRestartButtonBlock:^(id sender) {
                [[CCDirector sharedDirector] popScene];
                [self_copy performSelector:@selector(restart) withObject:nil afterDelay:0.1];
            }];
            [pauseMenu setMenuButtonBlock:^(id sender) {
                [[CCDirector sharedDirector] popScene];
                [self_copy performSelector:@selector(backToMainMenu) withObject:nil afterDelay:0.1];
            }];
            [pauseMenu setMusicToggleBlock:^(id sender) {
                NSUInteger index = ((CCMenuItemToggle*)sender).selectedIndex;
                if (index == 0)
                {
                    SLLog(@"audio on");
                }
                else
                {
                    SLLog(@"audio off");
                }
            }];
            [pauseMenu setHelpButtonBlock:^(id sender) {
                SLLog(@"help");
            }];
            
            CCScene *scene = [CCScene node];
            [scene addChild:pauseMenu];
            [[CCDirector sharedDirector] pushScene:scene];
        }];
        [_toolbarLayer addAdditionalMenuItem:pause];
    }
    return _toolbarLayer;
}

- (void) backToMainMenu
{
    [_contentlayer dialogStop];
    [[CCDirector sharedDirector] popScene];
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenu scene]]];
}

- (void) restart
{
    [_contentlayer playSceneWithIndex:0];
}

- (void) dealloc
{
//    [_contentlayer release];
//    [_toolbarLayer release];
    
    [super dealloc];
    
}

@end
