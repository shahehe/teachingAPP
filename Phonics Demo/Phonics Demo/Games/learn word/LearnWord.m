//
//  LearnWordGameLayer.m
//  BookReader
//
//  Created by USTB on 12-10-12.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LearnWord.h"
#import "SimpleAudioEngine.h"

@implementation LearnWord

@synthesize player = _player;
@synthesize isPaused = _isPaused;

//+ (CCScene *)scene
//{
//    CCScene *scene = [CCScene node];
//    LearnWord *gameLayer = [LearnWord node];
//    [scene addChild:gameLayer];
//    return scene;
//}

- (id) initWithGameData:(NSDictionary *)data
{
    if (self = [super initWithGameData:data])
    {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        CGPoint size = ccpFromSize(screenSize);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"learnword.plist"];
        
        //background
        CCSprite *beach = [CCSprite spriteWithFile:@"beach.png"];
        beach.position = ccpMult(size, 0.5);
        [self addChild:beach z:-1];
        
        CCSprite *cloud = [CCSprite spriteWithSpriteFrameName:@"cloud.png"];
        cloud.anchorPoint = ccp(1, 0);
        cloud.position = ccpCompMult(size, ccp(1,0.8));
        [self addChild:cloud z:0];
        
        CCSprite *shine = [CCSprite spriteWithSpriteFrameName:@"shine.png"];
        shine.anchorPoint = ccp(0.5, 0.5);
        shine.position = ccpCompMult(size, ccp(0.6,0.9));
        [self addChild:shine z:1];
        
        CCSprite *sun = [CCSprite spriteWithSpriteFrameName:@"sun.png"];
        sun.anchorPoint = ccp(0.5, 1);
        sun.position = ccpCompMult(size, ccp(0.4,1));
        [self addChild:sun z:1];
        
        CCSprite *tree = [CCSprite spriteWithSpriteFrameName:@"tree.png"];
        tree.anchorPoint = ccp(0, 0.5);
        tree.position = ccpCompMult(size, ccp(0,0.5));
        [self addChild:tree z:1];
        
        board = [CCSprite spriteWithSpriteFrameName:@"board.png"];
        board.position = ccpCompMult(size, ccp(0.5,0.53));
        board.opacity = 0; // can't be seen
        [self addChild:board z:1];
        
        // status
        self.isPaused = NO;
        time = 0;
        
//      prepear data
//        NSString *phonics = [[AppManager sharedAppmanager] currentPhonics];
//        NSString *fileName = [NSString stringWithFormat:@"%@Word",phonics];
//        NSString *file = [[NSBundle  mainBundle] pathForResource:fileName ofType:@"plist"];
        cards = [self.gameData allKeys];
        [cards retain];
        
        cardCount = [cards count];
        NSAssert(cardCount > 0, @"Card is empty");
        currentCardIndex = 0;
        
        // vector
        candidateLetterLabels = [[CCArray arrayWithCapacity:CANDIDATE] retain];
        waitingLetterLabels = [[CCArray array] retain];
        
        allLabel = [CCNode node];
        [self addChild:allLabel z:2];
        
        monster = [CCSprite spriteWithSpriteFrameName:@"monster_eye_open.png"];
        monster.anchorPoint = ccp(0, 0);
        monster.scale = 0;
        [self addChild:monster z:1];
        
        // menu
        CCSprite *back = [CCSprite spriteWithFile:@"backButton.png"];
        CCSprite *backPressed = [CCSprite spriteWithFile:@"backButtonPressed.png"];
        CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:back selectedSprite:backPressed block:^(id sender) {
            [[NSNotificationCenter defaultCenter] \
             postNotificationName:@"PhonicsGameExit" object:self];
        }];
        CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
        menu.position = ccpCompMult(size, ccp(0.05,0.95));
        [self addChild:menu z:2];
        
        // Sound effect
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"beach.caf"];
    }
    return self;
}


#pragma mark -logic

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beach.caf"];
    
    CCFadeIn *showBoard = [CCFadeIn actionWithDuration:0.8f];
    
    __block id self_copy = self;
    CCCallBlock *refresh = [CCCallBlock actionWithBlock:^{
        [self_copy refreshGameWithIndex:currentCardIndex];
        [self_copy monsterAnimation];
    }];
    
    CCSequence *seq = [CCSequence actions:showBoard,refresh, nil];
    
    [board runAction:seq];
}

- (void) onExit
{
    [super onExit];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"learnword.plist"];
    [[SimpleAudioEngine sharedEngine] unloadEffect:@"beach.caf"];
}

