//
//  GradientLabel.m
//  BookReader
//
//  Created by USTB on 12-11-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GradientLabel.h"


@implementation GradientLabel

@synthesize type = _type;

+ (id) LabelWithString:(NSString*)string FontName:(NSString*)name FontSize:(CGFloat)size BackgroundColor:(ccColor3B)bgColor CoverColor:(ccColor3B)CoverColor
{
    return [[[self alloc] initWithString:string FontName:name FontSize:size BackgroundColor:bgColor CoverColor:CoverColor] autorelease];
}

- (id) initWithString:(NSString*)string FontName:(NSString*)name FontSize:(CGFloat)size BackgroundColor:(ccColor3B)bgColor CoverColor:(ccColor3B)CoverColor
{
    if (self = [super initWithString:string fontName:name fontSize:size])
    {
        self.color = bgColor;
        
        CCSprite *coverLabel = [CCSprite spriteWithTexture:self.texture rect:self.textureRect];
        coverLabel.color = CoverColor;
        progress = [CCProgressTimer progressWithSprite:coverLabel];
        _type = GradientLabelFromLeft;
        // setting
        progress.type = kCCProgressTimerTypeBar;
        progress.midpoint = ccp(0,0.5);
        progress.barChangeRate = ccp(1, 0);
        progress.anchorPoint = ccp(0, 0);

        [self addChild:progress];
    }
    return self;
}

- (void) setType:(GradientLabelType)type
{
    NSAssert(progress != nil, @"the cover progress bar is nil");
    if (YES)
    {
        switch (type) {
            case GradientLabelFromLeft:
                progress.midpoint = ccp(0,0.5);
                progress.barChangeRate = ccp(1,0);
                progress.anchorPoint = ccp(0,0);
                progress.position = ccp(0,0);
                break;
            case GradientLabelFromRight:
                progress.midpoint = ccp(1,0.5);
                progress.barChangeRate = ccp(-1,0);
                progress.anchorPoint = ccp(1,0);
                progress.position = ccp(self.boundingBox.size.width,0);
                break;
            default:
                break;
        }
    }
    _type = type;
}

- (void) playFrom:(float)startPercentage to:(float)endPercentage withDuration:(ccTime)duration
{
    CCProgressFromTo *action = [CCProgressFromTo actionWithDuration:duration from:startPercentage to:endPercentage];
    [progress runAction:action];
}

- (void) playTo:(float)endPercentage withDuration:(ccTime)duration
{
//  CCLOG(@"run action with duration:%f from percentage:%f",duration,progress.percentage);
    CCProgressFromTo *action = [CCProgressFromTo actionWithDuration:duration from:progress.percentage to:endPercentage];
    [progress runAction:action];
}

- (void) stop
{
    if ([progress numberOfRunningActions] > 0)
        [progress stopAllActions];
}

- (void) setLabelString:(NSString *)string withCoverColor:(ccColor3B)coverColor
{
    if ([string isEqualToString:self.string]) return;
    
    [self setString:string];
    
    CCSprite *sprite = [CCSprite spriteWithTexture:self.texture rect:self.textureRect];
    sprite.color = coverColor;
    [progress setSprite:sprite];
    progress.percentage = 0;
}

- (void) dealloc
{
    [progress stopAllActions];
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
