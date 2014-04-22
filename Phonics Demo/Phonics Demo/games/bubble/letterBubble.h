//
//  letterBubble.h
//  bubble
//
//  Created by yiplee on 13-4-1.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "bubble.h"

@interface letterBubble : bubble
@property(nonatomic,copy,readonly) NSString* letter;
- (id) initWithLetter:(NSString *)letter;
+ (letterBubble*) bubbleWithLetter:(NSString*)letter;

@end
