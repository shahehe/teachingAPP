//
//  GameLayer.m
//  bubble
//
//  Created by yiplee on 13-4-2.
//  Copyright 2013年 yiplee. All rights reserved.
//

#import "BubbleGameLayer.h"
#import "bubble.h"
#import "letterBubble.h"
#import "propsBubble.h"
#import "BubbleConfig.h"
#import "BubblePauseMenu.h"
#import "BubbleGameDoneLayer.h"
#import "BubbleGameOverLayer.h"

#import "SimpleAudioEngine.h"

#import "PGManager.h"

@implementation BubbleGameLayer
{
    // chipmunk space
    cpSpace *_space;
    cpShape *_walls[3];
    
    // Time tracking for the fixed timestep.
	ccTime _accumulator;
	int _ticks;
    
    //data
    NSArray *_words; // 本关需要用到的单词
    NSUInteger _wordsCount;
    NSInteger _currentIndex;
    
    CCArray *letterBubblePool;// store bubbles waiting to be added
    CCArray *letterBubbles; // store bubbles added
    
    NSMutableString *_selectedString;
    
    // touch
    bubble *_bubbleInTouch; // weak ref
    
    // game status
    NSUInteger _currentWordLength;  // 当前单词长度
    NSUInteger _selectedWordLength; // 已选出的字母个数
    CCArray *_tipLetters;   // strong ref
    CCSprite *reef;         // weak ref 礁石
    
    NSInteger _life;   // 生命,game over if _life = 0 .
    NSUInteger _lifeMax;    // 最大生命值
    CCArray *_livesStars;    // strong ref
    
    NSInteger _score;  // 分数
    CCLabelBMFont *_scoreLabel; // weak ref
    
    NSInteger _coin;   // 金币
    CCLabelBMFont *_coinLabel;  // weak ref
    
    CGFloat _totalTime; // 总时间
    CGFloat _wordTime;  // 某单词限定的时间
    
    // score pop label pool
//    CCArray *_scorePopLabelPool;
    BOOL _showTipLetter;
}

+ (CCScene*) gameWithWords:(NSArray *)words
{
    CCScene *scene = [CCScene node];
    [scene addChild:[[[BubbleGameLayer alloc] initWithWords:words] autorelease]];
    return scene;
}

- (void) dealloc
{
    CCLOG(@"bubble dealloc");
    
    [_gameName release];
    
    for (NSString *_word in _words)
    {
        [[SimpleAudioEngine sharedEngine] unloadEffect:[self audioFileNameWithWord:_word]];
    }

    [self unscheduleUpdate];
    
    for (int i=0;i<3;i++)
    {
        cpShapeFree(_walls[i]);
    }
    
    cpSpaceFree(_space);
    
    [_tipLetters release];
    _tipLetters = nil;
    [_livesStars release];
    _livesStars = nil;
    [_words release];
    _words = nil;
    [_selectedString release];
    _selectedString = nil;
    
    [letterBubblePool release];
    [letterBubbles release];
    
    [super dealloc];
}

