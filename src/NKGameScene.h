//
//  NKGameScene.h
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NKSceneNode.h"
#import "MiniMaze.h"
#import "Game.h"

@class NKGameBoardNode;
@class MiniGameNode;

@interface NKGameScene : NKSceneNode <MiniMazeObjDelegate, GameSceneProtocol>

@property (nonatomic, strong) NSMutableDictionary *gameTiles;  //objects:game tiles, key:location
//
@property (nonatomic,strong) NKNode* pivot;
@property (nonatomic,strong) NKScrollNode* boardScroll;
@property (nonatomic, strong) GameBoardNode *gameBoardNode;

@property (nonatomic, strong) MiniGameNode *miniGameNode;

-(void)setOrientation:(ofQuaternion)orientation;

-(void)gameDidFinishWithLose;
-(void)gameDidFinishWithWin;

@end
