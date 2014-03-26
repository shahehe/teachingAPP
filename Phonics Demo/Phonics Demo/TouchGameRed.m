//
//  TouchGameRed.m
//  LetterE
//
//  Created by yiplee on 14-3-26.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "Red.plist";

#import "config.h"
#import "TouchGameRed.h"

@implementation TouchGameRed
{
    NSDictionary *redImages;
}

+ (TouchGameRed *) gameLayer
{
    NSString *rootPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:touchingGameRootPath]];
    NSString *fileName = [NSString stringWithUTF8String:file];
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [[[self alloc] initWithGameData:dic] autorelease];
}

- (id) initWithGameData:(NSDictionary *)dic
{
    self = [super initWithGameData:dic];
    NSAssert(self, @"game:I see failed init");
    
    redImages = @{@"ring": @"red_ring.png",
                  @"road":@"red_road.png",
                  @"rocket":@"red_rocket.png",
                  @"rooster":@"red_rooster.png",
                  @"rose":@"red_rose.png",
                  @"rug":@"red_rug.png"};
    [redImages retain];
    [self preloadImages];
    
    return self;
}

- (void) dealloc
{
    [redImages release];
    [super dealloc];
}

- (void) preloadImages
{
    for (NSString *image in redImages.allValues)
    {
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [[CCTextureCache sharedTextureCache] addImageAsync:image withBlock:^(CCTexture2D *tex) {
            CGRect rect = CGRectZero;
            rect.size = tex.contentSize;
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
            [frameCache addSpriteFrame:frame name:image];
        }];
    }
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    NSString *name = object.name;
    NSString *frameName = [redImages objectForKey:name];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    if (object.displayFrame.texture != frame.texture)
    {
        object.displayFrame = frame;
        [object runAction:[CCFadeIn actionWithDuration:1]];
    }
    return YES;
}

@end
