//
//  CardMatchingGameLayer.m
//  Letter Games HD
//
//  Created by USTB on 12-11-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardMatchingGameLayer.h"
#import "CardMatching.h"

@implementation CardMatchingGameLayer

@synthesize totalScore = _totalScore;
@synthesize score = _score;
@synthesize time = _time;
@synthesize currentLevel = _currentLevel;

+ (instancetype) layerWithWords:(NSArray*)words
{
    return [[[self alloc] initWithWords:words] autorelease];
}

- (id) initWithWords:(NSArray *)words
{
    if (self = [super init])
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CGFloat width = size.width;
        CGFloat height = size.height;
//      CGPoint centerScreen = ccp(width*0.5f, height*0.5f);
        
        // preload word sound
        for (NSString *word in words)
        {
            NSString *wordAudioName = [NSString stringWithFormat:@"%@.caf",word];
            [[SimpleAudioEngine sharedEngine] preloadEffect:wordAudioName];
        }
        
#pragma mark -game status        
        // game status*****************************************************************
        wordsCount = MIN([words count],12);
//      NSAssert(wordsCount <= 12, @"there are too many words");
        _totalScore = 0;
        _score = 0;
        _currentLevel = 1;
        _time = 0; //120 seconds
        
        cardFlipDuration = 0.5;
        
        scoreRate = 100;
        
        isShow = NO;
        
        firstCard = nil;
        secondCard = nil;
        // game status*****************************************************************
        
#pragma mark -bus
        // bus area*********************************************************************
        nextCarIndex = 0;
        busStopShowPosition = ccp(width*0.15f, height*0.45f);
        busStopHidePosition = ccp(- width*0.15f, height*0.45f);
        busStopPlace = [CCSprite spriteWithSpriteFrameName:@"tingchewei.png"];
        busStopPlace.position = busStopHidePosition;
        [self addChild:busStopPlace];
        
        stopPostions = calloc(sizeof(CGPoint)*wordsCount, 1);
        NSAssert(stopPostions, @"stopPositions calloc failed");
        
        CGSize busStopSize = busStopPlace.contentSize;
        CGFloat busStopGridWidth = busStopSize.width * 0.5f;
        CGFloat busStopGridHeight = busStopSize.height / 6;
        cars = [CCArray arrayWithCapacity:wordsCount];
        CGPoint busStopShowOriginPoint = ccpSub(busStopShowPosition, ccp(busStopGridWidth, busStopGridHeight*3));
        for (NSUInteger i = 0;i<wordsCount;i++)
        {
            CGPoint tempPoint = ccp(((11-i)/6+0.5)*busStopGridWidth, ((11-i)%6+0.5)*busStopGridHeight);
            stopPostions[i] = ccpAdd(busStopShowOriginPoint, tempPoint);
            
            WordCar *car = [WordCar CarWithIndex:i andWord:[words objectAtIndex:i]];
            car.position = busStopHidePosition;
            [self addChild:car];
            [cars addObject:car];
        }
        numberOfShowCars = 0;
        [cars retain];
        // bus area*********************************************************************
        
#pragma mark -pencil
        //game status display area OR pencil********************************************
        pencil = [CCSprite spriteWithSpriteFrameName:@"qianbi.png"];
        pencilShowPosition = ccp(width*0.65f,height*0.9f);
        pencilHidePosition = ccp(width*0.65f,height*1.1f);
        pencil.position = pencilHidePosition;
        [self addChild:pencil];
        
        CGSize pencilSize = pencil.contentSize;
        CGFloat pencilWidth = pencilSize.width;
        CGFloat pencilHeight = pencilSize.height;
        NSString *scoreString = [NSString stringWithFormat:@"SCORE %i",_score + _totalScore];
        scoreLabel = [CCLabelBMFont labelWithString:scoreString fntFile:@"DenneSketchy30.fnt"];
        scoreLabel.anchorPoint = ccp(0, 0.5);
        scoreLabel.position = ccp(pencilWidth*0.05f, pencilHeight*0.45f);
        [pencil addChild:scoreLabel];
        
        NSString *levelString = [NSString stringWithFormat:@"LEVEL %i",_currentLevel];
        levelLabel = [CCLabelBMFont labelWithString:levelString fntFile:@"DenneSketchy30.fnt"];
        levelLabel.anchorPoint = ccp(0, 0.5);
        levelLabel.position = ccp(pencilWidth*0.35f, pencilHeight*0.45f);
        [pencil addChild:levelLabel];
        
        NSString *timeString = [NSString stringWithFormat:@"TIME %@",[NSString timeFromSecond:_time]];
        timeLabel = [CCLabelBMFont labelWithString:timeString fntFile:@"DenneSketchy30.fnt"];
        //timeLabel.anchorPoint = ccp(0, 0.5);
        timeLabel.position = ccp(pencilWidth*0.75f, pencilHeight*0.45f);
        [pencil addChild:timeLabel];
        //game status display area OR pencil*********************************************

#pragma mark -cards
        // card area *********************************************
        line = 2;
        row = 3;
        numberOfRemainCards = 0;
        cardPanel = [CCNode node];
        CGSize cardPanelSize = CGSizeMake(640, 576);
        [cardPanel setContentSize:cardPanelSize];
        cardPanel.anchorPoint = ccp(0, 0);
        cardPanelShowPosition = ccp(320, 64);
        cardPanelHidePosition = ccp(width,64);
        cardPanel.position = cardPanelHidePosition;
        [self addChild:cardPanel];
        cards = [CCArray arrayWithCapacity:wordsCount*2];
        for (NSUInteger i = 0;i<wordsCount;i++)
        {
            
            NSString *_word = [words objectAtIndex:i];
            Card *card1 = [Card cardWithCardWord:_word];
            Card *card2 = [Card cardWithCardWord:_word];
            [card1 setVertexZ:card1.contentSize.width*0.5f];
            [card2 setVertexZ:card1.contentSize.width*0.5f];
            card1.visible = NO;
            card2.visible = NO;
            [cardPanel addChild:card1];
            [cardPanel addChild:card2];
            [cards addObject:card1];
            [cards addObject:card2];
        }
        [cards retain];
        // card area *********************************************
        
        //pause button
        CCSprite *button = [CCSprite spriteWithSpriteFrameName:@"pauseButton.png"];
        CCSprite *buttonPressed = [CCSprite spriteWithSpriteFrameName:@"pauseButtonPressed.png"];
        
        __block id copy_self = self;
        CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemWithNormalSprite:button selectedSprite:buttonPressed block:^(id sender) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"button.caf"];
            [copy_self pauseButtonPressed];
        }];
        CCMenu *menu = [CCMenu menuWithItems:pauseButton, nil];
        menu.position = ccp(width*0.1, height*0.9);
        [self addChild:menu];
    }
    return self;
}

