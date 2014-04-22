//
//  PGStageMenu.m
//  Phonics Games
//
//  Created by yiplee on 14-4-6.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "PGStageMenu.h"
#import "PhonicsDefines.h"

#import "PGLetterMenu.h"

@interface CCSprite (stageLetter)

- (void) addLetter:(char)letter;

@end

@implementation CCSprite (stageLetter)

- (void) addLetter:(char)letter
{
    if (letter >= 'A')
    {
        letter = letter - ('A' - 'a');
    }
    
    NSString *frameName = [NSString stringWithFormat:@"button_%c.png",letter];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    CCSprite *s = [CCSprite spriteWithSpriteFrame:frame];
    
    s.position = ccpMult(ccpFromSize(self.boundingBox.size), 0.5);
    s.rotation = self.rotation;
    [self addChild:s];
}

@end

@interface PGStageMenu ()
{
    CCScrollLayer *scrollLayer;
    
    CCMenu *menu;
    CCSprite *title;
}

@end

@implementation PGStageMenu

+ (CCScene *) stageMenu
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [[self class] node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    self = [super init];
    
    [SPRITE_FRAME_CACHE addSpriteFramesWithFile:@"menu_stage.plist"];
    [SPRITE_FRAME_CACHE addSpriteFramesWithFile:@"menu_letter.plist"];
    
    RGB565
    CCSprite *bg = [CCSprite spriteWithFile:@"menu_farm_bg.pvr.ccz"];
    PIXEL_FORMAT_DEFAULT
    
    bg.position = CCMP(0.5, 0.5);
    bg.scaleX = SCREEN_WIDTH / bg.contentSize.width;
    bg.scaleY = SCREEN_HEIGHT/ bg.contentSize.height;
    [self addChild:bg z:0];
    
    title = [CCSprite spriteWithSpriteFrameName:@"menu_title.png"];
    title.position = CCMP(0.5, 0.85);
    [self addChild:title z:2];
    
    [self createScrollLayer];
    [self addChild:scrollLayer z:1];
    
    return self;
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
}

- (void) createScrollLayer
{
    NSMutableArray *items = [NSMutableArray array];
    char letter = 'A';
    NSUInteger line = 5;
    
    CGPoint start = ccp(0.15, 0.75);
    CGPoint direction = ccp(0.17, -0.25);
    
    CCLayer *layer_1 = [CCLayer node];
    {
        CCSprite *panel = [CCSprite spriteWithSpriteFrameName:@"menu_panel.png"];
        CGPoint size_p = ccpFromSize(panel.boundingBox.size);
        panel.position = CCMP(0.5, 0.45);
        panel.zOrder = 0;
        [layer_1 addChild:panel];
        
        
        for (int i = 0;i < 15 && letter <= 'Z';i++)
        {
            CCMenuItem *item = [self stageButtonWithLetter:letter];
            
            NSInteger x,y;
            x = i % line;
            y = i / line;
            CGPoint pos = ccpAdd(start, ccpCompMult(direction, ccp(x, y)));
            item.position = ccpCompMult(size_p, pos);
            [items addObject:item];
            
            item.isEnabled = YES;
            
            letter++;
        }
        
        CCMenu *_menu = [CCMenu menuWithArray:items];
        _menu.position = CGPointZero;
        [panel addChild:_menu];
    }
    
    [items removeAllObjects];
    
    CCLayer *layer_2 = [CCLayer node];
    {
        CCSprite *panel = [CCSprite spriteWithSpriteFrameName:@"menu_panel.png"];
        CGPoint size_p = ccpFromSize(panel.boundingBox.size);
        panel.position = CCMP(0.5, 0.45);
        panel.zOrder = 0;
        [layer_2 addChild:panel];
        
        
        for (int i = 0;i < 15 && letter <= 'Z';i++)
        {
            CCMenuItem *item = [self stageButtonWithLetter:letter];
            
            NSInteger x,y;
            x = i % line;
            y = i / line;
            CGPoint pos = ccpAdd(start, ccpCompMult(direction, ccp(x, y)));
            item.position = ccpCompMult(size_p, pos);
            [items addObject:item];
            
            item.isEnabled = YES;
         
            
            letter++;
        }
        
        CCMenu *_menu = [CCMenu menuWithArray:items];
        _menu.position = CGPointZero;
        [panel addChild:_menu];
    }
    
    NSArray *layers = @[layer_1,layer_2];
    
    scrollLayer = [CCScrollLayer nodeWithLayers:layers widthOffset:0];
    scrollLayer.showPagesIndicator = YES;
    scrollLayer.pagesIndicatorPosition = CCMP(0.5, 0.11);
    scrollLayer.pagesIndicatorSelectedColor = ccc4(33, 219, 148, 255);
    scrollLayer.pagesIndicatorNormalColor = ccc4(25, 25, 25, 225);
    [scrollLayer selectPage:0];
}

- (CCMenuItemSprite*) stageButtonWithLetter:(char)letter
{
    CCSprite *normal = [CCSprite spriteWithSpriteFrameName:@"menu_button_normal.png"];
    [normal addLetter:letter];
    
    CCSprite *pressed = [CCSprite spriteWithSpriteFrameName:@"menu_button_pressed.png"];
    [pressed addLetter:letter];
    
    CCSprite *locked = [CCSprite spriteWithSpriteFrameName:@"menu_button_lock.png"];
    
    CCMenuItemSprite *item = [CCMenuItemSprite itemWithNormalSprite:normal selectedSprite:pressed disabledSprite:locked block:^(id sender){
        SLLog(@"%c",letter);
        [[CCDirector sharedDirector] pushScene:[PGLetterMenu menuWithLetter:letter]];
    }];
    
    return item;
}

@end
