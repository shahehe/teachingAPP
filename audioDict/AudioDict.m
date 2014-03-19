//
//  AudioDict.m
//  dialogue
//
//  Created by yiplee on 13-8-27.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "AudioDict.h"
#import "SimpleAudioEngine.h"

static char *const audioDicFileName   = "audioDic.plist";
static char *const audioDicPath       = "data/audioDic";

#define APP_DOCUMENT_PATH       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0]

@implementation AudioDict

+ (AudioDict *)defaultAudioDict
{
    static dispatch_once_t pred;
    static AudioDict *instance = nil;
    
    dispatch_once(&pred,^{
        instance = [[AudioDict alloc] init];
    });
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        NSString *fileName = [NSString stringWithUTF8String: audioDicFileName];
        NSString *filePath = [APP_DOCUMENT_PATH stringByAppendingPathComponent:fileName];
        BOOL isExist       = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        
        _avaliableWords    = [[NSMutableDictionary alloc] init];
        _avalibleQueue     = dispatch_queue_create("com.yiplee.avalibleSoundEffect",NULL);
        
        if (!isExist)
        {
            [self refresh];
        }
        else
        {
            NSDictionary *backup = [NSDictionary dictionaryWithContentsOfFile:filePath];
            [_avaliableWords addEntriesFromDictionary:backup];
        }
        
        _loadedWords = [[NSMutableSet alloc] init];
        _loadedQueue = dispatch_queue_create("com.yiplee.loadedSoundEffect",NULL);
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    dispatch_sync(_avalibleQueue, ^{
        [_avaliableWords release];
    });
    
    dispatch_sync(_loadedQueue, ^{
        [_loadedWords release];
    });
    
    dispatch_release(_loadedQueue);
    dispatch_release(_avalibleQueue);
}

- (NSString *) avaliabelWordsInfo
{
    __block NSString *info = nil;
    dispatch_sync(_avalibleQueue, ^{
        info = [NSString stringWithFormat:@"avaliable words:\n%@",[_avaliableWords   description]];
    });
    return info;
}

- (NSString *) dumpCacheInfo
{
    __block NSString *info = nil;
    dispatch_sync(_loadedQueue, ^{
        info = [NSString stringWithFormat:@"loaded words:\n%@",[_loadedWords description]];
    });
    return info;
}

- (void) refresh
{
    NSString *sourcePath = [NSString stringWithUTF8String:audioDicPath];
    NSString *fullPath = nil;
    fullPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:sourcePath];
    
    NSError *error = nil;
    NSArray *audioFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:&error];
    
    if (error)
    {
        CCLOG(@"audio dic refresh error:\n%@",error);
        return;
    }
    
    for (NSString *audioFile in audioFiles)
    {
        if ([audioFile hasSuffix:@".caf"] || [audioFile hasSuffix:@".wav"] || [audioFile hasSuffix:@".mp3"])
        {
            NSString *word = [[audioFile stringByDeletingPathExtension] lowercaseString];
            NSString *audioPath = [sourcePath stringByAppendingPathComponent:audioFile];
            dispatch_sync(_avalibleQueue, ^{
                [_avaliableWords setValue:audioPath forKey:word];
            });
        }
    }
}

- (void) saveToFile
{
    NSString *fileName = [NSString stringWithUTF8String:audioDicFileName];
    NSString *filePath = [APP_DOCUMENT_PATH stringByAppendingPathComponent:fileName];
    
    dispatch_async(_avalibleQueue, ^{
        [_avaliableWords writeToFile:filePath atomically:YES];
    });
}

- (void) readWord:(NSString *)word
{
    NSString *_word = [word lowercaseString];
    __block NSString *_audioPath = nil;
    dispatch_sync(_avalibleQueue, ^{
        _audioPath = [[_avaliableWords valueForKey:_word] copy];
    });
    
    if (!_audioPath)
    {
        return;
    }
    
    if (![self isWordLoaded:_word])
    {
        [self preloadWord:_word];
    }
    
    [[SimpleAudioEngine sharedEngine] playEffect:_audioPath];
    [_audioPath autorelease];
}

- (BOOL) isWordAvaliable:(NSString *)word
{
    NSString *_word = [word lowercaseString];
    __block BOOL isContain = NO;
    dispatch_sync(_avalibleQueue, ^{
        isContain = [[_avaliableWords allKeys] containsObject:_word];
    });
    return isContain;
}

- (void) addWord:(NSString *)word audioFilePath:(NSString *)path
{
    dispatch_sync(_avalibleQueue, ^{
        [_avaliableWords setValue:path forKey:[word lowercaseString]];
    });
}

- (void) removeWordFromAvaliableList:(NSString *)word
{
    NSString *_word = [word lowercaseString];
    dispatch_sync(_avalibleQueue, ^{
        [_avaliableWords removeObjectForKey:_word];
    });
}

- (void) removeWordsFromAvaliableList:(NSArray *)words
{
    NSSet *set = [NSSet setWithArray:words];
    for (NSString *_word in set)
    {
        [self removeWordFromAvaliableList:_word];
    }
}

- (BOOL) isWordLoaded:(NSString *)word
{
    NSString *_word = [word lowercaseString];
    __block BOOL isLoaded = NO;
    dispatch_sync(_loadedQueue, ^{
        isLoaded = [_loadedWords containsObject:_word];
    });
    return isLoaded;
}

- (void) preloadWord:(NSString *)word
{
    NSString *_word = [word lowercaseString];
    __block NSString *_audioPath = nil;
    dispatch_sync(_avalibleQueue, ^{
        _audioPath = [_avaliableWords valueForKey:_word];
    });
    
    if (_audioPath == nil)
        return;
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:_audioPath];
    
    dispatch_sync(_loadedQueue, ^{
        [_loadedWords addObject:_word];
    });
}

- (void) preloadWords:(NSArray *)words
{
    NSSet *set = [NSSet setWithArray:words];
    for (NSString *word in set)
    {
        [self preloadWord:word];
    }
}

- (void) unloadWord:(NSString *)word
{
    NSString *_word = [word lowercaseString];
    if (![self isWordLoaded:_word])
        return;
    
    __block NSString *_audioPath = nil;
    dispatch_sync(_avalibleQueue, ^{
        _audioPath = [_avaliableWords valueForKey:_word];
    });
    
    [[SimpleAudioEngine sharedEngine] unloadEffect:_audioPath];
    dispatch_sync(_loadedQueue, ^{
        [_loadedWords removeObject:_word];
    });
}

- (void) unloadAll
{
    __block NSSet *set = nil;
    
    dispatch_sync(_loadedQueue, ^{
        set = [NSSet setWithSet:_loadedWords];
        [_loadedWords removeAllObjects];
    });
    
    for (NSString *_word in set)
    {
        __block NSString *_audioPath = nil;
        dispatch_sync(_avalibleQueue, ^{
            _audioPath = [_avaliableWords valueForKey:_word];
        });
        [[SimpleAudioEngine sharedEngine] unloadEffect:_audioPath];
    }
}

@end
