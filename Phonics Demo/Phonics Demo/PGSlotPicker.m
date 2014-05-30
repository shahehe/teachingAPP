//
//  PGSlotPicker.m
//  CCPickerView
//
//  Created by yiplee on 5/19/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "PGSlotPicker.h"

@implementation PGSlotPicker
{
    NSArray *componentNames;
    NSDictionary *componentInfo;
    
    CCMenuItemImage *handle;
}

+ (instancetype) pickerWithComponentData:(NSDictionary *)data
{
    return [[[self alloc] initWithComponentData:data] autorelease];
}

- (id) initWithComponentData:(NSDictionary *)data
{
    self = [super init];
    
    componentInfo = [data retain];
    componentNames = [[data allKeys] retain];
    
    self.delegate = self;
    self.dataSource = self;
    
    self.ignoreIndexs = [NSMutableIndexSet indexSet];
    
    CCSprite *handle_bg = [CCSprite spriteWithFile:@"slot_handle_bg.png"];
    handle_bg.anchorPoint = ccp(0, 0.5);
    
    CGPoint p_slot_size = ccpFromSize(self.contentSize);
    handle_bg.position = ccpCompMult(p_slot_size, ccp(0.32,0.02));
    handle_bg.zOrder = 12;
    [self addChild:handle_bg];
    
    __block PGSlotPicker *self_copy = self;
    handle = [CCMenuItemImage itemWithNormalImage:@"handle_off.png" selectedImage:nil disabledImage:@"handle_on.png" block:^(id sender) {
        [self_copy spin];
        
        CCMenuItemImage *item = sender;
        item.isEnabled = NO;
        item.anchorPoint = ccp(0.5, 1);
    }];
    handle.anchorPoint = ccp(0.5, 0);
    
    CCMenu *menu = [CCMenu menuWithItems:handle, nil];
    menu.position = ccpCompMult(ccpFromSize(handle_bg.contentSize), ccp(0.45,0.66));
    
    [handle_bg addChild:menu];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    
    [componentNames release];
    [componentInfo release];
    [_ignoreIndexs release];
    Block_release(_spinDone);
}

- (void) spin
{
    NSUInteger count = componentNames.count;
    NSUInteger idx = arc4random_uniform(count);
    
    if ([self.ignoreIndexs containsIndexesInRange:NSMakeRange(0, count)])
    {
        CCLOG(@"remove all index");
        [self.ignoreIndexs removeAllIndexes];
    }
    
    for (int i = 0;i < count;i++)
    {
        NSUInteger _idx = (idx + i) % count;
        
        if (![self.ignoreIndexs containsIndex:_idx])
        {
            idx = _idx;
            break;
        }
    }
    
    [self spinComponent:0 speed:20 easeRate:4 repeat:4 stopRow:idx];
}

#pragma mark - CCPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(CCPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(CCPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [componentNames count];
}

#pragma mark - CCPickerViewDelegate
- (CGFloat)pickerView:(CCPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 392/2;
}

- (CGFloat)pickerView:(CCPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 510/2;
}

- (NSString *)pickerView:(CCPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return @"Not used";
}

- (CCNode *)pickerView:(CCPickerView *)pickerView nodeForRow:(NSInteger)row forComponent:(NSInteger)component reusingNode:(CCNode *)node
{
    if (node && node.tag == row)
        return node;
    
    CCSprite *bg = [CCSprite spriteWithFile:@"slot_bg.png"];
    CGPoint p_bg = ccpFromSize(bg.boundingBox.size);
    
    NSString *imageFile = [componentInfo objectForKey:[componentNames objectAtIndex:row]];
    CCSprite *image = [CCSprite spriteWithFile:imageFile];
    image.position = ccpCompMult(p_bg, ccp(0.5,0.5));
    [bg addChild:image];
    
    bg.tag = row;
//    bg.scaleX = 1.1;
    
    return bg;
}

- (void)pickerView:(CCPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    CCLOG(@"didSelect row = %d, component = %d", row, component);
}

