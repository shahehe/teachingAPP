//
//  ToolbarLayer.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-22.
//  Copyright 2013年 USTB. All rights reserved.
//

#import "ToolbarLayer.h"
#import "PhonicsDefines.h"

#import "Cocos2d+CustomOptions.h"

typedef NS_ENUM(NSInteger, ToolbarChildTag) {
    ToolbarBackgroundTag = 0,
    ToolbarButtonItemsTag,
    ToolbarMenuTag,
    ToolbarTitleTag,
};

#define DEFAULT_BAR_HEIGHT (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 44 : 86)

#define TICK_TIME 8

#define ANIMATION_DURATION 0.3

@implementation ToolbarLayer

- (id) init
{
    if (self = [super init])
    {
        _sidePadding = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 24 : 48;
        _itemPadding = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 40 : 80;
        
        _barHeight = DEFAULT_BAR_HEIGHT;
        _barWidth = SCREEN_WIDTH;
        
        _backgroundColor = ccc4FFromccc3B(ccGRAY);
        
        _tickTime = 0;
        _hidden = NO;
        _autoHide = NO;
        
        _backgroundLayer = [CCLayerColor layerWithColor:ccc4BFromccc4F(_backgroundColor) width:_barWidth height:_barHeight];
        _backgroundLayer.ignoreAnchorPointForPosition = NO;
        _backgroundLayer.anchorPoint = ccp(0.5, 1);
        _backgroundLayer.position = CCMP(0.5, 1);
        
        [self addChild:_backgroundLayer];
        
        _toolbarMenu = [CCMenu node];
        _toolbarMenu.zOrder = ToolbarMenuTag;
        _toolbarMenu.tag = ToolbarMenuTag;
        _toolbarMenu.position = CGPointZero;
        _toolbarMenu.touchSwallow = NO;
        [_backgroundLayer addChild:_toolbarMenu];
        
        [self setTouchEnabled:YES];
    }
    return self;
}

- (void) setBackgroundColor:(ccColor4F)backgroundColor
{
    if (ccc4FEqual(_backgroundColor, backgroundColor))
        return;
    _backgroundColor = backgroundColor;
    ccColor4B color = ccc4BFromccc4F(backgroundColor);
    _backgroundLayer.color = ccc3(color.r, color.g, color.b);
    _backgroundLayer.opacity = color.a;
}

- (void) setBarHeight:(CGFloat)barHeight
{
    if (_barHeight == barHeight) return;
    NSAssert(barHeight > 0, @"toolbar height must be greater than zero");
    
    _barHeight = barHeight;
    [self refreshLayout];
}

- (void) setBarWidth:(CGFloat)barWidth
{
    if (_barWidth == barWidth) return;
    NSAssert(barWidth > 0, @"toolbar width must be greater than zero");
    
    _barWidth = barWidth;
    [self refreshLayout];
}

- (void) setSidePadding:(CGFloat)sidePadding
{
    if (_sidePadding == sidePadding) return;
    _sidePadding = sidePadding;
    
    [self refreshLayout];
}

- (void) setItemPadding:(CGFloat)itemPadding
{
    if (_itemPadding == itemPadding) return;
    _itemPadding = itemPadding;
    
    [self refreshLayout];
}

- (void) setBackgroundSpriteFrame:(CCSpriteFrame *)backgroundSpriteFrame
{
    if (!backgroundSpriteFrame) return;
    [_backgroundSpriteFrame release];
    _backgroundSpriteFrame = [backgroundSpriteFrame retain];
    if (!_backgroundSprite)
    {
        _backgroundSprite = [CCSprite spriteWithSpriteFrame:_backgroundSpriteFrame];
        [_backgroundLayer addChild:_backgroundSprite z:ToolbarBackgroundTag tag:ToolbarBackgroundTag];
    }
    else
    {
        _backgroundSprite.displayFrame = _backgroundSpriteFrame;
    }
    
    [_backgroundSprite setFrame:CGRectMake(0, 0, _barWidth, _barHeight)];
}

- (void) setTitleNode:(CCNode *)title
{
    if (title == _titleNode || title == nil) return;
    
    if (_titleNode)
    {
        [self removeChild:_titleNode cleanup:YES];
        _titleNode = nil;
    }
    
    _titleNode = title;
    
    _titleNode.anchorPoint = ccp(0.5, 1);
    _titleNode.position = ccp(_barWidth/2, _barHeight);
    [_backgroundLayer addChild:_titleNode z:ToolbarTitleTag tag:ToolbarTitleTag];
}

