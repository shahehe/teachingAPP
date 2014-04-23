//
//  CardProLayer.m
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "CardProLayer.h"
#import "ImageCardPro.h"

#import "PhonicsDefines.h"

#import "YRecorder.h"

@implementation CardProLayer
{
    CCLabelAtlas *star;
    
    CCMenuItemToggle *audio_control;
    CCMenuItemToggle *audio_record;
}

+ (instancetype) layerWithWord:(NSString *)word
{
    return [[[self alloc] initWithWord:word] autorelease];
}

- (id) initWithWord:(NSString *)word
{
    self = [super init];
    
    CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 153)];
    [self addChild:bgLayer z:0];
    
    ImageCardPro *card = [ImageCardPro cardWithWord:word];
    card.position = CCMP(0.5, 0.56);
    [self addChild:card z:1];
    
    CCSprite *panel = [CCSprite spriteWithFile:@"audio_control_panel.png"];
    panel.position = CCMP(0.5, 0.2);
    panel.zOrder = 2;
    [self addChild:panel];
    
    CGPoint p_size_panel = ccpFromSize(panel.boundingBox.size);
    
    CCMenuItemImage *audio_play = [CCMenuItemImage itemWithNormalImage:@"audio_pause.png" selectedImage:nil block:^(id sender) {
//        CCLOG(@"audio play");
        [[YRecorder sharedEngine] play];
    }];
    CCMenuItemImage *audio_pause = [CCMenuItemImage itemWithNormalImage:@"audio_play.png" selectedImage:nil block:^(id sender) {
        CCLOG(@"audio pause");
    }];
    audio_control = [CCMenuItemToggle itemWithItems:@[audio_play,audio_pause] block:^(id sender) {
        CCMenuItemToggle *t = (CCMenuItemToggle*)sender;
        [t.selectedItem activate];
    }];
    audio_control.selectedIndex = 1;
    audio_control.position = [panel convertToWorldSpace:ccpCompMult(p_size_panel, ccp(0.2, 0.45))];
    
    CCMenuItemImage *audio_record_start = [CCMenuItemImage itemWithNormalImage:@"audio_record_stop.png" selectedImage:nil block:^(id sender) {
        CCLOG(@"record start");
        [[YRecorder sharedEngine] record];
    }];
    CCMenuItemImage *audio_record_stop  = [CCMenuItemImage itemWithNormalImage:@"audio_record_start.png" selectedImage:nil block:^(id sender) {
        CCLOG(@"record stop");
        [[YRecorder sharedEngine] stop];
    }];
    audio_record = [CCMenuItemToggle itemWithItems:@[audio_record_start,audio_record_stop] block:^(id sender) {
        CCMenuItemToggle *t = (CCMenuItemToggle*)sender;
        [t.selectedItem activate];
    }];
    audio_record.selectedIndex = 1;
    audio_record.position = [panel convertToWorldSpace:ccpCompMult(p_size_panel, ccp(0.8, 0.45))];
    
    CCSprite *close = [CCSprite spriteWithSpriteFrameName:@"close.png"];
    
    CCMenuItemSprite *closeButton = [CCMenuItemSprite itemWithNormalSprite:close selectedSprite:nil block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    closeButton.position = ccpAdd(ccpCompMult(ccpFromSize(card.boundingBox.size), ccp(1,1)),card.boundingBox.origin);
    
    CCMenu *menu = [CCMenu menuWithItems:closeButton,audio_control,audio_record,nil];
    menu.position = CGPointZero;
    [self addChild:menu z:2];
    
    star = [CCLabelAtlas labelWithString:@"11111" charMapFile:@"little_stars.png" itemWidth:92.0/2 itemHeight:87.0/2 startCharMap:'0'];
    star.anchorPoint = ccp(0.5, 0.5);
    star.position = ccpCompMult(p_size_panel, ccp(0.5, 0.45));
    [panel addChild:star];
    
    return self;
}

- (void) setStars:(NSUInteger)s
{
    s = MIN(s, 5);
    NSRange r = NSMakeRange(0, s);
    NSString *str = [@"00000" substringWithRange:r];
    star.string = [@"11111" stringByReplacingCharactersInRange:r withString:str];
}

- (void) draw
{
    [super draw];
    
    [_sourceScene visit];
}

- (void) onEnter
{
    [super onEnter];
    [[YRecorder sharedEngine] setDelegate:self];
}

- (void) onExit
{
    [super onExit];
    [[YRecorder sharedEngine] setDelegate:nil];
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark --AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    audio_control.selectedIndex = 1;
    
//    [self setStars:arc4random_uniform(6)];
    static NSUInteger count = 0;
    
    count++;
    [self setStars:count];
}

@end
