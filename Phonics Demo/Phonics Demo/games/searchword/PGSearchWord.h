//
//  PGSearchWord.h
//  Phonics Games
//
//  Created by yiplee on 14-4-5.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "SimpleAudioEngine.h"

@interface PGSearchWord : CCLayer<CDLongAudioSourceDelegate>

@property (nonatomic,copy,readonly) NSString *gameName;
@property (nonatomic,retain) NSArray *words;
@property (nonatomic,copy,readonly) NSString *currentWord;

+ (CCScene*) gameWithWords:(NSArray*)words panelSize:(CGSize)pSize gridSize:(CGSize)gSize;
- (id) initWithWords:(NSArray*)words panelSize:(CGSize)pSize gridSize:(CGSize)gSize;

@end

@interface NSString  (yipleeInSearchWord)

/*
 //  检查一个单词是否可以放进一行字母里面去
 //  如果检测到可以放进去的情况，就返回单词第一个字母的位置
 //  正向返回正值，反向返回负值
 //  如果放不进去，则返回0
 */
- (int) insertIntoString:(NSString *) string enableBackward:(BOOL) enableBackward;

/*
 //  return a random character of String
 */
- (char) randomCharacter;

@end
