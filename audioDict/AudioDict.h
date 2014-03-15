//
//  AudioDict.h
//  dialogue
//
//  Created by yiplee on 13-8-27.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface AudioDict : NSObject
{
    NSMutableDictionary     *_avaliableWords;
    dispatch_queue_t        _avalibleQueue;
    
    NSMutableSet            *_loadedWords;
    dispatch_queue_t        _loadedQueue;
}

+ (AudioDict *) defaultAudioDict;

- (id) init;

- (NSString *) avaliabelWordsInfo;
- (NSString *) dumpCacheInfo;

- (void) refresh;
- (void) saveToFile;

- (void) readWord:(NSString *)word;
- (void) addWord:(NSString *)word audioFilePath:(NSString *)path;
- (void) removeWordFromAvaliableList:(NSString *)word;
- (void) removeWordsFromAvaliableList:(NSArray *)words;

- (BOOL) isWordAvaliable:(NSString *)word;
- (BOOL) isWordLoaded:(NSString *)word;

- (void) preloadWord:(NSString *)word;
- (void) preloadWords:(NSArray *)words;
- (void) unloadWord:(NSString *)word;
- (void) unloadAll;

@end


