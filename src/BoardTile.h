//
//  BoardTile.h
//  nike3dField
//
//  Created by Chroma Developer on 3/3/14.
//
//

#import "NKSpriteNode.h"

@class BoardLocation;
@class GameScene;

@interface BoardTile : NKSpriteNode

-(instancetype)initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size;

// MODEL
@property (nonatomic, strong) BoardLocation *location;

// VIEW
@property (nonatomic, weak) GameScene *delegate;

@end
