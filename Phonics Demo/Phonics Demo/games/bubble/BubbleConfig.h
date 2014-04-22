//
//  config.h
//  bubble
//
//  Created by yiplee on 13-4-1.
//  Copyright (c) 2013年 yiplee. All rights reserved.
//

#ifndef bubble_config_h
#define bubble_config_h

enum Z_LAYERS {
	Z_BACKGROUND = -1,
	Z_OBJECT,
	Z_BUBBLE,
	Z_PARTICLES,
    Z_COVER,
	Z_PHYSICS_DEBUG,
	Z_MENU,
};

static const cpLayers PhysicsBubbleBit = 1<<31;

// These are the layer bitmasks used for bubble and edges.
static const cpLayers PhysicsEdgeLayers = ~PhysicsBubbleBit;
static const cpLayers PhysicsBubbleLayers = CP_ALL_LAYERS;

#endif
