//
//  TouchGameYellow.m
//  LetterE
//
//  Created by yiplee on 14-4-19.
//  Copyright 2014年 USTB. All rights reserved.
//
static char *const file = "yellow.plist";

#import "config.h"
#import "TouchGameYellow.h"

@implementation TouchGameYellow
{
    CCSprite *hammer;
    CGPoint hammerPos;
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
    
    hammer = [CCSprite spriteWithFile:@"hammer.png"];
    hammer.anchorPoint = ccp(0.214,0.679);
    hammer.zOrder = 4;
    [self addChild:hammer];
    
    hammerPos = CCMP(0.931, 0.126);
    hammer.position = hammerPos;
    
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
        
        CCSprite *mud = [CCSprite spriteWithFile:@"mud.png"];
        CGPoint p_size = ccpFromSize(object.boundingBox.size);
        mud.position = ccpCompMult(p_size, ccp(0.520, -0.037));
        [object addChild:mud];
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        object.visible = YES;
        [object runAction:[CCFadeIn actionWithDuration:0.8]];
        
        NSString *file = [object.name stringByAppendingPathExtension:@"png"];
        CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:file];
        CGRect rect = CGRectZero;
        rect.size= tex.contentSize;
        
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
        object.userObject = frame;
        
        [[CCTextureCache sharedTextureCache] removeTextureForKey:file];
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        [object stopAllActions];
        object.opacity = 255;
    }];
    
    self.autoActiveNext = NO;
    
    return self;
}

- (void) cleanCache
{
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"mouse.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"mud.png"];
    
    [super cleanCache];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    if (object.tag >= 3)
        return YES;
    
    [hammer stopAllActions];
    
    __block id self_copy =self;
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:object.position];
    CCCallBlock *moveDone = [CCCallBlock actionWithBlock:^{
        [object removeAllChildrenWithCleanup:YES];
        object.displayFrame = object.userObject;
        object.contentSize = object.displayFrame.texture.contentSize;
        object.tag = 3;
        [self_copy activeNextObjects];
    }];
    CCMoveTo *moveBack = [CCMoveTo actionWithDuration:0.5 position:hammerPos];
    
    CCSequence *seq = [CCSequence actions:move,moveDone,moveBack, nil];
    [hammer runAction:seq];
    
    return YES;
}

@end
