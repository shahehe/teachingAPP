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

#import "Gardenlayer.h"
#import "RedRoomLayer.h"

#import "AnimatedSprite.h"

#import "PhonicsGames.h"

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
    
    // Garden
    CCMenuItem *item2 = [CCMenuItemFont itemWithString:@"Garden" block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[Gardenlayer scene]];
    }];
    // added by yiplee
    
    // red
    CCMenuItem *item3 = [CCMenuItemFont itemWithString:@"Red" block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[RedRoomLayer scene]];
    }];
    
    //games
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"gamedata" ofType:@"plist"];
    NSDictionary* gameData = [NSDictionary dictionaryWithContentsOfFile:dataPath];
    NSUInteger _capacity = PhonicsGameMaxIndex;
    NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:_capacity];
    [menuItems addObject:item1];
    [menuItems addObject:item2];
    [menuItems addObject:item3];
    
    for (int i = 0;i < _capacity;i++)
    {
        NSString *itemName = [NSString stringWithUTF8String:gameNames[i]];
        CCMenuItemFont *_item = [CCMenuItemFont itemWithString:itemName block:^(id sender) {
            [[PhonicsGames sharedGames] startGame:i data:gameData];
            CCLOG(@"launch game:%@",itemName);
        }];
        _item.color = ccWHITE;
        [menuItems addObject:_item];
    }
    

//    CCMenu *menu = [CCMenu menuWithItems:item1,item2, nil];
    CCMenu *menu = [CCMenu menuWithArray:menuItems];
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
