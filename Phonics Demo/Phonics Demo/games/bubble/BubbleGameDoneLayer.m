//
//  GameDoneLayer.m
//  bubble
//
//  Created by yiplee on 13-4-27.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "BubbleGameDoneLayer.h"
#import "BubbleGameLayer.h"

@implementation BubbleGameDoneLayer
{
    CCScene *backScene; // weak ref
    
    CCArray *stars; // strong wef
    CCLabelBMFont *scoreLabel;  // weak ref
    CCLabelBMFont *coinLabel;   // weak ref
    CCSprite *coinIcon;         // weak ref
    CCProgressTimer *titleProgress;     // weak ref
    CCParticleSystem *firework; // weak ref
    
    NSInteger index;
    BOOL isUpdate;
}

+ (CCScene*) sceneWithBackScene:(CCScene *)_scene
{
    CCScene *scene = [CCScene node];
    BubbleGameDoneLayer *layer = [[[self alloc] initWithBackScene:_scene] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithBackScene:(CCScene*)scene
{
    if (self = [super init])
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_texture.plist"];
        
        backScene = scene;
        
        if (backScene)
        {
            CCLayerColor *bgLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 153)];
            [self addChild:bgLayer];
        }
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint size = ccpFromSize(screenSize);
        
        CCSprite *backBoard = [CCSprite spriteWithFile:@"pass_bg.png"];
        backBoard.position = ccpMult(size, 0.5f);
        [self addChild:backBoard];
        
        CGPoint boardSize = ccpFromSize(backBoard.boundingBox.size);
        
        // buttons
        CCSprite *stage_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_stage.png"];
        CCSprite *stage_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_stage_pressed.png"];
        CCMenuItemSprite *stage_button = [CCMenuItemSprite itemWithNormalSprite:stage_button_normal selectedSprite:stage_button_select block:^(id sender) {
            [[CCDirector sharedDirector] popScene];
            [(BubbleGameLayer*)backScene backToMenu];
            
            [BubbleGameLayer cleanCaches];
        }];
        stage_button.position = ccpCompMult(boardSize, ccp(0.778,0.2665));
        
        CCSprite *replay_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_replay.png"];
        CCSprite *replay_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_replay_pressed.png"];
        CCMenuItemSprite *replay_button = [CCMenuItemSprite itemWithNormalSprite:replay_button_normal selectedSprite:replay_button_select  block:^(id sender) {
            CCLOG(@"replay");
            [[CCDirector sharedDirector] popScene];
           
        }];
        replay_button.position = ccpCompMult(boardSize, ccp(0.578,0.2665));
        
        CCSprite *resume_button_normal = [CCSprite spriteWithSpriteFrameName:@"pause_menu_resume.png"];
        CCSprite *resume_button_select = [CCSprite spriteWithSpriteFrameName:@"pause_menu_resume_pressed.png"];
        CCMenuItemSprite *resume_button = [CCMenuItemSprite itemWithNormalSprite:resume_button_normal selectedSprite:resume_button_select block:^(id sender){
            CCLOG(@"resume");
//            [[CCDirector sharedDirector] popScene];
        }];
        resume_button.position = ccpCompMult(boardSize, ccp(0.378,0.2665));
        
        CCMenu *menu = [CCMenu menuWithItems:stage_button,resume_button,replay_button, nil];
        menu.position = CGPointZero;
        
        [backBoard addChild:menu];
        
        // labels
        CCSprite *scoreTitle = [CCSprite spriteWithSpriteFrameName:@"pass_score.png"];
        scoreTitle.anchorPoint = ccp(1, 0.5);
        scoreTitle.position = ccpCompMult(boardSize, ccp(0.55, 0.50));
        [backBoard addChild:scoreTitle];
        
        scoreLabel = [CCLabelBMFont labelWithString:@" " fntFile:@"Lithos_pro_yellow.fnt"];
        scoreLabel.scale = 0.5;
//        scoreLabel.visible = NO;
        scoreLabel.opacity = 0;
        scoreLabel.anchorPoint = ccp(0, 0.65);
        scoreLabel.position = scoreTitle.position;
        [backBoard addChild:scoreLabel];
        
        CCSprite *coinTitle = [CCSprite spriteWithSpriteFrameName:@"pass_coin.png"];
        coinTitle.anchorPoint = ccp(1, 0.5);
        coinTitle.position = ccpCompMult(boardSize, ccp(0.55, 0.40));
        [backBoard addChild:coinTitle];
        
        coinIcon = [CCSprite spriteWithSpriteFrameName:@"pass_coin_icon.png"];
        coinIcon.anchorPoint = ccp(0, 0.5);
        coinIcon.position = coinTitle.position;
        coinIcon.visible = NO;
        [backBoard addChild:coinIcon];
        
        coinLabel = [CCLabelBMFont labelWithString:@"10" fntFile:@"Lithos_pro_yellow.fnt"];
        coinLabel.scale = 0.5;
//        coinLabel.visible = NO;
        coinLabel.opacity = 0;
        coinLabel.anchorPoint = ccp(0, 0.65);
        coinLabel.position = ccpAdd(coinIcon.position, ccp(coinIcon.boundingBox.size.width, 0));
        [backBoard addChild:coinLabel];
        
        // stars
        stars = [[CCArray alloc] initWithCapacity:3];
        CGPoint *starPositions = calloc(sizeof(CGPoint)*3, 1);
        starPositions[0] = CGPointMake(0.477, 0.695);
        starPositions[1] = CGPointMake(0.627, 0.695);
        starPositions[2] = CGPointMake(0.777, 0.695);
        for (int i = 0;i < 3;i++)
        {
            CCSprite *star = [CCSprite spriteWithSpriteFrameName:@"pass_star.png"];
            star.visible = NO;
            star.scale = 0;
            star.position = ccpCompMult(boardSize, starPositions[i]);
            [stars addObject:star];
            [backBoard addChild:star];
        }
        
        // title
        CCSprite *title = [CCSprite spriteWithSpriteFrameName:@"pass_title.png"];
        
        titleProgress = [CCProgressTimer progressWithSprite:title];
        [titleProgress setType:kCCProgressTimerTypeBar];
        titleProgress.midpoint = ccp(0, 0);
        titleProgress.barChangeRate = ccp(0.8, 0.2);
        titleProgress.position = ccpCompMult(boardSize, ccp(0.45, 0.708));
        [backBoard addChild:titleProgress];
        
        firework = [CCParticleSystemQuad particleWithFile:@"firework.plist"];
        firework.positionType = kCCPositionTypeFree;
        firework.visible = NO;
        firework.position = ccpAdd(titleProgress.boundingBox.origin,ccp(0, 50));
        [backBoard addChild:firework];
        
        _starLevel = arc4random_uniform(2) + 1;
//        _starLevel = 3;
        index = 0;
        isUpdate = YES;
        [self scheduleUpdate];
    }
    return self;
}