- (id) initWithWords:(NSArray*)words
{
    if (self = [super init])
    {
        _gameName = [@"Bubble" copy];
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint size = ccpFromSize(screenSize);
        
        NSString *currentPhonics = [[words objectAtIndex:0] substringWithRange:NSMakeRange(0, 1)];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_texture.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"bubble_object.plist"];
        // bg
        CCSprite *bg = [CCSprite spriteWithFile:@"game_bg.png"];
        bg.position = ccpMult(size, 0.5);
        [self addChild:bg z:Z_BACKGROUND];
        
        CCSprite *cover_left = [CCSprite spriteWithFile:@"game_bg_left.png"];
        cover_left.anchorPoint = CGPointZero;
        cover_left.position = ccpMult(size, 0);
        [self addChild:cover_left z:Z_COVER];
        
        CCSprite *cover_right = [CCSprite spriteWithFile:@"game_bg_right.png"];
        cover_right.anchorPoint = ccp(1, 0);
        cover_right.position = ccpCompMult(size, ccp(1,0));
        [self addChild:cover_right z:Z_COVER];
        
        // banner 顶部菜单栏
        CCSprite *game_banner = [CCSprite spriteWithSpriteFrameName:@"game_banner.png"];
        game_banner.anchorPoint = ccp(0.5,0.96);
        game_banner.position = ccpCompMult(size, ccp(0.5,1));
        [self addChild:game_banner z:Z_MENU];
        
        CGPoint banner_size_p = ccpFromSize(game_banner.boundingBox.size);
        
        CCSprite *banner_title = [CCSprite spriteWithSpriteFrameName:@"game_title_bg.png"];
        banner_title.position = ccpMult(banner_size_p, 0.5);
        [game_banner addChild:banner_title];
        
        // show title
        CCLabelTTF *title = [CCLabelTTF labelWithString:currentPhonics fontName:@"GillSans-Bold" fontSize:24];
        title.position = ccpCompMult(banner_size_p, ccp(0.5,0.52));
        [game_banner addChild:title];
        
        // pause button
        __block BubbleGameLayer* self_copy = self;
        CCSprite *pause_button_normal = [CCSprite spriteWithSpriteFrameName:@"game_pause.png"];
        CCSprite *pause_button_pressed = [CCSprite spriteWithSpriteFrameName:@"game_pause_pressed.png"];
        CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemWithNormalSprite:pause_button_normal selectedSprite:pause_button_pressed block:^(id sender) {

            [[CCDirector sharedDirector] pushScene:[BubblePauseMenu sceneWithScene:(CCScene*)self_copy]];
        }];
        pauseButton.position = ccpCompMult(size, ccp(0.919,0.954));
        CCMenu *game_menu = [CCMenu menuWithItems:pauseButton, nil];
        game_menu.position = ccp(0, 0);
        [self addChild:game_menu z:Z_MENU];
        
        // game status
        _score = 0;
        _coin = 0;
        
        // score label
        _scoreLabel = [CCLabelBMFont labelWithString:@" " fntFile:@"Lithos_pro_white.fnt"];
        _scoreLabel.scale = 0.4;
        _scoreLabel.anchorPoint = ccp(0, 0.5);
        _scoreLabel.position = ccpCompMult(banner_size_p, ccp(0.04,0.40));
        [game_banner addChild:_scoreLabel];
        [self updateScoreLabel];
        
