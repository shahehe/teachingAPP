//
//  Cards.m
//  BookReader
//
//  Created by USTB on 12-11-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Card.h"


@implementation Card

@synthesize word = _word;
@synthesize frontImg = _frontImg,backImg = _backImg;
@synthesize isShow = _isShow;

+ (id) cardWithWord:(NSString *)word frontImg:(CCSprite *)frontImg backImg:(CCSprite *)backImg
{
    return ([[[self alloc]initWithWord:word frontImg:frontImg backImg:backImg] autorelease]);
}

+ (id) cardWithCardWord:(NSString*)word
{
    return ([[[self alloc]initWithCardWord:word] autorelease]);
}

- (id) initWithWord:(NSString *)word frontImg:(CCSprite *)frontImg backImg:(CCSprite *)backImg
{
    if (self = [super init])
    {
        _frontImg = frontImg;
        _backImg = backImg;
        self.word = word;
        _isShow = NO;
        
        [self setContentSize:_frontImg.contentSize];
        
        CGSize size = self.contentSize;
        CGPoint center = ccp(size.width*0.5f, size.height*0.5f);
        
        _frontImg.position = center;
        [self addChild:_frontImg z:0];
        _frontImg.visible = NO;
        
        _backImg.position = center;
        [self addChild:_backImg z:1];
        _backImg.visible = YES;
    }
    return self;
}

- (id) initWithCardWord:(NSString*)word
{
    NSString *_frontImgName = [NSString stringWithFormat:@"%@.png",word];
    NSString *_backImgName = @"backCard.png";
    CCSprite *tempFrontImg = [CCSprite spriteWithSpriteFrameName:_frontImgName];
    CCSprite *tempBackImg = [CCSprite spriteWithSpriteFrameName:_backImgName];
    return [self initWithWord:word frontImg:tempFrontImg backImg:tempBackImg];
}

- (void) showFromDirection:(FlipDirection)_direction withDuration:(ccTime)_duration
{
    if (_isShow) return;
    _isShow = YES;
    
    CGFloat _angleZ_1,_angleZ_2;
    CGFloat _deltaAngleZ_1,_deltaAngleZ_2;
    CGFloat _angleX_1,_angleX_2;
    CGFloat _deltaAngleX_1,_deltaAngleX_2;
    
    switch (_direction) {
        case FlipFromLeft:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = -90.f;_angleX_1 = 0.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = -270.f;_deltaAngleZ_2 = -90.f;_angleX_2 = 0.f;_deltaAngleX_2 = 0.f;
            break;
        case FlipFromRight:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = 90.f;_angleX_1 = 0.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = 270.f;_deltaAngleZ_2 = 90.f;_angleX_2 = 0.f;_deltaAngleX_2 = 0.f;
            break;
        case FlipFromUp:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = 90.f;_angleX_1 = 90.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = 270.f;_deltaAngleZ_2 = 90.f;_angleX_2 = 90.f;_deltaAngleX_2 = 0.f;
            break;
        case FlipFromDown:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = 90.f;_angleX_1 = -90.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = 270.f;_deltaAngleZ_2 = 90.f;_angleX_2 = -90.f;_deltaAngleX_2 = 0.f;
            break;
        default:
            NSAssert(NO, @"this case should not be reached");
            break;
    }
    
    //do something
    id flipFirstHalf = [CCOrbitCamera actionWithDuration:_duration/2 radius:1.f deltaRadius:0.f angleZ:_angleZ_1 deltaAngleZ:_deltaAngleZ_1 angleX:_angleX_1 deltaAngleX:_deltaAngleX_1];
    CCCallBlock *replaceSprite = [CCCallBlock actionWithBlock:^{
        _backImg.visible = NO;
        _frontImg.visible = YES;
    }];
    id flipSecondHalf = [CCOrbitCamera actionWithDuration:_duration/2 radius:1.f deltaRadius:0.f angleZ:_angleZ_2 deltaAngleZ:_deltaAngleZ_2 angleX:_angleX_2 deltaAngleX:_deltaAngleX_2];
    CCSequence *show = [CCSequence actions:flipFirstHalf,replaceSprite,flipSecondHalf, nil];
    [self runAction:show];
}

- (void) hideFromDirection:(FlipDirection)_direction withDuration:(ccTime)_duration
{
    if (!_isShow) return;
    _isShow = NO;
    
    CGFloat _angleZ_1,_angleZ_2;
    CGFloat _deltaAngleZ_1,_deltaAngleZ_2;
    CGFloat _angleX_1,_angleX_2;
    CGFloat _deltaAngleX_1,_deltaAngleX_2;
    
    switch (_direction) {
        case FlipFromLeft:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = -90.f;_angleX_1 = 0.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = -270.f;_deltaAngleZ_2 = -90.f;_angleX_2 = 0.f;_deltaAngleX_2 = 0.f;
            break;
        case FlipFromRight:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = 90.f;_angleX_1 = 0.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = 270.f;_deltaAngleZ_2 = 90.f;_angleX_2 = 0.f;_deltaAngleX_2 = 0.f;
            break;
        case FlipFromUp:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = 90.f;_angleX_1 = 90.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = 270.f;_deltaAngleZ_2 = 90.f;_angleX_2 = 90.f;_deltaAngleX_2 = 0.f;
            break;
        case FlipFromDown:
            _angleZ_1 = 0.f;_deltaAngleZ_1 = 90.f;_angleX_1 = -90.f;_deltaAngleX_1 = 0.f;
            _angleZ_2 = 270.f;_deltaAngleZ_2 = 90.f;_angleX_2 = -90.f;_deltaAngleX_2 = 0.f;
            break;
        default:
            NSAssert(NO, @"this case should not be reached");
            break;
    }
    
    //do something
    id flipFirstHalf = [CCOrbitCamera actionWithDuration:_duration/2 radius:1.f deltaRadius:0.f angleZ:_angleZ_1 deltaAngleZ:_deltaAngleZ_1 angleX:_angleX_1 deltaAngleX:_deltaAngleX_1];
    CCCallBlock *replaceSprite = [CCCallBlock actionWithBlock:^{
        _backImg.visible = YES;
        _frontImg.visible = NO;
    }];
    id flipSecondHalf = [CCOrbitCamera actionWithDuration:_duration/2 radius:1.f deltaRadius:0.f angleZ:_angleZ_2 deltaAngleZ:_deltaAngleZ_2 angleX:_angleX_2 deltaAngleX:_deltaAngleX_2];
    CCSequence *hide = [CCSequence actions:flipFirstHalf,replaceSprite,flipSecondHalf, nil];
    [self runAction:hide];
}

- (void) showDirect
{
    if (_isShow) return;
    _isShow = YES;
    _backImg.visible = NO;
    _frontImg.visible = YES;
}

- (void) hideDirect
{
    if (!_isShow) return;
    _isShow = NO;
    _backImg.visible = YES;
    _frontImg.visible = NO;
}

- (void) flipCardFromDirection:(FlipDirection)_direction withDuration:(ccTime)_duration
{
    if (_isShow)
        [self hideFromDirection:_direction withDuration:_duration];
    else
        [self showFromDirection:_direction withDuration:_duration];
}

- (BOOL) isMatchWithCard:(Card *)_card
{
    if ([self.word isEqualToString:_card.word])
        return YES;
    return NO;
}

- (void) dealloc
{
    [_word release];
    [super dealloc];
}

@end
