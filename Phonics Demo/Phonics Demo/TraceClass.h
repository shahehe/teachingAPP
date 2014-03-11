//
//  TraceClass.h
//  newtrace
//
//  Created by Richard Guan on 10/2/13.
//  Copyright 2013 Yan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TraceClass : CCNode {
    
}

-(id)   initWithPositionX: (int) positionX
                PositionY: (int) positionY
                    Scale: (float) scale
                     Name: (NSString *) name;


-(BOOL) pointIsOutOfTheBound:(CGPoint)  point;

@end
