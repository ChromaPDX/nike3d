//
//  GlobalTypes.h
//  NSFW-bench
//
//  Created by Chroma Developer on 1/14/14.
//  Copyright (c) 2014 Chroma Developer. All rights reserved.
//

#ifndef NSFW_bench_GlobalTypes_h
#define NSFW_bench_GlobalTypes_h

#ifndef SKColor
#define SKColor UIColor
#endif

// BOARD + GEOMETRY


#define BOARD_WIDTH 7
#define BOARD_LENGTH 10

#define TILE_WIDTH 72
#define TILE_HEIGHT 96


// ANIMATION

#define FAST_ANIM_DUR .2
#define CAM_SPEED 1.
#define CARD_ANIM_DUR .3

// UI COLORS

#define V2RED [SKColor colorWithRed:255./255. green:42./255. blue:0./255. alpha:1.]
#define V2BLUE [SKColor colorWithRed:0./255. green:92./255. blue:255./255. alpha:1.]
#define V2GREEN [SKColor colorWithRed:52./255. green:255./255. blue:42./255. alpha:1.]

#define OFRED ofColor(255, 42, 0, 150)
#define OFBLUE ofColor(0, 92, 255, 150)
#define OFGREEN ofColor(0, 100, 40, 220)

#define V2SKILL [SKColor colorWithRed:154./255. green:0./255. blue:226./255. alpha:1.]
#define V2GEAR [SKColor colorWithRed:255./255. green:206/255. blue:0./255. alpha:1.]
#define V2BOOST V2RED

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
