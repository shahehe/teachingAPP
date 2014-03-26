//
//  TouchGameKiss.m
//  LetterE
//
//  Created by yiplee on 14-3-22.
//  Copyright (c) 2014年 USTB. All rights reserved.
//
static char *const file = "kiss.plist";

#import "config.h"
#import "TouchGameKiss.h"

CGPoint screen_p()
{
    return  ccpFromSize([CCDirector sharedDirector].winSize);
}

CGPoint node_p(CCNode *node)
{
    return ccpFromSize(node.boundingBox.size);
}

@interface KissObject : CCSprite
{
    CGPoint _kissPosition;
    CCSprite *hearts;
}

@property (nonatomic,readonly) CGPoint kissPosition;

+ (KissObject*) newObject;

- (id) initObject;

- (void) kiss;

@end

@implementation KissObject

+ (KissObject*) newObject
{
    return [[[[self class] alloc] initObject] autorelease];
}

- (id) initObject
{
    return nil;
}

- (id) initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    NSAssert(self, @"failed init");
    
    hearts = [CCSprite spriteWithFile:@"hearts.png"];
    hearts.visible = NO;
    hearts.zOrder = 10;
    [self addChild:hearts];
    
    return self;
}

- (void) dealloc
{
    [self unscheduleAllSelectors];
    [super dealloc];
}

- (CGPoint) kissPosition
{
    return [self convertToWorldSpace:_kissPosition];
}

- (void) kiss
{
    [self schedule:@selector(heartAnimation) interval:1.2 repeat:kCCRepeatForever delay:0];
}

- (void) heartAnimation
{
    hearts.visible = YES;
    hearts.position = _kissPosition;
    hearts.scale = 1;
    hearts.opacity = 255;
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:1 position:ccp(100,100)];
    CCScaleTo *scale = [CCScaleTo actionWithDuration:1 scale:2];
    CCFadeOut *fade = [CCFadeOut actionWithDuration:1];
    [hearts runAction:move];
    [hearts runAction:scale];
    [hearts runAction:fade];
}

@end

@interface KissObjectKoala : KissObject
{
    CCSprite *head;
    CCTexture2D *bodyTex;
}

@end

@implementation KissObjectKoala

- (id) initObject
{
    self = [super initWithFile:@"koala.png"];
    NSAssert(self, @"faile init");
    
    self.position = ccpCompMult(screen_p(), ccp(0.583,0.441));
    _kissPosition = ccpCompMult(node_p(self), ccp(0.675, 0.426));
    
    head = [CCSprite spriteWithFile:@"koala_kiss_head.png"];
    head.anchorPoint = ccp(0.394, 0.022);
    head.position = ccpCompMult(ccpFromSize(self.contentSize), ccp(0.524, 0.329));
    [self addChild:head];
    head.visible = NO;
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"koala_kiss_body.png" withBlock:^(CCTexture2D *tex) {
        bodyTex = [tex retain];
    }];
    
    return self;
}

- (void) kiss
{
    [super kiss];
    
    CGRect rect = CGRectZero;
    rect.size = bodyTex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:bodyTex rect:rect];
    self.displayFrame = frame;
    
    head.visible = YES;
    
    CCRotateBy *rotate1 = [CCRotateBy actionWithDuration:0.8 angle:10];
    CCRotateBy *rotate2 = [CCRotateBy actionWithDuration:1.6 angle:-20];
    CCRotateBy *rotate3 = [CCRotateBy actionWithDuration:0.8 angle:10];
    CCSequence *s = [CCSequence actions:rotate1,rotate2,rotate3, nil];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
    [head runAction:r];
}

- (void) dealloc
{
    [bodyTex release];
    [[CCTextureCache sharedTextureCache] removeTexture:bodyTex];
    [super dealloc];
}

@end

@interface KissObjectBird : KissObject
{
    CCTexture2D *_tex;
}

@end

@implementation KissObjectBird

- (id) initObject
{
    self = [super initWithFile:@"bird.png"];
    NSAssert(self, @"failed init");
    
    self.position = ccpCompMult(screen_p(), ccp(0.590,0.454));
    _kissPosition = ccpCompMult(node_p(self), ccp(0.56, 0.54));
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"bird_kiss.png" withBlock:^(CCTexture2D *tex) {
        _tex = [tex retain];
    }];
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [_tex release];
    [[CCTextureCache sharedTextureCache] removeTexture:_tex];
}

