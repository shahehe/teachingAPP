//
//  SearchWordGameLayer.m
//  BookReader
//
//  Created by USTB on 12-10-24.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchWord.h"

#import "Color.h"
#import "ExtraAction.h"

@implementation SearchWord

@synthesize gridHeght = _gridHeight,gridWidth = _gridWidth;
@synthesize panelHeight = _panelHeight,panelWidth = _panelWidth;
@synthesize choosedString = _choosedString;

@synthesize player = _player;

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    SearchWord *searchWordGameLayer = [SearchWord node];
    [scene addChild:searchWordGameLayer];
    return scene;
}

- (id) initWithGameData:(NSDictionary *)data
{
    if (self = [super initWithGameData:data])
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"searchWord.plist"];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //background
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"background.png"];
        background.anchorPoint = ccp(0, 0);
        [self addChild:background z:-1];

        words = [CCArray arrayWithNSArray:[self.gameData allKeys]];
        CCLOG(@"tatal %d word",[words count]);
        
        wordsNotInsert = [words count];
        
        //  init gridPanel
        self.panelWidth = 630;
        self.panelHeight = 720;
        self.gridWidth = 90;
        self.gridHeght = 90;
        
        _letterSize = 80;
        
        enableVertical = YES;
        enableHorizontal = YES;
        enableDiagonalUp = YES;
        enableDiagonalDown = YES;
        enableBackward = YES;
        
        //  game
        gameIndex = 0;
        choosedLabels = [CCArray arrayWithCapacity:5]; //CCArray是动态数组，这里的5没有影响
        self.choosedString = @"";
        firstIndex = -1;
        lastIndex = -1;
        
        isLevelDone = NO;
        
        //color
        originColor = ccBLACK;
    //  correctColor = ccGREEN;
    //  wrongColor = ccRED;
        
        CCSprite *_board = [CCSprite spriteWithFile:@"sige.png"];
        CGFloat _scale = _board.contentSize.width/2/_gridWidth;
        CCLOG(@"scale:%f",_scale);
        CGRect boardRect = CGRectMake(0, 0, _panelWidth*_scale, _panelHeight*_scale);
        
        CCSprite *panelboard = [CCSprite spriteWithTexture:_board.texture rect:boardRect];
        ccTexParams params =
        {
            GL_LINEAR,
            GL_LINEAR,
            GL_REPEAT,
            GL_REPEAT
        };
        [panelboard.texture setTexParameters:&params];
        panelboard.scale = 1/_scale;
        panelboard.anchorPoint = ccp(0,0);
        CCNode *panel = [CCNode node];
        [panel setContentSize:CGSizeMake(self.panelWidth , self.panelHeight)];
        panel.anchorPoint = ccp(0.5, 0.5);
        panel.position = ccp(panel.contentSize.width*0.5+20, size.height*0.5);
        [panel addChild:panelboard];
        [self addChild:panel z:1 tag:PanelTag];
        
        //font batch node
        letterNode = [CCSpriteBatchNode batchNodeWithFile:@"FrankfurterStd.png"];
        [panel addChild:letterNode z:1];
        
        //board
        board = [CCSprite spriteWithSpriteFrameName:@"ban.png"];
        board.position = ccp(size.width*0.84, size.height*0.6);
        [self addChild:board z:1];
        
        //backboard
        CGRect backboardRect = CGRectMake(0, 0, _panelWidth+20, _panelHeight+20);
        CCSprite *backboard = [CCSprite spriteWithFile:@"smallCube.png" rect:backboardRect];
        backboard.color = ccc3(255,136,10);
        backboard.position = ccp(panel.contentSize.width*0.5, panel.contentSize.height*0.5);
        [panel addChild:backboard z:-1];
        
        //cat
        cat = [Tiger newTiger];
        cat.position = ccp(size.width*0.84, size.height*0.75);
        [self addChild:cat z:0];
        
        //insect
        insect = [FreeMoveObject objectWithSpriteFrameName:@"chong.png" startRotation:-90];
        insect.moveSpeed = 120;
        insect.rotateSpeed = 360;
        insect.movingRect = board.boundingBox;
        insect.position = ccp(size.width*0.95, size.height*0.70);
        [self addChild:insect z:3];
        
        //word board
        wordBoard = [CCSprite spriteWithSpriteFrameName:@"yun.png"];
        wordBoard.position = ccp(size.width*0.84, size.height*0.25);
        [self addChild:wordBoard z:1];
        CGPoint wordBoardCenter = ccpMult(ccp(wordBoard.contentSize.width, wordBoard.contentSize.height), 0.5);
        CGSize wordBoardSize = CGSizeMake(150, 150);
        NSUInteger wordBoardLabelSize = 150/([words count]);
        NSString *wordLabelString = @"WORDS:\n";
