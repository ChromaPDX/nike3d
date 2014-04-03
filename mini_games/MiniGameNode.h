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

class MiniTouch;
class MiniTouchDelegate;

class MiniCups;
class MiniCupsDelegate;

@interface MiniGameNode : NKNode

-(instancetype)initWithSize:(CGSize) size;

@property (nonatomic) MiniMaze *miniMaze;
@property (nonatomic) MiniTouch *miniTouch;
@property (nonatomic) MiniCups *miniCups;

@property (nonatomic) NSString *cardCategoryTitle;
// the other mini titles can be made into variables too, like above

-(void)startMiniGame;

@end
