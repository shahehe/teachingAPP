//
//  PGSearchWord.m
//  Phonics Games
//
//  Created by yiplee on 14-4-5.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "PGSearchWord.h"
#import "UtilsMacro.h"

#import "LetterGrid.h"
#import "CCLabelBMFontOnBacthNode.h"
#import "CCLinePro.h"

#import "PGTimer.h"
#import "GradientLabel.h"
#import "PGColor.h"

#import "PGManager.h"

@interface PGSearchWord ()
{
    CCNode *wordPanel;
    CCSpriteBatchNode *gridBatch;
    CCSpriteBatchNode *letterLabelBatch;
    
    CGSize gridSize;
    NSUInteger row;
    NSUInteger line;
    CGFloat letterSize;
    
    // audio
    CDLongAudioSource *audioPlayer;
    
    // info
    NSMutableDictionary *wordResults;
    NSMutableDictionary *wordHints;
    
    //logic
    NSMutableString *choosedString;
    NSInteger firstIndex;
    NSInteger lastIndex;
    CCLinePro *currentLine;
    
    // color
    ccColor3B highlightedColor;
    
    // timer
    PGTimer *timer;
    
    // word label
    GradientLabel *wordLabel;
}

@property (nonatomic,assign) NSUInteger currentIndex;

@end

@implementation PGSearchWord

+ (CCScene*) gameWithWords:(NSArray *)words panelSize:(CGSize)pSize gridSize:(CGSize)gSize
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [[[[self class] alloc] initWithWords:words panelSize:pSize gridSize:gSize] autorelease];
    [scene addChild:layer];
    return scene;
}

- (id) initWithWords:(NSArray *)words panelSize:(CGSize)pSize gridSize:(CGSize)gSize
{
    self = [super init];
    
    // background
    RGB565
    CCSprite *bg = [CCSprite spriteWithFile:@"search_word_bg.pvr.ccz"];
    PIXEL_FORMAT_DEFAULT
    bg.position = CMP(0.5);
    bg.scaleX = SCREEN_WIDTH / bg.contentSize.width;
    bg.scaleY = SCREEN_HEIGHT / bg.contentSize.height;
    [self addChild:bg z:0];
    
    _gameName = [@"SearchWord" copy];
//    self.words = words;
    
    gridSize = gSize;
    row = pSize.height / gSize.height;
    line = pSize.width / gSize.width;
    
    letterSize = MIN(gridSize.width, gridSize.height) - 10;
    
    wordPanel = [CCNode node];
    {
        CGSize p_size = CGSizeMake(line*gSize.width, row*gSize.height);
        wordPanel.contentSize = p_size;
        wordPanel.anchorPoint = ccp(0.5, 0.5);
        wordPanel.position = CCMP((SCREEN_WIDTH-p_size.width/2-50)/SCREEN_WIDTH, 0.45);
        [self addChild:wordPanel z:1];
    }
    
    RGB565
    CCSprite *letterPanel = [CCSprite spriteWithFile:@"search_word_letter_panel.pvr.ccz"];
    PIXEL_FORMAT_DEFAULT
    letterPanel.position = wordPanel.position;
    letterPanel.scaleX = (wordPanel.contentSize.width + 30)/letterPanel.contentSize.width;
    letterPanel.scaleY = (wordPanel.contentSize.height+ 30)/letterPanel.contentSize.height;
    letterPanel.zOrder = 0;
    [self addChild:letterPanel];
    
    gridBatch = [CCSpriteBatchNode batchNodeWithFile:@"blockTexture.png"];
    [gridBatch retain];
    [wordPanel addChild:gridBatch z:1];
    
    letterLabelBatch = [CCSpriteBatchNode batchNodeWithFile:@"FrankfurterStd.png"];
    [letterLabelBatch retain];
    [wordPanel addChild:letterLabelBatch z:3];
    
    // audio
    audioPlayer = [[CDLongAudioSource alloc] init];
    audioPlayer.delegate = self;
    // timer
    timer = [[PGTimer alloc] init];
    
    // info
    wordResults = [[NSMutableDictionary alloc] init];
    wordHints = [[NSMutableDictionary alloc] init];
    
    //menu
    CCMenuItemImage *back = [CCMenuItemImage itemWithNormalImage:@"back_button_N.png" selectedImage:@"back_button_P.png" block:^(id sender){
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"search_word_bg.pvr.ccz"];
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"search_word_letter_panel.pvr.ccz"];
        [[CCTextureCache sharedTextureCache] removeTextureForKey:@"search_word_word_panel.pvr.ccz"];
        [[CCDirector sharedDirector] popScene];
    }];
    back.position = CCMP(0.05, 0.92);
    
    __block PGSearchWord *self_copy = self;
    CCMenuItemImage *restart = [CCMenuItemImage itemWithNormalImage:@"restart_button_N.png" selectedImage:@"restart_button_P.png" block:^(id sender) {
        [self_copy->wordPanel removeAllChildren];
        [self_copy->wordPanel addChild:self_copy->gridBatch z:1];
        [self_copy->wordPanel addChild:self_copy->letterLabelBatch z:3];
        
        self_copy.currentIndex = 0;
        [self_copy playWordAtIndex:0];
    }];
    restart.position = CCMP(0.95, 0.92);
    
    CCMenu *menu = [CCMenu menuWithItems:back,restart, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:4];
    
    [self prepareWordPanelWithWords:words];
    
    choosedString = [[NSMutableString alloc] initWithString:@""];
    
    [self setTouchEnabled:YES];
    
    _currentIndex = 0;
    
    return self;
}

