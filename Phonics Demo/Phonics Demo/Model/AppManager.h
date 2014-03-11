//
//  AppManager.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-21.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppManager : NSObject

// return a instance of AppManager
+ (AppManager*) sharedManager;

#pragma mark --memory

- (void) purgeCache;

#pragma mark --dialogue
// ratain texture caches
@property (readonly,retain) CCArray *dialogTextures;
// cache capacity , default is 4.
@property (nonatomic,readwrite) NSUInteger dialogTextureCacheCapacity;

- (void) purgeOutdataedDialogTexturesWithRate:(CGFloat)rate;
- (void) purgeAllDialogTextures;
- (void) registerTextureToDialogCache:(CCTexture2D*)texture;

@end
