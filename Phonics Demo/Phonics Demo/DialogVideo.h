//
//  DialogVideo.h
//  Phonics Demo
//
//  Created by Yan Feng on 10/1/13.
//  Copyright 2013 USTB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCVideoPlayer.h"
#import "DialogContentLayer.h"

@interface DialogVideo : CCLayer <CCVideoPlayerDelegate>{
    
}
// returns a CCScene that contains the HelloWorldLayer as the only child
-(id) initWithFile:(NSString *)filename;
+(CCScene *) scene;

@end
