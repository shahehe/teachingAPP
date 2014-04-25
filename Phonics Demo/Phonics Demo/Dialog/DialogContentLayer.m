//
//  DialogContentLayer.m
//  Phonics Demo
//
//  Created by yiplee on 13-8-3.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#import "DialogContentLayer.h"
#import "Dialog.h"

#import "CCAnimation+Helper.h"
#import "AnimatedSprite.h"
@implementation DialogContentLayer

@synthesize numberOfScenes      = _numberOfScenes;
@synthesize indexOfCurrentScene = _indexOfCurrentScene;
@synthesize dialogBoxRect       = _dialogBoxRect;
@synthesize isPlaying           = _isPlaying;
@synthesize soundLabelDict      = _soundLabelDict;


- (AnimatedSprite *) createAnimatedSpriteWithPlistName:(NSString *) spriteSheetPrefix   framePrefix:(NSString *) framePrefix firstFrameIndex:(int) startidx animationName:(NSString *)name delay:(double)delayValue
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist", spriteSheetPrefix]];
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", spriteSheetPrefix]];
    [self addChild:spriteSheet z:20];
    
    
    AnimatedSprite * animSprite = [AnimatedSprite spriteWithSpriteFrameName:[NSString stringWithFormat:framePrefix,startidx]] ;
    [spriteSheet addChild:animSprite];
    [animSprite addLoopingAnimation:name frame:framePrefix delay:delayValue firstFrameIdx:1];
    return animSprite;
}

