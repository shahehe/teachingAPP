//
//  DLSubtitleLabel.m
//  DLSubtitleLabel
//
//  Created by yiplee on 14-3-3.
//  Copyright 2014年 yiplee. All rights reserved.
//

// to enable audio dic ,set the value bigger than Zero
#define __AUDIO_DICT_INTEGRATE_ 0

#if __AUDIO_DICT_INTEGRATE_ > 0
#define __AUDIO_DICT_
#endif

#import "DLSubtitleLabel.h"

#ifdef __AUDIO_DICT_
#import "AudioDict.h"
#endif

static char *const punctuations = " ,.:""''!?-(){}[];<>/_";

@implementation DLSubtitleLabel
{
    NSRange *_wordRanges;
    CGRect  *_wordRects;
    
    NSUInteger _numberOfWords;
    NSUInteger _indexOfHighlightedWord;
}

-(id) initWithString:(NSString*)theString fntFile:(NSString*)fntFile width:(float)width alignment:(CCTextAlignment)alignment imageOffset:(CGPoint)offset
{
    if (self = [super initWithString:theString fntFile:fntFile width:width alignment:alignment imageOffset:offset])
    {
        [self creatWordRangesAndRects];
        
        _touchEnable = NO;
        _highlightedColor = ccRED;
        
        _indexOfHighlightedWord = NSNotFound;
        _delegate = nil;
    }
    return self;
}

- (void) dealloc
{
    free(_wordRanges);
    free(_wordRects);
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [super dealloc];
}