//        wordBoardLabel = [CCLabelTTF labelWithString:wordLabelString dimensions:wordBoardSize hAlignment:kCCTextAlignmentLeft vAlignment:kCCTextAlignmentLeft lineBreakMode:kCCLineBreakModeWordWrap fontName:@"DENNE|Sketchy" fontSize:wordBoardLabelSize];
        wordBoardLabel = [CCLabelTTF labelWithString:wordLabelString
                                            fontName:@"DENNE|Sketchy"
                                            fontSize:wordBoardLabelSize
                                          dimensions:wordBoardSize
                                          hAlignment:kCCTextAlignmentLeft
                                          vAlignment:kCCVerticalTextAlignmentCenter
                                       lineBreakMode:kCCLineBreakModeWordWrap];
        wordBoardLabel.position = wordBoardCenter;
        wordBoardLabel.color = originColor;
        [wordBoard addChild:wordBoardLabel];
        
        // menu
        // menu
        CCSprite *back = [CCSprite spriteWithFile:@"backButton.png"];
        CCSprite *backPressed = [CCSprite spriteWithFile:@"backButtonPressed.png"];
        CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:back selectedSprite:backPressed block:^(id sender) {
            [[NSNotificationCenter defaultCenter] \
             postNotificationName:@"PhonicsGameExit" object:self];
        }];
        CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
        menu.position = ccpCompMult(ccpFromSize(size), ccp(0.95,0.95));
        [self addChild:menu z:4];
        
        /******* retain area ****************/
        [words retain]; //  release at dealloc
        [choosedLabels retain]; //  release at dealloc
        //[self.choosedString retain];
        /******* retain area ****************/
        
        /****** release area ****************/
        
        /****** release area ****************/
    }
    return self;
}