- (id) init
{
    if (self = [super init])
    {
        _numberOfScenes = 0;
        _indexOfCurrentScene = 0;
        _dialogBoxRect = CGRectZero;
        
    }
    
    
    return self;
}
-(void) initRecordingButton
{
    [CCMenuItemFont setFontSize:32];
    [CCMenuItemFont setFontName: @"Courier New"];
    NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:5];
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"录音"
                                                     block:^(id sender) {
                                                         
                                                     }];
    
    [menuItems addObject:item1];
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"停止"
                                                     block:^(id sender) {
                                                         [item1 setString:@"test"];
                                                     }];
    [menuItems addObject:item2];
    CCMenuItem *item3 = [CCMenuItemFont itemWithString:@"播放" block:^(id sender) {
        
    }];
    item3.color = ccYELLOW;
    
    [menuItems addObject:item3];
    
    
    CCMenu *menu = [CCMenu menuWithArray:menuItems];
    [menu alignItemsHorizontallyWithPadding:20];
    
    menu.position = ccpMult(SCREEN_SIZE_AS_POINT, 0.95);
    [self addChild:menu z:999];
    
}
- (id) initWithInitOptions:(NSDictionary *)options
// only common property should be read here
{
    self = [super init];
    //[self initRecordingButton];
    animSprites = [[NSMutableArray alloc] init];
    animSpritesNames = [[NSMutableArray alloc] init];
    animStartTime = [[NSMutableArray alloc] init];
    firstAnimIdxOfScene =[[NSMutableArray alloc] init];
    animName2SpriteIdx = [[NSMutableDictionary alloc] init];
    
    do {
        if (!self) break;
        if (!options || [[options allKeys] count] == 0) break;
        _isPlaying = YES;
        SLLog(@"load options");
        self.lessonLetter = [options valueForKey:@"letter"];
        self.soundNameWord = [ options valueForKey:@"soundNameWord"];
        
        
        
        NSString *audioFileName = [options valueForKey:@"audioFileName"];
        _audioSource = [[CDLongAudioSource alloc] init];
        _audioSource.delegate = self;
        [_audioSource load:audioFileName];
        
        NSString *titlePeriodValue = [options valueForKey:@"titlePeriod"];
        CLPeriod titlePeriod = CGPointZero;
        if (titlePeriodValue) titlePeriod = CGPointFromString(titlePeriodValue);
        _audioSource.audioSourcePlayer.currentTime = titlePeriod.x;
        audioPauseTime = titlePeriod.y;
        
        NSDictionary *background = [[options valueForKey:@"images"] valueForKey:@"background"];
        NSString *backgroundTextureName = [background valueForKey:@"textureFileName"];
        BACKGROUND_PIXEL
        [[CCTextureCache sharedTextureCache] addImage:backgroundTextureName];
        [self addBackgroundImageWithFile:backgroundTextureName fitScreen:YES];
        
        NSArray *contents = [[options valueForKey:@"images"] valueForKey:@"contents"];
        DIALOG_CONTENT_PIXEL
        for (NSDictionary *content in contents)
        {
            NSString *frameName = [content valueForKey:@"frameFileName"];
            NSString *textureName = [content valueForKey:@"textureFileName"];
            CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:textureName];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:frameName texture:tex];
        }
        PIXEL_FORMAT_DEFAULT
        NSArray *scenes = [options valueForKey:@"scenes"];
        _numberOfScenes = [scenes count];
        _indexOfCurrentScene = 0;
        _dialogBoxRect = CGRectZero;
        
        
        scenePeriods = calloc(sizeof(CLPeriod)*_numberOfScenes, 1);
        int i = 0;
        self.animStartTimeDict = [ [NSMutableDictionary alloc] init];
        self.soundLabelDict = [[NSMutableDictionary alloc] init];
        self.dialogDict     = [[NSMutableDictionary alloc] init];
        int animationsCount = 0;
        for (NSDictionary *scene in scenes)
        {
            for(NSString *key in [scene allKeys]) {
                NSLog(@"%@",[scene objectForKey:key]);
            }
            //当前场景对应的声音文件的开始和结束
            NSString *periodValue = [scene valueForKey:@"audioPeriod"];
            // 当前场景对应的声音文件的内容
            NSString *dialog      = [scene valueForKey:@"dialog"];
            
            [self.dialogDict setObject:dialog forKey:[NSNumber numberWithInt:i]];
            CLPeriod period = CGPointFromString(periodValue);
            scenePeriods[i] = period;
            
            //声音文件中每个单词的发音的起始位置，用于实现文字显示和声音的同步
            NSArray *arr =[scene valueForKey:@"soundLabel"];
            if ( [arr count] > 0)
            {
                [self.soundLabelDict setObject: arr forKey:[NSNumber numberWithInt:i]];
            }
            
            
            /* 下面的代码是载入／解析和动画相关的内容：
             动画分为两种： 一种是通过代码生成的，我们成为native animation (isNativeAnimation == YES)
             另外一种是通过载入美工绘制的连续动画帧来实现的，
             这种动画需要plist和png两个文件
             所有动画都有一个字段"startTime"用来表示动画显示／激活的触发时间
             "isRepeatAnim == YES" 代表这个动画已经在前面载入了，在当前触发时间需要再次显示
             */
            NSArray *animArray = [scene valueForKey:@"animations"];
            if ( [animArray count] > 0 )
            {
                [firstAnimIdxOfScene addObject:[NSNumber numberWithInt:animationsCount]];
            }
            else
            {
                [firstAnimIdxOfScene addObject:[NSNumber numberWithInt:-1]];
            }
            if ( [animArray count] > 0)
            {
                for( int i = 0; i < [animArray count]; ++i)
                {
                    NSDictionary * anim         = (NSDictionary *)[animArray objectAtIndex:i];
                    BOOL isNativeAnimation      = [anim valueForKey:@"isNativeAnimation"];
                    NSNumber * startTime        = [anim valueForKey:@"startTime"];
                    [animStartTime addObject:startTime];
                    BOOL isRepeatAnim           = [anim valueForKey:@"isRepeatAnim"];
                    
                    if ( isNativeAnimation) {
                        [animSprites addObject:[NSNull null]];
                        [animSpritesNames addObject:[NSNull null]];
                        
                        
                    }
                    else if ( isRepeatAnim )  // Repeat 表示这个动画本身已经在前面的场景生成
                    {
                        NSString * animationName    = [anim valueForKey:@"animationName"];
                        
                        NSNumber * animIdx          = [animName2SpriteIdx valueForKey:animationName];
                        AnimatedSprite * sprite     = (AnimatedSprite *)[animSprites objectAtIndex:[animIdx integerValue] ];
                        NSNumber * posX             = [anim valueForKey:@"posX"];
                        NSNumber * posY             = [anim valueForKey:@"posY"];
                        sprite.position = CCMP([posX floatValue], [posY floatValue]);
                        
                        [animSprites addObject:sprite];
                        [animSpritesNames addObject:animationName];
                        
                    }
                    else {
                        NSString * animationName    = [anim valueForKey:@"animationName"];
                        NSNumber * index            = [anim valueForKey:@"firstFrameIndex"];
                        NSString * framePrefix      = [anim valueForKey:@"framePrefix"];
                        NSString * PlistName        = [anim valueForKey:@"PlistName"];
                        NSNumber * delayValue       = [anim valueForKey:@"delay"];
                        
                        AnimatedSprite * sprite = [self createAnimatedSpriteWithPlistName:PlistName framePrefix:framePrefix firstFrameIndex:[index intValue] animationName:animationName delay:[delayValue doubleValue]];
                        
                        NSNumber * posX             = [anim valueForKey:@"posX"];
                        NSNumber * posY             = [anim valueForKey:@"posY"];
                        sprite.position = CCMP([posX floatValue], [posY floatValue]);
                        [sprite startAnimation:animationName];
                        
                        [animSprites addObject:sprite];
                        [animSpritesNames addObject:animationName];
                        [animName2SpriteIdx setObject:[NSNumber numberWithInt:animationsCount] forKey:animationName];
                        
                    }
                    
                    animationsCount++;
                }
            }
            i++;
        }
        
    } while (0);
    
    if (_audioSource) [self scheduleUpdate];
    
    // initialize two labels to show text sync with voice
    whiteboardBackgroundLabel = [CCLabelBMFont labelWithString:@""
                                                       fntFile:@"ComicSans_back.fnt"];
    whiteboardBackgroundLabel.anchorPoint = ccp(0, 1);
    whiteboardBackgroundLabel.position = CCMP(0.3, 0.7);
    
    foregroundLabel = [CCLabelBMFont labelWithString:@""
                                             fntFile:@"ComicSans_on.fnt"];
    
    
    [self addChild:foregroundLabel z:2];
    [self addChild:whiteboardBackgroundLabel z:1];
    return self;
}

