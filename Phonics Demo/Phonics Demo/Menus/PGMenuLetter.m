//
//  PGMenuLetter.m
//  LetterE
//
//  Created by yiplee on 4/29/14.
//  Copyright 2014 USTB. All rights reserved.
//

#import "PGMenuLetter.h"

#import "ImageMatch.h"

#import "Dialog.h"

#import "config.h"
#import "TouchGameLayer.h"

#import "GooseGame.h"
#import "PGLearnWord.h"

#import "PGSearchWord.h"
#import "CardMatching.h"
#import "BubbleGameLayer.h"
#import "LoadingLayer.h"

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
    "TouchGameBabyToy",//B
    "can_u.plist",//C
    "den.plist",//D
    "E",
    "TouchGameFound",//F
    "Garden.plist",//G
    "happy_me.plist",//H
    "I",
    "TouchGameJar",//J
    "TouchGameKiss",//K
    "TouchGameLook",//L
    "I_love.plist",//M
    "TouchGameNotFood",//N
    "O",
    "TouchGamePlease",//P
    "TouchGameWill",//Q
    "TouchGameRed",//R
    "TouchGameISee",//S
    "TouchGameTime",//T
    "U",
    "TouchGameVeryGood",//V
    "TouchGameWhere",//W
    "TouchGameSix",//X
    "TouchGameYellow",//Y
    "TouchGameZoo"//Z
};

@interface PGMenuLetter ()
{
    CCMenuItem *backButton;
    
    CCMenu *activeMenu;
}

@property (nonatomic,readonly) char letter;
@property (nonatomic,copy) NSArray *words;
@property (nonatomic,assign) CCMenu *letterMenu;
@property (nonatomic,assign) CCMenu *gameMenu;
@property (nonatomic,assign) CCMenu *reviewMenu;

@end

@implementation PGMenuLetter

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
    
    _letter = letter;
    
    NSString *fileName = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"wordList.plist"];
    NSArray *allWords = [NSArray arrayWithContentsOfFile:fileName];
    self.words = [allWords objectAtIndex:self.letter - 'A'];
    NSLog(@"%@",self.words.debugDescription);
    
    RGBA4444
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu_letter_list.plist"];
    
    RGB565
    CCSprite *bg = [CCSprite spriteWithFile:@"menu_farm_bg.pvr.ccz"];
    PIXEL_FORMAT_DEFAULT
    
    bg.position = CCMP(0.5, 0.5);
    bg.scaleX = SCREEN_WIDTH / bg.contentSize.width;
    bg.scaleY = SCREEN_HEIGHT/ bg.contentSize.height;
    [self addChild:bg z:0];
    
    __block PGMenuLetter *self_copy = self;
    backButton = [CCMenuItemImage itemWithNormalImage:@"back_button_N.png" selectedImage:@"back_button_P.png" block:^(id sender){
        if (((CCNode*)sender).tag == 1)
        {
            [[CCDirector sharedDirector] popScene];
        }
        else
        {
            [((CCNode*)sender) runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(-SCREEN_WIDTH*0.8, 0)]];
            ((CCNode*)sender).tag = 1;
            
            CCNode *panel_1 = self_copy.letterMenu.parent;
            [panel_1 runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(SCREEN_WIDTH, 0)]];
            CCNode *panel_2 = self_copy->activeMenu.parent;
            [panel_2 runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(SCREEN_WIDTH, 0)]];
            
            self_copy->activeMenu.enabled = NO;
            self_copy->activeMenu = self_copy.letterMenu;
            self_copy->activeMenu.enabled = YES;
        }
    }];
    backButton.tag = 1;
    backButton.position = CCMP(0.1, 0.9);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    activeMenu = self.letterMenu;
    
    return self;
}

- (void) dealloc
{
    [_words release];
    [super dealloc];
}

- (CCMenuItemSprite*) buttonWithNode:(CCNode*)node
{
    CCSprite *N = [CCSprite spriteWithSpriteFrameName:@"menu_button_N"];
    CCSprite *P = [CCSprite spriteWithSpriteFrameName:@"menu_button_P"];
    
    CCMenuItemSprite *item = [CCMenuItemSprite itemWithNormalSprite:N selectedSprite:P];
    
    CGPoint p = ccpFromSize(item.boundingBox.size);
    node.position = ccpMult(p, 0.5);
    [item addChild:node];
    
    return item;
}

