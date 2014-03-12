//
//  LetterSound.m
//  little games
//
//  Created by yiplee on 14-2-25.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "LetterSound.h"


@implementation LetterSound
{
    CCLabelTTF *tipLabel;
    
    CCNode *targetNode;
    
    CCArray *letters;
}

- (id) initWithGameData:(NSDictionary *)data
{
    if (self = [super initWithGameData:data])
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCMenuItemFont *back = [CCMenuItemFont itemWithString:@"BACK" block:^(id sender) {
            [[NSNotificationCenter defaultCenter] \
             postNotificationName:@"PhonicsGameExit" object:self];
        }];
        back.color = ccYELLOW;
        back.position = ccp(size.width*0.05, size.height*0.95);
        
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
        
        tipLabel = [CCLabelTTF labelWithString:@"_" fontName:@"ChalkboardSE-Bold" fontSize:96];
        tipLabel.position = ccp(size.width*0.5, size.height*0.5);
        
        tipLabel.opacity = 0;
        [self addChild:tipLabel z:1];
        
        letters = [[CCArray alloc] init];
        CGPoint size_p = ccpFromSize(size);
        for (int i = 'A';i <= 'F';i++)
        {
            NSString *letter = [NSString stringWithFormat:@"%c",i];
            CCLabelTTF *label = [CCLabelTTF labelWithString:letter fontName:@"Palatino-Bold" fontSize:64];
            label.color = ccWHITE;
            CGFloat x = MIN(MAX(CCRANDOM_0_1(),0.1),0.9);
            CGFloat y = MIN(MAX(CCRANDOM_0_1(),0.1),0.9);
            label.position = ccpCompMult(size_p, ccp(x,y));
            [self addChild:label z:0];
            
            [letters addObject:label];
        }
        
        [self setTouchEnabled:YES];
        targetNode = nil;
    }
    return self;
}

- (void) dealloc
{
    [letters release];
    letters = nil;
    
    [super dealloc];
}

- (void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self start];
}

- (void) start
{
    if (targetNode)
    {
        ((CCLabelTTF*)targetNode).color = ccWHITE;
    }
    
    NSUInteger c = [letters count];
    NSUInteger index = arc4random() % c;
    
    targetNode = [letters objectAtIndex:index];
    
    tipLabel.color = ccGREEN;
    tipLabel.opacity = 255;
    tipLabel.string = ((CCLabelTTF*)targetNode).string;
    
    CCFadeTo *fade = [CCFadeTo actionWithDuration:1 opacity:0];
    [tipLabel runAction:fade];
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
    
    for (CCLabelTTF *letter in letters) {
        if (CGRectContainsPoint(letter.boundingBox, location))
        {
            if (targetNode == letter)
            {
                letter.color = ccGREEN;
            }
            else letter.color = ccRED;
            
            targetNode = letter;
            
            [self scheduleOnce:@selector(start) delay:1];
            
            break;
        }
    }
}

@end
