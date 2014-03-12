//
//  LetterWriting.m
//  little games
//
//  Created by yiplee on 14-2-25.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "LetterWriting.h"


@implementation LetterWriting
{
    // For demo
    CCLabelTTF *_tipsLable;
}

- (id) initWithGameData:(NSDictionary *)data
{
    if (self = [super initWithGameData:data])
    {
        NSString *_tip = @"绿色为对的，红色为错的";
        _tipsLable = [CCLabelTTF labelWithString:_tip fontName:@"Helvetica" fontSize:(42)];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        _tipsLable.position = ccp(size.width*0.5, size.height*0.5);
        
        [self addChild:_tipsLable z:1];
        
        self.correctLetterSprites = [NSMutableArray array];
        self.incorrectLetterSprites = [NSMutableArray array];
        
        [self scheduleOnce:@selector(start) delay:0.8];
        
        [self setTouchEnabled:YES];
        
        CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"BACK" block:^(id sender) {
            [[NSNotificationCenter defaultCenter] \
             postNotificationName:@"PhonicsGameExit" object:self];
        }];
        back.color = ccYELLOW;
        back.position = ccp(size.width*0.05, size.height*0.95);
        
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    return self;
}

- (void) dealloc
{
    self.correctLetterSprites = nil;
    [_correctLetterSprites release];
    
    self.incorrectLetterSprites = nil;
    [_incorrectLetterSprites release];
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [super dealloc];
}

- (void) start
{
    _tipsLable.visible = NO;
    _tipsLable.anchorPoint = ccp(0.5, 0.9);
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    _tipsLable.position = ccp(size.width*0.5,size.height);
    
    CGPoint size_p = ccpFromSize(size);
    for (int i=0;i < 2;i++)
    {
        CCLabelTTF *_letter = [CCLabelTTF labelWithString:@"K" fontName:@"GillSans-BoldItalic" fontSize:48];
        CGFloat x = MIN(MAX(CCRANDOM_0_1(),0.1),0.9);
        CGFloat y = MIN(MAX(CCRANDOM_0_1(),0.1),0.9);
        _letter.position = ccpCompMult(size_p, ccp(x,y));
        
        _letter.color = ccGREEN;
        [self.correctLetterSprites addObject:_letter];
        
        [self addChild:_letter z:0];
    }
    
    for (int i=0;i < 4;i++)
    {
        CCLabelTTF *_letter = [CCLabelTTF labelWithString:@"K" fontName:@"GillSans-BoldItalic" fontSize:48];
        CGFloat x = MIN(MAX(CCRANDOM_0_1(),0.1),0.9);
        CGFloat y = MIN(MAX(CCRANDOM_0_1(),0.1),0.9);
        _letter.position = ccpCompMult(size_p, ccp(x,y));
        
        _letter.color = ccRED;
        [self.incorrectLetterSprites addObject:_letter];
        
        [self addChild:_letter z:0];
    }
}

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
    
    int c = [self.correctLetterSprites count];
    for (int i=c-1;i >=0;i--) {
        CCNode *_letter = [self.correctLetterSprites objectAtIndex:i];
        if (CGRectContainsPoint(_letter.boundingBox, location))
        {
            [self.correctLetterSprites removeObject:_letter];
            [self removeChild:_letter];
            
            _tipsLable.string = @"RIGHT";
            _tipsLable.color = ccGREEN;
            
            _tipsLable.visible = YES;
            _tipsLable.opacity = 255;
            [_tipsLable stopAllActions];
            CCFadeTo *fade = [CCFadeTo actionWithDuration:0.5 opacity:0];
            [_tipsLable runAction:fade];
            
            break;
        }
    }
    
    int m = [self.incorrectLetterSprites count];
    for (int i=m-1;i>=0;i--) {
        CCNode *_letter = [self.incorrectLetterSprites objectAtIndex:i];
        if (CGRectContainsPoint(_letter.boundingBox, location))
        {
            [self.incorrectLetterSprites removeObject:_letter];
            [self removeChild:_letter];
            
            _tipsLable.string = @"WRONG";
            _tipsLable.color = ccRED;
            
            _tipsLable.visible = YES;
            _tipsLable.opacity = 255;
            [_tipsLable stopAllActions];
            CCFadeTo *fade = [CCFadeTo actionWithDuration:0.5 opacity:0];
            [_tipsLable runAction:fade];
            
            break;
        }
    }

}

@end
