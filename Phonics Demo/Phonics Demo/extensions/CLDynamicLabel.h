//
//  CLDynamicLable.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-25.
//  Copyright 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef NS_ENUM(NSInteger, CLLableAppearMode)
{
    CLLableAppearModePerWord = 0,
    CLLableAppearModePerCharacter,
    CLLableAppearModeOnce,
    
    CLLableAppearModeDefault = CLLableAppearModePerWord,
};

@interface CLDynamicLabel : CCLabelBMFont

@property (nonatomic,readonly) BOOL isPlaying;
@property (nonatomic,assign) ccTime interval;

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset;

#pragma mark --control

@property (nonatomic,assign) CLLableAppearMode appearMode;

- (void) play;
- (void) pause;
- (void) stop;

- (void) playWithString:(NSString*)string;
- (void) playWithAdditionalString:(NSString*)string;

#pragma mark --event

- (void) setPlayCompletionBlock:(void (^)(id sender)) block;

@end

@interface NSString (Character)

- (CCArray*) componentsDivideByCharacter;

@end