//        _scorePopLabelPool = [[CCArray alloc] init];
        
        // coin icon
        CCSprite *coin_icon = [CCSprite spriteWithSpriteFrameName:@"game_coin.png"];
        coin_icon.position = ccpCompMult(banner_size_p, ccp(0.20,0.5));
        [game_banner addChild:coin_icon];
        
        // coin label
        _coinLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d",_coin] fntFile:@"Lithos_pro_white.fnt"];
        _coinLabel.scale = 0.4;
        _coinLabel.anchorPoint = ccp(0, 0.5);
        _coinLabel.position = ccpCompMult(banner_size_p, ccp(0.25,0.40));
        [game_banner addChild:_coinLabel];
        
        // live star
        _life = _lifeMax = 3;
        _livesStars = [[CCArray arrayWithCapacity:_lifeMax] retain];
        CGPoint _temp_pos = ccpCompMult(banner_size_p, ccp(0.84,0.52));
        for (int i = 0;i < _life;i++)
        {
            CCSprite *life_star_bg = [CCSprite spriteWithSpriteFrameName:@"game_life_no.png"];
            life_star_bg.anchorPoint = ccp(1, 0.5);
            life_star_bg.position = _temp_pos;
            [game_banner addChild:life_star_bg];
            CCSprite *life_star = [CCSprite spriteWithSpriteFrameName:@"game_life.png"];
            life_star.position = life_star_bg.position;
            life_star.anchorPoint = ccp(1, 0.5);
            [game_banner addChild:life_star];
            [_livesStars insertObject:life_star atIndex:0];
            
            _temp_pos = ccpAdd(_temp_pos, ccp(-life_star_bg.boundingBox.size.width, 0));
        }
        
        // word tip
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"tip_letter.plist"];
        reef = [CCSprite spriteWithSpriteFrameName:@"game_reef.png"];
        reef.anchorPoint = ccp(0, 0.5);
        reef.position = ccpCompMult(size, ccp(0, 0.32));
        [self addChild:reef z:Z_BACKGROUND];
        _currentWordLength = 0;
        _selectedWordLength = 0;
        _tipLetters = [[CCArray array] retain];
        
        // initialize data
        
        
        _words = [[NSArray alloc] initWithArray:words];
        
        // preload sound effect
        for (NSString *_word in _words)
        {
            [[SimpleAudioEngine sharedEngine] preloadEffect:[self audioFileNameWithWord:_word]];
        }
        
        _wordsCount = [_words count];
        _currentIndex = 0;
        
        //pool
        letterBubblePool = [[CCArray alloc] init];
        letterBubbles = [[CCArray alloc] init];
        
        // set up the physics space
        _space = cpSpaceNew();
        // 重力,负值向下，正值向上
        cpSpaceSetGravity(_space, cpv(0, -10.0f));
        
        // Allow collsion shapes to overlap by 4 pixels.
        // 容许物理引擎形状有 4 个像素的交叉，别弹开太快
        cpSpaceSetCollisionSlop(_space, 4.0f);
        
        //add wall around, 三面墙,其中下面那面墙在屏幕下方外面 100 点的位置
        {
            cpBody *staticBody = cpSpaceGetStaticBody(_space);
            cpFloat radius = 1.0f;
            
            // four corner
            cpVect leftDown = cpv(225, -100);
            cpVect leftUp = cpv(225,size.y);
            cpVect rightDown = cpv(size.x, -100);
            cpVect rightUp = cpv(size.x, size.y);
            
            _walls[0] = cpSpaceAddShape(_space, cpSegmentShapeNew(staticBody, leftDown, leftUp, radius));
			cpShapeSetFriction(_walls[0], 1.0f);
            cpShapeSetElasticity(_walls[0], 1.0f);
			cpShapeSetLayers(_walls[0], PhysicsEdgeLayers);
            
            _walls[1] = cpSpaceAddShape(_space, cpSegmentShapeNew(staticBody, leftDown, rightDown, radius));
			cpShapeSetFriction(_walls[1], 1.0f);
            cpShapeSetElasticity(_walls[1], 1.0f);
			cpShapeSetLayers(_walls[1], PhysicsEdgeLayers);
            
            _walls[2] = cpSpaceAddShape(_space, cpSegmentShapeNew(staticBody, rightDown, rightUp, radius));
			cpShapeSetFriction(_walls[2], 1.0f);
            cpShapeSetElasticity(_walls[2], 1.0f);
			cpShapeSetLayers(_walls[2], PhysicsEdgeLayers);
        }
        
        // set debug draw
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForCPSpace:_space];
        debugNode.visible = NO;
        [self addChild:debugNode z:Z_PHYSICS_DEBUG];

        // touch
        _bubbleInTouch = nil;

        self.gameLevel = BubbleLevelEasy;
        
        for (int i = 0;i < 20;i++)
        {
            coinBubble *coin = [coinBubble coinBubbleWithCoin:1];
            coin.isObjectPerformScale = YES;
            [letterBubblePool addObject:coin];
        }
        
        [self performSelector:@selector(startCurrentWord) withObject:nil afterDelay:1.0f];
    }
    return self;
}