- (void) onEnter
{
    [super onEnter];
    
    //  CGSize size = [[CCDirector sharedDirector] winSize];
    
    //  insert words into grid
    //  m : gridWidthCount
    //  n : gridHeightCount
    NSUInteger m = self.panelWidth/self.gridWidth;
    NSUInteger n = self.panelHeight/self.gridHeght;
    
    //  init grid
    char letters[m][n];
    for (NSUInteger i=0;i<m;i++)
        for (NSUInteger j=0;j<n;j++)
            letters[i][j] = '*';
    
    //  init label array
    letterLabels = [CCArray arrayWithCapacity:m*n];
    
    enum Direction _direction;
    NSInteger startX = 0,startY = 0;
    NSInteger directionX = 0,directionY = 0;
    NSString *line;
    NSUInteger failedTimes = 0;
    
    NSAssert(enableVertical||enableHorizontal||enableDiagonalUp||enableDiagonalDown, @"all directions has been disabled");
    
    //  loop
    while (wordsNotInsert > 0)
    {
        if (failedTimes > 20)
        {
            CCLOG(@"have to give up remain words:");
            for (int __index=0;__index < wordsNotInsert;__index++)
            {
                CCLOG(@"%@",[words objectAtIndex:0]);
                [words removeObjectAtIndex:0];
            }
            break;
        }
        
        line = @"";
        
        //  get a random direction
        //  get a random line
        //  direction = Vertical, m lines
        //  direction = Horizontal, n lines
        //  direction = DiagonalUp, m+n-1 lines
        //  direction = DiagonalDown, m+n-1 lines
        _direction = arc4random_uniform(4);
        if (_direction == Vertical)
        {
            if (!enableVertical) continue;
            startX = arc4random_uniform(m);
            startY = n-1;
            directionX = 0;
            directionY = -1;
            for (NSUInteger i=0;i<n;i++)
            {
                //NSString *_letter = [NSString stringWithFormat:@"%c",letters[startX][startY-i]];
                line = [line stringByAppendingFormat:@"%c",letters[startX][startY-i]];
            }
        }
        
        else if(_direction == Horizontal)
        {
            if (!enableHorizontal) continue;
            startX = 0;
            startY = arc4random_uniform(n);
            directionX = 1;
            directionY = 0;
            for (NSUInteger i=0;i<m;i++)
            {
                line = [line stringByAppendingFormat:@"%c",letters[startX+i][startY]];
            }
        }
        
        else if (_direction == DiagonalUp)
        {
            if (!enableDiagonalUp) continue;
            
            NSUInteger _index = arc4random_uniform(m+n-1);
            directionX = 1;
            directionY = 1;
            if (_index < n)
            {
                startX = 0;
                startY = _index;
            }
            
            else
            {
                startX = _index - n + 1;
                startY = 0;
            }
            
            for (NSUInteger i=0;;i++)
            {
                if (startX+i >= m || startY+i >= n) break;
                line = [line stringByAppendingFormat:@"%c",letters[startX+i][startY+i]];
            }
        }
        else if (_direction == DiagonalDown)
        {
            if (!enableDiagonalDown) continue;
            
            NSUInteger _index = arc4random_uniform(m+n-1);
            directionX = 1;
            directionY = -1;
            if (_index < n)
            {
                startX = 0;
                startY = _index;
            }
            
            else
            {
                startX = _index - n + 1;
                startY = n-1;
            }
            
            for (NSInteger i=0;;i++)
            {
                if (startX+i >= m || startY-i < 0) break;
                line = [line stringByAppendingFormat:@"%c",letters[startX+i][startY-i]];
            }

        }
        //CCLOG(line);
    
        //insert word into line
        NSUInteger _remainWord = wordsNotInsert;
        CCLOG(@"remain word:%d",_remainWord);
        int i = 0;
        for (;i<_remainWord;i++)
        {
            NSString *_word = [[words objectAtIndex:i] uppercaseString];
            CCLOG(@"get word:%@",_word);
            int _index = [_word insertIntoString:line enableBackward:enableBackward];
            if (_index == 0) continue;
            else
            {
                CCLOG(@"%@ insert into %@ succesfully",_word,line);
                CCLOG(@"failed %d times",failedTimes);
                failedTimes = 0;
                
                wordsNotInsert--;
                
                //put word into line
                NSUInteger _startPosition = abs(_index)-1;
  
                NSUInteger _wordLength = [_word length];
      
                int _lineDirection = _index < 0 ? -1:1;

                for (int j=0;j<_wordLength;j++)
                {
                   
                    NSAssert(_startPosition>=0 && _startPosition < [line length], @"out of range");
                    NSString *__letter = [_word substringWithRange:NSMakeRange(j, 1)];
                    
                    line = [line stringByReplacingCharactersInRange:NSMakeRange(_startPosition, 1) withString:__letter];
                    
                    _startPosition = _startPosition + _lineDirection;
                }
                
                //move this word to the tail
                CCLOG(@"remove %@ at %d",[words objectAtIndex:i],i);
                [words removeObjectAtIndex:i];
                [words addObject:_word];
                
                //write line back to grid
                NSUInteger _lineLength = [line length];
                for (int j=0;j<_lineLength;j++)
                {
                    letters[startX+directionX*j][startY+directionY*j] = [line characterAtIndex:j];
                }
                
                CCLOG(@"%@",line);
                break;
            }
        }
        if (i == _remainWord) failedTimes++;
    }
    CCLOG(@"insert done");
    
    //use random letter to fill blank grid ('*")
    //transform char array to label and add to panel
    
    //CCNode *_panel = [self getChildByTag:PanelTag];
    
    NSString *_allLetter = [@"abcdefghijklmnopqrstuvwxyz" uppercaseString];
    for (int i=0;i<m;i++)
    {
        for (int j=0;j<n;j++)
        {
            if(letters[i][j] == '*')
            {
                letters[i][j] = [_allLetter randomCharacter];
            }
            NSString *_str = [NSString stringWithFormat:@"%c",letters[i][j]];
            
            CCLabelBMFont *_label = [CCLabelBMFont labelWithString:_str fntFile:@"FrankfurterStd.fnt"];
            [letterLabels addObject:_label];
            //_label.anchorPoint = ccp(0.5, 0.5);
            //_label.position = ccp(self.gridWidth*(0.5+i), self.gridHeght*(0.5+j)-8);
            //_label.color = originColor;
            //[_panel addChild:_label z:1];
            [_label addToBatchNode:letterNode zOrder:1 position:ccp(self.gridWidth*(0.5+i), self.gridHeght*(0.5+j)-8)];
        }
    }
    
    //CCLOG(@"labels:%d",[letterLabels count]);
    
    //schedule
    [self refreshGameWithIndex:gameIndex];
    //  [self scheduleUpdate];
    [self setTouchEnabled:YES];
    
    //insect
    [insect beClicked];
    
    /******* retain area ****************/
    [letterLabels retain]; //  release at dealloc
    /******* retain area ****************/
    
    /****** release area ****************/
    
    /****** release area ****************/
}

