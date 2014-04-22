//
//  TouchGameLayer.h
//  touchGames
//
//  Created by yiplee on 14-3-13.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "DLSubtitleLabel.h"
#import "SimpleAudioEngine.h"

@interface GameObject : CCSprite<CCTouchOneByOneDelegate>
{
    NSString *_name;
    NSString *_content;
    NSString *_audioFileName;
    CGRect _touchRect;
}

@property (nonatomic,copy) NSString *name;
// 携带的内容
@property (nonatomic,copy) NSString *content;
// 音频文件名称
@property (nonatomic,copy) NSString *audioFileName;
@property (nonatomic,assign) CGRect touchRect;

+ (GameObject *) objectWithFile:(NSString*)file content:(NSString*)content audioFileName:(NSString*)audio;
- (id) initWithFile:(NSString*)file content:(NSString*)content audioFileName:(NSString*)audio;

@end

typedef enum : NSUInteger {
    GameModeOneByOne = 0,
    GameModeAllAtOnce = 1,
    GameModeDefault = GameModeOneByOne
} TouchGameMode;

////////////////////////////////////////
void unblinkSprite(CCSprite *t);
void blinkSprite(CCSprite *t);
////////////////////////////////////////

@interface TouchGameLayer : CCLayer <DLSubtitleLabelDelegate,CDLongAudioSourceDelegate>
{
    void (^_objectLoaded)(GameObject *object);
    void (^_objectActived)(GameObject *object);
    void (^_objectClicked)(GameObject *object);
    
    BOOL _autoActiveNext;
}

@property (nonatomic,copy,readonly) NSString *gameTitle;
@property (nonatomic,assign) TouchGameMode gameMode;
@property (nonatomic,readonly) GameObject *runningObject;
@property (nonatomic,assign) BOOL autoActiveNext;

+ (TouchGameLayer *) gameLayerWithGameData:(NSDictionary*)dic;
- (id) initWithGameData:(NSDictionary*)dic;
- (BOOL) objectHasBeenClicked:(GameObject *)object;

- (void) cleanCache;

- (NSUInteger) objectCount;
- (GameObject *) gameObjectAtIndex:(NSInteger)idx;

- (void) activeNextObjects;

- (DLSubtitleLabel*) contentLabel;

// action
- (void) setObjectLoadedBlock:(void (^)(GameObject *object))block;
- (void) setObjectActivedBlock:(void (^)(GameObject *object))block;
- (void) setObjectCLickedBlock:(void (^)(GameObject *object))block;

- (void) contentDidFinishReading:(GameObject*)object;

@end