static const int TICKS_PER_SECOND = 120;
//在 update 里面不断检查更新泡泡
// 如果泡泡跑到了屏幕外面，则将其移除，放回泡泡池，等待下一次放出
// 否则，则更新泡泡的大小，浮力以及阻力
- (void) update:(ccTime)delta
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    // update bubble sattus
    
    CCArray *_tempArray = [letterBubbles copy];
    for (bubble *_bubble in _tempArray)
    {
        cpBody *_body = _bubble.bubble.CPBody;
        //cpVect pos = cpBodyGetPos(_body);
        
        if (_bubble.bubble.boundingBox.origin.y > size.height)
        {
            // out of screen
            [self removeBubble:_bubble];
            [letterBubblePool addObject:_bubble];
            /*
            if (_bubble.bubbleType == BubbleTypeLetter)
            {
                [letterBubblePool addObject:_bubble];
            }
             */
            [letterBubbles removeObject:_bubble];
        }
        else
        {
            cpFloat _scaleRate = 1 + _bubble.pos.y/size.height;
            _scaleRate = MIN(_scaleRate, 2);
            _scaleRate = MAX(_scaleRate, 1);
            [_bubble setScaleRate:_scaleRate];
            cpFloat radius = ((cpCircleShape*)_bubble.shape)->r;
            // 加浮力与阻力
            // 先清零
            cpBodyResetForces(_body);
            // 加浮力 f = r^3 * g r:半径 g:重力加速度
            cpBodyApplyForce(_body, cpv(0,radius*radius*radius*fabsf(_space->gravity.y)), cpvzero);
            // 加阻力 f = -v * 20r v：速度 r:半径
            cpBodyApplyForce(_body, cpvmult(_body->v, -20*radius), cpvzero);
        }
    }
    [_tempArray release];
    
    // chipmunk run , 大概一帧更新两次
    ccTime fixed_dt = 1.0/(ccTime)TICKS_PER_SECOND;
	_accumulator += MIN(delta, 0.1);
	// Subtract off fixed-sized chunks of time from the accumulator and step
	while(_accumulator > fixed_dt){
		[self tick:fixed_dt]; // this make the physics engine run
		_accumulator -= fixed_dt;
	}
}

- (void) tick:(ccTime)dt
{
    CGFloat halfWidth = [[CCDirector sharedDirector] winSize].width/2;
    static int _tick = 1;
    
    // release bubble in the bubble pool
    // 使用 _tick % 20 == 0 来放缓释放新泡泡的速度
    // 不断检查泡泡池中是否还有泡泡，有的话，就释放
    bubble *_bubble = [letterBubblePool randomObject];
    if (_bubble && _tick % 20 == 0)
    {
        _tick = 1;
        // 总共尝试10次，直到找到一个空白区域让泡泡可以释放出来
        for (int i = 0;i < 10;i++)
        {
            _bubble.pos = cpv(arc4random_uniform(halfWidth)+halfWidth/1.5, 0);
            if (!cpSpaceShapeQuery(_space, _bubble.shape, NULL, NULL))
            {
                [self addBubble:_bubble];
                [_bubble setScaleRate:1];
                [letterBubbles addObject:_bubble];
                [letterBubblePool removeObject:_bubble];
                
                break;
            }
        }
    }
    
    // 让 chipmunk 碰撞引擎运转
    cpSpaceStep(_space, dt); 
    
    _tick++;
}

- (void) onEnter
{
    [super onEnter];
    
    [self setTouchEnabled:YES];
    [self scheduleUpdate];
}

- (void) onExit
{
    [super onExit];
    [self setTouchEnabled:NO];
    [self unscheduleUpdate];
}

- (void) setGameLevel:(BubbleLevel)gameLevel
{
    if (gameLevel == BubbleLevelHard)
    {
        _showTipLetter = NO;
    }
    else
    {
        _showTipLetter = YES;
    }
    
    if (_gameLevel == gameLevel) return;
    
    _gameLevel = gameLevel;
    
    for (int i=0;i< _gameLevel;i++)
    {
        for (int i = 'a';i<='z';i++)
        {
            NSString *letter = [NSString stringWithFormat:@"%c",i];
            letterBubble *_bubble = [letterBubble bubbleWithLetter:letter];
            _bubble.isObjectPerformScale = YES;
            [letterBubblePool addObject:_bubble];
        }
    }
    
    
}

- (NSString*) audioFileNameWithWord:(NSString*)word
{
    return [[word lowercaseString] stringByAppendingPathExtension:@"caf"];
}

#pragma mark -bubble

// 将泡泡加到物理引擎中参与运算
// 将泡泡加入到 layer 中显示出来
- (void) addBubble:(bubble*)_bubble
{
    [_bubble addToSpace:_space];
    
    cpBody *_body = _bubble.bubble.CPBody;
    //扭矩，让泡泡旋转
    cpBodySetTorque(_body, CCRANDOM_MINUS1_1()*5.0f); // torsion
    
    // x,y 两个方向的速度
    cpFloat vel_x = CCRANDOM_MINUS1_1()*100.0f;
    cpFloat vel_y = CCRANDOM_0_1()*100.0f + 60.0f;
    cpBodySetVel(_body, cpv(vel_x, vel_y)); // velocity
    
    // 添加精灵
    [self addChild:_bubble.bubble z:Z_BUBBLE];
    if (_bubble.object)
        [self addChild:_bubble.object z:Z_OBJECT];
}

