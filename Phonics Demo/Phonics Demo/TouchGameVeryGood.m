//
//  TouchGameVeryGood.m
//  LetterE
//
//  Created by yiplee on 14-3-28.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "very_good.plist";

#import "config.h"
#import "TouchGameVeryGood.h"

inline CGPoint node_p(CCNode *node)
{
    return ccpFromSize(node.boundingBox.size);
}

@interface TouchGameVeryGood ()
{
    NSDictionary *touchPositions;
    
    CCSprite *hand;
}

@end

@implementation TouchGameVeryGood

+ (instancetype) gameLayer
{
    NSString *rootPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:touchingGameRootPath]];
    NSString *fileName = [NSString stringWithUTF8String:file];
    NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [[[self alloc] initWithGameData:dic] autorelease];
}

- (id) initWithGameData:(NSDictionary *)dic
{
    self = [super initWithGameData:dic];
    NSAssert1(self, @"game:%@ failed init",self);
    
    touchPositions = @{@"van": @"{0.826,0.592}",
                       @"vegetable": @"{0.612,0.304}",
                       @"vest":@"{0.666,0.499}",
                       @"violin":@"{0.703,0.463}",
                       @"vacuum":@"{0.870,0.159}"};
    [touchPositions retain];
    
    hand = [CCSprite spriteWithFile:@"hand.png"];
    hand.zOrder = 2;
    [self addChild:hand];
    [self resetHand];
    
    __block TouchGameVeryGood *self_copy = self;
    [self setObjectLoadedBlock:^(GameObject *object) {
        if ([object.name hasSuffix:@"van"])
        {
            CCSprite *wheel1 = [CCSprite spriteWithFile:@"wheel.png"];
            wheel1.position = ccpCompMult(node_p(object), ccp(0.772,0.041));
            [object addChild:wheel1];
            
            CCSprite *wheel2 = [CCSprite spriteWithFile:@"wheel.png"];
            wheel2.position = ccpCompMult(node_p(object), ccp(0.183,0.118));
            [object addChild:wheel2];
            
            [object runAction:[CCMoveTo actionWithDuration:1 position:CCMP(0.741, 0.535)]];
            [wheel1 runAction:[CCRotateBy actionWithDuration:1 angle:-720]];
            [wheel2 runAction:[CCRotateBy actionWithDuration:1 angle:-720]];
        }
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        [self_copy resetHand];
        
        CGPoint pos = ccpCompMult(node_p(object), CGPointFromString([self_copy->touchPositions objectForKey:object.name]));
        pos = [object convertToWorldSpace:pos];
        
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:pos];
        
        CCScaleTo *scale1 = [CCScaleTo actionWithDuration:0.5 scale:1.3];
        CCScaleTo *scale2 = [CCScaleTo actionWithDuration:0.5 scale:1.0];
        CCSequence *scale_seq = [CCSequence actions:scale1,scale2, nil];
        CCSequence *seq = [CCSequence actions:move,scale_seq,[[scale_seq copy] autorelease],[[scale_seq copy] autorelease], nil];
        [self_copy->hand runAction:seq];
        [[self_copy contentLabel] setString:@"  "];
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        if (object.tag == 1)
        {
            self_copy->hand.visible = NO;
            [self_copy->hand stopAllActions];
        }
    }];
    
    self.autoActiveNext = NO;
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [touchPositions release];
}


- (void) resetHand
{
    hand.position = CCMP(0.617, 0.085);
    hand.visible = YES;
    [hand stopAllActions];
    [hand runAction:[CCFadeIn actionWithDuration:1]];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if (self.runningObject && self.runningObject.tag == 2 && self.runningObject != object)
        return NO;
    
    if (![super objectHasBeenClicked:object])
        return NO;
    
    return YES;
}

- (void) contentDidFinishReading:(GameObject *)object
{
    if (object.tag <= 2)
        [self activeNextObjects];
    object.tag = 3;
}

@end
