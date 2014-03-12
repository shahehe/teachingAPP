//
//  PhonicsGameLayer.h
//  little games
//
//  Created by yiplee on 14-2-19.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PhonicsGameLayer : CCLayer {
    
    NSDictionary *_gameData;
}

@property (nonatomic,retain) NSDictionary* gameData;

+ (CCScene *) gameWithData:(NSDictionary*)data;

- (id) initWithGameData:(NSDictionary *)data;

@end