- (void) onExit
{
    [super onExit];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"searchWord.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"catAnimation.plist"];
}

- (void) refreshGameWithIndex:(NSUInteger) _index
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // color
    coverColor = [Color randomBrightColor];
    [Color introduceColor:originColor];
    [Color introduceColor:coverColor];
    
    // label
    NSString *_word = [words objectAtIndex:_index];
    NSString *_fontName = @"DENNE|Sketchy";
    NSUInteger _fontSize = 80;
    if (wordLabel == nil)
    {
        wordLabel = [GradientLabel LabelWithString:_word FontName:_fontName FontSize:_fontSize BackgroundColor:originColor CoverColor:coverColor];
        NSAssert(board, @"board is not added");
        wordLabel.position = ccpSub(board.position,ccp(0, 5));
        [self addChild:wordLabel z:1 tag:WordTag];
    }
    else
    {
        CGPoint t_position = wordLabel.position;
       
        
        CCFadeOut *fadeout = [CCFadeOut actionWithDuration:0.5];
        CCMoveTo *moveIn = [CCMoveTo actionWithDuration:0.5 position:t_position];
        CCEaseOut *easeOut = [CCEaseOut actionWithAction:moveIn rate:4];
        CCCallBlock *updateLabel = [CCCallBlock actionWithBlock:^{
            if (wordBoardLabel)
            {
                NSString *tempString = [NSString stringWithFormat:@"%@",wordBoardLabel.string];
                NSString *appendingString = [NSString stringWithFormat:@" %@",wordLabel.string];
                [wordBoardLabel setString:[tempString stringByAppendingString:appendingString]];
            }
            wordLabel.position = ccp(size.width+wordLabel.contentSize.width, t_position.y);
            [wordLabel setLabelString:_word withCoverColor:coverColor];
            wordLabel.opacity = 255;
        }];
        //CCFadeIn *fadein = [CCFadeIn actionWithDuration:0.5];
        CCSequence *seq = [CCSequence actions:fadeout,updateLabel,easeOut, nil];
        
        //CCBlink *blink = [CCBlink actionWithDuration:0.5f blinks:3];
        [wordLabel runAction:seq];
        //[wordLabel runAction:blink];
    }
    
    //init player
    if (_player != nil)
    {
        [_player release];
        _player = nil;
        
    }
    NSString *audioFileName = [[self.gameData valueForKey:[_word lowercaseString]] objectForKey:@"audioFile"];
    NSURL *fileURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:audioFileName isDirectory:NO];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    if (self.player)
    {
        _player.delegate = self;
    }
//    [fileURL release];
    [_player prepareToPlay];
    
    isLevelDone = NO;
    [self setTouchEnabled:YES];
}



- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (isLevelDone)
        [self goToNext];
}