- (void) setLeftItems:(NSArray *)leftItems
{
    NSAssert(leftItems, @"toolbar: can't add nil as bar item");
    
    for (CCNode *item in self.leftItems)
        [item removeFromParentAndCleanup:YES];
    [self.leftItems release];
    
    _leftItems = leftItems;
    [_leftItems retain];
    
    CGPoint position = ccp(_sidePadding, _barHeight/2);
    for (CCNode *item in self.leftItems)
    {
        item.position = position;
        item.zOrder = ToolbarButtonItemsTag;
        
        if ([item isKindOfClass:[CCMenuItem class]])
            [_toolbarMenu addChild:item];
        else
            [_backgroundLayer addChild:item];
        
        position.x += _itemPadding;
    }
}

- (void) setRightItems:(NSArray *)rightItems
{
    NSAssert(rightItems, @"toolbar: can't add nil as bar item");
    
    for (CCNode *item in self.rightItems)
        [item removeFromParentAndCleanup:YES];
    [self.rightItems release];
    
    _rightItems = rightItems;
    [_rightItems retain];
    
    CGPoint position = ccp(_barWidth-_sidePadding, _barHeight/2);
    int i = [self.rightItems count];
    while (i--) {
        CCNode *item = [self.rightItems objectAtIndex:i];
        item.position = position;
        if ([item isKindOfClass:[CCMenuItem class]])
            [_toolbarMenu addChild:item];
        else
            [_backgroundLayer addChild:item];
        position.x -= _itemPadding;
    }
}

- (void) refreshLayout
{
    [_backgroundLayer changeWidth:_barWidth height:_barHeight];
    [_backgroundSprite setFrame:CGRectMake(0, 0, _barWidth, _barHeight)];
    
    CGPoint position = ccp(_sidePadding, _barHeight/2);
    for (CCNode *item in self.leftItems)
    {
        item.position = position;
        position.x += _itemPadding;
    }

    position = ccp(_barWidth-_sidePadding, _barHeight/2);
    int i = [self.rightItems count];
    while (i--) {
        CCNode *item = [self.rightItems objectAtIndex:i];
        item.position = position;
        position.x -= _itemPadding;
    }
    
    _titleNode.position = ccp(_barWidth/2, _barHeight);
}

- (void) addAdditionalMenuItem:(CCMenuItem *)item
{
    item.position = [_toolbarMenu convertToNodeSpace:item.position];
    [_toolbarMenu addChild:item];
}

#pragma mark --logic

- (void) update:(ccTime)delta
{
    if (self.isHidden) return;

    _tickTime -= delta;
    if (_tickTime <= 0)
    {
        [self toolbarHideWithAnimation:YES];
    }
}

- (void) setAutoHide:(BOOL)autoHide
{
    if (_autoHide == autoHide) return;
    _autoHide = autoHide;
    
    if (_autoHide)
    {
        [self unscheduleUpdate];
        [self scheduleUpdate];
        _tickTime = TICK_TIME;
    }
    else
    {
        [self unscheduleUpdate];
        _tickTime = 0;
        [self toolbarShowWithAnimation:YES];
    }
}

- (void) active
{
    _tickTime = TICK_TIME;
    [self toolbarShowWithAnimation:YES];
}

- (void) toolbarShowWithAnimation:(BOOL)isAnimation
{
    if (!self.isHidden) return;
    _hidden = NO;
    CGFloat duration = isAnimation ? ANIMATION_DURATION : 0;
    CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:ccp(0, SCREEN_HEIGHT-_backgroundLayer.position.y)];
    CCEaseSineOut *ease = [CCEaseSineOut actionWithAction:move];
    [_backgroundLayer stopAllActions];
    [_backgroundLayer runAction:ease];
    
    if (self.autoHide)
    {
        _tickTime = TICK_TIME;
    }
}

- (void) toolbarHideWithAnimation:(BOOL)isAniamtion
{
    if (self.isHidden) return;
    _hidden = YES;
    CGFloat duration = isAniamtion ? ANIMATION_DURATION : 0;
    CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:ccp(0, SCREEN_HEIGHT+_barHeight-_backgroundLayer.position.y)];
    CCEaseSineIn *ease = [CCEaseSineIn actionWithAction:move];
    [_backgroundLayer stopAllActions];
    [_backgroundLayer runAction:ease];
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-1 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint position = [self convertTouchToNodeSpace:touch];
    if (_autoHide && SCREEN_HEIGHT - position.y <= self.barHeight)
    {
        [self active];
        return YES;
    }
    return NO;
}

#pragma mark --dealloc

- (void) dealloc
{
    [_leftItems release];
    _leftItems = nil;
    
    [_rightItems release];
    _rightItems = nil;
    
    [_backgroundSpriteFrame release];
    _backgroundSpriteFrame = nil;
    
    [super dealloc];
}

@end