- (void) pauseButtonPressed
{
    [(CardMatching*)self.parent.parent pause];
}

- (void) updatePerMinute
{
    _time--;
    if (_time == 0)
        [self gameOver];
    else if (_time <= 5)
    {
        CCScaleTo *scale1 = [CCScaleTo actionWithDuration:0.4f scale:1.2];
        CCEaseOut *ease1 = [CCEaseOut actionWithAction:scale1 rate:1];
        CCScaleTo *scale2 = [CCScaleTo actionWithDuration:0.4f scale:1.0];
        CCEaseIn *ease2 = [CCEaseIn actionWithAction:scale2 rate:1];
        
        CCSequence *seq = [CCSequence actionOne:ease1 two:ease2];
        [timeLabel runAction:seq];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"buuu.caf"];
    }
    NSString *timeString = [NSString stringWithFormat:@"TIME %@",[NSString timeFromSecond:_time]];
    [timeLabel setString:timeString];
}

- (void) updateScoreLabel
{
    NSString *scoreString = [NSString stringWithFormat:@"SCORE %i",_score + _totalScore];
    [scoreLabel setString:scoreString];
}

- (void) prepareLayer
{
    // cards
    CGSize cardPanelSize = cardPanel.contentSize;
    CGFloat cardPanelWidth = cardPanelSize.width;
    CGFloat cardPanelHeight = cardPanelSize.height;
    
    CGFloat gridWidth = cardPanelWidth / row;
    CGFloat gridHeight = cardPanelHeight / line;
    numberOfRemainCards = line * row;
    CGPoint *points = calloc(sizeof(CGPoint)*numberOfRemainCards, 1);
    for (NSUInteger i = 0;i < line;i++)
        for (NSUInteger j = 0;j < row;j++)
        {
            points[i*row + j] = ccp(gridWidth*(j+0.5), gridHeight*(i+0.5));
        }
    
    for (NSUInteger i = 0;i < numberOfRemainCards;i++)
    {
        NSUInteger _index = arc4random_uniform(numberOfRemainCards - i);
        Card *_card = [cards objectAtIndex:i];
        [_card hideDirect];
        _card.scale = 1.0f;
        _card.position = points[_index];
        _card.visible = YES;
        float _scale = MIN((gridHeight-10)/_card.contentSize.height,1);
        _card.scale = _scale;
        points[_index] = points[numberOfRemainCards - i - 1];
    }
    
    free(points);
    
    // cars
    numberOfShowCars = 0;
    for (WordCar *car in cars)
    {
        [car stopAllActions];
        car.position = busStopHidePosition;
    }
    
    //game status
    scoreRate = 100;
    _score = 0;
//  _score += _time * 10;
    [self updateScoreLabel];
    
    _time = 60;
    
    NSString *timeString = [NSString stringWithFormat:@"TIME %@",[NSString timeFromSecond:_time]];
    [timeLabel setString:timeString];
    
    //bus stop
    nextCarIndex = 0;
    
    //pencil
    NSString *levelString = [NSString stringWithFormat:@"LEVEL %i",_currentLevel];
    [levelLabel setString:levelString];
}

