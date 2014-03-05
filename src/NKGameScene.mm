//
//  NKGameScene.m
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"

@interface NKGameScene (){
    float boardScale;
    NSMutableDictionary *playerSprites;
    BoardLocation *fingerLocationOnBoard;  // so far, used when moving a card onto the board, traversing over board tiles
    
//    ButtonSprite *end;
//    ButtonSprite *draw;
}
@end

@implementation NKGameScene

-(void)setOrientation:(ofQuaternion)orientation {
    _pivot.node->setOrientation(orientation);
}

-(instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.] ];
        [self setupGameBoard];
    }
    
    return self;
}
-(void)setupGameBoard {
    
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    _gameTiles = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    _pivot = [[NKNode alloc]init];
    
    [self addChild:_pivot];

    
    NKSpriteNode *logo = [[NKSpriteNode alloc]initWithTexture:[NKSpriteNode texNamed:@"GAMELOGO.png"] color:nil size:CGSizeMake(TILE_WIDTH*4, TILE_WIDTH*5.2)];
    //[logo setPosition:CGPointMake(self.size.width*.5, self.size.height*.5)];
    [_pivot addChild:logo];
    [logo setZPosition:-3];

    
    _boardScroll = [[NKScrollNode alloc] initWithColor:nil size:CGSizeMake(BOARD_WIDTH*TILE_WIDTH, BOARD_LENGTH*TILE_HEIGHT)];
    
    [_pivot addChild:_boardScroll];
    
    _gameBoardNode = [[GameBoardNode alloc] initWithTexture:[NKSpriteNode texNamed:@"Background_Field.png"] color:Nil size:CGSizeMake(BOARD_WIDTH*TILE_WIDTH + TILE_WIDTH*.7, BOARD_LENGTH*TILE_HEIGHT + TILE_HEIGHT/2.)];
    
    [_boardScroll addChild:_gameBoardNode];
    
    _gameBoardNode.userInteractionEnabled = true;
    
    
    for(int i = 0; i < BOARD_WIDTH; i++){
        for(int j = 0; j < BOARD_LENGTH; j++){
            BoardTile *square = [[BoardTile alloc] initWithTexture:Nil color:[NKColor colorWithRed:.7 green:1. blue:1. alpha:.1] size:CGSizeMake(TILE_WIDTH-20, TILE_HEIGHT-20)];
            
            [square setLocation:[BoardLocation pX:i Y:j]];
            [_gameBoardNode addChild:square];
            [_gameTiles setObject:square forKey:square.location];
            
            //[square setPosition:CGPointMake((i+.5)*TILE_WIDTH - (TILE_WIDTH*BOARD_WIDTH*.5), ((j+.5)*TILE_HEIGHT) - (TILE_HEIGHT*BOARD_LENGTH*.5)) ];
            
            [square setPosition:CGPointMake((i+.5)*TILE_WIDTH - (TILE_WIDTH*BOARD_WIDTH*.5), ((j+.5)*TILE_HEIGHT) - (TILE_HEIGHT*BOARD_LENGTH*.5)) ];
        }
    }
    
    NKSpriteNode *lines = [[NKSpriteNode alloc] initWithTexture:[NKSpriteNode texNamed:@"Field_Layer01.png"] color:nil size:_gameBoardNode.size];
    
    [_gameBoardNode addChild:lines];
    [lines set3dPosition:ofPoint(0,0,5)];
    
    NKSpriteNode *glow = [[NKSpriteNode alloc] initWithTexture:[NKSpriteNode texNamed:@"Field_Layer02.png"] color:nil size:_gameBoardNode.size];
    
    [_gameBoardNode addChild:glow];
    [glow set3dPosition:ofPoint(0,0,10)];
    
    
    for (int i = 0; i < 7; i++){
    PlayerNode *player1 = [[PlayerNode alloc] initWithTexture:[NKSpriteNode texNamed:@"PlayerIndicator_PlayerON.png"] color:nil size:CGSizeMake(TILE_WIDTH, TILE_HEIGHT)];
    
    [_gameTiles[[BoardLocation pX:i Y:rand()%7]] addChild:player1];
    
    [player1 set3dPosition:ofPoint(0,0,TILE_HEIGHT/2.)];
    
    player1.node->setOrientation(ofVec3f(90,0,0));
        
        [player1 runAction:[NKAction repeatActionForever:[NKAction rotateByAngle:90 duration:.1 + ((rand()%100) / 100.)]]];
        
    }
    
    //[self loadShader:[[NKDrawDepthShader alloc] initWithNode:self paramBlock:nil]];
    //
    
}

-(void)startMiniGame {
    
    _miniGameNode = [[MiniGameNode alloc] initWithSize:self.size];
    
    [self addChild:_miniGameNode];
    

    [_miniGameNode startMiniGame];
    
   // [self loadShader:[[NKGaussianBlur alloc] initWithNode:self blurSize:4 numPasses:4]];
    
}

-(void)gameDidFinishWithWin {
    [_miniGameNode removeFromParent];
    _miniGameNode = nil;
}

-(void)gameDidFinishWithLose {
    [_miniGameNode removeFromParent];
    _miniGameNode = nil;
}

//-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
//    [super updateWithTimeSinceLast:dt];
//    
//    if (_miniGameNode) {
//        [_miniGameNode updateWithTimeSinceLast:dt];
//    }
//    
//}
//-(void)draw {
//    [super draw];
//    
//    if (_miniGameNode) {
//        [_miniGameNode draw];
//    }
//}

-(bool)touchUp:(CGPoint)location id:(int)touchId {
    if (!_miniGameNode) {
        [self startMiniGame];
    }
    return [super touchUp:location id:touchId];
    
}

@end
