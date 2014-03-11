//
//  HelloWorldLayer.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-3.
//  Copyright USTB 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "PhonicsDefines.h"

#import "IntroLayer.h"

#import "Cocos2d+CustomOptions.h"
#import "CLDynamicLabel.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"letter_identification_bgimage_a.pvr.ccz"];
        background.position = ccpMult(SCREEN_SIZE_AS_POINT, 0.5);
        [background setFrame:self.boundingBox];
        [self addChild:background z:-1];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
		
		CGSize size = SCREEN_SIZE;
        
		CLDynamicLabel *lable = [CLDynamicLabel labelWithString:@" " fntFile:@"ahnbergh.fnt"];
        lable.anchorPoint = ccp(0, 1);
        lable.position = ccpCompMult(SCREEN_SIZE_AS_POINT, ccp(0.05, 0.8));
        [self addChild:lable];
        
        lable.interval = 0.3;
        lable.appearMode = CLLableAppearModePerCharacter;
        [lable setPlayCompletionBlock:^(id sender) {
            SLLog(@"play done");
        }];
        
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// to avoid a retain-cycle with the menuitem and blocks
//		__block id copy_self = self;
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Start" block:^(id sender) {
			[lable playWithString:@"Yes apple \nstarts with the letter A , \nThis is a big A\n Can you say A !"];
		}];
		
		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Pause" block:^(id sender) {
			[lable pause];
			
		}];
        
        CCMenuItem *play = [CCMenuItemFont itemWithString:@"Play" block:^(id sender) {
			[lable play];
			
		}];
        
        CCMenuItem *stop = [CCMenuItemFont itemWithString:@"Stop" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[[self class] scene]];
			
		}];

		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, play,itemLeaderboard,stop, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 100)];
		
		// Add the menu to the layer
		[self addChild:menu];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
