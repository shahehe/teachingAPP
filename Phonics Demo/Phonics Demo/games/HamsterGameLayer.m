//
//  HamsterGameLayer.m
//  Hamster
//
//  Created by yiplee on 5/23/14.
//  Copyright 2014 yiplee. All rights reserved.
//

#import "HamsterGameLayer.h"

#import "SimpleAudioEngine.h"

static CGPoint randomePointInRect(CGRect rect)
{
    static NSUInteger ratio = 2;
    ratio = (ratio + 3) % 4;
    return ccpAdd(rect.origin, ccp(ratio / 4.0 *rect.size.width, CCRANDOM_0_1() *rect.size.height));
}

#pragma mark --hamster

@interface Hamster : CCSprite
{
    CCLabelTTF *wordLabel;
}

+ (instancetype) hamsterWithWord:(NSString*)word;
- (id) initWithWord:(NSString*)word;

- (void) setWord:(NSString*) word;
- (NSString*) word;

@end

@implementation Hamster

+ (instancetype) hamsterWithWord:(NSString *)word
{
    return [[[self alloc] initWithWord:word] autorelease];
}

- (id) initWithWord:(NSString *)word
{
    NSUInteger idx = arc4random_uniform(3) + 1;
    NSString *frameName = [NSString stringWithFormat:@"Hamster-%d.png",idx];
    
    self = [super initWithSpriteFrameName:frameName];
    CGPoint p_size = ccpFromSize(self.contentSize);
    
    CGPoint mudPos,wordPos;
    switch (idx) {
        case 1:
            mudPos = ccp(0.497,0.434);
            wordPos = ccp(0.376,0.787);
            break;
        case 2:
            mudPos = ccp(0.497,0.408);
            wordPos = ccp(0.460,0.727);
            break;
        case 3:
            mudPos = ccp(0.524,0.382);
            wordPos = ccp(0.442,0.684);
            break;
        default:
            NSAssert(NO, @"out of range");
            break;
    }
    
    CCSprite *mud = [CCSprite spriteWithSpriteFrameName:@"mud.png"];
    mud.position = ccpCompMult(p_size, mudPos);
    [self addChild:mud];
    
    wordLabel = [CCLabelTTF labelWithString:word fontName:@"GillSans" fontSize:18 * CC_CONTENT_SCALE_FACTOR()];
    wordLabel.color = ccBLACK;
    wordLabel.position = ccpCompMult(p_size, wordPos);
    [self addChild:wordLabel];
    
    return self;
}

- (void) setWord:(NSString *)word
{
    [wordLabel setString:word];
}

- (NSString *)word
{
    return [wordLabel string];
}

- (void) setOpacity:(GLubyte)opacity
{
    [super setOpacity:opacity];
    
    for (CCSprite *node in self.children)
    {
        node.opacity = opacity;
    }
}

- (void) dealloc
{
    [super dealloc];
}

@end

#pragma mark --Hamster Game Layer

@implementation HamsterGameLayer
{
    CCArray *hamsters;
    CCSprite *image;  // weak ref
    
    CGRect hamsterAppearRect;
    
    NSUInteger wordCount;
    NSArray *wordArray;
    NSUInteger idx;
    
    NSUInteger boyScore;
    CCLabelTTF *boyScoreLabel;
    NSUInteger hamsterScore;
    CCLabelTTF *hamsterScoreLabel;
}

+ (instancetype) hamsterGameWithWords:(NSArray *)words
{
    return [[[self alloc] initGameWithWords:words] autorelease];
}