- (void) kiss
{
    [super kiss];
    
    CGRect rect = CGRectZero;
    rect.size = _tex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:_tex rect:rect];
    self.displayFrame = frame;
    self.position = ccpCompMult(screen_p(), ccp(0.664, 0.407));
    
    CCJumpBy *jump1 = [CCJumpBy actionWithDuration:2 position:ccp(0, 0) height:20 jumps:3];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
    CCSequence *s = [CCSequence actions:jump1,delay, nil];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
    
    [self runAction:r];
}

@end

@interface KissObjectGoldfish : KissObject
{
    CCTexture2D *_tex;
}

@end

@implementation KissObjectGoldfish

- (id) initObject
{
    self = [super initWithFile:@"goldfish.png"];
    
    self.position = ccpCompMult(screen_p(), ccp(0.589, 0.450));
    _kissPosition = ccpCompMult(node_p(self), ccp(0.560, 0.523));
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"goldfish_kiss.png" withBlock:^(CCTexture2D *tex) {
        _tex = [tex retain];
    }];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [_tex release];
    [[CCTextureCache sharedTextureCache] removeTexture:_tex];
}

- (void) kiss
{
    [super kiss];
    
    CGRect rect = CGRectZero;
    rect.size = _tex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:_tex rect:rect];
    self.displayFrame = frame;
}

@end

@interface KissObjectKangaroo : KissObject
{
    CCTexture2D *_tex;
    
    CCSprite *kangaroo;
}

@end

@implementation KissObjectKangaroo

- (id) initObject
{
    self = [super initWithFile:@"kangaroo.png"];
    self.position = ccpCompMult(screen_p(), ccp(0.616, 0.438));
    _kissPosition = ccpCompMult(node_p(self), ccp(0.662, 0.517));
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"kangaroo_bg.png" withBlock:^(CCTexture2D *tex) {
        _tex = [tex retain];
    }];
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"kangaroo_kiss.png" withBlock:^(CCTexture2D *tex) {
        CGRect rect = CGRectZero;
        rect.size = tex.contentSize;
        CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:tex rect:rect];
        kangaroo = [[CCSprite spriteWithSpriteFrame:frame] retain];
    }];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [_tex release];
    [[CCTextureCache sharedTextureCache] removeTexture:_tex];
    [kangaroo release];
}

- (void) kiss
{
    [super kiss];
    
    CGRect rect = CGRectZero;
    rect.size = _tex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:_tex rect:rect];
    self.displayFrame = frame;
    
    self.position = ccpCompMult(screen_p(), ccp(0.607, 0.167));
    kangaroo.position = ccpCompMult(node_p(self), ccp(0.486, 1.285));
    [self addChild:kangaroo];
    
    CCJumpBy *jump1 = [CCJumpBy actionWithDuration:2 position:ccp(0, 0) height:20 jumps:3];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1];
    CCSequence *s = [CCSequence actions:jump1,delay, nil];
    CCRepeatForever *r = [CCRepeatForever actionWithAction:s];
    [kangaroo runAction:r];
}

@end

@interface KissObjectCat : KissObject
{
    CCTexture2D *_tex;
}

@end

@implementation KissObjectCat

- (id) initObject
{
    self = [super initWithFile:@"cat.png"];
    self.position = ccpCompMult(screen_p(), ccp(0.588, 0.446));
    _kissPosition = ccpCompMult(node_p(self), ccp(0.571, 0.518));
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"cat_kiss.png" withBlock:^(CCTexture2D *tex) {
        _tex = [tex retain];
    }];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [_tex release];
    [[CCTextureCache sharedTextureCache] removeTexture:_tex];
}

- (void) kiss
{
    [super kiss];
    
    CGRect rect = CGRectZero;
    rect.size = _tex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:_tex rect:rect];
    self.displayFrame = frame;
}

@end

@interface KissObjectWhale : KissObject
{
    CCTexture2D *_tex;
}

@end

@implementation KissObjectWhale