- (CCMenu *)letterMenu
{
    if (_letterMenu)
        return _letterMenu;
    
    NSArray *itemNames = @[@"dialog",@"vocabulary",@"story",@"review",@"game",@"pronunciation"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemNames.count];
    
    CGPoint startPos = ccp(0.30, 0.70);
    CGPoint offset = ccp(0.43, -0.25);
    
    CCSprite *panel = [CCSprite spriteWithSpriteFrameName:@"menu_panel"];
    panel.position = CMP(0.5);
    [self addChild:panel];
    
    CGPoint p_size = ccpFromSize(panel.boundingBox.size);
    NSUInteger idx = 0;
    for (NSString *name in itemNames)
    {
        NSString *imageName = [@"menu_" stringByAppendingString:name];
        CCSprite *image = [CCSprite spriteWithSpriteFrameName:imageName];
        CCMenuItem *item = [self buttonWithNode:image];
        [items addObject:item];
        
        int x = idx % 2;
        int y = idx / 2;
        item.position = ccpCompMult(ccpAdd(startPos, ccpCompMult(offset, ccp(x, y))),p_size);
        
        idx++;
    }
    
    idx = 0;
    __block PGMenuLetter *self_copy = self;
    @autoreleasepool //dialog
    {
        CCMenuItem *item = [items objectAtIndex:idx];
        [item setBlock:^(id sender) {
            CCScene *scene = [Dialog dialogWithContentLayerType:DialogContentTypeLetterIdentification letter:self_copy.letter];
            [[CCDirector sharedDirector] pushScene:scene];
        }];
        
        NSString * className = [@"LetterIdentification" stringByAppendingString:[NSString stringWithFormat:@"%c", self.letter]];
        Class letterId = NSClassFromString(className);
        if ( !letterId )
        {
            item.isEnabled = NO;
        }
        
        idx++;
    }
    
    @autoreleasepool //vocabulary
    {
        CCMenuItem *item = [items objectAtIndex:idx];
        [item setBlock:^(id sender) {
            CCScene *game = [ImageMatch gameSceneWithWords:@[@"horse",@"hog",@"house",@"hen"]];
            [[CCDirector sharedDirector] pushScene:game];
        }];
        idx++;
    }
    
    @autoreleasepool //story
    {
        NSString *storyName = [NSString stringWithUTF8String:storys[self.letter-'A']];
        CCMenuItem *item = [items objectAtIndex:idx];
        [item setBlock:^(id sender) {
            CCScene *scene = [CCScene node];
            if ([storyName hasSuffix:@"plist"])
            {
                NSString *rootPath = [NSString stringWithUTF8String:touchingGameRootPath];
                NSString *filePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:rootPath] stringByAppendingPathComponent:storyName];
                NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
                TouchGameLayer *game = [TouchGameLayer gameLayerWithGameData:dic];
                [scene addChild:game];
            }
            else
            {
                Class story = NSClassFromString(storyName);
                [scene addChild:[story performSelector:@selector(gameLayer)]];
            }
            
            [[CCDirector sharedDirector] pushScene:scene];
        }];
        item.isEnabled = storyName.length > 1 ? YES : NO;
        
        idx++;
    }
    
    @autoreleasepool //review
    {
        CCMenuItem *item = [items objectAtIndex:idx];
        [item setBlock:^(id sender) {
            [self_copy->backButton runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(SCREEN_WIDTH*0.8, 0)]];
            [self_copy.letterMenu.parent runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(-SCREEN_WIDTH, 0)]];
            [self_copy.reviewMenu.parent runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(-SCREEN_WIDTH, 0)]];
            
            self_copy->activeMenu.enabled = NO;
            self_copy->activeMenu = self_copy.reviewMenu;
            self_copy->activeMenu.enabled = YES;
            
            self_copy->backButton.tag = 2;
        }];
        
        idx++;
    }
    
    @autoreleasepool //game
    {
        CCMenuItem *item = [items objectAtIndex:idx];
        [item setBlock:^(id sender) {
            [self_copy->backButton runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(SCREEN_WIDTH*0.8, 0)]];
            [self_copy.letterMenu.parent runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(-SCREEN_WIDTH, 0)]];
            [self_copy.gameMenu.parent runAction:[CCMoveBy actionWithDuration:0.4 position:ccp(-SCREEN_WIDTH, 0)]];
            
            self_copy->activeMenu.enabled = NO;
            self_copy->activeMenu = self_copy.gameMenu;
            self_copy->activeMenu.enabled = YES;
            
            self_copy->backButton.tag = 2;
        }];
        
        idx++;
    }
    
    @autoreleasepool //pronunciation
    {
        CCMenuItem *item = [items objectAtIndex:idx];
        [item setBlock:^(id sender) {
            
        }];
        idx++;
    }
    
    _letterMenu = [CCMenu menuWithArray:items];
    _letterMenu.position = CGPointZero;
    [panel addChild:_letterMenu];
    
    return _letterMenu;
}

