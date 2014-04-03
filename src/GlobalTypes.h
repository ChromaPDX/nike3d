//
//  GlobalTypes.h
//  NSFW-bench
//
//  Created by Chroma Developer on 1/14/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

//#define OF_BACKED

#ifndef NSFW_bench_GlobalTypes_h
#define NSFW_bench_GlobalTypes_h

#ifndef SKColor
#define SKColor UIColor
#endif

// BOARD + GEOMETRY


#define BOARD_WIDTH 7
#define BOARD_LENGTH 10

#define TILE_WIDTH 96
#define TILE_HEIGHT 116


// ANIMATION

#define FAST_ANIM_DUR .2
#define CAM_SPEED 1.
#define CARD_ANIM_DUR .3

// UI COLORS

#define V2RED [NKColor colorWithRed:224./255. green:82./255. blue:98./255. alpha:1.]
#define V2BLUE [NKColor colorWithRed:13./255. green:107./255. blue:209./255. alpha:1.]
#define V2GREEN [NKColor colorWithRed:0./255. green:168./255. blue:171./255. alpha:1.]
#define V2YELLOW [NKColor colorWithRed:231./255. green:174./255. blue:31./255. alpha:1.]
#define V2ORANGE [NKColor colorWithRed:247./255. green:138./255. blue:37./255. alpha:1.]
#define V2PURPLE [NKColor colorWithRed:138./255. green:85./255. blue:255./255. alpha:1.]
#define V2MAGENTA [NKColor colorWithRed:184./255. green:39./255. blue:244./255. alpha:1.]

#define OFRED ofColor(255, 42, 0, 150)
#define OFBLUE ofColor(0, 92, 255, 150)
#define OFGREEN ofColor(0, 100, 40, 220)

#define MOVE_CAMERA 1
#define BALL_SCALE_BIG .5
#define BALL_SCALE_SMALL .25

#define debugUI 1

#ifdef debugUI
#define UILog NSLog
#else
#define UILog //
#endif



#endif
