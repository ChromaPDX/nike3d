//
//  BoardTile.h
//  nike3dField
//
//  Created by Chroma Developer on 3/3/14.
//
//

#import "NKSpriteNode.h"
@class BoardLocation;

@interface BoardTile : NKSpriteNode

// MODEL
@property (nonatomic, strong) BoardLocation *location;

-(instancetype)initWithTexture:(ofTexture *)texture color:(UIColor *)color size:(CGSize)size;

@end
