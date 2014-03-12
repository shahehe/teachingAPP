//
//  PhonicsDefines.h
//  Phonics Demo
//
//  Created by yiplee on 13-7-20.
//  Copyright (c) 2013年 USTB. All rights reserved.
//

#ifndef Phonics_Demo_PhonicsDefines_h
#define Phonics_Demo_PhonicsDefines_h

#define NEED_OUTPUT_LOG         1

#define APP_CACHES_PATH         [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0]

#define APP_DOCUMENT_PATH       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0]

#define SCREEN_SIZE             [[CCDirector sharedDirector] winSize]

#define SCREEN_WIDTH            SCREEN_SIZE.width
#define SCREEN_HEIGHT           SCREEN_SIZE.height

#define SCREEN_SIZE_AS_POINT    ccp(SCREEN_WIDTH,SCREEN_HEIGHT)

#define CCMP(x,y)               ccpCompMult(SCREEN_SIZE_AS_POINT,ccp((x),(y)))
#define CMP(x)                  CCMP(x,x)

#define IS_IPHONE               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_4_INCH               (SCREEN_HEIGHT > 480.0)

#define RGBCOLOR(r,g,b)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)      [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define APP_STORE_LINK_http     @"null"
#define APP_STORE_LINK_iTunes   @"null"

#define SPRITE_FRAME_CACHE      [CCSpriteFrameCache sharedSpriteFrameCache]
#define TEXTURE_CACHE           [CCTextureCache sharedTextureCache]

#define RGBA8888 [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
#define RGBA4444 [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
#define RGB565 [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
#define PIXEL_FORMAT_DEFAULT    RGBA8888

#if NEED_OUTPUT_LOG

#define SLog(xx, ...)   NSLog(xx, ##__VA_ARGS__)
#define SLLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define SLLogRect(rect) \
SLLog(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height)

#define SLLogPoint(pt) \
SLLog(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define SLLogSize(size) \
SLLog(@"%s w=%f, h=%f", #size, size.width, size.height)

#define SLLogColor(_COLOR) \
SLLog(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

#else

#define SLog(xx, ...)  ((void)0)
#define SLLog(xx, ...)  ((void)0)

#endif


#endif
