//
//  GradientLabel.h
//  BookReader
//
//  Created by USTB on 12-11-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {
    GradientLabelFromLeft = 0,
    GradientLabelFromRight
    } GradientLabelType;

@interface GradientLabel : CCLabelTTF
{
    CCProgressTimer *progress;
    
    GradientLabelType _type;
}

@property (nonatomic,readwrite) GradientLabelType type;

+ (id) LabelWithString:(NSString*)string FontName:(NSString*)name FontSize:(CGFloat)size BackgroundColor:(ccColor3B)bgColor CoverColor:(ccColor3B)CoverColor;

- (id) initWithString:(NSString*)string FontName:(NSString*)name FontSize:(CGFloat)size BackgroundColor:(ccColor3B)bgColor CoverColor:(ccColor3B)CoverColor;

- (void) playFrom:(float)startPercentage to:(float)endPercentage withDuration:(ccTime)duration;

- (void) playTo:(float)endPercentage withDuration:(ccTime)duration;

- (void) stop;

- (void) setLabelString:(NSString*)string withCoverColor:(ccColor3B)coverColor;

@end