- (void) refreshGameWithIndex:(NSUInteger) _index
{
    NSAssert(_index < cardCount, @"learn word:can't get words");
    
    [self reset];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    CGPoint sizePoint = ccpFromSize(size);
    CGFloat _halfWidth = size.width*0.5;
    CGFloat _halfHeight = size.height*0.5;
    
    //name
    NSString *wordString = [[cards objectAtIndex:_index] uppercaseString];
    NSUInteger wordStringLenght = [wordString length];
    
//  [wordString printSelf];
    
    //color
//  NSString *colorString = [dic objectForKey:@"color"];
    
    //bgcolor
//  NSString *bgColorString = [dic objectForKey:@"bgColor"];
//  bgColor = [self string2Color:bgColorString defaultColor:bgColor];
//  bgColor = [bgColorString string2ColorWithDefaultColor:ccBLUE];
    bgColor = ccc3(1, 206, 250);
    
    //letterIndex
    NSString *indexString = @"1";
    NSArray *letterIndex = [indexString componentsSeparatedByString:@","];
    
//    waitingLetterLabels = [CCArray arrayWithCapacity:[letterIndex count]];
//    [waitingLetterLabels retain];
    
    CCArray *candidateLetters = [CCArray arrayWithCapacity:CANDIDATE];
    //将每个字母作为一个label
    CCArray *_letters = [self separateStringToLetter:wordString];
    CCArray *letterLabels = [CCArray arrayWithCapacity:wordStringLenght];
    
    CGPoint t_position = ccp(_halfWidth,_halfHeight);
    for (int i=0;i<wordStringLenght;i++)
    {
        NSString *_letter = [_letters objectAtIndex:i];
        CCLabelTTF *_letterLabel = [CCLabelTTF labelWithString:_letter fontName:FONTNAME fontSize:FONTSIZE];
        _letterLabel.anchorPoint = ccp(0,0.5);
        if ([letterIndex containsObject:[NSString stringWithFormat:@"%i",(i+1)]])
        {
            [candidateLetters addObject:_letter];
            _letterLabel.color = ccGRAY;
            [waitingLetterLabels addObject:_letterLabel];
        }
        else
        {
            _letterLabel.color = ccc3(252, 206, 0);
        }
        _letterLabel.position = t_position;
        t_position = ccp(t_position.x + _letterLabel.boundingBox.size.width, t_position.y);
    //  [self addChild:_letterLabel];
        [letterLabels insertObject:_letterLabel atIndex:i];
    }
    
    //CCLOG(@"letterLabels has %i child",[letterLabels count]);
    //CCLOG(@"waitingLetterLabels has %i child",[waitingLetterLabels count]);
    
    //将labels移到屏幕中间。
    CGFloat xOffset = (t_position.x - _halfWidth)*0.5;
//  CCLOG(@"xOffset:%f",xOffset);
    for (int i=0;i<wordStringLenght;i++)
    {
        CCLabelTTF *object = [letterLabels objectAtIndex:i];
        CGPoint _oldPosition = object.position;
        object.position = ccp(_oldPosition.x - xOffset, _oldPosition.y);
        [allLabel addChild:object z:1];
    }
    
    //初始化gradientLabelTimer
    CCLabelTTF *gradientLabel = [CCLabelTTF labelWithString:wordString fontName:FONTNAME fontSize:FONTSIZE];
//  CCLOG(@"gradient wide:%f",gradientLabel.contentSize.width);
//  gradientColor = [self string2Color:colorString defaultColor:ccBLUE];
    gradientColor = ccRED;
    gradientLabel.color = gradientColor;
    gradientLabelTimer = [CCProgressTimer progressWithSprite:gradientLabel];
    gradientLabelTimer.type = kCCProgressTimerTypeBar;
    gradientLabelTimer.midpoint = ccp(0,0);
    gradientLabelTimer.barChangeRate = ccp(1, 0);
    gradientLabelTimer.position = ccp(_halfWidth, _halfHeight);
    gradientLabelTimer.percentage = 0;
    [allLabel addChild:gradientLabelTimer z:2];
    
    //准备和添加 candidateLetter
    [candidateLetterLabels addObjectsFromArray:[self randomLetterLabelsIncludeLetters:candidateLetters andCount:CANDIDATE]];
    //candidateLetterLabels = [self randomLetterLabelsIncludeLetters:candidateLetters andCount:CANDIDATE];
    //[candidateLetterLabels retain];
    //CCLOG(@"candidateLetterLabels has %i child",[candidateLetterLabels count]);
    
    //将CANDIDATE个label摆在适当位置
    NSUInteger _candidateCount = [candidateLetterLabels count];
    CGPoint _point1 = ccpCompMult(sizePoint, ccp(0.35,0.24));
    CGPoint _point2 = ccpCompMult(sizePoint, ccp(0.39,0.14));
    CGPoint _point3 = ccpCompMult(sizePoint, ccp(0.45,0.22));
    CGPoint _point4 = ccpCompMult(sizePoint, ccp(0.48,0.13));
    CGPoint _point5 = ccpCompMult(sizePoint, ccp(0.52,0.26));
    CGPoint _point6 = ccpCompMult(sizePoint, ccp(0.57,0.14));
    CGPoint _point7 = ccpCompMult(sizePoint, ccp(0.62,0.25));
    CGPoint _point8 = ccpCompMult(sizePoint, ccp(0.66,0.16));
    CGPoint points[] = {_point1,_point2,_point3,_point4,_point5,_point6,_point7,_point8};
    for (int i=0;i<8;i++)
    {
        NSUInteger _index = arc4random() % _candidateCount;
        CCLabelTTF *tempLabel = [candidateLetterLabels objectAtIndex:_index];
        tempLabel.skewX = arc4random_uniform(21) + 20;
        tempLabel.skewX *= (arc4random_uniform(11) > 5) ? 1:-1;
        //tempLabel.skewY = arc4random_uniform(21) - 10;
        tempLabel.position = points[i];
        [allLabel addChild:tempLabel z:1];
        [candidateLetterLabels removeObject:tempLabel];
        [candidateLetterLabels addObject:tempLabel];
        _candidateCount--;
    }
    //CCLOG(@"candidateLetterLabels has %i child",[candidateLetterLabels count]);
    
    //init the player
//    NSString *audioFileName = [[NSString stringWithFormat:@"%@",wordString] lowercaseString];
    NSString *audioFileName = [[self.gameData valueForKey:[cards objectAtIndex:_index]] objectForKey:@"audioFile"];
    NSURL *//fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:audioFileName ofType:@"caf"]];
    fileURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:audioFileName isDirectory:NO];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    [self player].delegate = self;
