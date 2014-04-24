//
//  PGLetterMenu.m
//  LetterE
//
//  Created by yiplee on 14-4-22.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "PGLetterMenu.h"
#import "ImageMatch.h"
#import "GooseGame.h"

#import "Dialog.h"

#import "PGGameListMenu.h"

#import "config.h"
#import "TouchGameLayer.h"

#import "TouchGameISee.h"
#import "TouchGameJar.h"
#import "TouchGamePlease.h"
#import "TouchGameTime.h"
#import "TouchGameKiss.h"
#import "TouchGameBabyToy.h"
#import "TouchGameRed.h"
#import "TouchGameFound.h"
#import "TouchGameVeryGood.h"
#import "TouchGameLook.h"
#import "TouchGameWill.h"
#import "TouchGameYellow.h"
#import "TouchGameZoo.h"
#import "TouchGameWhere.h"
#import "TouchGameNotFood.h"
#import "TouchGameSix.h"

static char *const storys[] =
{
    "A",
    "TouchGameBabyToy",
    "C",
    "D",
    "E",
    "TouchGameFound",
    "G",
    "H",
    "I",
    "TouchGameJar",
    "TouchGameKiss",
    "TouchGameLook",
    "M",
    "TouchGameNotFood",
    "O",
    "TouchGamePlease",
    "TouchGameWill",
    "TouchGameRed",
    "TouchGameISee",
    "TouchGameTime",
    "U",
    "TouchGameVeryGood",
    "TouchGameWhere",
    "TouchGameSix",
    "TouchGameYellow",
    "TouchGameZoo"
};

@implementation PGLetterMenu

+ (CCScene *) menuWithLetter:(char)letter
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [[[[self class] alloc] initWithLetter:letter] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithLetter:(char)letter
{
    self = [super init];
    
    NSString *font = @"Avenir-BlackOblique";
    //title
    {
        NSString *l = [NSString stringWithFormat:@"%c",letter];
        CCLabelTTF *title = [CCLabelTTF labelWithString:l fontName:font fontSize:64];
        title.color = ccWHITE;
        title.position = CCMP(0.5, 0.8);
        [self addChild:title];
    }
    
    [CCMenuItemFont setFontName:font];
    
    CCMenuItemFont *dialog = [CCMenuItemFont itemWithString:@"dialog" block:^(id sender) {
        CCScene *scene = [Dialog dialogWithContentLayerType:DialogContentTypeLetterIdentification letter:letter];
        [[CCDirector sharedDirector] pushScene:scene];
    }];
    NSString * className = @"LetterIdentification";
    className = [className stringByAppendingString:[NSString stringWithFormat:@"%c", letter]];
    Class letterId = NSClassFromString(className);
    if ( !letterId )
    {
        dialog.isEnabled = NO;
    }
    
    CCMenuItemFont *vocabulary = [CCMenuItemFont itemWithString:@"vocabulary" block:^(id sender) {
        CCScene *game = [ImageMatch gameSceneWithWords:@[@"horse",@"hog",@"house",@"hen"]];
        [[CCDirector sharedDirector] pushScene:game];
    }];
    vocabulary.color = ccWHITE;
    
    NSString *storyName = [NSString stringWithUTF8String:storys[letter-'A']];
    CCMenuItemFont *story = [CCMenuItemFont itemWithString:@"story" block:^(id sender) {
        Class story = NSClassFromString(storyName);
        CCScene *scene = [story performSelector:@selector(gameLayer)];
        [[CCDirector sharedDirector] pushScene:scene];
    }];
    story.color = ccWHITE;
    story.isEnabled = storyName.length > 1 ? YES : NO;
    
    CCMenuItemFont *game = [CCMenuItemFont itemWithString:@"game" block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[PGGameListMenu menuWithLetter:letter]];
    }];
    game.color = ccWHITE;
    
    CCMenuItemFont *review = [CCMenuItemFont itemWithString:@"review" block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[GooseGame gameScene]];
    }];
    review.color = ccWHITE;
    
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"BACK" block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    back.color = ccYELLOW;
    
    CCMenu *menu = [CCMenu menuWithItems:dialog,vocabulary,story,game,review,back, nil];
    [menu alignItemsVerticallyWithPadding:20];
    menu.position = CMP(0.5);
    [self addChild:menu];
    
    return self;
}

@end
