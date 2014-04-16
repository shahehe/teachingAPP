//
//  ImageMatch.m
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "ImageMatch.h"
#import "config.h"
#import "PhonicsDefines.h"

#import "Cocos2d+CustomOptions.h"
#import "ImageCard.h"

#import "CardProLayer.h"

#import "AudioDict.h"
@interface ImageMatch ()
{
    NSMutableArray *cards;
}

@property(nonatomic,retain) NSArray *words;
@property(nonatomic,assign) NSUInteger currentIndex;
@property(nonatomic,copy,readonly) NSString *currentWord;

@end

@implementation ImageMatch

+ (CCScene *) gameSceneWithWords:(NSArray*)words
{
    CCScene *scene = [CCScene node];
    [scene addChild:[[self class] gameWithWord:words]];
    return scene;
}

+ (instancetype) gameWithWord:(NSArray *)words
{
    return [[[self alloc] initWithWords:words] autorelease];
}

- (id) initWithWords:(NSArray *)words
{
    self = [super init];
    
    self.words = words;
    
    [[AudioDict defaultAudioDict] preloadWords:self.words];
    // get the first letter of first word;
    NSString *letter = [[[self.words firstObject] substringWithRange:NSMakeRange(0, 1)] lowercaseString];
    
    // set search path
    NSString *rootPath = [NSString stringWithUTF8String:imageMatchGameRootPath];
    NSArray *searchPath = @[rootPath,@""];
    [[CCFileUtils sharedFileUtils] setSearchPath:searchPath];
    [[CCFileUtils sharedFileUtils] purgeCachedEntries];
    
    RGB565
    CCSprite *bg = [CCSprite spriteWithFile:@"image_match_bg.pvr.ccz"];
    bg.position = CMP(0.5);
    [bg fitSize:SCREEN_SIZE scaleIn:YES];
    [self addChild:bg z:0];
    PIXEL_FORMAT_DEFAULT    
    
    // preload sprite frames
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"letters.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"image_match_objects.plist"];
    
    NSString *imagesName = [letter stringByAppendingString:@"_objects.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:imagesName];
    
    // plates
    CGPoint platePos[4] = {
        ccp(0.25*(0+0.5), 0.6),
        ccp(0.25*(1+0.5), 0.6),
        ccp(0.25*(2+0.5), 0.6),
        ccp(0.25*(3+0.5), 0.6),
    };
    for (int i=0,idx = arc4random_uniform(10);i<4;i++,idx++)
    {
        NSString *frameName = [@"plate" stringByAppendingFormat:@"%d.png",idx%10];
        CCSprite *plate = [CCSprite spriteWithSpriteFrameName:frameName];
        plate.anchorPoint = ccp(0.5, 1.5);
        plate.position = ccpCompMult(SCREEN_SIZE_AS_POINT,platePos[i]);
        plate.zOrder = 0;
        [self addChild:plate];
    }
    
    // cards
    CGPoint cardsPos[4] = {
        ccp(0.25*(0+0.5), 0.2),
        ccp(0.25*(1+0.5), 0.2),
        ccp(0.25*(2+0.5), 0.2),
        ccp(0.25*(3+0.5), 0.2),
    };
    NSUInteger count = MIN(self.words.count,4);
    cards = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i=0;i<count;i++)
    {
        NSString *word = [self.words objectAtIndex:i];
        ImageCard *card = [ImageCard imageCardWithWord:word];
        card.position = ccpCompMult(SCREEN_SIZE_AS_POINT, cardsPos[i]);
        [self addChild:card z:1];
        [card addImageToNode:self position:ccpCompMult(SCREEN_SIZE_AS_POINT,platePos[i])];
        [cards addObject:card];
        
        [card setCardClickBlock:^(id sender) {
            CardProLayer *layer = [CardProLayer layerWithWord:((ImageCard*)sender).word];
            layer.sourceScene = (CCScene*)self;
            CCScene *scene = [CCScene node];
            [scene addChild:layer];
            [[CCDirector sharedDirector] pushScene:scene];
        }];
    }
    
    for (int i=0;i<count;i++)
    {
        ImageCard *card1 = [cards objectAtIndex:i];
        ImageCard *card2 = [cards objectAtIndex:(i+1+arc4random_uniform(count-1))%count];
        CGPoint temp = card1.position;
        card1.position = card2.position;
        card2.position = temp;
    }
    
    for (int i=0;i<count;i++)
    {
        ImageCard *card1 = [cards objectAtIndex:i];
        ImageCard *card2 = [cards objectAtIndex:(i+1+arc4random_uniform(count-1))%count];
        CGPoint temp = card1.imagePosition;
        card1.imagePosition = card2.imagePosition;
        card2.imagePosition = temp;
    }

    
    __block ImageMatch *self_copy = self;
    // menu
    CCSprite *menu_button_N = [CCSprite spriteWithSpriteFrameName:@"menu_button_N.png"];
    CCSprite *menu_button_P = [CCSprite spriteWithSpriteFrameName:@"menu_button_P.png"];
    CCMenuItemSprite *menu_button = [CCMenuItemSprite itemWithNormalSprite:menu_button_N selectedSprite:menu_button_P block:^(id sender) {
        [self_copy backToMenu];
        [[AudioDict defaultAudioDict] unloadAll];
    }];
    menu_button.position = CMP(0.90);
    
    CCMenuItem *bigLetterButton = nil, *littleLetterButton = nil;
    
    {
        NSString *l1 = [letter stringByAppendingString:@"1-big.png"];
        NSString *l2 = [letter stringByAppendingString:@"2-big.png"];
        CCSprite *N = [CCSprite spriteWithSpriteFrameName:@"letterButton_N.png"];
        CCSprite *L1 = [CCSprite spriteWithSpriteFrameName:l1];
        [N addChild:L1];
        [L1 setBoundingBoxCenterOfParent];
        
        CCSprite *H = [CCSprite spriteWithSpriteFrameName:@"letterButton_H.png"];
        CCSprite *L2 = [CCSprite spriteWithSpriteFrameName:l2];
        [H addChild:L2];
        [L2 setBoundingBoxCenterOfParent];
        
        bigLetterButton = [CCMenuItemSprite itemWithNormalSprite:N selectedSprite:H];
    }
    {
        NSString *l1 = [letter stringByAppendingString:@"1-small.png"];
        NSString *l2 = [letter stringByAppendingString:@"2-small.png"];
        CCSprite *N = [CCSprite spriteWithSpriteFrameName:@"letterButton_N.png"];
        CCSprite *L1 = [CCSprite spriteWithSpriteFrameName:l1];
        [N addChild:L1];
        [L1 setBoundingBoxCenterOfParent];
        
        CCSprite *H = [CCSprite spriteWithSpriteFrameName:@"letterButton_H.png"];
        CCSprite *L2 = [CCSprite spriteWithSpriteFrameName:l2];
        [H addChild:L2];
        [L2 setBoundingBoxCenterOfParent];
        
        littleLetterButton = [CCMenuItemSprite itemWithNormalSprite:N selectedSprite:H];
    }
    
    bigLetterButton.position = CCMP(0.05, 0.90);
    [bigLetterButton setBlock:^(id sender) {
        [littleLetterButton unselected];
        [bigLetterButton selected];
        
        for (ImageCard *card in self_copy->cards)
        {
            [card setWord:[card.word uppercaseString]];
        }
    }];
    
    littleLetterButton.position = CCMP(0.15, 0.90);
    [littleLetterButton setBlock:^(id sender) {
        [bigLetterButton unselected];
        [littleLetterButton selected];
        
        for (ImageCard *card in self_copy->cards)
        {
            [card setWord:[card.word lowercaseString]];
        }
    }];
    
    [littleLetterButton selected];
    
    CCMenu *menu = [CCMenu menuWithItems:bigLetterButton,littleLetterButton,menu_button, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:4];

    
    return self;
}

- (void) dealloc
{
    CCLOG(@"image match:dealloc");
    [_words release];
    [cards release];
    [super dealloc];
}

/**
 *  current word playing
 *
 *  @return NSString
 */
- (NSString*) currentWord
{
    return [self.words objectAtIndex:self.currentIndex];
}

- (void) backToMenu
{
    // reset search path
    [[CCFileUtils sharedFileUtils] setSearchPath:@[@""]];
    [[CCFileUtils sharedFileUtils] purgeCachedEntries];
    // back to previous scene
    [[CCDirector sharedDirector] popScene];
}

@end