- (void) dealloc
{
    [_gameName release];
    [_words release];
    
    [letterLabelBatch release];
    [gridBatch release];
    
    [audioPlayer release];
    [timer release];
    [wordResults release];
    [wordHints release];
    
    [choosedString release];
    
    [super dealloc];
}

- (void) onEnter
{
    [super onEnter];
    [self playWordAtIndex:_currentIndex];
}

- (NSString*) currentWord
{
//    if (_currentIndex < _words.count)
        return [_words objectAtIndex:_currentIndex];
    
//    return nil;
}

- (void) prepareWordPanelWithWords:(NSArray*)words
{
    [gridBatch removeAllChildrenWithCleanup:YES];
    [letterLabelBatch removeAllChildrenWithCleanup:YES];
    
    char letters[line][row];
    NSUInteger m = line,n=row;
    for (NSUInteger i=0;i<m;i++)
        for (NSUInteger j=0;j<n;j++)
            letters[i][j] = '*';
    
    NSMutableArray *remainWords = [NSMutableArray arrayWithCapacity:words.count];
    for (NSString *word in words)
    {
        [remainWords addObject:[word uppercaseString]];
    }
    
    NSMutableArray *activeWords = [NSMutableArray array];
    
    enum Direction
    {
        Vertical = 0,
        Horizontal,
        DiagonalUp, //  斜向上
        DiagonalDown    //  斜向下
    } _direction;
    
    NSInteger startX = 0,startY = 0;
    NSInteger directionX = 0,directionY = 0;
    NSMutableString *l = [NSMutableString string];
    NSUInteger failedTimes = 0;
    
    while (remainWords.count > 0)
    {
        if (failedTimes > 20)
        {
            SLLog(@"have to give up remain words:%@",remainWords.description);
            break;
        }
        
        [l setString:@""];
        _direction = arc4random_uniform(4);
    
        if (_direction == Vertical)
        {
            startX = arc4random_uniform(m);
            startY = n-1;
            directionX = 0;
            directionY = -1;
            for (NSUInteger i=0;i<n;i++)
            {
                [l appendFormat:@"%c",letters[startX][startY-i]];
            }
        }
    
        else if(_direction == Horizontal)
        {
            startX = 0;
            startY = arc4random_uniform(n);
            directionX = 1;
            directionY = 0;
            for (NSUInteger i=0;i<m;i++)
            {
                [l appendFormat:@"%c",letters[startX+i][startY]];
            }
        }

        else if (_direction == DiagonalUp)
        {
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
                [l appendFormat:@"%c",letters[startX+i][startY+i]];
            }
        }

        else if (_direction == DiagonalDown)
        {
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
                [l appendFormat:@"%c",letters[startX+i][startY-i]];
            }
            
        }
        
        NSUInteger _remainWord = remainWords.count;
        
        int i = 0;
        for (;i<_remainWord;i++)
        {
            NSString *_word = [remainWords objectAtIndex:i];
            SLLog(@"get word:%@",_word);
            int _index = [_word insertIntoString:l enableBackward:YES];
            if (_index == 0) continue;
            else
            {
                SLLog(@"%@ insert into %@ succesfully",_word,l);
                SLLog(@"failed %d times",failedTimes);
                failedTimes = 0;
                
                [activeWords addObject:_word];
                [remainWords removeObject:_word];
                //put word into line
                NSUInteger _startPosition = abs(_index)-1;
                NSUInteger _wordLength = [_word length];
                
                NSUInteger hintIndex = (startX + _startPosition*directionX) * row + (startY + _startPosition*directionY);
                [wordHints setObject:[NSNumber numberWithUnsignedInt:hintIndex] forKey:_word];
                
                int _lineDirection = _index < 0 ? -1:1;
                
                for (int j=0;j<_wordLength;j++)
                {
                    
                    NSAssert(_startPosition < [l length], @"out of range");
                    NSString *__letter = [_word substringWithRange:NSMakeRange(j, 1)];
                    
                    [l replaceCharactersInRange:(NSMakeRange(_startPosition, 1)) withString:__letter];
                    _startPosition = _startPosition + _lineDirection;
                }
                
                
                //write line back to grid
                NSUInteger _lineLength = [l length];
                for (int j=0;j<_lineLength;j++)
                {
                    letters[startX+directionX*j][startY+directionY*j] = [l characterAtIndex:j];
                }
                
                break;
            }
        }
        if (i == _remainWord)
            failedTimes++;
    }
    SLLog(@"insert done");
    self.words = activeWords;
    SLLog(@"word hints:%@",wordHints.description);
    
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
            
            LetterGrid *_letterGrid = [LetterGrid gridWithSize:gridSize letter:letters[i][j]];
            if ((i+j) % 2 == 0)
            {
                _letterGrid.color = ccc3(146,205,201);
            }
            else
            {
                _letterGrid.color = ccc3(243, 232, 190);
            }
            _letterGrid.gridIndex = ccp(i, j);
            _letterGrid.tag = i * row + j;
            _letterGrid.position = ccp(gridSize.width*(0.5+i),gridSize.height*(0.5+j));
            [gridBatch addChild:_letterGrid];
            
            CCLabelBMFont *_label = [CCLabelBMFont labelWithString:_str fntFile:@"FrankfurterStd.fnt"];
            _label.scale = letterSize/MAX(_label.boundingBox.size.width, _label.boundingBox.size.height);
            _label.position = ccp(gridSize.width*(0.5+i),gridSize.height*(0.5+j)-8);
            [_label addToBatchNode:letterLabelBatch zOrder:1 position:_label.position];
            
            _letterGrid.userObject = _label;
        }
    }

}

