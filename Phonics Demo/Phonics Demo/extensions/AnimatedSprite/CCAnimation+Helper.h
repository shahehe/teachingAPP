//
//  CCAnimation+Helper.h
//  LetterA
//
//  Created by Yan Feng on 1/28/14.
//  Copyright (c) 2014 USTB. All rights reserved.
//

#import "CCAnimation.h"

@interface CCAnimation (Helper)
+(CCAnimation*) animationWithFile:(NSString*)name frameCount:(int)frameCount delay:(float)delay;
+(CCAnimation*) animationWithFrame:(NSString*)frame frameCount:(int)frameCount delay:(float)delay;
+(CCAnimation*) animationWithFrame:(NSString*)frame startIdx:(int)startIdx endIdx:(int)endIdx delay:(float)delay;
@end
