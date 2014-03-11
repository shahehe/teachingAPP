//
//  MainMenu.m
//  Phonics Demo
//
//  Created by yiplee on 13-7-26.
//  Copyright 2013年 USTB. All rights reserved.
//

#import "MainMenu.h"

#import "HelloWorldLayer.h"
#import "Dialog.h"
#import "DialogVideo.h"

#import "AnimatedSprite.h"
@implementation MainMenu

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    [scene addChild:[[self class] node]];
    return scene;
}

- (id) init
{
    self = [super init];
    if (self == nil) return nil;
    
    RGB565
    NSString *fileName = @"letter_identification_bgimage_a.pvr.ccz";
    [self addBackgroundImageWithFile:fileName fitScreen:YES];
    RGBA8888
    
    [[[CCDirector sharedDirector] touchDispatcher] removeAllDelegates];
    
    [CCMenuItemFont setFontSize:32];
    [CCMenuItemFont setFontName: @"Courier New"];

    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"认识字母"
        block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:
                [Dialog dialogWithContentLayerType:DialogContentTypeLetterIdentification letter:'A']];
    }];

    CCMenu *menu = [CCMenu menuWithItems:item1, nil];
    [menu alignItemsVerticallyWithPadding:20];

    menu.position = ccpMult(SCREEN_SIZE_AS_POINT, 0.5);
    [self addChild:menu];

        return self;

}
- (void) loadSpritesheet:(NSString *)spritesheetName {
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
    NSString *pvrccz = [NSString stringWithFormat:@"%@.pvr.ccz", spritesheetName];
    CCSpriteBatchNode *loadingBatchNode = [CCSpriteBatchNode batchNodeWithFile:pvrccz];
    [self addChild:loadingBatchNode z:2];
    NSString *plist = [NSString stringWithFormat:@"%@.plist", spritesheetName];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plist];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
}
- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [CCLabelBMFont purgeCachedData];
}

-(void) delete:(id)sender
{
    [[[CCDirector sharedDirector] touchDispatcher] removeAllDelegates];
}


@end