- (void) creatWordRangesAndRects
{
    NSString *characters = [NSString stringWithUTF8String:punctuations];
    NSCharacterSet *_set = [NSCharacterSet characterSetWithCharactersInString:characters];
    
    NSString *content = [self.string stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSArray *words = [content wordsSeparatedByCharactersInSet:_set];
    
    [self loadAudioFileOfWords:words];
    
    _numberOfWords = [words count];
    
    free(_wordRanges);
    _wordRanges = calloc(sizeof(NSRange)*_numberOfWords, 1);
    
    NSRange searchRange = NSMakeRange(0, content.length);
    for (int i = 0;i < _numberOfWords;i++)
    {
        NSString *word = [words objectAtIndex:i];
        _wordRanges[i] = [content rangeOfString:word options:NSLiteralSearch range:searchRange];
        searchRange.location = _wordRanges[i].location + _wordRanges[i].length;
        searchRange.length = content.length - searchRange.location;
    }
    
    free(_wordRects);
    _wordRects = calloc(sizeof(CGRect)*_numberOfWords, 1);
    
    CGRect rect;
    CGPoint p1,p2;
    for (int i = 0;i < _numberOfWords;i++)
    {
        NSArray *letters = [self childrenInRange:_wordRanges[i]];
        
        CCSprite *s = [letters objectAtIndex:0];
        p1.x = CGRectGetMinX(s.boundingBox);
        p1.y = CGRectGetMinY(s.boundingBox);
        s = [letters lastObject];
        p2.x = CGRectGetMaxX(s.boundingBox);
        p2.y = CGRectGetMaxY(s.boundingBox);
        
        for (s in letters)
        {
            CGFloat y1 = CGRectGetMinY(s.boundingBox);
            if (p1.y > y1) p1.y = y1;
            
            CGFloat y2 = CGRectGetMaxY(s.boundingBox);
            if (p2.y < y2) p2.y = y2;
        }
        
        rect.origin = p1;
        rect.size = CGSizeMake(p2.x-p1.x, p2.y-p1.y);
        
        _wordRects[i] = rect;
    }
}

- (void) setString:(NSString *)label
{
    [super setString:label];
    
    [self creatWordRangesAndRects];
}

- (void) setScale:(float)scale
{
    [super setScale:scale];
    
    [self creatWordRangesAndRects];
}

- (void) setRotation:(float)rotation
{
    // do nothing
    CCLOGWARN(@"You are attempting to rotate the subtitleLabel and the operation has been rejected");
}

- (BOOL) touchEnable
{
    return _touchEnable;
}

- (void) setTouchEnable:(BOOL)touchEnable
{
    if (_touchEnable == touchEnable)
        return;
    
    _touchEnable = touchEnable;
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    if (_touchEnable)
    {
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
}

- (NSArray *) childrenInRange:(NSRange)range
{
    CCArray *chidren = self.children;
    NSUInteger count = [chidren count];
    
    NSRange origin   = NSMakeRange(0, count);
    NSRange newRange = NSIntersectionRange(range, origin);
    
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:newRange.length];
    for (int i = newRange.location;i < newRange.location+newRange.length;i++)
    {
        [newArray addObject:[chidren objectAtIndex:i]];
    }
    return newArray;
}

- (NSArray *) lettersWithWordIndex:(NSUInteger)index
{
    NSAssert(index < _numberOfWords, @"out of range");
    NSRange range = _wordRanges[index];
    
    return [self childrenInRange:range];
}

- (NSUInteger) indexOfWordAtLocation:(CGPoint)location
{
    NSUInteger index = NSNotFound;
    for (int i = 0;i < _numberOfWords;i++)
    {
        if (CGRectContainsPoint(_wordRects[i], location))
        {
            index = i;
            break;
        }
    }
    return index;
}

- (NSRange) rangeOfWordAtLocation:(CGPoint)location
{
    NSUInteger index = [self indexOfWordAtLocation:location];
    
    if (index != NSNotFound)
    {
        return _wordRanges[index];
    }
    else return NSMakeRange(0, 0);
}

- (NSString*) stringWithRange:(NSRange)range
{
    return [self.string substringWithRange:range];
}

- (void) highlightedWordWithIndex:(NSUInteger)index
{
    NSArray *letters = [self lettersWithWordIndex:index];
    for (CCSprite* letter in letters)
    {
        letter.color = _highlightedColor;
    }
}

- (void) unhighlightedWordWithIndex:(NSUInteger)index
{
    NSArray *letters = [self lettersWithWordIndex:index];
    for (CCSprite* letter in letters)
    {
        letter.color = self.color;
    }
}

- (void) touchAtPosition:(CGPoint)position
{
    NSUInteger index = [self indexOfWordAtLocation:position];
    
    if (index != _indexOfHighlightedWord && _indexOfHighlightedWord != NSNotFound)
    {
        [self unhighlightedWordWithIndex:_indexOfHighlightedWord];
    }
    
    if (index != NSNotFound)
    {
        [self highlightedWordWithIndex:index];
    }
    
    _indexOfHighlightedWord = index;
}

#pragma mark --audio dict

- (void) loadAudioFileOfWords:(NSArray*)words
{
#ifdef __AUDIO_DICT_
    [[AudioDict defaultAudioDict] preloadWords:words];
#endif
}

#pragma mark --CCTouchOneByOneDelegate

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    CGRect rect = self.boundingBox;
    rect.origin = CGPointZero;
    
    if (!CGRectContainsPoint(rect, location))
    {
        return NO;
    }
    
    [self touchAtPosition:location];
    
    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    [self touchAtPosition:location];
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_indexOfHighlightedWord != NSNotFound)
    {
        [self unhighlightedWordWithIndex:_indexOfHighlightedWord];
        
        if ([_delegate respondsToSelector:@selector(subtitleLabelClickOnWord:sender:)])
        {
            NSString *word = [self stringWithRange:_wordRanges[_indexOfHighlightedWord]];
            [_delegate subtitleLabelClickOnWord:word sender:self];
            
#ifdef __AUDIO_DICT_
            [[AudioDict defaultAudioDict] readWord:word];
#endif
        }
        _indexOfHighlightedWord = NSNotFound;
    }
    
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_indexOfHighlightedWord != NSNotFound)
    {
        [self unhighlightedWordWithIndex:_indexOfHighlightedWord];
        _indexOfHighlightedWord = NSNotFound;
    }
}

@end

@implementation NSString (words)

- (NSArray *) wordsSeparatedByCharactersInSet:(NSCharacterSet*) set
{
    NSArray *t_words = [self componentsSeparatedByCharactersInSet:set];
    
    // remove empty words
    NSMutableArray *words = [NSMutableArray array];
    for (NSString *word in t_words)
    {
        if (word.length > 0)
            [words addObject:word];
    }
    
    return words;
}

@end
