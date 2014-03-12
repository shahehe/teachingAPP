//
//  Color.m
//  BookReader
//
//  Created by USTB on 12-11-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Color.h"


@implementation Color

+ (ccColor3B) addColor:(ccColor3B)color onColor:(ccColor3B)originColor
{
    ccColor3B newColor;
    newColor.r = (color.r + originColor.r) * 0.5;
    newColor.g = (color.g + originColor.g) * 0.5;
    newColor.b = (color.b + originColor.b) * 0.5;
    return newColor;
}

+ (ccColor3B) removeColor:(ccColor3B)color fromColor:(ccColor3B)originColor
{
    ccColor3B newColor;
    newColor.r = MAX((originColor.r * 2 - color.r),0);
    newColor.g = MAX((originColor.g * 2 - color.g),0);
    newColor.b = MAX((originColor.b * 2 - color.b),0);
    return newColor;
}

+ (ccColor3B) randomColor
{
    ccColor3B newColor;
    newColor.r = arc4random_uniform(255);
    newColor.g = arc4random_uniform(255);
    newColor.b = arc4random_uniform(255);
    return newColor;
}

// out of date
+ (ccColor3B) randomBrightColorOld
{
    ccColor3B newColor;
    NSInteger colorValue = arc4random_uniform(255) + 255;
    newColor.r = arc4random_uniform(255);
    newColor.g = MIN(colorValue - newColor.r,255);
    newColor.b = MAX(colorValue-newColor.r-newColor.g,0);
    return newColor;
}

+ (ccColor3B) randomBrightColor
{
    ccColor3B newColor;
    
    NSUInteger value[3];
    value[0] = 0;
    value[1] = 255;
    value[2] = arc4random_uniform(255);
    
    NSUInteger _index = arc4random_uniform(3);
    newColor.r = value[_index];
    value[_index] = value[2];
   
    _index = arc4random_uniform(2);
    newColor.g = value[_index];
    value[_index] = value[1];
    
    newColor.b = value[0];
    
    return newColor;
}

+ (ccColor4B) randomBrightColor4B
{
    ccColor4B newColor;
    
    ccColor3B color = [self randomBrightColor];
    newColor.r = color.r;
    newColor.g = color.g;
    newColor.b = color.b;
    
    newColor.a = arc4random_uniform(255);
    
    return newColor;
}

+ (ccColor3B) reverseColor:(ccColor3B)color
{
    ccColor3B newColor;
    
    newColor.r = 255 - color.r;
    newColor.g = 255 - color.g;
    newColor.b = 255 - color.b;
    
    return newColor;
}

+ (void) introduceColor:(ccColor3B)color
{
    CCLOG(@"color r:%i,g:%i,b:%i",color.r,color.g,color.b);
}

@end

@implementation NSString (yipleeColor)

- (ccColor3B) string2ColorWithDefaultColor:(ccColor3B)defaultColor
{
    ccColor3B color = defaultColor;
    
    if ([self hasPrefix:@"#"])
        self = [self substringFromIndex:1];
    if ([self length] == 6)
    {
        unsigned int r, g, b;
        [[NSScanner scannerWithString:[self substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[self substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[self substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
        color.r = r;
        color.g = g;
        color.b = b;
    }
    return color;
}

@end
