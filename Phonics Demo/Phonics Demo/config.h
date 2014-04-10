//
//  config.h
//  LetterE
//
//  Created by yiplee on 14-3-17.
//  Copyright (c) 2014年 USTB. All rights reserved.
//

#ifndef LetterE_config_h
#define LetterE_config_h

#define SCREEN_SIZE             [[CCDirector sharedDirector] winSize]
#define SCREEN_WIDTH            SCREEN_SIZE.width
#define SCREEN_HEIGHT           SCREEN_SIZE.height
#define SCREEN_SIZE_AS_POINT    ccp(SCREEN_WIDTH,SCREEN_HEIGHT)
#define CCMP(x,y)               ccpCompMult(SCREEN_SIZE_AS_POINT,ccp((x),(y)))
#define CMP(x)                  CCMP(x,x)

static char *const touchingGameRootPath = "Assets/touchingGames";
static char *const BMFontDirPath = "Assets/BMFont";
static char *const imageMatchGameRootPath = "Assets/imageMatch";
static char *const audioDicPath = "data/audioDic";

#endif
