//
//  MyCocos2DClass.m
//  phonics matching cards HD
//
//  Created by USTB on 12-12-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Button.h"
#import "SimpleAudioEngine.h"

@implementation Button

@synthesize string = _string;
@synthesize labelColor;
@synthesize labelSize;

+ (id) buttonWithString:(NSString *)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite block:(void(^)(id sender))block
{
    return [[[self alloc] initWithString:buttonString color:(ccColor3B)color normalSprite:normalSprite selectedSprite:selectedSprite block:block] autorelease];
}

+ (id) buttonWithString:(NSString *)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol> *)disabledSprite block:(void (^)(id))block
{
    return [[[self alloc] initWithString:buttonString color:color normalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block] autorelease];
}

- (id) initWithString:(NSString *)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol> *)disabledSprite block:(void (^)(id))block
{
    if (self = [super initWithNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite block:block])
    {
        _string = buttonString;
        
        CGFloat width = self.contentSize.width;
        CGFloat height = self.contentSize.height;
        
        NSString *fontName = @"DENNE|Sketchy";
        CGFloat fontSize = height*0.65;
        
        if (buttonString.length > 10) fontSize = height * 0.5;
        
        label = [CCLabelTTF labelWithString:_string fontName:fontName fontSize:fontSize];
        label.color = color;
        label.position = ccp(width/2, height/2);
        [self addChild:label];
    }
    return self;

}

- (id) initWithString:(NSString *)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite block:(void(^)(id sender))block
{
    return [self initWithString:buttonString color:color normalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:nil block:block];
}

- (ccColor3B) labelColor
{
    return label.color;
}

- (void) setLabelColor:(ccColor3B)labelColor_
{
    [label setColor:labelColor_];
}

- (CGFloat) labelSize
{
    return label.fontSize;
}

- (void) setLabelSize:(CGFloat)labelSize_
{
    label.fontSize = labelSize_;
}


- (void) activate
{
    [super activate];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
}

@end

@implementation BlueButton

+ (id) blueButtonWithString:(NSString *)buttonString block:(void(^)(id sender))block
{
    CCSprite *_normal = [CCSprite spriteWithSpriteFrameName:@"button2.png"];
    CCSprite *_selected = [CCSprite spriteWithSpriteFrameName:@"button2_pressed2.png"];
    
    return [self buttonWithString:buttonString color:ccc3(51, 102, 255) normalSprite:_normal selectedSprite:_selected block:block];
}

@end

@implementation OrangeButton

+ (id) orangeButtonWithString:(NSString *)buttonString block:(void(^)(id sender))block
{
    CCSprite *_normal = [CCSprite spriteWithSpriteFrameName:@"button1.png"];
    CCSprite *_selected = [CCSprite spriteWithSpriteFrameName:@"button1_pressed2.png"];
    
    return [self buttonWithString:buttonString color:ccc3(244, 98, 103) normalSprite:_normal selectedSprite:_selected block:block];
}

@end

@implementation redBlueButton

+ (id) redBluButtonWithString:(NSString *)buttonString block:(void (^)(id))block
{
    CCSprite *_normal = [CCSprite spriteWithSpriteFrameName:@"button3.png"];
    CCSprite *_selected = [CCSprite spriteWithSpriteFrameName:@"button3_pressed.png"];
    
    return [self buttonWithString:buttonString color:ccBLACK normalSprite:_normal selectedSprite:_selected block:block];
}

@end

@implementation radioButton

+ (id) radioButtonWithString:(NSString *)buttonString block:(void (^)(id))block
{
    CCSprite *_normal = [CCSprite spriteWithSpriteFrameName:@"button5.png"];
    CCSprite *_selected = [CCSprite spriteWithSpriteFrameName:@"button5_pressed.png"];
    CCSprite *_disable = [CCSprite spriteWithSpriteFrameName:@"button5_disable.png"];
    
    return [self buttonWithString:buttonString color:ccWHITE normalSprite:_normal selectedSprite:_selected disabledSprite:_disable block:block];
}

@end
