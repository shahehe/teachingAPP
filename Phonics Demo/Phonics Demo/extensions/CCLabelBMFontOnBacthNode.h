//
//   CCLabelBMFontOnBacthNode.h
//  Letter Games HD
//
//  Created by USTB on 12-11-28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLabelBMFont (AddToBatchNode)

-(void)addToBatchNode:(CCSpriteBatchNode *)batchnode zOrder:(int)order position:(CGPoint)position;

@end