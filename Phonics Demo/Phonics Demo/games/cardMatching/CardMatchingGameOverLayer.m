//
//  CardMatchingGameOverLayer.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchingGameOverLayer.h"
#import "CardMatching.h"

@implementation CardMatchingGameOverLayer

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    CardMatchingGameOverLayer *layer = [CardMatchingGameOverLayer node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    if (self = [super init])
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGFloat winWidth = winSize.width;
        CGFloat winHeight = winSize.height;
        
        isShow = NO;
        
        boardShowPoint = ccp(winWidth*0.5f, winHeight*0.6f);
        boardHidePoint = ccp(winWidth*0.5f, winHeight*1.3f);
        backBoard = [CCSprite spriteWithSpriteFrameName:@"gameDoneBackground.png"];
        backBoard.position = boardHidePoint;
        [self addChild:backBoard];
        
        CGSize boardSize = backBoard.contentSize;
        CGFloat boardWidth = boardSize.width;
        CGFloat boardHeight = boardSize.height;
        
        //cat
        CCSprite *cat = [CCSprite spriteWithSpriteFrameName:@"catSad.png"];
        cat.position = ccp(boardWidth*0.2f, boardHeight*0.5f);
        [backBoard addChild:cat];
        
        //title
        CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"gameOver.png"];
        title.position = ccp(boardWidth*0.6f, boardHeight*0.7f);
        [backBoard addChild:title];
        
        // score
        scoreLabel = [CCLabelBMFont labelWithString:@"SCORE 0" fntFile:@"DenneSketchy60.fnt"];
        scoreLabel.color = ccGRAY;
        scoreLabel.position = ccp(boardWidth*0.6f, boardHeight*0.4f);
        [backBoard addChild:scoreLabel];
        
        //menu
        __block id copy_self = self;
        
        OrangeButton *again = [OrangeButton orangeButtonWithString:@"TRY AGAIN" block:^(id sender) {
            [copy_self tryAgainPressed];
        }];
        
        OrangeButton *back = [OrangeButton orangeButtonWithString:@"SELECT STAGE" block:^(id sender) {
            [copy_self selectStageButtonPressed];
        }];
        
        menu = [CCMenu menuWithItems:back,again, nil];
        [menu alignItemsHorizontallyWithPadding:100];
        
        menuShowPoint = ccp(winWidth*0.5f, winHeight*0.20f);
        menuHidePoint = ccp(winWidth*0.5f, -winHeight*0.20f);
        menu.position = menuHidePoint;
        [self addChild:menu];
    }
    return self;
}

- (void) tryAgainPressed
{
    CCCallBlock *hide = [CCCallBlock actionWithBlock:^{
        [self hideWithDuration:0.4f];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.45f];
    CCCallBlock *playAgain = [CCCallBlock actionWithBlock:^{
        [(CardMatching*)self.parent.parent playAgain];
    }];
    
    CCSequence *seq = [CCSequence actions:hide,delay,playAgain, nil];
    [self runAction:seq];
}

- (void) selectStageButtonPressed
{
    [(CardMatching*)self.parent.parent backToMainMenu];
}

- (void) prepareWithScore:(NSUInteger)score
{
    NSString *scoreLabelString = [NSString stringWithFormat:@"SCORE %i",score];
    [scoreLabel setString:scoreLabelString];
}

- (void) showWithDuration:(ccTime)_duration
{
    if (isShow) return;
    isShow = YES;
    
    CCMoveTo *boardMove = [CCMoveTo actionWithDuration:_duration position:boardShowPoint];
    CCEaseOut *boardEase = [CCEaseOut actionWithAction:boardMove rate:1];
    [backBoard runAction:boardEase];
    
    CCMoveTo *menuMove = [CCMoveTo actionWithDuration:_duration position:menuShowPoint];
    CCEaseOut *menuEase = [CCEaseOut actionWithAction:menuMove rate:1];
    [menu runAction:menuEase];
}

- (void) hideWithDuration:(ccTime)_duration
{
    if (!isShow) return;
    isShow = NO;
    
    CCMoveTo *boardMove = [CCMoveTo actionWithDuration:_duration position:boardHidePoint];
    CCEaseIn *boardEase = [CCEaseIn actionWithAction:boardMove rate:1];
    [backBoard runAction:boardEase];
    
    CCMoveTo *menuMove = [CCMoveTo actionWithDuration:_duration position:menuHidePoint];
    CCEaseIn *menuEase = [CCEaseIn actionWithAction:menuMove rate:1];
    [menu runAction:menuEase];
}

- (void) dealloc
{
    [super dealloc];
}

@end
