//
//  TouchGameISee.m
//  LetterE
//
//  Created by yiplee on 14-3-18.
//  Copyright (c) 2014年 USTB. All rights reserved.
//

static char *const file = "I_see.plist";

#import "config.h"
#import "TouchGameISee.h"

@implementation TouchGameISee
{
    CCSprite *glass; // weak ref
    CGPoint glassPosition;
    
    CCSprite *displaySprite;
    CGPoint displayPosition;
    NSDictionary *displayImages;
}

+ (TouchGameISee *) gameLayer
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
    
    glassPosition = ccp(0.86,0.15);
    glass = [CCSprite spriteWithFile:@"glass.png"];
    glass.position = CCMP(glassPosition.x, glassPosition.y);
    glass.zOrder = 4;
    glass.anchorPoint = ccp(0.25, 0.75);
    [self addChild:glass];
    
    displaySprite = nil;
    displayPosition = CCMP(0.514, 0.578);
    displayImages = @{@"shark": @"shark_big.png",
                      @"sheep":@"sheep_big.png",
                      @"shrimp":@"shrimp_big.png",
                      @"snail":@"snail_big.png",
                      @"snake":@"snake_big.png",
                      @"spider":@"spider_big.png"};
    [displayImages retain];
    
    [self preloadImages];
    
    return self;
}

- (void) preloadImages
{
    for (NSString *image in displayImages.allValues)
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
    NSString *frameName = [displayImages objectForKey:name];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    
    if (displaySprite != nil)
    {
        displaySprite.displayFrame = frame;
    }
    else
    {
//        CCLOG(@"init displaySprite");
        displaySprite = [CCSprite spriteWithSpriteFrame:frame];
        displaySprite.position = displayPosition;
        displaySprite.zOrder = 4;
        [self addChild:displaySprite];
    }
    displaySprite.visible = NO;
    displaySprite.scale = 0.3;
    [displaySprite stopAllActions];
    
    CGPoint pos = object.position;
    
    [glass stopAllActions];
    CCMoveTo *moveToObject = [CCMoveTo actionWithDuration:0.5 position:pos];
    CCCallBlock *call = [CCCallBlock actionWithBlock:^{
        displaySprite.visible = YES;
        [displaySprite runAction:[CCScaleTo actionWithDuration:0.5 scale:1]];
//        CCLOG(@"call");
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.5];
    CCMoveTo *moveBack = [CCMoveTo actionWithDuration:0.5 position:CCMP(glassPosition.x, glassPosition.y)];
    CCSequence *seq = [CCSequence actions:moveToObject,call,delay,moveBack, nil];
    [glass runAction:seq];
    
    return YES;
}

- (void) dealloc
{
    [displayImages release];
    displayImages = nil;
    
    [super dealloc];
}

@end