- (id) initGameWithWords:(NSArray *)words
{
    self = [super init];
    
    CGPoint p_size = ccpFromSize([[CCDirector sharedDirector] winSize]);
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hamster_texture.plist"];
    
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    CCSprite *bg = [CCSprite spriteWithFile:@"hamster_bg.pvr.ccz"];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    
    bg.position = ccpMult(p_size, 0.5);
    bg.zOrder = 0;
    [self addChild:bg];
    
    wordArray = [words copy];
    wordCount = wordArray.count;
    idx = 0;
    
    hamsters = [[CCArray arrayWithCapacity:wordCount] retain];
    
    __block HamsterGameLayer *self_copy = self;
    [words enumerateObjectsUsingBlock:^(id obj, NSUInteger _idx, BOOL *stop) {
        NSString *word = obj;
        [[CCTextureCache sharedTextureCache] addImage:[self imagePathForWord:word]];
        [[SimpleAudioEngine sharedEngine] preloadEffect:[self soundPathForWord:word]];
        
        if (_idx % 3 == 0)
        {
            Hamster *h = [Hamster hamsterWithWord:word];
            [self_copy->hamsters addObject:h];
            [self_copy addChild:h z:2];
            h.visible = NO;
        }
    }];
    
    hamsterAppearRect = CGRectMake(p_size.x * 0.1, p_size.y * 0.48, p_size.x * 0.8, p_size.y * 0.16);
    
    boyScore = hamsterScore = 0;
    boyScoreLabel = [CCLabelTTF labelWithString:@" " fontName:@"GillSans" fontSize:16 * CC_CONTENT_SCALE_FACTOR()];
    boyScoreLabel.position = ccpCompMult(p_size, ccp(0.062,0.074));
    boyScoreLabel.color = ccBLACK;
    [self addChild:boyScoreLabel z:1];
    
    hamsterScoreLabel = [CCLabelTTF labelWithString:@" " fontName:@"GillSans" fontSize:16 * CC_CONTENT_SCALE_FACTOR()];
    hamsterScoreLabel.position = ccpCompMult(p_size, ccp(0.94,0.079));
    hamsterScoreLabel.color = ccBLACK;
    [self addChild:hamsterScoreLabel z:1];
    
    [self refreshScoreLabel];
    
    [self setTouchEnabled:YES];
    
    return self;
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self playWordAtIndex:idx];
}

- (void) onExit
{
    [super onExit];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"hamster_texture.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"hamster_texture.pvr.ccz"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"hamster_bg.pvr.ccz"];
    
    for (NSString *word in wordArray)
    {
        [[CCTextureCache sharedTextureCache] removeTextureForKey:[self imagePathForWord:word]];
    }
}

- (void) dealloc
{
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"hamster_bg.pvr.ccz"];
    
    [wordArray release];
    [hamsters release];
    [super dealloc];
}

- (void) refreshScoreLabel
{
    boyScoreLabel.string = [NSString stringWithFormat:@"%d",boyScore];
    hamsterScoreLabel.string = [NSString stringWithFormat:@"%d",hamsterScore];
}

- (void) playWordAtIndex:(NSUInteger)index
{
    if (index >= wordCount)
    {
        NSString *resultStr = boyScore > hamsterScore ? @"win.png" : @"lose.png";
        CCSprite* result = [CCSprite spriteWithSpriteFrameName:resultStr];
        result.scale = 0.1;
        result.position = ccpMult(ccpFromSize([[CCDirector sharedDirector] winSize]), 0.5);
        [self addChild:result z:4];
        
        [result runAction:[CCEaseBounceOut actionWithAction:[CCScaleTo actionWithDuration:0.6 scale:2]]];
        
        return;
    }
    
    idx = index;
    
    NSString *currentWord = [wordArray objectAtIndex:idx];
    [[SimpleAudioEngine sharedEngine] playEffect:[self soundPathForWord:currentWord]];
    
    CCTexture2D *tex = [[CCTextureCache sharedTextureCache] textureForKey:[self imagePathForWord:currentWord]];
    
    if (image)
    {
        [image setTexture:tex];
    }
    else
    {
        image = [CCSprite spriteWithTexture:tex];
        image.position = ccpCompMult(ccpFromSize([[CCDirector sharedDirector] winSize]), ccp(0.50,0.15));
        [self addChild:image z:1];
    }

    for (int i = 0;i<hamsters.count;i++)
    {
        Hamster *h = [hamsters objectAtIndex:i];
        h.word = [wordArray objectAtIndex:(idx + i) % wordCount];
        
        h.position = randomePointInRect(hamsterAppearRect);
        h.visible = YES;
        h.opacity = 255;
    }
}

- (NSString *) imagePathForWord:(NSString*)word
{
    return [NSString stringWithFormat:@"Assets/imageMatch/%@.png",word.lowercaseString];
}

- (NSString *) soundPathForWord:(NSString*)word
{
    return [NSString stringWithFormat:@"data/audioDic/%@.caf",word.lowercaseString];
}

#pragma mark -touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (idx >= wordCount)
    {
        [[CCDirector sharedDirector] popScene];
        return NO;
    }
    
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self convertTouchToNodeSpace:touch];
    
    NSString *currentWord = [wordArray objectAtIndex:idx];
    
    for (Hamster *h in hamsters)
    {
        if(h.opacity == 255 && CGRectContainsPoint(h.boundingBox, pos))
        {
            if ([h.word isEqualToString:currentWord])
            {
                boyScore ++;
                [self playWordAtIndex:++idx];
            }
            else
            {
                hamsterScore ++;
                [h runAction:[CCFadeOut actionWithDuration:0.6]];
            }
            
            [self refreshScoreLabel];
            break;
        }
    }
}

@end
