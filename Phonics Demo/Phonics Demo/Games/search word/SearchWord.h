//
//  SearchWordGameLayer.h
//  BookReader
//
//  Created by USTB on 12-10-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "cocos2d.h"
#import "GradientLabel.h"
#import "CCLinePro.h"
#import "FreeMoveObject.h"
#import "Tiger.h"
#import "CCLabelBMFontOnBacthNode.h"

#import "PhonicsGameLayer.h"

enum LabelTag
{
    PanelTag = 0,
    LetterTag,
    WordTag,
};

enum Direction
{
    Vertical = 0,
    Horizontal,
    DiagonalUp, //  斜向上
    DiagonalDown    //  斜向下
};

@interface SearchWord : PhonicsGameLayer <AVAudioPlayerDelegate>
{
    //  待选择的单词
    CCArray *words;
    NSUInteger wordsNotInsert;
    
    // labels
    CCArray *letterLabels;
    
    //letter
    
    //  default:300x360 (10x12) grid:30x30
    CGFloat _panelWidth;
    CGFloat _panelHeight;
    
    NSUInteger _gridWidth;
    NSUInteger _gridHeight;
    
    CGFloat _letterSize;
    CGFloat _wordSize;
    
    //direction
    BOOL enableVertical;
    BOOL enableHorizontal;
    BOOL enableDiagonalUp;
    BOOL enableDiagonalDown;
    BOOL enableBackward;
    
    //game
    NSInteger gameIndex;
    GradientLabel *wordLabel;
    CCArray *choosedLabels;
    NSString *_choosedString;
    NSInteger firstIndex;
    NSInteger lastIndex;
    
    BOOL isLevelDone;
    
    //color
    ccColor3B originColor;
    ccColor3B coverColor;
    
    //player
    AVAudioPlayer *_player;
    
    //line
    CCLinePro *currentLine;    //weak ref
    
    //board
    CCSprite *board;    //weak ref
    
    //cat
    Tiger *cat;      //weak ref
    
    //insect
    FreeMoveObject *insect; //weak ref
    
    //word board
    CCSprite *wordBoard;
    CCLabelTTF *wordBoardLabel; //weak ref
    
    //font batch node
    CCSpriteBatchNode *letterNode;
}

@property (nonatomic,readwrite) CGFloat panelWidth;
@property (nonatomic,readwrite) CGFloat panelHeight;
@property (nonatomic,readwrite) NSUInteger gridWidth;
@property (nonatomic,readwrite) NSUInteger gridHeght;

@property (nonatomic,copy) NSString *choosedString;

@property(nonatomic,assign) AVAudioPlayer *player;

+ (CCScene *) scene;


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