- (void) onEnter
{
    [super onEnter];
}

- (void) draw
{
    [super draw];
    
    if (backScene)
        [backScene visit];
}

- (void) update:(ccTime)delta
{
    if (!isUpdate) return;
    
    switch (index) {
        case 0:
            isUpdate = NO;
            [self showTitle];
            break;
        case 1:
            isUpdate = NO;
            [self showLabel];
            break;
        case 2:
            isUpdate = NO;
            [self showStar];
            break;
        default:
            CCLOG(@"update done");
            [self unscheduleUpdate];
            break;
    }
}

- (void) showTitle
{
    firework.visible = YES;
    
    CCProgressFromTo *progress = [CCProgressFromTo actionWithDuration:2.0f from:0 to:100];

    CCCallBlock *progressDone = [CCCallBlock actionWithBlock:^{
        index += 1;
        isUpdate = YES;
        firework.totalParticles = 0;
    }];
    [titleProgress runAction:[CCSequence actions:progress,progressDone, nil]];
    
    ccBezierConfig bezier;
    bezier.controlPoint_1 = firework.position;
    bezier.controlPoint_2 = ccpAdd(titleProgress.boundingBox.origin, ccp(0, titleProgress.contentSize.height));
    bezier.endPosition = ccpAdd(titleProgress.boundingBox.origin, ccpFromSize(titleProgress.contentSize));
//    [firework runAction:[CCMoveTo actionWithDuration:1.5 position:ccpAdd(titleProgress.boundingBox.origin, ccpFromSize(titleProgress.contentSize))]];
    [firework runAction:[CCBezierTo actionWithDuration:1.5 bezier:bezier]];
}

- (void) showLabel
{
    CCCallBlock *showScore = [CCCallBlock actionWithBlock:^{
        CCLOG(@"%@",[NSString stringWithFormat:@"%U",_score]);
        [scoreLabel setString:[NSString stringWithFormat:@"%U",_score]];
        [scoreLabel runAction:[CCFadeTo actionWithDuration:0.6f opacity:255]];
    }];
    CCDelayTime *delay1 = [CCDelayTime actionWithDuration:0.8f];
    CCCallBlock *showCoin = [CCCallBlock actionWithBlock:^{
        coinIcon.visible = YES;
        [coinLabel setString:[NSString stringWithFormat:@"%u",_coin]];
        [coinLabel runAction:[CCFadeTo actionWithDuration:0.6f opacity:255]];
    }];
    CCDelayTime *delay2 = [CCDelayTime actionWithDuration:0.8f];
    CCCallBlock *showLabelDone = [CCCallBlock actionWithBlock:^{
        index += 1;
        isUpdate = YES;
    }];
    
    [self runAction:[CCSequence actions:showScore,delay1,showCoin,delay2,showLabelDone, nil]];
}

- (void) showStar
{
    CCLOG(@"show star");
    int i = 0;
    for (;i < _starLevel;i++)
    {
        CCSprite *star = [stars objectAtIndex:i];
        if (star.visible == NO)
        {
            isUpdate = NO;
            CCLOG(@"turn off update");
            star.visible = YES;
            
            CCScaleTo *scaleStar = [CCScaleTo actionWithDuration:0.8f scale:1.0f];
            CCEaseBounceOut *scaleEase = [CCEaseBounceOut actionWithAction:scaleStar];
            CCCallBlock *scaleDone = [CCCallBlock actionWithBlock:^{
                isUpdate = YES;
                CCLOG(@"turn on update");
            }];
            
            [star runAction:[CCSequence actions:scaleEase,scaleDone, nil]];
            break;
        }
    }
    
    if (i == _starLevel)
    {
        index += 1;
        isUpdate = YES;
    }
}

- (void) dealloc
{
    CCLOG(@"index is %d",index);
    [super dealloc];
    
    [stars release];
    stars = nil;
}

@end
