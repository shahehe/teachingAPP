//
//  TraceClass.m
//  newtrace
//
//  Created by Richard Guan on 10/2/13.
//  Copyright 2013 Yan Feng. All rights reserved.
//

#import "TraceClass.h"


@interface TraceClass ()

@property   (nonatomic, strong) CCSprite *mySprite;

@end

@implementation TraceClass
@synthesize mySprite = _mySprite;


-(id)   initWithPositionX: (int) positionX
                PositionY: (int) positionY
                    Scale: (float) scale
                   Name: (NSString *) name
{
    self = [super init];
    if (self) {
        self.mySprite = [CCSprite spriteWithFile:name];
        [self.mySprite setPosition:ccp(positionX,positionY)];
        [self.mySprite setScale:(scale)];
        [self addChild:self.mySprite];

    }
    return self;
}


/**
    判断点是否在图片非透明区域
    在返回YES 
    不在返回NO
 **/
-(BOOL) pointIsOutOfTheBound:(CGPoint)  point;
{
    BOOL result = NO;
//    NSLog(@"%f",self.mySprite.boundingBox.size.width);
    point.x = point.x - self.mySprite.position.x + 0.5 * self.mySprite.boundingBox.size.width;
    point.x /= self.mySprite.scale;
    point.y = point.y - self.mySprite.position.y + 0.5 * self.mySprite.boundingBox.size.height;
    point.y /= self.mySprite.scale;
//    NSLog(@"cX=%f cY=%f", point.x, point.y);
//    NSLog(@"w=%f h=%f", self.mySprite.boundingBox.size.width, self.mySprite.boundingBox.size.height);
    
    if (point.x < 0 || point.y < 0 || point.x > self.mySprite.boundingBox.size.width / self.mySprite.scale || point.y > self.mySprite.boundingBox.size.height / self.mySprite.scale) {
        return YES;
    }
    
    UInt8 data[4];
    CCRenderTexture* renderTexture = [[CCRenderTexture alloc] initWithWidth:self.mySprite.boundingBox.size.width / self.mySprite.scale * CC_CONTENT_SCALE_FACTOR()
                                                                     height:self.mySprite.boundingBox.size.height / self.mySprite.scale * CC_CONTENT_SCALE_FACTOR()
                                                                pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    [renderTexture begin];
    [self.mySprite draw];
    
    glReadPixels((GLint)point.x,(GLint)point.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    [renderTexture end];
    [renderTexture release];
    
//    NSLog(@"R: %d, G: %d, B: %d, A: %d", data[0], data[1], data[2], data[3]);
    
    if (data[3] == 0) {
        result = YES;
    }
    
    return  result;
}

-(void) dealloc
{
    [self.mySprite release];
    [super dealloc];
}

@end