//    [fileURL release];
    [_player prepareToPlay];
}

- (void) update:(ccTime) delta
{
    time += delta;
    if (time > 12)
    {
        [self monsterAnimation];
        time = 0;
    }
    
    NSUInteger waitingLabelCount = [waitingLetterLabels count];
    
    if (waitingLabelCount == 0)
    {
        [self unscheduleUpdate];
        [self setTouchEnabled:NO];
        [self performAudio];
        [self candidateLabelFadeOut];
        [self performGradient];
    }
    else
    {
        //遍历waitingLabels
        NSUInteger _candidateLabelCount = [candidateLetterLabels count];
        int _candidateLabelIndex = _candidateLabelCount - 1;
        
        for(;_candidateLabelIndex >= 0;_candidateLabelIndex--)
        {
            CCLabelTTF *tempCandidateLabel = [candidateLetterLabels objectAtIndex:_candidateLabelIndex];
            int _waitingLabelIndex = waitingLabelCount - 1;
            for (;_waitingLabelIndex >= 0;_waitingLabelIndex--)
            {
                CCLabelTTF *tempWaitingLabel = [waitingLetterLabels objectAtIndex:_waitingLabelIndex];
                if (CGRectContainsPoint(tempWaitingLabel.boundingBox, tempCandidateLabel.position))
                {
                    NSString *_candidateLabelString = tempCandidateLabel.string;
                    NSString *_waitingLabelString = tempWaitingLabel.string;
                    if ([_candidateLabelString isEqualToString:_waitingLabelString])
                    {
                        if (_candidateLabelIndex == isBeingTouchedLabelIndex)
                        {
                            tempCandidateLabel.color = ccGREEN;
                        }
                        else
                        {
                            CGPoint _tempWaitingLabelCenter = ccp(tempWaitingLabel.position.x+tempWaitingLabel.contentSize.width*0.5, tempWaitingLabel.position.y);
                            CCMoveTo *move = [CCMoveTo actionWithDuration:0.1 position:_tempWaitingLabelCenter];
                            [tempCandidateLabel runAction:move];
                            
                            //  将tempCandidateLabel挪动到数组最后面。
                            [candidateLetterLabels removeObject:tempCandidateLabel];
                            [waitingLetterLabels removeObject:tempWaitingLabel];
                            waitingLabelCount--;
                            
                            [self removeChild:tempWaitingLabel cleanup:NO];
                        }
                    }
                    else
                    {
                        if (_candidateLabelIndex == isBeingTouchedLabelIndex)
                        {
                            tempCandidateLabel.color = ccRED;
                        }
                    }
                    break;
                }
                else
                {
                    tempCandidateLabel.color = bgColor;
                }
            }
        }
    }
}

