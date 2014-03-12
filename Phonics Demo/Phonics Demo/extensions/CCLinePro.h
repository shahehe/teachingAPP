//
//  CCLinePro.h
//  BookReader
//
//  Created by USTB on 12-11-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLinePro : CCSprite
{
    CGPoint _startPoint;
    CGPoint _endPoint;
    
    CGFloat _width;
}

@property(nonatomic,readwrite) CGPoint startPoint;
@property(nonatomic,readwrite) CGPoint endPoint;
@property(nonatomic,readwrite) CGFloat lineWidth;

+ (id) lineFromStartPoint:(CGPoint) startPoint toEndPoint:(CGPoint) endPoint withWidth:(CGFloat) width;

- (id) initFromStartPoint:(CGPoint) startPoint toEndPoint:(CGPoint) endPoint withWidth:(CGFloat) width;

@end