- (void) reset
{
    scoreRate = 100;
    
    firstCard = nil;
    secondCard = nil;
    
    for (Card *card in cards)
        card.visible = NO;
}

- (void) hideWithDuration:(ccTime)_duration
{
    if (!isShow) return;
    isShow = NO;
    
    // cars
    CGFloat width = [[CCDirector sharedDirector] winSize].width;
    for (NSUInteger i = 0;i < numberOfShowCars;i++)
    {
        WordCar *car = [cars objectAtIndex:i];
        [car stopAllActions];
        CGPoint destination = ccp( width+car.boundingBox.size.width, car.position.y);
        [car runTo:destination withDuration:_duration];
    }
    
    //pencil
    CCMoveTo *movePencil = [CCMoveTo actionWithDuration:_duration position:pencilHidePosition];
    CCEaseOut *easePencil = [CCEaseOut actionWithAction:movePencil rate:1];
    [pencil runAction:easePencil];
    
    
    //card Panel
    CCMoveTo *movePanel = [CCMoveTo actionWithDuration:_duration position:cardPanelHidePosition];
    CCEaseOut *easePanel = [CCEaseOut actionWithAction:movePanel rate:1];
    [cardPanel runAction:easePanel];
    
    // bus stop
    CCMoveTo *moveStopPlace = [CCMoveTo actionWithDuration:_duration position:busStopHidePosition];
    CCEaseOut *easeStopPlace = [CCEaseOut actionWithAction:moveStopPlace rate:1];
    
    [busStopPlace runAction:easeStopPlace];
    
    [self setTouchEnabled:NO];
    
    //schedule
    [self unschedule:@selector(updatePerMinute)];
}

- (void) hideimmediately
{
    if (!isShow) return;
    isShow = NO;
    
    for (WordCar *car in cars)  car.position = busStopHidePosition;
    pencil.position = pencilHidePosition;
    cardPanel.position = cardPanelHidePosition;
    busStopPlace.position = busStopHidePosition;
}

