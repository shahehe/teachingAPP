//
//  DialogVideo.m
//  Phonics Demo
//
//  Created by Yan Feng on 10/1/13.
//  Copyright 2013 USTB. All rights reserved.
//

#import "DialogVideo.h"


@implementation DialogVideo
//Your delegate class should conform to CCVideoPlayerDelegate and implement these methods:
-(id) initWithFile:(NSString *)filename
{
    if( (self=[super init])) {
        [CCVideoPlayer setDelegate:self];
        [CCVideoPlayer setNoSkip:NO];
        [CCVideoPlayer playMovieWithFile:filename];
        
    }
    return self;
}
-(id) init

{
    
    // always call “super” init
    
    // Apple recommends to re-assign “self” with the “super” return value
    
    if( (self=[super init])) {
        [CCVideoPlayer setDelegate:self];
        [CCVideoPlayer setNoSkip:NO];
        //[CCVideoPlayer playMovieWithFile:@"video.mp4"];
        [CCVideoPlayer playMovieWithFile:@"hd.mov"];
        
    }
    
    return self;
    
}

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	DialogVideo *layer = [DialogVideo node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) moviePlaybackFinished

{

    NSLog(@"movie back finished");
    
    [[CCDirector sharedDirector] startAnimation];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void) movieStartsPlaying

{
    
    NSLog(@"movie start play");
    
    [[CCDirector sharedDirector] stopAnimation];
    
}@end
