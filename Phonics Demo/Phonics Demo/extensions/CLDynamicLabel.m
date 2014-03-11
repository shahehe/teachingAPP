//
//  CLDynamicLable.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-25.
//  Copyright 2013年 USTB. All rights reserved.
//

#import "CLDynamicLabel.h"

@interface CLDynamicLabel ()
{
    ccTime tickTime;
    
    // Play Completion Block
    void (^_block)(id sender);
    
    NSString *stringFormat;
}

@property (nonatomic,retain) CCArray *words;

@end

@implementation CLDynamicLabel

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset
{
    if (self = [super initWithString:theString fntFile:fntFile width:width alignment:alignment imageOffset:offset])
    {
        _interval = 0.3f;
        
        tickTime = 0;
        
        self.words = [CCArray array];
        
        _appearMode = CLLableAppearModeDefault;
        stringFormat = @"%@ %@";
        
        _block = nil;
        
        [self scheduleUpdate];
    }
    return self;
}

- (void) update:(ccTime)delta
{
    tickTime += delta;
    
    if (tickTime > _interval)
    {
        tickTime = 0;
        
        if ([_words count] > 0)
        {
            NSString *tempWord = [_words objectAtIndex:0];
            if (self.string.length == 0) self.string = tempWord;
            else self.string = [NSString stringWithFormat:stringFormat,self.string,tempWord];
            [_words removeObjectAtIndex:0];
        }
        else
        {
            [self pause];
            if (_block) _block(self);
        }
    }
}

- (void) setInterval:(ccTime)interval
{
    NSAssert(interval > 0, @"CLDynamicLable:interval must be positive");
    
    _interval = interval;
}

#pragma mark --control

- (void) setAppearMode:(CLLableAppearMode)appearMode
{
    _appearMode = appearMode;
    
    if (appearMode == CLLableAppearModePerCharacter)
        stringFormat = @"%@%@";
    else stringFormat = @"%@ %@";
}

- (void) play
{
    _isPlaying = YES;
    [self unscheduleUpdate];
    [self scheduleUpdate];
}

- (void) pause
{
    _isPlaying = NO;
    [self unscheduleUpdate];
}

- (void) stop
{
    _isPlaying = NO;
    tickTime = _interval;
    
    [_words removeAllObjects];
    
    Block_release(_block);
    _block = nil;
}

- (void) playWithString:(NSString *)string
{
    self.string = @"";
    [self stop];
    
    [_words addObjectsFromArray:[self arrayWithString:string mode:_appearMode]];
    
    [self play];
}

- (void) playWithAdditionalString:(NSString *)string
{
    [_words addObjectsFromArray:[self arrayWithString:string mode:_appearMode]];
    
    if (!self.isPlaying)
    {
        tickTime = _interval;
        [self play];
    }
}

- (CCArray*) arrayWithString:(NSString*)string mode:(CLLableAppearMode)mode
{
    CCArray *array = nil;
    
    switch (mode) {
        case CLLableAppearModePerWord:
            array = [CCArray arrayWithNSArray:[string componentsSeparatedByString:@" "]];
            break;
        case CLLableAppearModeOnce:
            array = [CCArray arrayWithNSArray:[NSArray arrayWithObject:string]];
            break;
        case CLLableAppearModePerCharacter:
            array = [string componentsDivideByCharacter];
            break;
        default:
            break;
    }
    
    return array;
}

#pragma mark --event

- (void) setPlayCompletionBlock:(void (^)(id))block
{
    Block_release(_block);
    _block = nil;
    if (block)
        _block = Block_copy(block);
}

#pragma mark --dealloc

- (void) dealloc
{
    [self unscheduleUpdate];
    Block_release(_block);
    
    [_words release];
    _words = nil;
    
    [stringFormat release];
    
    [super dealloc];
}

@end

@implementation NSString (Character)

- (CCArray*) componentsDivideByCharacter
{
    NSUInteger length = self.length;
    
    const char *str = [self UTF8String];
    
    CCArray *array = [CCArray arrayWithCapacity:length];
    
    int i = 0;
    for (;i < length;i++)
    {
        [array addObject:[NSString stringWithFormat:@"%c",str[i]]];
    }
    
    return array;
}

@end