- (CGFloat)spaceBetweenComponents:(CCPickerView *)pickerView {
    return 0;
}

- (CGSize)sizeOfPickerView:(CCPickerView *)pickerView {
    CGSize size = CGSizeMake((738+360)/2, 1146/2);
    
    return size;
}

- (CCNode *)overlayImage:(CCPickerView *)pickerView {
    CCSprite *sprite = [CCSprite spriteWithFile:@"slot_e.png"];
    return sprite;
}

- (void)onDoneSpinning:(CCPickerView *)pickerView component:(NSInteger)component {
    NSLog(@"result: %@",[componentNames objectAtIndex:[self selectedRowInComponent:component]]);
    [self.ignoreIndexs addIndex:[self selectedRowInComponent:component]];
    
    handle.isEnabled = YES;
    handle.anchorPoint = ccp(0.5, 0);
    
    if (_spinDone)
    {
        _spinDone([componentNames objectAtIndex:[self selectedRowInComponent:component]]);
    }
}

@end

@interface slotPickerLayer : CCLayer

+ (CCScene*) pickerLayerWithScene:(CCScene*)scene;
- (id) initWithScene:(CCScene*)scene;

@end

@implementation slotPickerLayer
{
    CCScene *_scene; //weak ref
}

+ (CCScene*) pickerLayerWithScene:(CCScene *)scene
{
    return [[[self alloc] initWithScene:scene] autorelease];
}

- (id) initWithScene:(CCScene *)scene
{
    self = [super init];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    _scene = scene;
    
    CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(0,0,0,125)];
    [self addChild:background];
    
    NSDictionary* images = @{@"deer"    :@"Assets/imageMatch/deer.png",
                             @"car"     :@"Assets/imageMatch/car.png",
                             @"flamingo":@"Assets/imageMatch/flamingo.png",
                             @"dolphin" :@"Assets/imageMatch/dolphin.png",
                             @"cake"    :@"Assets/imageMatch/cake.png",
                             @"boat"    :@"Assets/imageMatch/boat.png",
                             @"bear"    :@"Assets/imageMatch/bear.png"};
    
    PGSlotPicker *slotPicker = [PGSlotPicker pickerWithComponentData:images];
    slotPicker.position = ccpMult(ccpFromSize(winSize), 0.5);
    [self addChild:slotPicker];
    
    CCLabelTTF *name = [CCLabelTTF labelWithString:@"Name" fontName:@"GillSans" fontSize:24*CC_CONTENT_SCALE_FACTOR()];
    name.color = ccWHITE;
    name.position = ccpCompMult(ccpFromSize(winSize), ccp(0.2, 0.5));
    [self addChild:name];
    
    slotPicker.spinDone = ^(NSString *str){
        name.string = str;
    };
    
    CCMenuItemFont *exit = [CCMenuItemFont itemWithString:@"exit" block:^(id sender) {
        [[CCDirector sharedDirector] popScene];
    }];
    exit.color = ccRED;
    exit.position = ccpMult(ccpFromSize(winSize), 0.9);
    
    CCMenu *menu = [CCMenu menuWithItems:exit, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    return self;
}

- (void) draw
{
    if(_scene) [_scene visit];
    [super draw];
}

@end

@implementation CCLayer (slotPicker)

- (void) addSlotPickerWithData:(NSDictionary *)data at:(CGPoint)pos
{
    CCMenuItemFont *picker = [CCMenuItemFont itemWithString:@"PICKER"];
    picker.color = ccRED;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    picker.position = ccpCompMult(ccpFromSize(winSize), pos);
    
    CCMenu *menu = [CCMenu menuWithItems:picker, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:NSIntegerMax - 1];
    
    __block id self_copy = self;
    [picker setBlock:^(id sender) {
        slotPickerLayer *pickerLayer = [[[slotPickerLayer alloc] initWithScene:((CCScene*)self_copy)] autorelease];
        CCScene *scene = [CCScene node];
        [scene addChild:pickerLayer];
        [[CCDirector sharedDirector] pushScene:scene];
    }];
}

@end