- (id) initObject
{
    self = [super initWithFile:@"whale.png"];
    self.position = ccpCompMult(screen_p(), ccp(0.588, 0.443));
    _kissPosition = ccpCompMult(node_p(self), ccp(0.248, 0.440));
    
    [[CCTextureCache sharedTextureCache] addImageAsync:@"whale_kiss.png" withBlock:^(CCTexture2D *tex) {
        _tex = [tex retain];
    }];
    
    CCSprite *bg = [CCSprite spriteWithFile:@"whale_bg.png"];
    bg.position = ccpCompMult(node_p(self), ccp(0.428, 0.196));
    [self addChild:bg];
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [_tex release];
    [[CCTextureCache sharedTextureCache] removeTexture:_tex];
}

- (void) kiss
{
    [super kiss];
    
    CGRect rect = CGRectZero;
    rect.size = _tex.contentSize;
    CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:_tex rect:rect];
    self.displayFrame = frame;
}

@end

@interface TouchGameKiss ()
{
    NSDictionary *displaySprites;
    
    CCSprite *shine;
    
    KissObject *displaySprite;
}

@end

@implementation TouchGameKiss

+ (TouchGameKiss *) gameLayer
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
    NSAssert(self, @"game:I see failed init");
    KissObject *bird = [KissObjectBird newObject];
    KissObject *cat = [KissObjectCat newObject];
    KissObject *goldfish = [KissObjectGoldfish newObject];
    KissObject *kangaroo = [KissObjectKangaroo newObject];
    KissObject *koala = [KissObjectKoala newObject];
    KissObject *whale = [KissObjectWhale newObject];
    
    displaySprites = @{@"bird":bird,
                       @"cat":cat,
                       @"goldfish":goldfish,
                       @"kangaroo":kangaroo,
                       @"koala":koala,
                       @"whale":whale};
    [displaySprites retain];
    CCLayerGradient *bg = [CCLayerGradient layerWithColor:ccc4(255, 255, 255, 255) fadingTo:ccc4(0, 255, 255, 25.5) alongVector:ccp(0, 1)];
    bg.contentSize = SCREEN_SIZE;
    bg.zOrder = -2;
    [self addChild:bg];
    
    shine = [CCSprite spriteWithFile:@"shine.png"];
    shine.position = ccpCompMult(screen_p(), ccp(0.219, 0.602));
    shine.visible = NO;
    shine.zOrder = 0;
    [self addChild:shine];
    
    __block TouchGameKiss* self_copy = self;
    [self setObjectLoadedBlock:^(GameObject *object) {
        object.visible = NO;
    }];
    
    [self setObjectActivedBlock:^(GameObject *object) {
        blinkSprite(object);
        ((CCSprite*)self_copy->shine).visible = YES;
        
        object.visible = YES;
        
        [self_copy removeChild:self_copy->displaySprite cleanup:YES];
        self_copy->displaySprite = [self_copy->displaySprites objectForKey:object.name];
        [self_copy addChild:self_copy->displaySprite];
        
        ([self_copy contentLabel]).string = object.content;
    }];
    
    [self setObjectCLickedBlock:^(GameObject *object) {
        unblinkSprite(object);
        ((CCSprite*)self_copy->shine).visible = NO;
    }];
    
    [self scheduleUpdate];
    [self setAutoActiveNext:NO];
    
    [self setTouchEnabled:YES];
    
    return self;
}

- (void) dealloc
{
    [self unscheduleUpdate];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [displaySprites release];
    displaySprites = nil;
    
    [super dealloc];
}

- (void) update:(ccTime)delta
{
    shine.rotation += 100 * delta;
    shine.opacity = self.runningObject.opacity;
}

- (void) setGameMode:(TouchGameMode)gameMode
{
    // do nothing
}

- (BOOL) objectHasBeenClicked:(GameObject *)object
{
    if (![super objectHasBeenClicked:object])
        return NO;
    
    if (object.tag < 3)
    {
        __block GameObject *objc = object;
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:displaySprite.kissPosition];
        CCCallBlock *done = [CCCallBlock actionWithBlock:^{
            objc.visible = NO;
            [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:object];
        
            [displaySprite kiss];
        }];
        CCSequence *seq = [CCSequence actions:move,done, nil];
        [objc runAction:seq];
        object.tag = 3;
    }
    return YES;
}

#pragma mark --touch

-(void) registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.runningObject.tag > 2)
        [self activeNextObjects];
}

@end