#pragma mark -touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (insect && CGRectContainsPoint(insect.boundingBox,location))
    {
        [insect beClicked];
        return NO;
    }
    
    if (CGRectContainsPoint(cat.boundingBox, location) && !CGRectContainsPoint(board.boundingBox, location))
    {
        [cat speakWithDuration:_player.duration];
        [_player play];
        return NO;
    }
    
    /*
    if (CGRectContainsPoint(wordLabel.boundingBox, location))
    {
        [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
        return NO;
    }
     */
    
    self.choosedString = @"";
    [choosedLabels removeAllObjects];
    
    NSInteger _index = [self indexOfLetterByPosition:location];
    if (_index != NSNotFound)
    {
        CGPoint t_positin = [self positionByIndex:_index];
        firstIndex = _index;
        lastIndex = _index;
        
        currentLine = [CCLinePro lineFromStartPoint:t_positin toEndPoint:t_positin withWidth:_letterSize];
        currentLine.color = coverColor;
        currentLine.opacity = 255*0.4;
        [[self getChildByTag:PanelTag] addChild:currentLine z:0];
        
        [self letterFormIndex:firstIndex toIndex:lastIndex];
    }
    

    return YES;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    NSInteger _index = [self indexOfLetterByPosition:location];
    if (_index != NSNotFound)
    {
        CGPoint t_positin = [self positionByIndex:_index];
        if (firstIndex == -1)
        {
            firstIndex = _index;
            lastIndex = _index;
            
            currentLine = [CCLinePro lineFromStartPoint:t_positin toEndPoint:t_positin withWidth:_letterSize];
            currentLine.color = coverColor;
            currentLine.opacity = 255*0.4;
            [[self getChildByTag:PanelTag] addChild:currentLine z:0];
        }
        else if (lastIndex != _index)
        {
            lastIndex = _index;
            if([self letterFormIndex:firstIndex toIndex:lastIndex])
                currentLine.endPoint = t_positin;
        }
    }
    }

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    firstIndex = lastIndex = -1;
    NSString *_word = [words objectAtIndex:gameIndex];
    if ([_word isEqualToString:self.choosedString])
    {
        [self setTouchEnabled:NO];
        [_player play];
        //CCLOG(@"player duration:%f",_player.duration);
        [wordLabel playTo:100 withDuration:_player.duration];
        [cat speakWithDuration:_player.duration];
        isLevelDone = YES;
    }
    else
    {
        if ([choosedLabels count] > 0)
        {
            [cat shakingHeadWithDuration:0.4];
            if ([wordLabel numberOfRunningActions] == 0)
                [wordLabel shakeWithRound:1];
        
            if (currentLine)
            {
                [[self getChildByTag:PanelTag] removeChild:currentLine cleanup:YES];
                currentLine = nil;
            }
        }
    }
    
    
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    firstIndex = lastIndex = -1;
    if (currentLine)
    {
        [[self getChildByTag:PanelTag] removeChild:currentLine cleanup:YES];
        currentLine = nil;
    }
}

- (CCLabelBMFont*) labelByTouch:(CGPoint) _location
{
    int _index = [self indexOfLetterByPosition:_location];
    if (_index != NSNotFound)
    {
        CCLabelBMFont* _label = [letterLabels objectAtIndex:_index];
        return _label;
    }
    return nil;
}

- (NSUInteger) indexOfLetterByPosition:(CGPoint) t_positin
{
    int _index = NSNotFound;
    CCNode *_panel = [self getChildByTag:PanelTag];
    if (CGRectContainsPoint(_panel.boundingBox, t_positin))
    {
        CGPoint _relativePosition = ccpSub(t_positin, _panel.boundingBox.origin);
        int i = _relativePosition.x/self.gridWidth;
        int j = _relativePosition.y/self.gridHeght;
        int n = self.panelHeight/self.gridHeght;
        _index = n*i+j;
    }
    return _index;
}

- (CGPoint) positionByIndex:(NSUInteger)index
{
    int n = self.panelHeight/self.gridHeght;
    CGPoint relativePoint = ccp((index/n+0.5)*_gridWidth, (index%n+0.5)*_gridHeight);
    return relativePoint;
}

#pragma mark -logic