- (void) goToNext
{
    currentCardIndex++;
    if (currentCardIndex == cardCount)
    {
        [allLabel removeAllChildrenWithCleanup:YES];
        //[board runAction:[CCFadeOut actionWithDuration:0.4f]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"beach.caf"];
        
        // well done
        CCLabelTTF *done = [CCLabelTTF labelWithString:@"Well Done" fontName:FONTNAME fontSize:FONTSIZE/2];
        done.position = ccpCompMult(ccpFromSize(board.contentSize), ccp(0.5, 0.45));
        done.color = ccGREEN;
        [board addChild:done];
    }
    else
        [self refreshGameWithIndex:currentCardIndex];
}

- (void) reset
{
    [waitingLetterLabels removeAllObjects];
    [candidateLetterLabels removeAllObjects];
    
    [allLabel removeAllChildrenWithCleanup:YES];

    if (_player != nil)
    {
        [_player release];
        _player = nil;
    }
    
    if (!self.isPaused)    [self setTouchEnabled:YES];
    [self scheduleUpdate];
}

- (void) pause
{
    if (!self.isPaused)
    {
//        self.isTouchEnabled = NO;
        [self setTouchEnabled:YES];
        self.isPaused = YES;
    }
}

- (void) play
{
    if (self.isPaused)
    {
       
//        self.isTouchEnabled = YES;
        [self setTouchEnabled:YES];
        self.isPaused = NO;
    }
}

#pragma mark -aniamtion

- (void) monsterAnimation
{
    CCScaleTo *action1 = [CCScaleTo actionWithDuration:0.3f scale:1];
    
    CCSpriteFrame *frame1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster_eye_open.png"];
    CCSpriteFrame *frame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster_eye_close.png"];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:frame1,frame2, nil] delay:0.4];
    animation.restoreOriginalFrame = YES;
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    CCRepeat *action2 = [CCRepeat actionWithAction:animate times:2];
    
    CCScaleTo *action3 = [CCScaleTo actionWithDuration:0.3f scale:0];
    
    CCSequence *seq = [CCSequence actions:action1,action2,action3, nil];
    [monster stopAllActions];
    [monster runAction:seq];
}

- (void) performAudio
{
    [_player play];
}

- (void) candidateLabelFadeOut
{
    for (CCLabelTTF *label in candidateLetterLabels)
    {
        CCFadeOut *fade = [CCFadeOut actionWithDuration:0.8];
        [label runAction:fade];
    }
}

- (void) performGradient
{
//  ccTime _duration = MAX(_player.duration, 1.0);
    ccTime _duration = _player.duration;
    
    CCProgressFromTo *progress = [CCProgressFromTo actionWithDuration:_duration from:0 to:100];
    CCCallFunc *func = [CCCallFunc actionWithTarget:self selector:@selector(goToNext)];
    CCSequence *seq = [CCSequence actions:progress,func,nil];
    [gradientLabelTimer runAction:seq];
//  [gradientLabelTimer pauseSchedulerAndActions];
//  [gradientLabelTimer resumeSchedulerAndActions];
}

#pragma mark -string
- (CCArray*) separateStringToLetter:(NSString*)_string
{
    CCArray *strings = [CCArray arrayWithCapacity:5];
    do
    {
        NSUInteger _stringLenght = [_string length];
        if (_stringLenght == 0) break;
        
        for (int i=0;i<_stringLenght;i++)
        {
            NSRange range = NSMakeRange(i, 1);
            NSString *_letter = [_string substringWithRange:range];
            [strings insertObject:_letter atIndex:i];
        }
        break;
    } while (0);
    
    return strings;
}

- (CCArray*) randomLetterLabelsIncludeLetters:(CCArray*) _includeLetters andCount:(NSUInteger) _count
{
    CCArray *array = [CCArray arrayWithCapacity:_count];
    NSUInteger i = [_includeLetters count];

    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";//26 letters
    for(NSUInteger j=0;j<_count;j++)
    {
        NSString *_letter;
        if (j < i)
        {
            _letter = [_includeLetters objectAtIndex:j];
        }
        else
        {
            NSUInteger _index = arc4random() % 26;
            NSRange _range = NSMakeRange(_index, 1);
            _letter = [letters substringWithRange:_range];
        }
        CCLabelTTF *_label = [CCLabelTTF labelWithString:_letter fontName:FONTNAME fontSize:FONTSIZE];
        _label.color = bgColor;
        [array addObject:_label];
    }
    
    return array;
}

