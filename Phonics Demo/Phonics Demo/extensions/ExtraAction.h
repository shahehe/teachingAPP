//
//  ExtraAction.h
//  BookReader
//
//  Created by USTB on 12-11-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ExtraAction : NSObject {
    
}

@end

@interface CCNode (yipleeAction)

- (void) shakeWithRound:(NSUInteger) round;

@end