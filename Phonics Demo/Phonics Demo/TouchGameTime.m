//
//  TouchGameTime.m
//  LetterE
//
//  Created by yiplee on 14-3-21.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "time.plist";

char *const times[] = {"8:10","8:30","10:00","15:30","16:00","16:40"};

#import "config.h"
#import "TouchGameTime.h"

@interface TouchGameTime ()
{
    NSDictionary *displayImages;
    
    CCSprite *displaySprite;
    
    __block NSUInteger __count;
}

@end

@implementation TouchGameTime

+ (TouchGameTime *) gameLayer
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
    
    displayImages = @{@"1":@"activity_1.png",
                      @"2":@"activity_2.png",
                      @"3":@"activity_3.png",
                      @"4":@"activity_4.png",
                      @"5":@"activity_5.png",
                      @"6":@"activity_6.png"};
    [displayImages retain];
    
    [self preloadImages];
    
    __count = 0;
    [self setObjectActivedBlock:^(GameObject *object) {
        blinkSprite(object);
        NSString *time = [NSString stringWithUTF8String:times[__count]];
        CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:time fontName:@"Helvetica" fontSize:36];
        timeLabel.color = ccBLACK;
        CGSize size = object.boundingBox.size;
        timeLabel.position = ccpMult(ccpFromSize(size), 0.5);
        [object addChild:timeLabel];
        __count++;
    }];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [displayImages release];
}

- (void) setGameMode:(TouchGameMode)gameMode
{
    self.gameMode = GameModeDefault;
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
        displaySprite = [CCSprite spriteWithSpriteFrame:frame];
        displaySprite.position = CCMP(1, 0);
        displaySprite.anchorPoint = ccp(1, 0);
        displaySprite.zOrder = 4;
        [self addChild:displaySprite];
    }
    
    return YES;
}

@end