- (void) showWithDuration:(ccTime)_duration
{
    if (isShow) return;
    isShow = YES;
    
    //pencil
    CCMoveTo *movePencil = [CCMoveTo actionWithDuration:_duration position:pencilShowPosition];
    CCEaseOut *easePencil = [CCEaseOut actionWithAction:movePencil rate:1];
    [pencil runAction:easePencil];
    
    //card Panel
    CCMoveTo *movePanel = [CCMoveTo actionWithDuration:_duration position:cardPanelShowPosition];
    CCEaseOut *easePanel = [CCEaseOut actionWithAction:movePanel rate:1];
    [cardPanel runAction:easePanel];
    
    // bus stop
    CCMoveTo *moveStopPlace = [CCMoveTo actionWithDuration:_duration position:busStopShowPosition];
    CCEaseOut *easeStopPlace = [CCEaseOut actionWithAction:moveStopPlace rate:1];
    [busStopPlace runAction:easeStopPlace];
    
    [self setTouchEnabled:YES];
    
    //schedule
    [self unschedule:@selector(updatePerMinute)];
    [self schedule:@selector(updatePerMinute) interval:1.0f];
}

- (void) levelDone
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"applause.caf"];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    //score
    _totalScore += _score;
    _score = _totalScore;
    _totalScore += _time * (20);
    
    // firework
    CCParticleSystem* firework = [CCParticleSystemQuad particleWithFile:@"firework.plist"];
    firework.positionType = kCCPositionTypeFree;
    firework.autoRemoveOnFinish = YES;
    firework.position = ccp(width*0.5f, height*0.75f);
    [self addChild:firework];
    
    _currentLevel++;
    switch (_currentLevel) {
        case 0:
        case 1:
            _currentLevel = 1;
            line = 2;row = 3;
            break;
        case 2:
            line = 2;row = 4;
            break;
        case 3:
            line = 3;row = 4;
            break;
        case 4:
            line = 4;row = 4;
            break;
        case 5:
            line = 4;row = 5;
            break;
        case 6:
            line = 4;row = 6;
            break;
        default:
            _currentLevel = 1;
            line = 2;row = 3;
            [self gameDone];
            return;
            break;
    }
    NSUInteger needWords = line*row*0.5f;
    if (needWords > wordsCount)
    {
        [self gameDone];
        return;
    }
    
    // call parent to switch layer
    CCCallBlock *hide = [CCCallBlock actionWithBlock:^{
        [self hideWithDuration:2.0f];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.05f];
    CCCallBlock *callParent = [CCCallBlock actionWithBlock:^{
        [(CardMatching*)self.parent.parent levelDone];
    }];
    
    CCSequence *seq = [CCSequence actions:hide,delay,callParent, nil];
    [self runAction:seq];
}

