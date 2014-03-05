//
//  MiniGameNode.h
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NKNode.h"

class MiniMaze;
class MiniMazeDelegate;

@interface MiniGameNode : NKNode

-(instancetype)initWithSize:(CGSize) size;

@property (nonatomic) MiniMaze *miniMaze;

-(void)startMiniGame;

@end
