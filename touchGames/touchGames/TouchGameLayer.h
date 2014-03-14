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

@interface TouchGameLayer : CCLayer <DLSubtitleLabelDelegate,CDLongAudioSourceDelegate>
{
    
}

+ (TouchGameLayer *) gameLayerWithGameData:(NSDictionary*)dic;

- (id) initWithGameData:(NSDictionary*)dic;

@end
