//
//  TouchGameBabyToy.m
//  LetterE
//
//  Created by yiplee on 14-3-24.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "toy.plist";

#import "config.h"
#import "TouchGameBabyToy.h"

@interface TouchGameBabyToy ()
{
    CCSprite *displaySprite;
    
    NSDictionary *images;
    
    NSMutableArray *crawlFrames;
}

@end

@implementation TouchGameBabyToy

+ (TouchGameBabyToy *) gameLayer
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
    
    images = @{@"bubbles":@"bubbles.png",
               @"ball":@"ball.png",
               @"bell":@"bell.png",
               @"blanket":@"blanket.png",
               @"blocks":@"blocks.png",
               @"box":@"box.png"};
    [images retain];
    
    
    displaySprite = nil;
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
    }];
    
    __block TouchGameBabyToy* self_copy = self;
    [self setObjectActivedBlock:^(GameObject *object) {
        object.visible = YES;
        
        CCSpriteFrame *f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:object.name];
        if (!f)
        {
            NSString *image = [self_copy->images objectForKey:object.name];
            CCSprite *temp = [CCSprite spriteWithFile:image];
            
            f = temp.displayFrame;
        }
        
        if (self_copy->displaySprite)
        {
            self_copy->displaySprite.displayFrame = f;
        }
        else
        {
            self_copy->displaySprite = [CCSprite spriteWithSpriteFrame:f];
            [self_copy addChild:self_copy->displaySprite];
        }
        
        if ([object.name hasSuffix:@"bubbles"])
        {
            self_copy->displaySprite.anchorPoint = ccp(0.159, 0.236);
            self_copy->displaySprite.position = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.295, 0.426));
            self_copy->displaySprite.scale = 0.01;
        }
        else
        {
            [self_copy->displaySprite stopAllActions];
            self_copy->displaySprite.opacity = 255;
            self_copy->displaySprite.anchorPoint = ccp(0.5, 0.5);
            self_copy->displaySprite.position = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.818, 0.326));
            self_copy->displaySprite.scale = 1;
        }
        
        blinkSprite(object);
        
        ([self_copy contentLabel]).string = object.content;
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
        object.opacity = 255;
        object.visible = YES;
    }];
    
    [self preloadImages];
    [self preloadCrawlAnimation];
    
    self.autoActiveNext = NO;
    
    crawlFrames = nil;
    
    [self setTouchEnabled:YES];
    return self;
    
}

- (void) dealloc
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [images release];
    [crawlFrames release];
    
    [super dealloc];
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onExitTransitionDidStart
{
    [super onExitTransitionDidStart];
}

- (void) cleanCache
{
    [images enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *name = key;
        NSString *image = obj;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:name];
        [[CCTextureCache sharedTextureCache] removeTextureForKey:image];
    }];
    
    for (int i=1;i<=30;i++)
    {
        NSString *key = [NSString stringWithFormat:@"boy_crawl%02d.png",i];
        CCLOG(@"release tex:%@",key);
        [[CCTextureCache sharedTextureCache] removeTextureForKey:key];
    }

    [super cleanCache];
}

- (void) setGameMode:(TouchGameMode)gameMode
{
    // do nothing
}

- (void) preloadImages
{
    [images enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *name = key;
        NSString *image = obj;
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [[CCTextureCache sharedTextureCache] addImageAsync:image withBlock:^(CCTexture2D *tex) {
            CGRect rect = CGRectZero;
            rect.size = tex.contentSize;
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
            [frameCache addSpriteFrame:frame name:name];
            CCLOG(@"add %@ as %@",frame,name);
        }];
    }];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if (![super objectHasBeenClicked:object])
        return NO;
    
    CCLOG(@"click on %@",object.name);
    if ([object.name hasSuffix:@"bubbles"])
    {
        displaySprite.anchorPoint = ccp(0.159, 0.236);
        displaySprite.position = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.295, 0.426));
        displaySprite.scale = 0.01;
        
        CCFadeOut *fade = [CCFadeOut actionWithDuration:2];
        CCScaleTo *scale = [CCScaleTo actionWithDuration:2 scale:1.2];
        ccBezierConfig config;
        config.controlPoint_1 = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.295, 0.426));
        config.controlPoint_2 = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.494, 0.647));
        config.endPosition = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.527, 0.966));
        CCBezierTo *move = [CCBezierTo actionWithDuration:2 bezier:config];
        [displaySprite runAction:move];
        [displaySprite runAction:fade];
        [displaySprite runAction:scale];
    }

    else if (object.tag < 3)
    {
        CCMoveBy *move = [CCMoveBy actionWithDuration:4 position:ccp(600, 0)];
        CCCallBlock *done = [CCCallBlock actionWithBlock:^{
            [object stopAllActions];
        }];
        CCSequence *seq = [CCSequence actions:move,done, nil];
        CCRepeatForever *r = [CCRepeatForever actionWithAction:[self crawlAnimation]];
            
        [object runAction:seq];
        [object runAction:r];
    }
    
    object.tag = 3;
    
    return YES;
}

- (void) preloadCrawlAnimation
{
    for (int i=1;i<=30;i++)
    {
        NSString *key = [NSString stringWithFormat:@"boy_crawl%02d.png",i];
        [[CCTextureCache sharedTextureCache] addImageAsync:key withBlock:^(CCTexture2D *tex) {
        }];
    }
}

- (CCAnimate *) crawlAnimation
{
    if (!crawlFrames)
    {
        crawlFrames = [[NSMutableArray arrayWithCapacity:30] retain];
        for (int i=1;i<=30;i++)
        {
            NSString *key = [NSString stringWithFormat:@"boy_crawl%02d.png",i];
            CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:key];
            CGRect rect = CGRectZero;
            rect.size = tex.contentSize;
            CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
            [crawlFrames addObject:frame];
        }
    }
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:crawlFrames delay:0.05];
    return [CCAnimate actionWithAnimation:animation];
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.runningObject.tag > 2)
    {
        [self.runningObject removeFromParentAndCleanup:YES];
        [self activeNextObjects];
    }
}


@end