// 从物理引擎中移除泡泡
// 从屏幕上移除精灵
- (void) removeBubble:(bubble*)_bubble
{
    [_bubble removeFromSpace:_space];
    
    [self removeChild:_bubble.bubble];
    [self removeChild:_bubble.object];
}

#pragma mark -logic

- (void) updateScoreLabel
{
    if (!_scoreLabel) return;
    
    NSString *score = [NSString stringWithFormat:@"%d",_score];
    [_scoreLabel setString:score];
}

- (void) updateCoinLabel
{
    if (!_coinLabel) return;
    
    NSString *coin = [NSString stringWithFormat:@"%d",_coin];
    [_coinLabel setString:coin];

}

- (void) updateLifeStars
{
    if (!_livesStars) return;
    
    CCSprite *star = nil;
    for (int i = 1;i <= _lifeMax;i++)
    {
        star = (CCSprite*)[_livesStars objectAtIndex:i-1];
        if (i <= _life)
            star.visible = YES;
        else star.visible = NO;
    }
}

- (void) updateTipLetters
{
    if (!_tipLetters || [_tipLetters count] == 0) return;
    
    CCSprite *_temp = nil;
    for (int i = 0; i < _currentWordLength;i++)
    {
        _temp = [_tipLetters objectAtIndex:i];
        if (i < _selectedWordLength && _showTipLetter)
            _temp.visible = YES;
        else _temp.visible = NO;
    }
}

- (void) resetTipLetters
{
    [reef removeAllChildrenWithCleanup:YES];
    
    NSString *word = [_words objectAtIndex:_currentIndex];
    _currentWordLength = word.length;
    _selectedWordLength = 0;
    
    [_tipLetters removeAllObjects];
    
    CGPoint reef_size = ccpFromSize(reef.boundingBox.size);
    CGPoint temp_pos = ccpCompMult(reef_size, ccp(0.145, 0.45));
    CGFloat y_offset = -8;
    
    for (int i = 0;i < _currentWordLength;i++)
    {
        char _temp = [word characterAtIndex:i];
        NSString *backImg = [NSString stringWithFormat:@"tip_back_%c.png",_temp];
        NSString *frontImg = [NSString stringWithFormat:@"tip_front_%c.png",_temp];
        
        CCSprite* backLetter = [CCSprite spriteWithSpriteFrameName:backImg];
        backLetter.anchorPoint = ccp(0, 0.5);
        backLetter.position = temp_pos;
        if (!_showTipLetter) backLetter.visible = NO;
        [reef addChild:backLetter];
        
        CCSprite* frontLetter = [CCSprite spriteWithSpriteFrameName:frontImg];
        frontLetter.anchorPoint = ccp(0, 0.5);
        frontLetter.position = temp_pos;
        frontLetter.visible = NO;
        [reef addChild:frontLetter];
        [_tipLetters addObject:frontLetter];
        
        temp_pos = ccpAdd(temp_pos, ccp(backLetter.boundingBox.size.width,y_offset));
    }
}

- (void) startWordWithIndex:(NSUInteger)index
{
    if (_selectedString)
    {
        [_selectedString release];
        _selectedString = nil;
    }
    _selectedString = [[NSMutableString string] retain];
    
    [self resetTipLetters];
    [self readWordWithIndex:index];
}

- (void) startCurrentWord
{
    [self startWordWithIndex:_currentIndex];
}

// 以播放音效的形式朗读单词
- (void) readWordWithIndex:(NSUInteger)index
{
    NSString *word = [_words objectAtIndex:index];
    CCLOG(@"read word:%@",word);
    NSString *audioFile = [NSString stringWithFormat:@"%@.caf",word];
    [[SimpleAudioEngine sharedEngine] playEffect:audioFile];
}