#pragma mark -touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    [choosedString setString:@""];
    firstIndex = lastIndex = -1;
    
    NSInteger _index = [self indexOfLetterByPosition:location];
    if (_index != NSNotFound)
    {
        CGPoint t_positin = [self positionByIndex:_index];
        firstIndex = _index;
        lastIndex = _index;
        
        if (currentLine)
        {
            [wordPanel removeChild:currentLine cleanup:YES];
            currentLine = nil;
        }
        currentLine = [CCLinePro lineFromStartPoint:t_positin toEndPoint:t_positin withWidth:letterSize];
        currentLine.color = highlightedColor;
        currentLine.opacity = 255*0.8;
        [wordPanel addChild:currentLine z:2];
        
        [self letterFormIndex:firstIndex toIndex:lastIndex];
        
        return YES;
    }
    
    return NO;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    NSInteger _index = [self indexOfLetterByPosition:location];
    
    if (_index != NSNotFound)
    {
        CGPoint t_positin = [self positionByIndex:_index];
        if (lastIndex != _index)
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
    
    SLLogString(choosedString);
    if ([self.currentWord isEqualToString:choosedString])
    {
        [self setTouchEnabled:NO];
        [self finishWord:self.currentWord];
    }
    else
    {
        if (currentLine)
        {
            [wordPanel removeChild:currentLine cleanup:YES];
            
        }
    }
    
    currentLine = nil;
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    firstIndex = lastIndex = -1;
    if (currentLine)
    {
        [wordPanel removeChild:currentLine cleanup:YES];
        currentLine = nil;
    }
}

- (CCLabelBMFont*) labelByTouch:(CGPoint) _location
{
    int _index = [self indexOfLetterByPosition:_location];
    if (_index != NSNotFound)
    {
        CCLabelBMFont* _label = [[gridBatch getChildByTag:_index] userObject];
        return _label;
    }
    return nil;
}

