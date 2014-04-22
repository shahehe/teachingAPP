//
//  PGGameListMenu.m
//  Phonics Games
//
//  Created by yiplee on 14-4-7.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "PGGameListMenu.h"
#import "PhonicsDefines.h"

#import "PGLearnWord.h"
#import "PGSearchWord.h"
#import "CardMatching.h"
#import "BubbleGameLayer.h"

#import "PGStageMenu.h"
#import "LoadingLayer.h"

@implementation PGGameListMenu

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
    
    NSArray *w = @[@"cat",@"mat",@"add",@"bag",@"bat",@"man"];
    
    NSString *font = @"Avenir-BlackOblique";
    NSString *l = [NSString stringWithFormat:@"%c",letter];
    CCLabelTTF *title = [CCLabelTTF labelWithString:l fontName:font fontSize:64];
    title.color = ccWHITE;
    title.position = CCMP(0.5, 0.8);
    [self addChild:title];
    
    [CCMenuItemFont setFontName:font];
    
    CCMenuItemFont *learnWord = [CCMenuItemFont itemWithString:@"Learn Word" block:^(id sender) {
        PGLearnWord *game = [PGLearnWord gameWithWords:w];
        game.gameLevel = LearnWordLevelNormal;
        CCScene *scene = [CCScene node];
        [scene addChild:game];
        [[CCDirector sharedDirector] pushScene:scene];
    }];
    learnWord.color = ccWHITE;
    
    CCMenuItemFont *searchWord = [CCMenuItemFont itemWithString:@"Search Word" block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[PGSearchWord gameWithWords:w panelSize:CGSizeMake(640, 640) gridSize:CGSizeMake(80, 80)]];
    }];
    searchWord.color = ccWHITE;
    
    CCMenuItemFont *cardMatch = [CCMenuItemFont itemWithString:@"Card Match" block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[CardMatching gameWithWords:w]];
    }];
//    cardMatch.isEnabled = NO;
    cardMatch.color = ccWHITE;
    
    CCMenuItemFont *bubble = [CCMenuItemFont itemWithString:@"Bubble" block:^(id sender) {
        
        [[CCDirector sharedDirector] pushScene:[LoadingLayer scene]];
        
        dispatch_queue_t queue = dispatch_queue_create("bubble", NULL);
        dispatch_async(queue, ^{
            CCGLView *view = (CCGLView*)[[CCDirector sharedDirector] view];
            EAGLContext *_auxGLcontext = [[EAGLContext alloc]
                             initWithAPI:kEAGLRenderingAPIOpenGLES2
                             sharegroup:[[view context] sharegroup]];
            if( [EAGLContext setCurrentContext:_auxGLcontext] )
            {
                [BubbleGameLayer preloadTextures];
                glFlush();
                
                [EAGLContext setCurrentContext:nil];
            }
            
            [_auxGLcontext release];
            dispatch_sync(dispatch_get_main_queue(), ^{
                CCScene *game = [BubbleGameLayer gameWithWords:w];
                [[CCDirector sharedDirector] popScene];
                [[CCDirector sharedDirector] pushScene:game];
            });
        });
        
        dispatch_release(queue);
    }];
    bubble.color = ccWHITE;
    
    CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"BACK" block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    back.color = ccYELLOW;
    
    CCMenu *menu = [CCMenu menuWithItems:learnWord,searchWord,cardMatch,bubble,back, nil];
    [menu alignItemsVerticallyWithPadding:20];
    menu.position = CMP(0.5);
    [self addChild:menu];
    
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
}

- (void) dealloc
{
    NSLog(@"game list : dealloc");
    [super dealloc];
}

@end