// 点击了某个字母泡泡
// 如果字母是对的，返回 true
// 否则，返回 false
- (BOOL) selectLetter:(NSString*)letter
{
    NSString *_tempStr = [_selectedString stringByAppendingString:letter];
    NSString *_currentWord = [_words objectAtIndex:_currentIndex];
    
    if ([_currentWord hasPrefix:_tempStr])
    {
        [_selectedString appendString:letter];
        return YES;
    }
    else return NO;
}

- (void) touchPropsBubble:(propsBubble*)_bubble
{
    if (_bubble.score != 0)
    {
        _score += _bubble.score;
        _score = MAX(_score, 0);
        [self updateScoreLabel];
    }
    
    if (_bubble.coin != 0)
    {
        _coin += _bubble.coin;
        _coin = MAX(_coin, 0);
        [self updateCoinLabel];
    }
    
    if (_bubble.live != 0)
    {
        _life += _bubble.live;
        _life = MAX(0, _life);
        _life = MIN(_lifeMax, _life);
        [self updateLifeStars];
    }
    
    [self removeBubble:_bubble];
}

- (void) touchLetterBubble:(letterBubble*)_bubble
{
    NSString *_letter = ((letterBubble*)_bubbleInTouch).letter;
    CCLOG(@"touch word:%@",_letter);
    if ([self selectLetter:_letter])
    {
        static int scoreRate = 100;
        _score += scoreRate;
        [self showScoreLabelWithScore:scoreRate atPosition:_bubble.pos];
        
        _selectedWordLength = MIN(_selectedWordLength+1, _currentWordLength);
        [self updateTipLetters];
        
        NSString *_currentWord = [_words objectAtIndex:_currentIndex];
        if ([_selectedString isEqualToString:_currentWord])
        {
            CCLOG(@"%@ is done",_currentWord);
            [self wordDone];
        }
    }
    else
    {
        int t_score = MIN(_score, 10);
        _score -= t_score;
        if (t_score > 0)
            [self showScoreLabelWithScore:-t_score atPosition:_bubble.pos];
        _life -= 1;
        _life = MAX(0, _life);
        [self updateLifeStars];
        if (_life <= 0)
            [self gameFailed];
    }
    
    [self updateScoreLabel];
    
    [self removeBubble:_bubble];
    [letterBubblePool addObject:_bubble];
    [letterBubbles removeObject:_bubble];
}

- (void) showScoreLabelWithScore:(NSInteger)t_score atPosition:(CGPoint)t_position
{
    if (_score == 0) return;
    
    NSString *fontFile = t_score > 0 ? @"Lithos_pro_green.fnt":@"Lithos_pro_red.fnt";
    NSString *scoreStr = [NSString stringWithFormat:@"%+d",t_score];
    CCLabelBMFont* t_label = [CCLabelBMFont labelWithString:scoreStr fntFile:fontFile];
    
    t_label.scale = 0.5;
    t_label.position = t_position;
    [self addChild:t_label z:Z_COVER];
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:0.3f position:ccp(0, 20)];
    [t_label runAction:move];
    
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.3f scale:0.8];
    CCEaseIn *scale_ease = [CCEaseIn actionWithAction:scale rate:1];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.2f];
    __block id copy_self = self;
    CCCallBlock *remove = [CCCallBlock actionWithBlock:^{
        [copy_self removeChild:t_label cleanup:YES];
    }];
    CCSequence *seq = [CCSequence actions:scale_ease,delay,remove, nil];
    [t_label runAction:seq];
}

// 单词完成
- (void) wordDone
{
    _currentIndex++;
    
    if (_currentIndex >= _wordsCount)
    {
        [self gameDone];
    }
    else
        [self performSelector:@selector(startCurrentWord) withObject:nil afterDelay:1.0f];
}

// 游戏通关
- (void) gameDone
{
    CCLOG(@"game done");
    
    [[PGManager sharedManager] finishGame:self.gameName];
    
    BubbleGameDoneLayer *layer = [[[BubbleGameDoneLayer alloc] initWithBackScene:(CCScene*)self] autorelease];
    layer.score = _score;
//    [[GameManager sharedManager] setCurrentScore:_score];
    layer.coin = _coin;
//    [[GameManager sharedManager] setCurrentCoin:_coin];
    layer.starLevel = arc4random_uniform(2) + 1;
//    [[GameManager sharedManager] setCurrentRate:layer.starLevel];
    CCScene *scene = [CCScene node];
    [scene addChild:layer];
    [[CCDirector sharedDirector] pushScene:scene];
}

