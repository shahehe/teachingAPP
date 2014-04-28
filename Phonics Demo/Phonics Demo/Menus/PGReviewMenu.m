//
//  PGReviewMenu.m
//  LetterE
//
//  Created by yiplee on 4/28/14.
//  Copyright 2014 USTB. All rights reserved.
//

#import "PGReviewMenu.h"
#import "PhonicsDefines.h"

#import "GooseGame.h"
#import "PGLearnWord.h"

@implementation PGReviewMenu

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
    
    NSArray *w = @[@"cat",@"mat",@"add",@"bag",@"bat",@"man"];
    
    CCMenuItemFont *learnWord = [CCMenuItemFont itemWithString:@"Learn Word" block:^(id sender) {
        PGLearnWord *game = [PGLearnWord gameWithWords:w];
        game.gameLevel = LearnWordLevelNormal;
        CCScene *scene = [CCScene node];
        [scene addChild:game];
        [[CCDirector sharedDirector] pushScene:scene];
    }];
    learnWord.color = ccWHITE;
    
    CCMenuItemFont *goose = [CCMenuItemFont itemWithString:@"Goose" block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[GooseGame gameScene]];
    }];
    goose.color = ccWHITE;
    
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"BACK" block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    back.color = ccYELLOW;
    
    CCMenu *menu = [CCMenu menuWithItems:learnWord,goose,back, nil];
    [menu alignItemsVerticallyWithPadding:20];
    menu.position = CMP(0.5);
    [self addChild:menu];
    
    return self;
}

@end
