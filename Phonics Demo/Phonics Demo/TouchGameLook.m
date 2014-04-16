//
//  TouchGameLook.m
//  LetterE
//
//  Created by yiplee on 14-4-14.
//  Copyright 2014年 USTB. All rights reserved.
//

static char *const file = "look.plist";

#import "config.h"
#import "TouchGameLook.h"

@implementation TouchGameLook
{
    CCSprite *book_open;
    CCSprite *displayItem;
    
    NSDictionary *displayImages;
}

+ (instancetype) gameLayer
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
    
    displayImages = @{@"ladybug":@"ladybug.png",
                      @"lamb":@"lamb.png",
                      @"lamp":@"lamp.png",
                      @"lantern":@"lantern.png",
                      @"lobster":@"lobster.png"
                      };
    [displayImages retain];
    [self preloadImages];
    
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        object.visible = YES;
        blinkSprite(object);
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
    }];
    
    book_open = [CCSprite spriteWithFile:@"book_open.png"];
    book_open.position = CCMP(0.419, 0.661);
    book_open.zOrder = 3;
    book_open.visible = NO;
    [self addChild:book_open];
    
    [self setAutoActiveNext:NO];
    
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

- (void) cleanCache
{
    for (NSString *image in displayImages.allValues)
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:image];
        [[CCTextureCache sharedTextureCache] removeTextureForKey:image];
    }
    
    [super cleanCache];
}

- (void) dealloc
{
    [displayImages release];
    [super dealloc];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    object.visible = NO;
    book_open.visible = YES;
    
    [[self contentLabel] setVisible:YES];
    
    NSString *frameName = [displayImages objectForKey:object.name];
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    if (displayItem)
    {
        displayItem.displayFrame = frame;
    }
    else
    {
        displayItem = [CCSprite spriteWithSpriteFrame:frame];
        displayItem.zOrder = 4;
        displayItem.position = CCMP(0.499, 0.697);
        [self addChild:displayItem];
    }
    displayItem.visible = YES;
    
    return YES;
}

- (void) activeNextObjects
{
    [super activeNextObjects];
    
    book_open.visible = NO;
    displayItem.visible = NO;
}

- (void) contentDidFinishReading:(GameObject *)object
{
    [[self contentLabel] setVisible:NO];
    [self activeNextObjects];
}

@end
