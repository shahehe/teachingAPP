//
//  IntroLayer.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-3.
//  Copyright USTB 2013年. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "PGStageMenu.h"

#import "AudioDict.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init])) {

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"Default.png"];
			background.rotation = 90;
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		background.position = ccp(size.width/2, size.height/2);

		// add the label as a child to this Layer
		[self addChild: background];
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
    
    [AudioDict defaultAudioDict];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[PGStageMenu stageMenu]]];
}

- (void) dealloc
{
    [super dealloc];
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Default.png"];
    else
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Default-Landscape~ipad.png"];
}

@end
