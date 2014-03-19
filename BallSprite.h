//
//  BallSprite.h
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NKSpriteNode.h"

@class PlayerSprite;

@interface BallSprite : NKSpriteNode

@property (nonatomic, weak) PlayerSprite *player;

@end