- (CCMenu *) reviewMenu
{
    if (_reviewMenu)
        return _reviewMenu;
    
    CCSprite *panel = [CCSprite spriteWithSpriteFrameName:@"menu_panel"];
    panel.position = CCMP(1.5,0.5);
    [self addChild:panel];
    
    CGPoint p_size = ccpFromSize(panel.boundingBox.size);
    
    __block PGMenuLetter *self_copy = self;
    
    CCLabelTTF *learn_word_label = [CCLabelTTF labelWithString:@"Learn Word" fontName:@"Avenir-BlackOblique" fontSize:24*CC_CONTENT_SCALE_FACTOR()];
    learn_word_label.color = ccWHITE;
    CCMenuItem *learn_word = [self buttonWithNode:learn_word_label];
    [learn_word setBlock:^(id sender) {
        PGLearnWord *game = [PGLearnWord gameWithWords:self_copy.words];
        game.gameLevel = LearnWordLevelNormal;
        CCScene *scene = [CCScene node];
        [scene addChild:game];
        [[CCDirector sharedDirector] pushScene:scene];
    }];
    
    CCLabelTTF *goose_label = [CCLabelTTF labelWithString:@"Goose" fontName:@"Avenir-BlackOblique" fontSize:20*CC_CONTENT_SCALE_FACTOR()];
    goose_label.color = ccWHITE;
    CCMenuItem *goose = [self buttonWithNode:goose_label];
    [goose setBlock:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[GooseGame gameScene]];
    }];
    
    _reviewMenu = [CCMenu menuWithItems:learn_word,goose, nil];
    _reviewMenu.position = ccpCompMult(p_size, ccp(0.5,0.45));
    [_reviewMenu alignItemsVerticallyWithPadding:18];
    
    [panel addChild:_reviewMenu];
    
    return _reviewMenu;
}

- (CCMenu*) gameMenu
{
    if (_gameMenu)
        return _gameMenu;
    
    CCSprite *panel = [CCSprite spriteWithSpriteFrameName:@"menu_panel"];
    panel.position = CCMP(1.5,0.5);
    [self addChild:panel];
    
    CGPoint p_size = ccpFromSize(panel.boundingBox.size);
    NSArray *w = @[@"cat",@"mat",@"add",@"bag",@"bat",@"man"];
    
    __block PGMenuLetter *self_copy = self;
    CCMenuItem *search_word = nil;
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Search Word" fontName:@"Avenir-BlackOblique" fontSize:20*CC_CONTENT_SCALE_FACTOR()];
        label.color = ccWHITE;
        search_word = [self buttonWithNode:label];
        [search_word setBlock:^(id sender) {
            [[CCDirector sharedDirector] pushScene:[PGSearchWord gameWithWords:self_copy.words panelSize:CGSizeMake(640, 640) gridSize:CGSizeMake(80, 80)]];
        }];
    }
    
    CCMenuItem *card_match = nil;
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Card Match" fontName:@"Avenir-BlackOblique" fontSize:24*CC_CONTENT_SCALE_FACTOR()];
        label.color = ccWHITE;
        card_match = [self buttonWithNode:label];
        [card_match setBlock:^(id sender) {
            [[CCDirector sharedDirector] pushScene:[CardMatching gameWithWords:w]];
        }];
    }
    
    CCMenuItem *bubble = nil;
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Bubble" fontName:@"Avenir-BlackOblique" fontSize:24*CC_CONTENT_SCALE_FACTOR()];
        label.color = ccWHITE;
        bubble = [self buttonWithNode:label];
        [bubble setBlock:^(id sender) {
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
                    CCScene *game = [BubbleGameLayer gameWithWords:self_copy.words];
                    [[CCDirector sharedDirector] popScene];
                    [[CCDirector sharedDirector] pushScene:game];
                });
            });
            
            dispatch_release(queue);
        }];
    }
    
    _gameMenu = [CCMenu menuWithItems:search_word,card_match,bubble, nil];
    _gameMenu.position = ccpCompMult(p_size, ccp(0.5,0.45));
    [_gameMenu alignItemsVerticallyWithPadding:18];
    
    [panel addChild:_gameMenu];
    
    return _gameMenu;
}

@end
