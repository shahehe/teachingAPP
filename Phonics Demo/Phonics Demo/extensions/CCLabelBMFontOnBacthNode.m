//
//   CCLabelBMFontOnBacthNode.m
//  Letter Games HD
//
//  Created by USTB on 12-11-28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CCLabelBMFontOnBacthNode.h"


@implementation CCLabelBMFont (AddToBatchNode)

-(void)addToBatchNode:(CCSpriteBatchNode *)batchnode zOrder:(int)order position:(CGPoint)position {
	for (int pos = self.children.count; pos > 0; --pos ) {
		CCSprite *node = [self.children objectAtIndex:pos-1];
        
		[node retain];
		[self removeChild:node cleanup:NO];
		[batchnode addChild:node z:order];
        
		[node setPosition:ccp(node.position.x+position.x-self.contentSize.width/2,
							  node.position.y+position.y-self.contentSize.height/2)];
        
		[node release];
	}
}

@end
