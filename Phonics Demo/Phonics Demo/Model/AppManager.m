//
//  AppManager.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-21.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "AppManager.h"
#import "PhonicsDefines.h"

#define DIALOG_TEXTURE_CACHE_CAPACITY_INIT 4

@interface AppManager ()

@end

static AppManager *instance = nil;

@implementation AppManager

+ (AppManager *)sharedManager
{    
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
    if (self = [super init])
    {
        _dialogTextureCacheCapacity = DIALOG_TEXTURE_CACHE_CAPACITY_INIT;
        
        _dialogTextures = [CCArray arrayWithCapacity:_dialogTextureCacheCapacity];
        [_dialogTextures retain];
    }
    return self;
}

- (void) dealloc
{
    [_dialogTextures release];
    _dialogTextures = nil;
    
    [instance release];
    instance = nil;
    
    [super dealloc];
}

#pragma mark --memory

- (void) purgeCache
{
    
}

#pragma mark --dialogue

- (void) purgeOutdataedDialogTexturesWithRate:(CGFloat)rate
{
    
}

- (void) purgeAllDialogTextures
{
    for (CCTexture2D *texture in _dialogTextures)
    {
        [[CCTextureCache sharedTextureCache] removeTexture:texture];
    }
    
    [_dialogTextures removeAllObjects];
}

- (void) registerTextureToDialogCache:(CCTexture2D*)texture
{
    
}

@end