- (void) update:(ccTime)delta
{
    if (_audioSource.audioSourcePlayer.currentTime >= audioPauseTime)
    {
        [self dialogAudioPlayDoneWithIndex:_indexOfCurrentScene];
        [_audioSource pause];
        self.isPlaying = NO;
        // rewind player to the start time of current scene
        _audioSource.audioSourcePlayer.currentTime = scenePeriods[_indexOfCurrentScene].x;
    }
    if ( self.isPlaying && wordsAudioPos && currWordOnWhiteBoardIdx < [wordsAudioPos count]) {
        NSString *currPosString = (NSString *)[wordsAudioPos objectAtIndex:currWordOnWhiteBoardIdx];
        float currPos = [currPosString floatValue];
        if ( _audioSource.audioSourcePlayer.currentTime > currPos )
        {
            NSRange wordRange = NSMakeRange(0,currWordOnWhiteBoardIdx+1);
            NSArray *firstNWords = [[whiteboardBackgroundLabel.string componentsSeparatedByString:@" "] subarrayWithRange:wordRange];
            foregroundLabel.string = [ firstNWords componentsJoinedByString:@" "];
            
            NSLog(@"%@",firstNWords);
            NSLog(@"%@ %g %g",foregroundLabel.string, currPos, _audioSource.audioSourcePlayer.currentTime );
            currWordOnWhiteBoardIdx++;
        }
        
    }
}

- (void) showWhiteBoardWordsSyncWithAudio
{
    [self showWhiteBoardWordsSyncWithAudio:YES];
}
// can not handle "\n" in plist
- (void) showWhiteBoardWordsSyncWithAudio:(BOOL)useDialogStringFromPlist
{
    whiteboardBackgroundLabel.visible = YES;
    if ( useDialogStringFromPlist )
        whiteboardBackgroundLabel.string = (NSString*)[self.dialogDict objectForKey:[NSNumber numberWithInt:_indexOfCurrentScene]];
    foregroundLabel.anchorPoint = ccp(0, 1);
    foregroundLabel.position = whiteboardBackgroundLabel.position;
    foregroundLabel.string = @"";
    currWordOnWhiteBoardIdx = 0;
    wordsAudioPos = [self.soundLabelDict objectForKey:[NSNumber numberWithInt:_indexOfCurrentScene]];
}