- (BOOL) letterFormIndex:(NSUInteger)first toIndex:(NSUInteger)last
{
    NSInteger directionX = 0;
    NSInteger directionY = 0;
    
//  NSUInteger m = self.panelWidth/self.gridWidth;
    NSUInteger n = self.panelHeight/self.gridHeght;
    
    NSUInteger firstX = first / n;
    NSUInteger firstY = first % n;
    
    NSUInteger lastX = last / n;
    NSUInteger lastY = last % n;
    
    NSInteger offsetX = lastX - firstX;
    NSInteger offsetY = lastY - firstY;
    
    if (offsetX == 0 || offsetY == 0 || offsetX == offsetY || offsetX == -offsetY)
    {
        if (offsetX > 0) directionX = 1;
        else if (offsetX < 0) directionX = -1;
        
        if (offsetY > 0) directionY = 1;
        else if (offsetY < 0) directionY = -1;
        
        self.choosedString = @"";
        [choosedLabels removeAllObjects];
        
        // add new label
        do {
            NSUInteger index = firstX * n + firstY;
            CCLabelBMFont *_label = [letterLabels objectAtIndex:index];
            NSAssert(_label, @"wordsearch:get a nil label");
            [choosedLabels addObject:_label];
            self.choosedString = [self.choosedString stringByAppendingString:_label.string];
            firstX = firstX + directionX;
            firstY = firstY + directionY;
            
        } while (firstX != lastX || firstY != lastY);
        
        // add last label;
        CCLabelBMFont *_label = [letterLabels objectAtIndex:lastX * n + lastY];
        NSAssert(_label, @"wordsearch:get a nil label");
        if (![choosedLabels containsObject:_label])
        {
            [choosedLabels addObject:_label];
            self.choosedString = [self.choosedString stringByAppendingString:_label.string];
        }
        
        
        return YES;
    }
    return NO;
}


- (void) goToNext
{
    gameIndex++;
    
    NSUInteger wordCount = [words count];
    
    if (gameIndex >= wordCount)
    {
        CCLabelTTF *done = [CCLabelTTF labelWithString:@"Well Done" fontName:@"Cooper Black" fontSize:42];
        done.position = wordLabel.position;
        done.color = ccGREEN;
        [self addChild:done z:2];
        
        [self removeChild:wordLabel cleanup:YES];
    }
    else
        [self refreshGameWithIndex:gameIndex];
}

- (void) dealloc
{
    [self unscheduleAllSelectors];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [words release];
    words = nil;
    [letterLabels release];
    letterLabels = nil;
    if (choosedLabels)
    {
        [choosedLabels release];
        choosedLabels = nil;
    }
    if (self.choosedString)
    {
        [_choosedString release];
        //  self.choosedString = nil;
    }
    
    if (_player != nil)
    {
        [_player release];
        _player = nil;
    }
    [super dealloc];
}

@end

@implementation NSString (yipleeInSearchWord)

- (int) insertIntoString:(NSString *)string enableBackward:(BOOL)enableBackward
{
    const char *originStr = [self UTF8String];
    const char *targetStr = [string UTF8String];
    
    int _direction = 0;
    
    if (enableBackward)
    {
        if (CCRANDOM_0_1() > 0.5f) _direction = 1;
        else _direction = -1;
    }
    else
    {
        _direction = 1;
    }
    
    NSUInteger originLength = [self length];
    NSUInteger targetLength = [string length];
    
    if (originLength > targetLength) return 0;
    
    int t_positin = arc4random_uniform(targetLength);
    for (int i=0;i<targetLength;i++,t_positin++)
    {
        t_positin = t_positin % targetLength;
        int j=0;
        for (;j<originLength;j++)
        {
            if (t_positin+j*_direction >= targetLength || t_positin+j*_direction < 0) break;
            if (targetStr[t_positin+j*_direction] == '*') continue;
            else if (targetStr[t_positin+j*_direction] == originStr[j]) continue;
            else break;
        }
        if (j == originLength) return (t_positin+1)*_direction;
    }
    
    if (enableBackward)
    {
        _direction = -_direction;
        for (int i=0;i<targetLength;i++,t_positin++)
        {
            t_positin = t_positin % targetLength;
            int j=0;
            for (;j<originLength;j++)
            {
                if (t_positin+j*_direction >= targetLength || t_positin+j*_direction < 0) break;
                if (targetStr[t_positin+j*_direction] == '*') continue;
                else if (targetStr[t_positin+j*_direction] == originStr[j]) continue;
                else break;
            }
            if (j == originLength) return (t_positin+1)*_direction;
        }
    }
    return 0;
}

- (char) randomCharacter
{
    return [self characterAtIndex:arc4random_uniform([self length])];
}

@end

