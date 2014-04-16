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

- (void) highlightWordWithIndex:(NSUInteger)index;
- (void) unhighlightWordWithIndex:(NSUInteger)index;

- (void) highlightFirstLetterOfWord:(NSString*)word color:(ccColor3B)color;

@end

@interface NSString (words)

- (NSArray *) wordsSeparatedByCharactersInSet:(NSCharacterSet*)set;

@end
