//
//  ImageCard.h
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ImageCard : CCSprite<CCTouchOneByOneDelegate>

@property(nonatomic,copy) NSString *word;
@property(nonatomic,retain,readonly) CCSprite *image;
@property(nonatomic,assign) CGPoint imagePosition;

+ (ImageCard*) imageCardWithWord:(NSString*)word;
- (id) initWithWord:(NSString*)word;

- (void) addImageToNode:(CCNode*)node position:(CGPoint)pos;
- (void) setCardClickBlock:(void (^)(id sender))block;

@end