- (void) dealloc
{
    [super dealloc];
    
    [_audioSource release];
    _audioSource = nil;
    
    free(scenePeriods);
}

- (ToolbarLayer *)toolbar
{
    if ([self.parent isKindOfClass:[Dialog class]])
    {
        return ((Dialog*)self.parent).toolbarLayer;
    }
    SLLog(@"can't access to toolbar");
    return nil;
}

- (void) dialogPlayEnd
{
    SLLog(@"dialog end");
}

- (BOOL) isAtFirstScene
{
    return (_indexOfCurrentScene == 0);
}

- (BOOL) isAtLastScene
{
    return (_indexOfCurrentScene == _numberOfScenes - 1);
}

#pragma mark --DialogControl

- (void) dialogPlay
{
    
}

- (void) dialogResume
{
    [[[CCDirector sharedDirector] scheduler] resumeTarget:self];
    [[[CCDirector sharedDirector] actionManager] resumeTarget:self];
    [_children makeObjectsPerformSelector:@selector(resumeSchedulerAndActions)];
    
    [_audioSource play];
    self.isPlaying = YES;
}

- (void) dialogPause
{
    [[[CCDirector sharedDirector] scheduler] pauseTarget:self];
    [[[CCDirector sharedDirector] actionManager] pauseTarget:self];
    [_children makeObjectsPerformSelector:@selector(pauseSchedulerAndActions)];
    
    [_audioSource pause];
    self.isPlaying = NO;
}

- (void) dialogStop
{
    if (sceneBlocks) {
        for (int i = 0;i<_numberOfScenes;i++)
            Block_release(sceneBlocks[i]);
        free(sceneBlocks);
    }
    
    [_audioSource stop];
    self.isPlaying = NO;
}
- (void) clearScene
{
    
}

- (void) resetScene
{
    whiteboardBackgroundLabel.visible = NO;
    
    foregroundLabel.string = @"";
    
}
- (BOOL) playSceneWithIndex:(NSUInteger)index
{
    
    
    if (index >= _numberOfScenes)
    {
        index--;
    }
    
    _indexOfCurrentScene = index;
    
    if (_audioSource && scenePeriods)
    {
        [_audioSource pause];
        CLPeriod period = scenePeriods[_indexOfCurrentScene];
        _audioSource.audioSourcePlayer.currentTime = period.x;
        audioPauseTime = MIN(period.y,_audioSource.audioSourcePlayer.duration);
        NSLog(@"curr secen %d currtime %g pauseTime %g",_indexOfCurrentScene, period.x, audioPauseTime);
        [_audioSource play];
        self.isPlaying = YES;
    }
    
    [self resetScene];
    sceneBlocks[_indexOfCurrentScene]();
    
    return YES;
    
}

- (void) dialogPlayNextScene
{
    [self playSceneWithIndex:_indexOfCurrentScene+1];
}

- (void) dialogPlayPreviousScene
{
    if (_indexOfCurrentScene == 0) return;
    [self playSceneWithIndex:_indexOfCurrentScene-1];
}

- (void) dialogReplayCurrentScene
{
    [self playSceneWithIndex:_indexOfCurrentScene];
}


- (CCAnimation*) loadPlistForAnimationWithName:(NSString*)plistFilePrefix frameName:(NSString*)fName startFrameIdx:(int)startIdx endFrameIndx:(int)endIdx
{
    
    
    
    NSMutableArray *bigAWrittingFrames = [NSMutableArray array];
    for (int i=startIdx; i<=endIdx; i++) {
        if ( i < 10 )
        {
            [bigAWrittingFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              //[NSString stringWithFormat:@"id_a_b_write000%d.png",i]]];
              [NSString stringWithFormat:@"%@0%d.png",fName,i]]];
            
        }
        else
        {
            [bigAWrittingFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"%@%d.png",fName,i]]];
        }
    }
    CCAnimation *anim = [CCAnimation
                         animationWithSpriteFrames:bigAWrittingFrames delay:0.1f];
    
    return anim;
}
#pragma mark --Dialog audio control

- (void) dialogAudioPlayDoneWithIndex:(NSUInteger)index
{
    SLLog(@"scene %u audio finish",index);
}

#pragma mark --CDLongAudioSourceDelegate

- (void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *) audioSource
{
    if (_audioSource == audioSource)
    {
        
    }
}

@end
