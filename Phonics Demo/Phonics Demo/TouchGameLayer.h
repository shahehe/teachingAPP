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

#import "TouchingGameMenu.h"

@interface GameObject : CCSprite<CCTouchOneByOneDelegate>
{
    NSString *_name;
    NSString *_content;
    NSString *_audioFileName;
    
    void (^_block)(id sender);
}

@property (nonatomic,copy) NSString *name;
// 携带的内容
@property (nonatomic,copy) NSString *content;

// 音频文件名称
@property (nonatomic,copy) NSString *audioFileName;

@property (nonatomic,assign) CGRect touchRect;

+ (GameObject *) objectWithFile:(NSString*)file content:(NSString*)content audioFileName:(NSString*)audio;
- (id) initWithFile:(NSString*)file content:(NSString*)content audioFileName:(NSString*)audio;

- (void) setBlock:(void (^)(id sender))block;

@end


@interface TouchGameLayer : CCLayer <DLSubtitleLabelDelegate,CDLongAudioSourceDelegate>
{
    
}

+ (TouchGameLayer *) gameLayerWithGameData:(NSDictionary*)dic;

- (id) initWithGameData:(NSDictionary*)dic;

- (void) objectHasBeenClicked:(GameObject *)object;

@end
