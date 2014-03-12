//
//  CCLinePro.m
//  BookReader
//
//  Created by USTB on 12-11-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCLinePro.h"


@implementation CCLinePro

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize lineWidth = _width;

+ (id) lineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withWidth:(CGFloat)width
{
    return [[[self alloc] initFromStartPoint:startPoint toEndPoint:endPoint withWidth:width] autorelease];
}

- (id) initFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withWidth:(CGFloat)width
{
    if (self = [super init])
    {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _width = width;
    }
    return self;
}

- (void) draw
{
    //set opengl status
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glDisable(GL_TEXTURE_2D);
    
    ccDrawColor4B(_realColor.r, _realColor.g, _realColor.b, _realOpacity);
    ccDrawSolidCircleLine(_startPoint, _endPoint, _width/2, 40);
    //ccDrawColor4B(color_.r, color_.g, color_.b, opacity_/2);
    //ccDrawCircleLine(_startPoint,_endPoint,_width/2+0.5f,40);
    
    //reset opengl status
    ccDrawColor4F(1, 1, 1, 1);
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    //glEnable(GL_TEXTURE_2D);
}

- (void) dealloc
{
    [super dealloc];
}

@end
