//
//  GameMenu.m
//  touchGames
//
//  Created by yiplee on 14-3-14.
//  Copyright 2014年 yiplee. All rights reserved.
//

#import "GameMenu.h"
#import "TouchGameLayer.h"

@implementation GameMenu
{

}

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [GameMenu node];
    [scene addChild:layer];
    return scene;
}

- (id) init
{
    self = [super init];
    NSAssert(self, @"menu failed init");
    
    NSDictionary*
    menuData = @{@"I love": @"I_love.plist",
                 @"Can U":@"can_u.plist",
                 @"Happy":@"happy_me.plist",
                 @"Red":@"Red.plist",
                 @"Garden":@"Garden.plist"};
    
    NSMutableArray *menuItems = [NSMutableArray array];
    for (NSString *name in menuData.allKeys)
    {
        NSString *fileName = [menuData objectForKey:name];
        NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
     
        
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
    
    CCMenu *menu = [CCMenu menuWithArray:menuItems];
    [menu alignItemsVerticallyWithPadding:30];
    [self addChild:menu];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    menu.position = ccpMult(ccpFromSize(size), 0.5);
    
    return self;
}

@end
