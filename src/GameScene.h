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

@class GameBoardNode;
@class MiniGameNode;
@class ActionWindow;
@class Card;
@class Game;


@interface GameScene : NKSceneNode <MiniMazeObjDelegate, GameSceneProtocol>

// SHARE GAME / UI PROPS

@property (nonatomic, weak) Game* game;
@property (nonatomic, weak) Card* selectedCard;
@property (nonatomic, weak) Card* selectedPlayer;

@property (nonatomic, strong) NSMutableDictionary *gameTiles;  //objects:game tiles, key:location

// UI NODES / SPRITES

@property (nonatomic,strong) NKNode* pivot;
@property (nonatomic,strong) NKScrollNode* boardScroll;
@property (nonatomic, strong) GameBoardNode *gameBoardNode;

@property (nonatomic, strong) ActionWindow *actionWindow;

@property (nonatomic, weak) NKNode *followNode;
@property (nonatomic, strong) NKSpriteNode *RTSprite;
@property (nonatomic, strong) NKSpriteNode *ballSprite;

@property (nonatomic, strong) NKSpriteNode *infoHUD;

@property (nonatomic, strong) MiniGameNode *miniGameNode;

-(void)setOrientation:(ofQuaternion)orientation;

-(void)gameDidFinishWithLose;
-(void)gameDidFinishWithWin;

// INTER NODE / DELEGATE

-(void)shouldPerformCurrentAction;
-(BOOL)requestActionWithPlayer:(PlayerSprite*)player;


@end