- (void) gameDone
{
    line = 2;
    row = 3;
    _currentLevel = 1;
    
    CCCallBlock *hide = [CCCallBlock actionWithBlock:^{
        [self hideWithDuration:2.0f];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.05f];
    CCCallBlock *callParent = [CCCallBlock actionWithBlock:^{
        [(CardMatching*)self.parent.parent gameDone];
    }];
    CCSequence *seq = [CCSequence actions:hide,delay,callParent, nil];
    [self runAction:seq];
}

- (void) gameOver
{
    _score += _totalScore;
    [self hideimmediately];
    [(CardMatching*)self.parent.parent gameOver];
}

- (void) onEnter
{
    [super onEnter];
}

- (void) onExit
{
    [super onExit];
}

- (void) dealloc
{
    [self unscheduleAllSelectors];
    [[[CCDirector sharedDirector] touchDispatcher] removeAllDelegates];
    [cars release];
    cars = nil;
    [cards release];
    cards = nil;
    
    free(stopPostions);
    [super dealloc];
}

#pragma mark -touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    Card *_card = [self cardByTouched:location];
    if (_card)
    {
        if (!_card.isShow)
        {
            [_card flipCardFromDirection:FlipFromRight withDuration:cardFlipDuration];
            NSString *wordFile = [[NSBundle mainBundle] pathForResource:_card.word ofType:@"caf"];
            [[SimpleAudioEngine sharedEngine] playEffect:wordFile];
        }
        
        if (!firstCard)
        {
            firstCard = _card;
            //[[SimpleAudioEngine sharedEngine] playEffect:@"select1.caf"];
        }
        else if (!secondCard)
        {
            secondCard = _card;
            //[[SimpleAudioEngine sharedEngine] playEffect:@"select2.caf"];
            if (secondCard == firstCard)
            {
                scoreRate = 100;
                
                [secondCard hideFromDirection:FlipFromRight withDuration:cardFlipDuration];
                firstCard = nil;
                secondCard = nil;
                return NO;
            }

            [self setTouchEnabled:NO];
            CCDelayTime *delay = [CCDelayTime actionWithDuration:cardFlipDuration+0.1f];
            CCCallBlock *compare = [CCCallBlock actionWithBlock:^{
                if ([firstCard isMatchWithCard:secondCard])
                {
                    firstCard.visible = NO;
                    secondCard.visible = NO;
                    NSInteger index = [cards indexOfObject:firstCard]/2;
                    WordCar *car = [cars objectAtIndex:index];
                    [car runTo:stopPostions[nextCarIndex++] withDuration:0.4f];
                    numberOfShowCars++;
                    numberOfRemainCards = numberOfRemainCards - 2;
                    
                    //particle
                    CCParticleSystem* cardSmash = [CCParticleSystemQuad particleWithFile:@"star.plist"];
                    cardSmash.positionType = kCCPositionTypeFree;
                    cardSmash.autoRemoveOnFinish = YES;
                    cardSmash.position = firstCard.position;
                    [cardPanel addChild:cardSmash];
                    
                    CCParticleSystem* cardDisappear = [CCParticleSystemQuad particleWithFile:@"star.plist"];
                    cardDisappear.positionType = kCCPositionTypeFree;
                    cardDisappear.autoRemoveOnFinish = YES;
                    cardDisappear.position = secondCard.position;
                    [cardPanel addChild:cardDisappear];
                    
                    _score += scoreRate;
                    scoreRate += 100;
                    [self updateScoreLabel];
                }
                else
                {
                    [firstCard flipCardFromDirection:FlipFromRight withDuration:cardFlipDuration];
                    [secondCard flipCardFromDirection:FlipFromRight withDuration:cardFlipDuration];
                    
                    scoreRate = 100;
                }
                firstCard = nil;
                secondCard = nil;

                [self setTouchEnabled:YES];
            }];
            CCDelayTime *delay2 = [CCDelayTime actionWithDuration:cardFlipDuration+0.1f];
            CCCallBlock *levelDone = [CCCallBlock actionWithBlock:^{
                if (numberOfRemainCards <= 0)
                    [self levelDone];
            }];
            CCSequence *seq = [CCSequence actions:delay,compare,delay2,levelDone, nil];
            [self runAction:seq];
        }
        
        return NO;
    }
    
    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    
}

- (Card*) cardByTouched:(CGPoint)touch
{
    Card *card = nil;
    if (CGRectContainsPoint(cardPanel.boundingBox, touch))
    {
        NSUInteger i = 0;
        NSUInteger cardsCount = [cards count];
        while (i < cardsCount)
        {
            Card *tempCard = [cards objectAtIndex:i++];
            if (tempCard.visible && CGRectContainsPoint(tempCard.boundingBox, ccpSub(touch, cardPanel.boundingBox.origin)))
            {
                card = tempCard;
                break;
            }
        }
    }
    return card;
}

@end

@implementation NSString (cardMatching)

+ (NSString*) timeFromSecond:(NSInteger)_second
{
    NSString *time = @"";
    if (_second <= 0) return @"00:00";
    NSUInteger hour = _second / 3600;
    if (hour > 0)
        time = [NSString stringWithFormat:@"%@%02i:",time,hour];
    NSUInteger minute = _second % 3600 /60;
    time = [NSString stringWithFormat:@"%@%02i:",time,minute];
    NSUInteger second = _second % 60;
    time = [NSString stringWithFormat:@"%@%02i",time,second];
    return time;
}

@end
