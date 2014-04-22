//
//  ImageCard.m
//  LetterE
//
//  Created by yiplee on 14-4-10.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "config.h"
#import "ImageCard.h"
#import "SimpleAudioEngine.h"

#import "AudioDict.h"

@interface ImageCard ()
{
    CCSprite *displayImage;
    CCLabelTTF *title;
    
    BOOL isImageSelected;
    CGPoint lastPosition;
    
    void (^cardClick)(id sender);
}

@property (nonatomic,assign) BOOL isImageShow;

@end

@implementation ImageCard

+ (ImageCard*) imageCardWithWord:(NSString*)word
{
    return [[[self alloc] initWithWord:word] autorelease];
}

- (id) initWithWord:(NSString *)word
{
    self = [super initWithSpriteFrameName:@"card.png"];
    
    displayImage = [CCSprite spriteWithSpriteFrameName:[word stringByAppendingString:@"-outline.png"]];
    [self addChild:displayImage];
    
    displayImage.position = ccpMult(ccpFromSize(self.boundingBox.size), 0.5);
    
    _image = [[CCSprite alloc] initWithSpriteFrameName:[word stringByAppendingString:@".png"]];
//    _image.userObject = self;
    
    NSString *panelName = [@"word_panel" stringByAppendingFormat:@"%d.png",arc4random_uniform(10)];
    CCSprite *wordPanel = [CCSprite spriteWithSpriteFrameName:panelName];
    wordPanel.position = ccpCompMult(ccpFromSize(self.boundingBox.size), ccp(0.5,1));
    [self addChild:wordPanel];
    
    title = [CCLabelTTF labelWithString:word fontName:@"Gill Sans" fontSize:32];
    title.color = ccWHITE;
    [wordPanel addChild:title];
    title.position = ccpMult(ccpFromSize(wordPanel.boundingBox.size), 0.5);
    
    [self setWord:word];
    
    cardClick = nil;

    self.isImageShow = NO;
    isImageSelected = NO;
    
    return self;
}

- (void) setWord:(NSString *)word
{
    _word = [word copy];
    
    title.string = _word;
}

- (void) setImagePosition:(CGPoint)imagePosition
{
    _imagePosition = imagePosition;
    self.image.position = _imagePosition;
}

- (void) setCardClickBlock:(void (^)(id))block
{
    Block_release(cardClick);
    cardClick = Block_copy(block);
}

- (NSString*) audioFilePath
{
    NSString *audioPath = [NSString stringWithUTF8String:audioDicPath];
    return [audioPath stringByAppendingPathComponent:[[self.word lowercaseString] stringByAppendingPathExtension:@"caf"]];
}

- (void) addImageToNode:(CCNode *)node position:(CGPoint)pos
{
    if (self.image.parent)
        return;
    
    [node addChild:self.image z:self.zOrder+1];
    [self setImagePosition:pos];
}

- (void) dealloc
{
//    CCLOG(@"card dealloc");
    Block_release(cardClick);
    [_word release];
    [_image release];
    [super dealloc];
}

- (void) onEnter
{
    [super onEnter];
    [self registerWithTouchDispatcher];
}

- (void) onExit
{
    [super onExit];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

#pragma mark --touch

- (void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];

    [[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.parent || !self.visible)
        return NO;
    
    CGPoint pos = [self.parent convertTouchToNodeSpace:touch];
    if (CGRectContainsPoint(self.boundingBox, pos))
        return YES;
    
    if (self.image.parent && !_isImageShow)
    {
        pos = [self.image.parent convertTouchToNodeSpace:touch];
        if (CGRectContainsPoint(self.image.boundingBox, pos))
        {
            isImageSelected = YES;
            lastPosition = pos;
            
            //play sound effect
            [[AudioDict defaultAudioDict] readWord:self.word];
            
            return YES;
        }
    }
    
    return NO;
}

- (void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (isImageSelected)
    {
        CGPoint pos = [self.image.parent convertTouchToNodeSpace:touch];
        CGPoint offset = ccpSub(pos, lastPosition);
        
        self.image.position = ccpAdd(self.image.position, offset);
        lastPosition = pos;
    }
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pos = [self.parent convertTouchToNodeSpace:touch];
    if (isImageSelected)
    {
        if (CGRectContainsPoint(self.boundingBox, pos))
        {
            self.isImageShow = YES;
            
            CCSprite *star = [CCSprite spriteWithSpriteFrameName:@"star_big.png"];
            star.position = ccpAdd(self.imagePosition, ccp(0, SCREEN_HEIGHT + star.boundingBox.size.height/2));
            [self.image.parent addChild:star z:1];
            CCAction *drop = [CCEaseBounceInOut actionWithAction:[CCMoveTo actionWithDuration:1.6 position:self.imagePosition]];
            [star runAction:drop];
            
            CGPoint p;
            p = [self.parent convertToWorldSpace:self.position];
            p = [self.image.parent convertToNodeSpace:p];
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.3 position:p];
            CCCallBlock *moveDone = [CCCallBlock actionWithBlock:^{
                [self.image removeFromParentAndCleanup:YES];
                displayImage.displayFrame = self.image.displayFrame;
                
//                cardClick(self);
            }];
            CCSequence *seq = [CCSequence actions:move,moveDone, nil];
            [self.image runAction:seq];
        }
        else
        {
            CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:self.imagePosition];
            [self.image runAction:move];
        }
        isImageSelected = NO;
    }
    else if(CGRectContainsPoint(self.boundingBox, pos))
    {
        // play sound effect
        [[AudioDict defaultAudioDict] readWord:self.word];
        
        if (self.isImageShow && cardClick)
        {
            cardClick(self);
        }
    }
}

- (void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (isImageSelected)
    {
        self.image.position = _imagePosition;
        isImageSelected = NO;
    }
}

@end
