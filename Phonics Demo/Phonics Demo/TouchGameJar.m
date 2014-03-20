//
//  TouchGameJar.m
//  LetterE
//
//  Created by yiplee on 14-3-20.
//  Copyright (c) 2014年 USTB. All rights reserved.
//

static char *const file = "jar.plist";

#import "config.h"
#import "TouchGameJar.h"

@interface TouchGameJar ()
{
    NSDictionary *jarImages;
}

@end

@implementation TouchGameJar

+ (TouchGameJar *) gameLayer
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
    
    jarImages = @{@"jellybean":@"jellybean.png",
                  @"jelly":@"jelly.png",
                  @"juice":@"juice.png",
                  @"jam":@"jam.png",
                  @"jewellery":@"jewellery.png"};
    [jarImages retain];
    [self preloadImages];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [jarImages release];
}

- (void) preloadImages
{
    for (NSString *image in jarImages.allValues)
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
    NSString *frameName = [jarImages objectForKey:name];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    if (object.displayFrame.texture != frame.texture)
    {
        CCSprite *temp = [CCSprite spriteWithSpriteFrame:object.displayFrame];
        temp.position = object.position;
        temp.zOrder = object.zOrder - 1;
        [self addChild:temp];
        
        object.opacity = 0;
        object.displayFrame = frame;
        
        CCFadeTo *fade = [CCFadeTo actionWithDuration:3 opacity:255];
        CCCallBlock *done = [CCCallBlock actionWithBlock:^{
            [temp removeFromParentAndCleanup:YES];
        }];
        CCSequence *seq = [CCSequence actions:fade,done, nil];
        [object runAction:seq];
    }
    
    return YES;
}


@end