// 游戏失败
- (void) gameFailed
{
    CCLOG(@"game over");
    
    [[CCDirector sharedDirector] pushScene:[BubbleGameOverLayer sceneWithBackScene:(CCScene*)self]];
}

- (void) backToMenu
{
    [self removeAllChildrenWithCleanup:YES];
    
    [[CCDirector sharedDirector] popScene];
}

#pragma mark -touch

// 注册触摸事件
-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// 点击屏幕上的一个点（座标）。先从物理引擎那获取被点击的 shape ，
// 然后从 shape 获取 data ，即 bubble 。
// 将 bubble 从物理引擎移除，然后放回泡泡池。
- (void) touchAtPosition:(CGPoint)position
{
    cpFloat radius = 10.f; //点击判断半径
    cpShape *shape = cpSpaceNearestPointQueryNearest(_space, position, radius, PhysicsBubbleBit, CP_NO_GROUP, NULL);
    if (shape)
    {
        _bubbleInTouch = (bubble*)cpShapeGetUserData(shape);
        
        if (_bubbleInTouch.bubbleType == BubbleTypeLetter)
        {
            [self touchLetterBubble:(letterBubble*)_bubbleInTouch];
        }
        else if (_bubbleInTouch.bubbleType == BubbleTypeProps)
        {
            [self touchPropsBubble:(propsBubble*)_bubbleInTouch];
        }
        else
        {
            CCLOG(@"unknow bubble type");
        }
        
        // 泡泡破碎粒子效果
        CCParticleSystem *bubble_particle = [CCParticleSystemQuad particleWithFile:@"game_bubble_particle.plist"];
        bubble_particle.autoRemoveOnFinish = YES;
        bubble_particle.positionType = kCCPositionTypeFree;
        bubble_particle.position = _bubbleInTouch.pos;
        [self addChild:bubble_particle z:Z_PARTICLES];
    }
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    cpVect pos = [self convertTouchToNodeSpace:touch];
    [self touchAtPosition:pos];
    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    cpVect pos = [self convertTouchToNodeSpace:touch];
    [self touchAtPosition:pos];
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    _bubbleInTouch = nil;
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    _bubbleInTouch = nil;
}

#pragma mark --cache

+ (void) preloadTextures
{
    NSArray *textures = @[@"bubble_object.png",
                          @"bubble_texture.png",
                          @"failed_bg.png",
                          @"game_bg.png",
                          @"game_bg_left.png",
                          @"game_bg_right.png",
                          @"pass_bg.png",
                          @"pause_menu_bg.png",
                          @"tip_letter.png",
                          @"Lithos_pro_green.png",
                          @"Lithos_pro_red.png",
                          @"Lithos_pro_white.png",
                          @"Lithos_pro_yellow.png"];
    
    for (NSString *texture in textures)
    {
        @autoreleasepool {
            [[CCTextureCache sharedTextureCache] addImage:texture];
        }
    }
}

+ (void) cleanCaches
{
    NSArray *frames = @[@"bubble_object.plist",
                        @"bubble_texture.plist",
                        @"tip_letter.plist"];
    for (NSString *frame in frames)
    {
        @autoreleasepool {
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:frame];
        }
    }
    
    NSArray *textures = @[@"bubble_object.png",
                          @"bubble_texture.png",
                          @"failed_bg.png",
                          @"game_bg.png",
                          @"game_bg_left.png",
                          @"game_bg_right.png",
                          @"pass_bg.png",
                          @"pause_menu_bg.png",
                          @"tip_letter.png",
                          @"Lithos_pro_green.png",
                          @"Lithos_pro_red.png",
                          @"Lithos_pro_white.png",
                          @"Lithos_pro_yellow.png"];
    
    for (NSString *texture in textures)
    {
        @autoreleasepool {
            [[CCTextureCache sharedTextureCache] removeTextureForKey:texture];
        }
    }

}

@end
