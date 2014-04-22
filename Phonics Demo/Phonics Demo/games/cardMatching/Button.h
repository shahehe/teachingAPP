//
//  MyCocos2DClass.h
//  phonics matching cards HD
//
//  Created by USTB on 12-12-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Button : CCMenuItemSprite {
    NSString *_string;
    CCLabelTTF *label;
}

@property (nonatomic,copy) NSString *string;
@property (nonatomic,assign) ccColor3B labelColor;
@property (nonatomic,assign) CGFloat labelSize;

+ (id) buttonWithString:(NSString*)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite  block:(void(^)(id sender))block;

+ (id) buttonWithString:(NSString*)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol> *)disabledSprite  block:(void(^)(id sender))block;

- (id) initWithString:(NSString*)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite block:(void(^)(id sender))block;

- (id) initWithString:(NSString*)buttonString color:(ccColor3B)color normalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol> *)disabledSprite block:(void(^)(id sender))block;

@end

@interface BlueButton : Button

+ (id) blueButtonWithString:(NSString*)buttonString block:(void(^)(id sender))block;

@end

@interface OrangeButton : Button

+ (id) orangeButtonWithString:(NSString*)buttonString block:(void(^)(id sender))block;

@end

@interface redBlueButton : Button

+ (id) redBluButtonWithString:(NSString *)buttonString block:(void (^)(id sender))block;

@end

@interface radioButton : Button

+ (id) radioButtonWithString:(NSString *)buttonString block:(void (^)(id sender))block;


@end