#pragma mark -collision


#pragma mark -touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    BOOL isTouchOnCandidateLabel = NO;
    NSUInteger _candidateCount = [candidateLetterLabels count];
    isBeingTouchedLabelIndex = -1;
    do
    {
        if (_candidateCount == 0)   break;
        CCLabelTTF *tempLabel = [candidateLetterLabels objectAtIndex:(_candidateCount - 1)];
        //tempLabel.color = ccRED;
        NSAssert(tempLabel != nil, @"tempLabel is nil");
        if (CGRectContainsPoint(tempLabel.boundingBox, location))
        {
            isBeingTouchedLabelIndex = _candidateCount - 1;
            isTouchOnCandidateLabel = YES;
            
            tempLabel.scale = 1.2;
            
            [tempLabel stopAllActions];
            if (tempLabel.skewX != 0 || tempLabel.skewY != 0)
            {
                CCSkewTo *skew = [CCSkewTo actionWithDuration:0.3f skewX:0 skewY:0];
                [tempLabel runAction:skew];
            }
            
            break;
        }
        _candidateCount--;
    } while (1);
    return isTouchOnCandidateLabel;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    time = 0;
    
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    if (isBeingTouchedLabelIndex > -1)
    {
        CCLabelTTF *tempLabel = [candidateLetterLabels objectAtIndex:isBeingTouchedLabelIndex];
        if (tempLabel != nil)
        {
            tempLabel.position = location;
    
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	//CGPoint location = [touch locationInView:[touch view]];
	//location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (isBeingTouchedLabelIndex < 0) return;
    CCLabelTTF *tempLabel = [candidateLetterLabels objectAtIndex:isBeingTouchedLabelIndex];
    //do something
    if (tempLabel != nil)
    {
        tempLabel.scale = 1.0;
        //tempLabel.color = bgColor;
        [candidateLetterLabels removeObject:tempLabel];
        [candidateLetterLabels addObject:tempLabel];
    }
        isBeingTouchedLabelIndex = -1;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	//CGPoint location = [touch locationInView:[touch view]];
	//location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (isBeingTouchedLabelIndex < 0) return;
    CCLabelTTF *tempLabel = [candidateLetterLabels objectAtIndex:isBeingTouchedLabelIndex];
    if (tempLabel != nil)
    {
        //do something
        tempLabel.scale = 1.0;
        //tempLabel.color = bgColor;
        [candidateLetterLabels removeObject:tempLabel];
        [candidateLetterLabels addObject:tempLabel];
    }
    
    isBeingTouchedLabelIndex = -1;
}

#pragma mark color

//
// 这个方法被 NSString 的 string2ColorWithDefaultColor 取代，不要再用.
//
- (ccColor3B) string2Color:(NSString *)colorStr defaultColor:(ccColor3B)defaultColor
{
    NSString *subStr = colorStr;
    ccColor3B color = defaultColor;
    
    if ([subStr hasPrefix:@"#"])  subStr = [subStr substringFromIndex:1];
    if ([subStr length] == 6)
    {
        unsigned int r, g, b;
        [[NSScanner scannerWithString:[subStr substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[subStr substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[subStr substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
        color.r = r;
        color.g = g;
        color.b = b;
    }
    
    return color;
}
#pragma mark -dealloc
-(void) dealloc
{
    [self reset];
    
    [waitingLetterLabels release];
    waitingLetterLabels = nil;
    [candidateLetterLabels release];
    candidateLetterLabels = nil;
    
    [self unscheduleAllSelectors];
    [self stopAllActions];
    //[[[CCDirector sharedDirector] touchDispatcher]removeAllDelegates];
    [cards release];
    cards = nil;
    
    [super dealloc];
}

@end

@implementation NSString (yiplee)

- (void) printSelf
{
    CCLOG(@"%@",self);
}

- (ccColor3B) string2ColorWithDefaultColor:(ccColor3B)defaultColor
{
    ccColor3B color = defaultColor;
    
    if ([self hasPrefix:@"#"])
        self = [self substringFromIndex:1];
    if ([self length] == 6)
    {
        unsigned int r, g, b;
        [[NSScanner scannerWithString:[self substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[self substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[self substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
        color.r = r;
        color.g = g;
        color.b = b;
    }
    return color;
}

@end
