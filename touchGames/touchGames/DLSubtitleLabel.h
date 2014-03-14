//
//  DLSubtitleLabel.h
//  DLSubtitleLabel
//
//  Created by yiplee on 14-3-3.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol DLSubtitleLabelDelegate <NSObject>
@optional
- (void) subtitleLabelClickOnWord:(NSString*)word sender:(id)sender;

@end

@interface DLSubtitleLabel : CCLabelBMFont <CCTouchOneByOneDelegate>
{
    BOOL _touchEnable;
}

@property (nonatomic,assign) ccColor3B highlightedColor;
@property (nonatomic,assign,readwrite) BOOL touchEnable;

@property (nonatomic,assign) id<DLSubtitleLabelDelegate> delegate;

- (NSArray *) lettersWithWordIndex:(NSUInteger)index;

- (void) highlightedWordWithIndex:(NSUInteger)index;
- (void) unhighlightedWordWithIndex:(NSUInteger)index;

@end

@interface NSString (words)

- (NSArray *) wordsSeparatedByCharactersInSet:(NSCharacterSet*)set;

@end