- (NSUInteger) indexOfLetterByPosition:(CGPoint) t_positin
{
    int _index = NSNotFound;
    if (CGRectContainsPoint(wordPanel.boundingBox, t_positin))
    {
        CGPoint _relativePosition = [wordPanel convertToNodeSpace:t_positin];
        int i = _relativePosition.x/gridSize.width;
        int j = _relativePosition.y/gridSize.height;
        _index = row*i+j;
    }
    return _index;
}

- (CGPoint) positionByIndex:(NSUInteger)index
{
    CGPoint relativePoint = ccp((index/row+0.5)*gridSize.width, (index%row+0.5)*gridSize.height);
    return relativePoint;
}

#pragma mark -logic

- (BOOL) letterFormIndex:(NSUInteger)first toIndex:(NSUInteger)last
{
    NSInteger directionX = 0;
    NSInteger directionY = 0;
    
    //  NSUInteger m = self.panelWidth/self.gridWidth;
    NSUInteger n = row;
    
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
        
        [choosedString setString:@""];
        
        // add new label
        do {
            NSUInteger index = firstX * n + firstY;
            LetterGrid *grid = (LetterGrid*)[gridBatch getChildByTag:index];
            NSAssert(grid, @"wordsearch:get a nil grid");
            
            [choosedString appendFormat:@"%c",grid.letter];
            firstX = firstX + directionX;
            firstY = firstY + directionY;
            
        } while (firstX != lastX || firstY != lastY);
        
        // add last label;
        if (offsetX !=0 || offsetY != 0)
        {
            LetterGrid *grid = (LetterGrid*)[gridBatch getChildByTag:lastX * n + lastY];
            [choosedString appendFormat:@"%c",grid.letter];
        }
        
        return YES;
    }
    return NO;
}

- (void) playWordAtIndex:(NSUInteger)idx
{
    NSString *_word = [self.words objectAtIndex:idx];
    
    [timer startTimer];
    highlightedColor = [PGColor randomBrightColor];
    
    if (wordLabel)
    {
        [wordLabel setLabelString:_word withCoverColor:highlightedColor];
    }
    else
    {
        RGBA4444
        CCSprite *wordLabelBg = [CCSprite spriteWithFile:@"search_word_word_panel.pvr.ccz"];
        PIXEL_FORMAT_DEFAULT
        wordLabelBg.position = CCMP(0.15, 0.5);
        wordLabelBg.zOrder = 0;
        [self addChild:wordLabelBg];
        
        NSString *_fontName = @"DENNE|Sketchy";
        NSUInteger _fontSize = 80;
        wordLabel = [GradientLabel LabelWithString:_word FontName:_fontName FontSize:_fontSize BackgroundColor:ccWHITE CoverColor:highlightedColor];
        wordLabel.color = ccBLACK;
        wordLabel.position = ccpCompMult(ccpFromSize(wordLabelBg.contentSize),ccp(0.48, 0.2));
        [wordLabelBg addChild:wordLabel z:1];
    }
    
    [audioPlayer stop];
    [audioPlayer load:[self audioFileOfWord:_word]];
    [audioPlayer rewind];
    
    [self setTouchEnabled:YES];
}

- (void) finishWord:(NSString*)word
{
    [timer stopTimer];
    
    CGFloat time = [timer timeElapsedInSeconds];
    NSDictionary *result = @{@"time": [NSNumber numberWithFloat:time]};
    [wordResults setValue:result forKey:word];
    
    [audioPlayer play];
    [wordLabel playFrom:0 to:100 withDuration:audioPlayer.audioSourcePlayer.duration];
}

- (void) playNextWord
{
    if (_currentIndex >= self.words.count - 1)
    {
        [self finishGame];
        return;
    }

    _currentIndex++;
    [self playWordAtIndex:_currentIndex];
}

- (void) finishGame
{
    SLLog(@"finish game with result:%@",wordResults.description);
    [[PGManager sharedManager] finishGame:self.gameName];
}

- (NSString *) audioFileOfWord:(NSString*)word
{
    return [[word lowercaseString] stringByAppendingPathExtension:@"caf"];
}

#pragma mark --CDLongAudioSourceDelegate

- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource
{
    SLLog(@"audio done");
    [self playNextWord];
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
