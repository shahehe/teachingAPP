//
//  TouchingGameMenu.m
//  LetterE
//
//  Created by yiplee on 14-3-17.
//  Copyright 2014年 USTB. All rights reserved.
//

#import "TouchingGameMenu.h"
#import "TouchGameLayer.h"

#import "MainMenu.h"

#include "config.h"

#import "TouchGameISee.h"
#import "TouchGameJar.h"
#import "TouchGamePlease.h"

@implementation TouchingGameMenu

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [TouchingGameMenu node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    if (self = [super init])
    {
        NSDictionary*
        menuData = @{@"I love": @"I_love.plist",
                     @"Can U":@"can_u.plist",
                     @"Happy":@"happy_me.plist",
                     @"Red":@"Red.plist",
                     @"Garden":@"Garden.plist"};
        
        NSString *rootPath = [NSString stringWithUTF8String:touchingGameRootPath];
        
        NSMutableArray *menuItems = [NSMutableArray array];
        for (NSString *name in menuData.allKeys)
        {
            NSString *fileName = [menuData objectForKey:name];
            NSString *filePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:rootPath] stringByAppendingPathComponent:fileName];
            
//            CCLOG(@"fileName:%@",filePath);
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
            
            CCMenuItemFont *item = [CCMenuItemFont itemWithString:name block:^(id sender) {
                TouchGameLayer *game = [TouchGameLayer gameLayerWithGameData:dic];
                CCScene *scene = [CCScene node];
                [scene addChild:game];
                [[CCDirector sharedDirector] replaceScene:scene];
            }];
            
            if (!dic)
            {
                [item setIsEnabled:NO];
            }
            
            item.color = ccWHITE;
            [menuItems addObject:item];
        }
        
        CCMenuItem *isee = [CCMenuItemFont itemWithString:@"I See" block:^(id sender) {
            TouchGameLayer *game = [TouchGameISee gameLayer];
            CCScene *scene = [CCScene node];
            [scene addChild:game];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        [menuItems addObject:isee];
        
        CCMenuItem *jar = [CCMenuItemFont itemWithString:@"Jar" block:^(id sender) {
            TouchGameLayer *game = [TouchGameJar gameLayer];
            CCScene *scene = [CCScene node];
            [scene addChild:game];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        [menuItems addObject:jar];
        
        CCMenuItem *please = [CCMenuItemFont itemWithString:@"Please" block:^(id sender) {
            TouchGameLayer *game = [TouchGamePlease gameLayer];
            CCScene *scene = [CCScene node];
            [scene addChild:game];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        [menuItems addObject:please];
        
        CCMenuItem *back = [CCMenuItemFont itemWithString:@"BACK" block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[MainMenu scene]];
        }];
        back.color = ccYELLOW;
        [menuItems addObject:back];
        
        CCMenu *menu = [CCMenu menuWithArray:menuItems];
        [menu alignItemsVerticallyWithPadding:30];
        [self addChild:menu];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        menu.position = ccpMult(ccpFromSize(size), 0.5);
    }
    
    return self;
}

@end
