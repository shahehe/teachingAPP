//
//  TouchGameSix.m
//  LetterE
//
//  Created by yiplee on 14-4-24.
//  Copyright 2014年 USTB. All rights reserved.
//
static char *const file = "six.plist";

#import "config.h"
#import "TouchGameSix.h"

@implementation TouchGameSix
{
    CCNode *displayImage; //weak ref
    NSMutableDictionary *images;
    
    NSInteger totalNumber;
    NSInteger currentNumber;
    
    CCLabelBMFont *number;
}

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
    
    images = [[NSMutableDictionary alloc] init];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"objects.plist"];
    
    // exits
    {
        CCSprite *exits = [CCSprite spriteWithSpriteFrameName:@"map"];
        exits.position = CCMP(0.65, 0.45);
        CGPoint size_p = ccpFromSize(exits.boundingBox.size);
        CGPoint pos[] =
        {
            ccp(0.094, 0.873),
            ccp(0.564, 0.896),
            ccp(0.888, 0.550),
            ccp(0.763, 0.126),
            ccp(0.319, 0.176),
            ccp(0.107, 0.462)
        };
        
        for (int i=0;i<6;i++)
        {
            CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"door"];
            s.position = ccpCompMult(size_p, pos[i]);
            s.visible = NO;
            [exits addChild:s];
        }
        
        [images setObject:exits forKey:@"exits"];
    }
    
    // axles
    {
        CCNode *node = [CCNode node];
        node.contentSize = CGSizeMake(400, 400);
        node.anchorPoint = CGPointZero;
        node.position = CCMP(0.417, 0.108);
        CGPoint size_p = ccpFromSize(node.contentSize);
        CGPoint pos[] =
        {
            ccp(0.151, 0.857),
            ccp(0.850, 0.857),
            ccp(0.151, 0.547),
            ccp(0.850, 0.547),
            ccp(0.151, 0.230),
            ccp(0.850, 0.230)
        };
        
        for (int i=0;i<6;i++)
        {
            CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"axle"];
            s.position = ccpCompMult(size_p, pos[i]);
            s.visible = NO;
            [node addChild:s];
        }
        
        [images setObject:node forKey:@"axles"];
    }
    
    // taxis
    {
        CCNode *node = [CCNode node];
        node.contentSize = CGSizeMake(400, 400);
        node.anchorPoint = CGPointZero;
        node.position = CCMP(0.417, 0.108);
        CGPoint size_p = ccpFromSize(node.contentSize);
        CGPoint pos[] =
        {
            ccp(0.151, 0.763),
            ccp(0.994, 0.763),
            ccp(0.151, 0.482),
            ccp(0.994, 0.482),
            ccp(0.151, 0.209),
            ccp(0.994, 0.209)
        };
        
        for (int i=0;i<6;i++)
        {
            CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"taxi"];
            s.position = ccpCompMult(size_p, pos[i]);
            s.visible = NO;
            [node addChild:s];
        }
        
        [images setObject:node forKey:@"taxis"];
    }

    // hexagons
    {
        CCNode *node = [CCNode node];
        node.contentSize = CGSizeMake(400, 400);
        node.anchorPoint = CGPointZero;
        node.position = CCMP(0.417, 0.108);
        CGPoint size_p = ccpFromSize(node.contentSize);
        CGPoint pos[] =
        {
            ccp(0.058, 0.763),
            ccp(0.605, 0.763),
            ccp(1.130, 0.763),
            ccp(0.058, 0.259),
            ccp(0.605, 0.259),
            ccp(1.130, 0.259)
        };
        
        for (int i=0;i<6;i++)
        {
            CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"hexagon"];
            s.position = ccpCompMult(size_p, pos[i]);
            s.visible = NO;
            [node addChild:s];
        }
        
        [images setObject:node forKey:@"hexagons"];
    }

    // exams
    {
        CCNode *node = [CCNode node];
        node.contentSize = CGSizeMake(400, 400);
        node.anchorPoint = CGPointZero;
        node.position = CCMP(0.417, 0.108);
        CGPoint size_p = ccpFromSize(node.contentSize);
        CGPoint pos[] =
        {
            ccp(0.058, 0.763),
            ccp(0.605, 0.763),
            ccp(1.130, 0.763),
            ccp(0.058, 0.122),
            ccp(0.605, 0.122),
            ccp(1.130, 0.122)
        };
        
        for (int i=0;i<6;i++)
        {
            CCSprite *s = [CCSprite spriteWithSpriteFrameName:@"exam"];
            s.position = ccpCompMult(size_p, pos[i]);
            s.scale = 0.6;
            s.visible = NO;
            [node addChild:s];
        }
        
        [images setObject:node forKey:@"exams"];
    }

    NSString *fontFile = @"Didot.fnt";
    NSString *fntFilePath = [[NSString stringWithUTF8String:BMFontDirPath] stringByAppendingPathComponent:fontFile];
    number = [CCLabelBMFont labelWithString:@"0" fntFile:fntFilePath];
    number.color = ccBLACK;
    number.position = CCMP(0.89, 0.745);
    number.zOrder = 3;
    [self addChild:number];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        blinkSprite(object);
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:object.name fontName:@"GillSans-Bold" fontSize:24];
        CGPoint size_p = ccpFromSize(object.boundingBox.size);
        label.position = ccpMult(size_p, 0.5);
        label.color = ccBLACK;
        [object addChild:label];
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
    }];
    
    [[self contentLabel] setScale:0.6];
    currentNumber = 0;
    totalNumber = 0;
//    [self scheduleUpdate];
    [self setAutoActiveNext:YES];
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [images release];
}

- (void) update:(ccTime)delta
{
    if (totalNumber <= 0)
    {
        [self unscheduleUpdate];
        return;
    }
    
    static CGFloat tick = 0;
    
    if (tick >= 4.0/6)
    {
        tick = 0;
        totalNumber --;
        
        CCSprite *s = [displayImage.children objectAtIndex:currentNumber];
        s.visible = YES;
        [s runAction:[CCFadeIn actionWithDuration:1]];
        currentNumber ++;
        number.string = [NSString stringWithFormat:@"%i",currentNumber];
    }
    
    tick += delta;
}

- (void) cleanCache
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"objects.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"objects.pvr.ccz"];
    
    [super cleanCache];
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if(![super objectHasBeenClicked:object])
        return NO;
    
    if (displayImage)
    {
        [displayImage removeFromParent];
    }
    
    displayImage = [images objectForKey:object.name];
    for (CCSprite *s in displayImage.children)
    {
        s.opacity = 0;
    }
    
    [self addChild:displayImage];
    
    if (totalNumber <= 0)
    {
        totalNumber = 6;
        currentNumber = 0;
        [self scheduleUpdate];
    }
    else
    {
        totalNumber = 6;
        currentNumber = 0;
    }
    
    return YES;
}

@end
