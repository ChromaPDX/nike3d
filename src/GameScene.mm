//
//  NKGameScene.m
//  nike3dField
//
//  Created by Chroma Developer on 2/27/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"
#import "ModelHeaders.h"

int THICK_LINE;
int MED_LINE;
float DRIBBLE_WIDTH;
float THUMB_OFFSET;
float UI_MULT;
float WINDOW_WIDTH;
float WINDOW_HEIGHT;
float ANCHOR_WIDTH;
float PARTICLE_SCALE;

@interface GameScene (){
    float boardScale;
    NSMutableDictionary *playerSprites;
    BoardLocation *fingerLocationOnBoard;  // so far, used when moving a card onto the board, traversing over board tiles
    
//    ButtonSprite *end;
//    ButtonSprite *draw;
}
@end

@implementation GameScene

-(void)setOrientation:(ofQuaternion)orientation {
    [_pivot setOrientation:orientation];
}

-(instancetype)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone ) {
            THICK_LINE = 2;
            MED_LINE = 1;
            THUMB_OFFSET = .72;
            UI_MULT = 1.1;
            WINDOW_WIDTH = size.width*.265;
            WINDOW_HEIGHT = size.height;
            ANCHOR_WIDTH = size.width * .65;
            PARTICLE_SCALE = 1.;
            DRIBBLE_WIDTH = 3;
        }
        else {
            DRIBBLE_WIDTH = 6;
            THICK_LINE = 3;
            MED_LINE = 2;
            THUMB_OFFSET = .05;
            UI_MULT = 1.;
            WINDOW_WIDTH = size.width*.275;
            WINDOW_HEIGHT = size.height;
            ANCHOR_WIDTH = size.width * .65;
            PARTICLE_SCALE = 2.;
            
        }

        boardScale = 1.;
        
        
//
//        _scoreBoard = [[ScoreBoard alloc] initWithTexture:nil color:nil size:CGSizeMake(WINDOW_WIDTH*2., WINDOW_WIDTH*.5)];
//        [_scoreBoard setPosition:CGPointMake(ANCHOR_WIDTH, self.size.height*.978333)];
//        [_scoreBoard setDelegate:self];
//        [_scoreBoard setZPosition:Z_INDEX_BOARD+2];
//        _scoreBoard.delegate = self;
//        
//        [self addChild:_scoreBoard];
//        
//        _fuelBar = [[FuelBar alloc]initWithTexture:[NKTexture textureWithImageNamed:@"BoostBarFull"] color:Nil size:CGSizeMake(size.height*.05625, size.height*.9)];
//        [self addChild:_fuelBar];
//        [_fuelBar setPosition:CGPointMake(WINDOW_WIDTH + size.height*.015, size.height*.49)];
//        [_fuelBar setZPosition:Z_INDEX_BOARD];
//        
//        NSLog(@"fuelBarSize: %f %f", size.height*.05625,size.height*.5);
        
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.] ];
        
        _game = [[Game alloc] init];
        _game.gameScene = self;
        
     
        
    }
    
    return self;
}

-(void)setupGameBoard {
    
    NSLog(@"setup gameBoard %f :%f",w,h);
    

    
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    _gameTiles = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    _pivot = [[NKNode alloc]init];
    
     _pivot.name = @"PIVOT";
    
    [self addChild:_pivot];
    
    [_pivot setPosition3d:(ofPoint(0,-h*.5,0))];
    
    
    _uxWindow = [[UXWindow alloc] initWithTexture:nil color:[NKColor colorWithRed:45/255. green:45/255. blue:45/255. alpha:.5] size:CGSizeMake(w, h*.15)];
    [_uxWindow setPosition3d:ofPoint(0,-h*.42,20)];
    _uxWindow.delegate = self;
    [self addChild:_uxWindow];
    
//    NKSpriteNode *logo = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:@"GAMELOGO.png"] color:nil size:CGSizeMake(TILE_WIDTH*4, TILE_WIDTH*5.2)];
//    [_pivot addChild:logo];
//    [logo setZPosition:-3];

    
//    _boardScroll = [[NKScrollNode alloc] initWithColor:nil size:CGSizeMake(BOARD_WIDTH*TILE_WIDTH + (TILE_WIDTH*.7), BOARD_LENGTH*TILE_HEIGHT + (TILE_HEIGHT*.5))];
//    
//    [_pivot addChild:_boardScroll];
    
    //_boardScroll.userInteractionEnabled = false;
    
    _gameBoardNode = [[GameBoardNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Background_Field.png"] color:Nil size:CGSizeMake(BOARD_WIDTH*TILE_WIDTH + (TILE_WIDTH*.7), BOARD_LENGTH*TILE_HEIGHT + (TILE_HEIGHT*.5))];
    
    [_pivot addChild:_gameBoardNode];
    
    [_gameBoardNode setPosition3d:ofPoint(0,h*.5,0)];
    
    _gameBoardNode.userInteractionEnabled = true;
    
    _gameBoardNode.name = @"Game Board";
    
    for(int i = 0; i < BOARD_WIDTH; i++){
        for(int j = 0; j < BOARD_LENGTH; j++){
            BoardTile *square = [[BoardTile alloc] initWithTexture:Nil color:nil size:CGSizeMake(TILE_WIDTH-2, TILE_HEIGHT-2)];
            
            [square setLocation:[BoardLocation pX:i Y:j]];
            
            square.delegate = self;
            
            [_gameBoardNode addChild:square];
            [_gameTiles setObject:square forKey:square.location];
            
            [square setPosition3d:ofPoint((i+.5)*TILE_WIDTH - (TILE_WIDTH*BOARD_WIDTH*.5), ((j+.5)*TILE_HEIGHT) - (TILE_HEIGHT*BOARD_LENGTH*.5),2) ];
        }
    }
    
    NKSpriteNode *lines = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer01.png"] color:nil size:_gameBoardNode.size];
    
    [_gameBoardNode addChild:lines];
    [lines setPosition3d:ofPoint(0,0,3)];
    
    NKSpriteNode *glow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer02.png"] color:nil size:_gameBoardNode.size];
    
    [_gameBoardNode addChild:glow];
    [glow setPosition3d:ofPoint(0,0,6)];
    
    
//    NKDrawDepthShader* ddepthShader = [[NKDrawDepthShader alloc] initWithNode:self paramBlock:nil];
//    //ddepthShader.useColor = true;
//    ddepthShader.shouldInvert= true;
    
   // [self loadShader:ddepthShader];
    
    //
    
//    [_pivot runAction:[NKAction repeatActionForever:[NKAction sequence:@[[NKAction moveByX:100 y:0 duration:1.] ,
//                                                                         [NKAction moveByX:-100 y:0 duration:1.] ,
//                                                                         [NKAction moveByX:0 y:100 duration:1.] ,
//                                                                         [NKAction moveByX:0 y:-100 duration:1.] ,
//                                                                         
//                                                                         ]
//                                                                         
//                                                     ]]];
//
    

    
    [_pivot runAction:[NKAction rotate3dToAngle:ofVec3f(-26, 0,0) duration:2.]];
    [_pivot runAction:[NKAction move3dTo:ofVec3f(0,-h*.35,0) duration:2.]];
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

#pragma mark - UI 

#pragma mark - CREATE PLAYER EVENT

-(void)resetFingerLocation {
    fingerLocationOnBoard = [BoardLocation pX:-999 Y:-999];
}


-(BOOL)requestActionWithPlayer:(PlayerSprite*)player {
    
    [self resetFingerLocation];
    
    if (_selectedCard) {
        // NSLog(@"has card, returning");
        [self setSelectedCard:nil];
    }
    _selectedPlayer = player.model;
    
    if ([_game canUsePlayer:player.model]){
        
        NSLog(@"CAN USE PLAYER: %@", player.model.name);
        
//        [_infoHUD setPlayer:player.model];
//        [_infoHUD setZPosition:Z_BOARD_LOW];
  //      [_gameBoardNode fadeInSprite:_infoHUD];
        
        return YES;
    }
    
    else {
        
        NSLog(@"NOPE NOT FOR PLAYER: %@", player.model.name);
        
//        [_infoHUD setPlayer:player.model];
//        [_infoHUD setZPosition:Z_BOARD_LOW];
//        [_gameBoardNode fadeInSprite:_infoHUD];
        
        return NO;
    }
}

// ADD ACTION STATISTICS TO GAME TILE VIEWS
// convert finger position to BoardLocation,
// get tile, add stuff to it


-(BOOL)validatePlayerMove:(Player *)card {
    
    if ([_game validatePlayerMove:card]) {
        NSLog(@"action is valid!");

        return 1;
    }
    
    else {
        
        NSLog(@"GameScene.m : shouldMovePlayer : remove action UI");
//        [_infoHUD setZPosition:Z_BOARD_LOW];
//        [_infoHUD validate:NO];
        
    }
    
    return 0;
    
}

#pragma mark - UX INTERACTION

-(BoardLocation*)locationOnBoardFromPoint:(CGPoint)location {
    
    return [BoardLocation pointWithCGPoint:CGPointMake((location.x + _gameBoardNode.size.width/2.) / TILE_WIDTH,(location.y + _gameBoardNode.size.height/2.) /TILE_HEIGHT)];
    
}

-(BOOL)isNewLocation:(BoardLocation*)loc {
    
    if ([loc isEqual:fingerLocationOnBoard]) {
        return 0;
    }
    
    fingerLocationOnBoard = [loc copy];
    
    return 1;
    
}


-(void)cleanUpUIForSequence:(GameSequence *)sequence {
    for (BoardTile* tile in _gameTiles.allValues) {
        [tile setColor:nil];
        [tile setTexture:nil];
        [tile setUserInteractionEnabled:false];
    }
}

-(void)setSelectedCard:(Card *)selectedCard {
    
    _game.selectedCard = selectedCard;
    _selectedCard = selectedCard;
    
}

-(void)showCardPath:(NSArray*)path{
    
    for (BoardTile* tile in _gameTiles.allValues) {
        [tile setColor:nil];
        [tile setTexture:nil];
        [tile setUserInteractionEnabled:false];
    }
    for (BoardLocation* loc in path) {
        BoardTile* tile = [_gameTiles objectForKey:loc];
        [tile setColor:V2BLUE];
        [tile.location setBorderShapeInContext:path];
        [tile setTextureForBorder:tile.location.borderShape];
        [tile setUserInteractionEnabled:true];
    }
    
}

-(void)setSelectedBoardTile:(BoardTile *)selectedBoardTile {
    
    
    if (_selectedCard) {
        _game.selectedLocation = selectedBoardTile.location;
    }
    
    _selectedBoardTile = selectedBoardTile;
}


#pragma mark - ANIMATIONS !!! AKA SOCCER_STAR_GALACTICA

-(void)animateEvent:(GameEvent*)event withCompletionBlock:(void (^)())block {
    
    float MOVE_SPEED = .35;
    float BALL_SPEED = .2;
    
    [self refreshActionPoints];
    
    PlayerSprite* player = [playerSprites objectForKey:event.playerPerforming];
    
    if (event.type == kEventStartTurn){
        block();
    }
    
    else if (event.type == kEventSetBallLocation) {
        
        [_gameBoardNode fadeInChild:self.ballSprite duration:.3];
        //[self cameraShouldFollowSprite:Nil withCompletionBlock:^{}];
        
        if (_game.ball.enchantee) {
 
            PlayerSprite* p = [playerSprites objectForKey:_game.ball.enchantee];
            
            [p getReadyForPosession:^{
                [self.ballSprite runAction:[NKAction move3dTo:[p.ballTarget positionInNode3d:_gameBoardNode] duration:BALL_SPEED]  completion:^{
                    //[_ballSprite removeAllActions];
                    block();
                    [p startPossession];
                    NSLog(@"ball actions : %d", [self.ballSprite hasActions]);
                    
                }];
            }];
            
        }
        
        else {
            block();
        }
        
    }
    
    else if (event.type == kEventMove){
        [player runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            
            if (event.playerPerforming.ball) {
                [player getReadyForPosession:^{
                    [self.ballSprite runAction:[NKAction move3dTo:[player.ballTarget positionInNode3d:_gameBoardNode] duration:BALL_SPEED] completion:^{
                        [player startPossession];
                        block();
                    }];
                }];
            }
            else {
                
                block();
            }
        }];
        
        
        
        
    }
    
    else if (event.type == kEventChallenge) {
        
        PlayerSprite* receiver = [playerSprites objectForKey:event.playerReceiving];
        
        NKEmitterNode *glow = [self ballGlowWithColor:receiver.color];
        
        [self.ballSprite addChild:glow];
        
        [glow runAction:[NKAction scaleTo:1. * PARTICLE_SCALE duration:CAM_SPEED*.5] completion:^{}];
        
        [player runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            
            if (event.wasSuccessful) {
                
                NKEmitterNode *glow2 = [self ballGlowWithColor:player.color];
                [self.ballSprite addChild:glow2];
                
                [glow2 runAction:[NKAction scaleTo:2. * PARTICLE_SCALE duration:.01] completion:^{
                    
                    [receiver stopPosession:^{
                        
                        [receiver runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.startingLocation] position] duration:MOVE_SPEED]];
                        
                        [glow removeFromParent];
                        [receiver addChild:glow];
                        [glow setPosition3d:[receiver.ballTarget positionInNode3d:_gameBoardNode]];
                        
                        [glow runAction:[NKAction moveTo:CGPointZero duration:CAM_SPEED*.25] completion:^{
                        }];
                        [glow runAction:[NKAction scaleTo:.01 * PARTICLE_SCALE duration:CAM_SPEED] completion:^{
                            [glow removeFromParent];
                        }];
                        
                        
                        [player stealPossesionFromPlayer:receiver];
                        [player startPossession];
                        
                        [glow2 runAction:[NKAction scaleTo:.01 * PARTICLE_SCALE duration:CAM_SPEED] completion:^{
                            [glow2 removeFromParent];
                        }];
                        
                        
                        block();
                        
                    }];
                    
                }];
                
            }
            else {
                
                
                [player runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.startingLocation] position] duration:MOVE_SPEED] completion:^{
                    [glow runAction:[NKAction scaleTo:.01 * PARTICLE_SCALE duration:CAM_SPEED*.25] completion:^{
                        [glow removeFromParent];
                    }];
                    block();
                }];
                
                
            }
            
        }];
        
        
        
        
        
    }
    
    else if (event.type == kEventKickPass || event.type == kEventKickGoal) {
        
         NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
        
        [self.ballSprite addChild:enchant];
        [enchant setZPosition:Z_INDEX_FX];
        [enchant setScale:.01];
        

        PlayerSprite* receiver = [playerSprites objectForKey:event.playerReceiving];
        
        float locScale = .5;
        if (event.type == kEventKickGoal) {
            locScale = 1.;
        }
        
        [enchant runAction:[NKAction scaleTo:2. * PARTICLE_SCALE * locScale duration:CAM_SPEED*.75] completion:^{
            
            [player stopPosession:^{
                
                if ((event.type == kEventKickPass && event.wasSuccessful)|| (event.type == kEventKickGoal && !event.wasSuccessful)) {
                    
                    // SUCESSFULL PASS OR FAILED GOAL
                    
                    [receiver getReadyForPosession:^{

                        // [self dollyTowards:receiver duration:CAM_SPEED*.25];
                        
                        NKAction *move = [NKAction move3dTo:[receiver.ballTarget positionInNode3d:_gameBoardNode] duration:BALL_SPEED];
                        
                        [move setTimingMode:NKActionTimingEaseOut];
                        
                        [self.ballSprite runAction:move completion:^(){
                            
                            
                            [receiver startPossession];
                            
                            if (event.type == kEventKickGoal) {
                                [self animateBigText:@"MISSED!" withCompletionBlock:^{
                                    
                                }];
                            }
                            
                            //                            else if (event.type == kGoaliePass) {
                            //
        
                            //
                            //                            }
                            
                            [enchant runAction:[NKAction scaleTo:.01 duration:CARD_ANIM_DUR*2] completion:^{
                                [enchant removeFromParent];
                                block();
                                
                            }];
                            
                            
                            
                            
                        }];
                        
                    }];
                }
                
                else if (event.wasSuccessful && event.type == kEventKickGoal) {
                    
                    // SUCCESSFUL GOAL
                    

                        CGPoint dest;
                        
                        if (event.manager.teamSide) {
                            dest = CGPointMake(-_gameBoardNode.size.width, 0);
                        }
                        else {
                            dest = CGPointMake(_gameBoardNode.size.width, 0);
                            
                        }
                        
                    
                        NKAction *move = [NKAction moveTo:dest duration:.3];
                        [move setTimingMode:NKActionTimingEaseOut];
                        
                        [self.ballSprite runAction:move completion:^(){
                            
                            NSLog(@"GameScene.m : animateEvent : GOAL");
                            
                            [self animateBigText:@"GOAL !!!" withCompletionBlock:^{
                                
                                [enchant runAction:[NKAction scaleTo:.01 duration:CAM_SPEED] completion:^{
                                    [enchant removeFromParent];
                                    _followNode = Nil;
                                    
                                    [self fadeOutChild:self.ballSprite duration:.3];
                                    
                                    block();
                                }];
                                
                                
                            }];
                            
                        }];
                        
  
                    
                    
                }
                
                else { // FAILED PASS
                    
                    
                    CGPoint dest = [[_gameTiles objectForKey:_game.ball.location] position];
                    
                    // [self dollyTowards:[_gameTiles objectForKey:_game.ball.location] duration:CAM_SPEED];
                    
                    dest.x -= TILE_WIDTH/3.;
                    dest.y += TILE_HEIGHT/3.;
                    
                    NKAction *move = [NKAction moveTo:dest duration:BALL_SPEED];
                    
                    [move setTimingMode:NKActionTimingEaseOut];
                    
                    [self.ballSprite runAction:move completion:^(){
                        
                        [self.ballSprite runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:CARD_ANIM_DUR]];
                        
                        [enchant runAction:[NKAction scaleTo:.01 duration:CARD_ANIM_DUR*2] completion:^{
                            [enchant removeFromParent];
                            block();
                        }];
                        
                    }];
                    
                    
                    
                    
                }
                
                
            }];
            
        }];
        
    }
    
    
    else if (event.type == kEventResetPlayers) {

        block();
        
    }

    else if (event.type == kEventPlayCard){
        
        // [self cameraShouldFollowSprite:nil withCompletionBlock:^{}];
        
        
        CardSprite* card = [_uxWindow spriteForCard:event.playerPerforming];
        
        //            [card removeFromParent];
        //            [_gameBoardNode addChild:card];
        //            [card setZRotation:[self rotationForManager:_game.me]];
        [card setHasShadow:YES];
        
        [card setZPosition:Z_INDEX_HUD];
        
        //[_uxWindow removeCard:card.model animated:YES withCompletionBlock:^{}];
        
        [card removeAllActions];
        
        if (card.flipped) {
            [card setFlipped:NO];
        }
        
        [card runAction:[NKAction scaleTo:1.5 duration:FAST_ANIM_DUR]];
        [card runAction:[NKAction fadeAlphaTo:1. duration:FAST_ANIM_DUR]];
        
        
        [card runAction:[NKAction moveTo:[self windowPosForBoardSprite:[_gameTiles objectForKey:event.location]] duration:CARD_ANIM_DUR] completion:^{
            [card runAction:[NKAction moveBy:CGVectorMake(0, 0) duration:CARD_ANIM_DUR*2] completion:^{
                [card.shadow runAction:[NKAction scaleTo:1.1 duration:CARD_ANIM_DUR]];
                
                NKAction *fall = [NKAction scaleTo:.5 duration:FAST_ANIM_DUR];
                [fall setTimingMode:NKActionTimingEaseIn];
                [card runAction:fall completion:^{
                    [card setZPosition:Z_INDEX_BOARD];
                    [card runAction:[NKAction moveBy:CGVectorMake(0, 0) duration:CARD_ANIM_DUR] completion:^{
                        block();
                        [_uxWindow fadeOutChild:card duration:FAST_ANIM_DUR];
                    }];
                }];
                
            }];
            
            
        }];
        
        
        
    }
    
    else if (event.type == kEventAddPlayer){
        [self addPlayerToBoardScene:event.playerPerforming animated:true withCompletionBlock:^{
            block();
        }];
    }
 
    else if (event.type == kEventRemovePlayer) {
        
        // [self cameraShouldFollowSprite:nil withCompletionBlock:^{   }];
        
        
        NSLog(@"GameScene.m : animateEvent : remove player");
        
        
        PlayerSprite* p = [playerSprites objectForKey:event.playerPerforming];
        
        [self removePlayerFromBoard:p animated:YES withCompletionBlock:^{
            block();
            
        }];
        
        
        
    }
    
    else if (event.type == kEventAddSpecial) {
        
        NSLog(@"GameScene.m : animateEvent : enchant");
        // MY PLAYER
        
        NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
//        NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Install" ofType:@"sks"]];
//        
//        NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], event.manager.color] times:@[@0,@.2]];
//        enchant.particleColorSequence = seq;
        
        [enchant setScale:2];
        [_gameBoardNode addChild:enchant];
        [enchant setZPosition:Z_INDEX_FX];
        [enchant setPosition:[[_gameTiles objectForKey:event.location] position]];
        [enchant runAction:[NKAction fadeAlphaTo:.9 duration:CARD_ANIM_DUR] completion:^{
            
            [enchant runAction:[NKAction fadeAlphaTo:0. duration:CARD_ANIM_DUR] completion:^{
                [enchant removeFromParent];
                block();
            }];
        }];
        
        
        
        
    }
    
    else if (event.type == kEventStartTurnDraw) {
        
        
//        if (event.playerPerforming) {
//            
//            if (_game.myTurn) {
//                
//                
//                if ([event.manager isEqual:_game.me]) {
//                    
//                    if (_game.thisTurnActions.count < 2) { // ONLY TURN START
//                        NSLog(@"GameScene.m : animate TURN START : draw");
//                        
//                        [_uxWindow addStartTurnCard:event.playerPerforming withCompletionBlock:^{
//                            block();
//                        }];
//                        
//                        return;
//                        
//                    }
//                }
//                
//            }
//            
//            
//            [_uxWindow addCard:event.playerPerforming animated:YES withCompletionBlock:^{
//                block();
//            }];
//            
//        }
//        
//        else {
//            block();
//        }
        block();
        
        
    }
    else if (event.type == kEventDraw) {
        
        
//        if (event.playerPerforming) {
//            
//            NSLog(@"GameScene.m : animateEvent : draw");
//            [_uxWindow addCard:event.playerPerforming animated:YES withCompletionBlock:^{
//                block();
//            }];
//            
//        }
//        
//        else {
//            block();
//        }

           block();
        
    }
    
    else if (event.type == kEventShuffleDeck) {
        NSLog(@"GameScene.m : animateEvent : shuffle");
        block();
    }
    
    else if (event.type == kEventRemoveSpecial) {
        
        
        NSSet *enchantments = [_game temporaryEnchantments];
        
        if (enchantments.count) {
            
            NSLog(@"GameScene purging enchantments");
            
            for (Card *c in enchantments) {
                
                PlayerSprite *p = [playerSprites objectForKey:c.enchantee];
                
                NKEmitterNode *glow = [self ballGlowWithColor:[NKColor colorWithRed:.6 green:1. blue:.6 alpha:.5]];
                
                [p addChild:glow];
                
                [glow runAction:[NKAction scaleTo:2.*PARTICLE_SCALE duration:CARD_ANIM_DUR*2] completion:^{
                    [glow removeFromParent];
                }];
                
                [glow runAction:[NKAction fadeAlphaTo:0. duration:CARD_ANIM_DUR*2]];
                
            }
            
        }
        
        block();
        
        
    }
    
    
    else {
        block();
    }
    
    
}

-(NKEmitterNode*)ballGlowWithColor:(NKColor*)color {
    
    NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
    
//    NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Install" ofType:@"sks"]];
//    NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], color] times:@[@0,@.2]];
//    enchant.particleColorSequence = seq;
//    
//    [enchant setZPosition:Z_INDEX_FX];
//    [enchant setScale:.01];
    
    return enchant;
    
};

-(void)finishSequenceWithCompletionBlock:(void (^)())block {
    NSLog(@"GameScene.m : finished actions, return camera to . . .");
    [self cameraShouldFollowSprite:Nil withCompletionBlock:^{
        block();
    }];
}

//-(void)animatePosessionFor:(Card*)card withCompletionBlock:(void (^)())block {
//
//    if (card.ball) {
//        PlayerSprite* player = [playerSprites objectForKey:card];
//
//        [player showBall];
//
//    }
//
//}

-(void)touchedScoreBoard {
    NSLog(@"touched score board");
    [_game showMetaData];
}

-(void)animateBigText:(NSString*)theText withCompletionBlock:(void (^)())block {
    
    NKLabelNode *bigText = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
    bigText.text = theText;
    bigText.fontSize = 150;
    bigText.fontColor = [NKColor whiteColor];//[NKColor colorWithRed:.2 green:.2 blue:1. alpha:1.];
    
    [bigText setScale:.1];
    [self addChild:bigText];
    [bigText setZPosition:Z_INDEX_FX];
    [bigText setPosition:CGPointMake(self.size.width * .64, self.size.height/2)];
    
    [bigText runAction:[NKAction scaleTo:1. duration:1.5] completion:^{
        [bigText removeFromParent];
        block();
    }];
    
    
}


-(void)refreshUXWindowForPlayer:(Player*)p withCompletionBlock:(void (^)())block {
    
    [_uxWindow refreshCardsForPlayer:p];
    
    //[self refreshActionPoints];
    
}

-(void)refreshActionPoints {
//    
//    [_uxWindow.turnTokenCount setText:[NSString stringWithFormat:@"%d", _game.me.ActionPoints]];
//    [_uxWindow.opTokenCount setText:[NSString stringWithFormat:@"%d", _game.opponent.ActionPoints]];
//    
}


//-(void)AniamteRoll:(GameEvent*)event withCompletionBlock:(void (^)())block {
//    if (!event.wasSuccessful) {
//        
//        float width = TILE_WIDTH*3;
//        float height = TILE_HEIGHT;
//        
//        NKSpriteNode *rollNode = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:0. green:0. blue:0. alpha:1.] size:CGSizeMake(width, height)];
//        [rollNode setAlpha:.7];
//        
//        [self addChild:rollNode];
//        [rollNode setPosition:CGPointMake(self.size.width/2. - width/2., self.size.height/2. - height/2.)];
//        [rollNode setAnchorPoint:CGPointZero];
//        
//        NKSpriteNode *difficulty = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:0. green:1. blue:0. alpha:.7] size:CGSizeMake(width, height/2)];
//        NKSpriteNode *roll = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:1. green:0. blue:.2 alpha:.7] size:CGSizeMake(width, height/2)];
//        
//        [roll setAnchorPoint:CGPointZero];
//        [difficulty setAnchorPoint:CGPointZero];
//        
//        [rollNode addChild:difficulty];
//        [rollNode addChild:roll];
//        
//        [difficulty setPosition:CGPointMake(0, height/2.)];
//        [roll setPosition:CGPointMake(0, 0)];
//        
//        [difficulty setSize:CGSizeMake(10, height/2.)];
//        [roll setSize:CGSizeMake(10, height/2.)];
//        
//        [difficulty runAction:[NKAction resizeToWidth:(width*action.totalSucess) height:height/2 duration:.2]];
//        //[difficulty runAction:[NKAction moveTo:CGPointMake(-width*event.success/2., height/4.) duration:.5]];
//        
//        [roll runAction:[NKAction resizeToWidth:(width*event.roll) height:height/2 duration:1.] completion:^{
//            //[roll runAction:[NKAction moveTo:CGPointMake((-width*event.roll)/2., -height/4.) duration:1.5] completion:^{
//            
//            [roll removeFromParent];
//            [difficulty removeFromParent];
//            
//            if (action.wasSuccessful) {
//                [rollNode setColor:[NKColor greenColor]];
//            }
//            else {
//                [rollNode setColor:[NKColor redColor]];
//            }
//            [rollNode runAction:[NKAction fadeAlphaTo:.5 duration:.5] completion:^{
//                [rollNode runAction:[NKAction fadeAlphaTo:0. duration:.5] completion:^{
//                    [rollNode removeFromParent];
//                    
//                }];
//                block();
//            }];
//        }];
//        
//    }
//    else {
//        NSLog(@"GameScene.m : rollEvent : SUCCESS, NO ROLL");
//        block();
//    }
//}


-(void)addPlayerToBoardScene:(Player *)player animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    PlayerSprite *person = [[PlayerSprite alloc] initWithTexture: Nil color:nil size:CGSizeMake(TILE_WIDTH, TILE_HEIGHT)];
    
    person.delegate = self;
    
    [person setModel:player];
    
    [playerSprites setObject:person forKey:person.model];
    
    BoardTile* tile = [_gameTiles objectForKey:player.location];
    
    [_gameBoardNode addChild:person];
    
    person.userInteractionEnabled = true;
    
    //[person setZPosition:Z_BOARD_PLAYER];
    
    if (!animated){
        
        [person setPosition:tile.position];
        
        block();
    }
    
    else {
        
        int newY = tile.position.y + TILE_HEIGHT*10;
        if (!_game.me.teamSide) {
            newY = tile.position.y - TILE_HEIGHT*10;
        }
        
        [person setPosition3d:ofPoint(tile.position.x, newY, 200)];
        [person setXScale:.33];
        

        ofVec3f target = tile.position3d;
        target.z += 2;
        
        [person runAction:[NKAction move3dTo:target duration:.4] completion:^{

            NKEmitterNode *enchant = [[NKEmitterNode alloc]init];
//            NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Enchant" ofType:@"sks"]];
//            NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], card.manager.color] times:@[@0,@.2]];
//            enchant.particleColorSequence = seq;
            
            [person addChild:enchant];
            
            [enchant setZPosition:Z_INDEX_FX];
            [enchant setScale:PARTICLE_SCALE];
            
            [enchant runAction:[NKAction fadeAlphaTo:0.01 duration:CARD_ANIM_DUR*2] completion:^{
                [enchant removeFromParent];
            }];
            
            block();
            
            [person runAction:[NKAction scaleXTo:1. duration:.3] completion:^{
            }];
            
           
            
        }];
        
        
        
        
        
    }
    
    
    
    
}

-(void)removePlayerFromBoard:(PlayerSprite *)person animated:(BOOL)animated withCompletionBlock:(void (^)())block {
    
    if (person) {
        
        [playerSprites removeObjectForKey:person.model];
        
        if (animated) {
            
            [person runAction:[NKAction scaleYTo:.2 duration:.2] completion:^{
                
                block();
                
                int newX = person.position.x - TILE_WIDTH*5;
                if (!_game.me.teamSide) {
                    newX = person.position.x + TILE_WIDTH*5;
                }
                
                [person runAction:[NKAction moveTo:CGPointMake(newX, person.position.y) duration:.4] completion:^{
                    
                    [person removeFromParent];
                    
                }];
                
            }];
            
            
        }
        
        else {
            
            [person removeFromParent];
            block();
        }
        
    }
    
    else {
        NSLog(@"### ERROR ### removing Nil Player Sprite");
        block();
    }
    
}

-(void)addCardToHand:(Card *)card {
    //[_uxWindow addCard:card];
}

-(void)removeCardFromHand:(Card *)card {
   // [_uxWindow removeCard:card];
}

-(BallSprite*)ballSprite {
    if (!_ballSprite) {
        _ballSprite = [[BallSprite alloc]init];
        _ballSprite.texture = [NKTexture textureWithImageNamed:@"ball_Texture.png"];
    }
    if (!_ballSprite.parent) {
        [_gameBoardNode addChild:_ballSprite];
    }
    return _ballSprite;
}

-(void)moveBallToLocation:(BoardLocation *)location {
    
    [_ballSprite setScale:BALL_SCALE_BIG];
    [_ballSprite setPosition:[[_gameTiles objectForKey:location] position]];
    _game.ball.location = location;
    
    NSLog(@"GameScene.m :: moving ball to: %d %d", location.x, location.y);
}

-(void)fadeOutHUD {
    
}



#pragma mark - POSITION FUNCTIONS
-(void)cameraShouldFollowSprite:(NKSpriteNode*)sprite withCompletionBlock:(void (^)())block {
    if (MOVE_CAMERA) {
        
        if (!sprite) {
            
            _followNode = Nil;
            [_gameBoardNode removeAllActions];
            
            if (_gameBoardNode.position.x != [self camPosNormal].x) {
                
                //[_gameBoardNode runAction:[NKAction scaleTo:1. duration:1.]];
                NKAction *move = [NKAction moveTo:[self camPosNormal] duration:.5];
                // boardScale = 1.;
                [move setTimingMode:NKActionTimingEaseOut];
                [_gameBoardNode runAction:move completion:^{
                    block();
                }];
                
            }
            
            else {
                block();
            }
            
        }
        else {
            [_gameBoardNode removeAllActions];
            NKAction *move = [NKAction moveTo:[self boardPosForSprite:sprite] duration:.5];
            [move setTimingMode:NKActionTimingEaseOut];
            [_gameBoardNode runAction:move completion:^{
                _followNode = sprite;
                block();
            }];
        }
        
    }
    
    else {
        
        [_gameBoardNode runAction:[NKAction scaleTo:1. duration:.05]];
        NKAction *move = [NKAction moveTo:[self camPosNormal] duration:.5];
        [move setTimingMode:NKActionTimingEaseIn];
        [_gameBoardNode runAction:move completion:^{
            block();
        }];
        
    }
}

-(void)zoomTowards:(NKSpriteNode*)sprite withCompletionBlock:(void (^)())block {
    
    [_gameBoardNode removeAllActions];
    
    [_gameBoardNode runAction:[NKAction scaleTo:1.2 duration:.5]];
    boardScale = 1.2;
    NKAction *move = [NKAction moveTo:[self boardPosForSprite:sprite] duration:.5];
    [move setTimingMode:NKActionTimingEaseIn];
    
    [_gameBoardNode runAction:move completion:^{
        
    }];
    
    block();
    
}


-(void)dollyTowards:(NKSpriteNode*)sprite duration:(float)duration{
    
    [_gameBoardNode removeAllActions];
    
    
    NKAction *move = [NKAction moveTo:[self camPosHalfTrack:sprite] duration:duration];
    
    [move setTimingMode:NKActionTimingEaseOut];
    
    
    [_gameBoardNode runAction:move completion:^{
    }];
    
    
}

//-(void) repositionGameBoardOnScreenAnimted:(BOOL)animated{
//    CGPoint newPosition =  [self camPosNormal];
//    if(!animated)
//        [_gameBoardNode setPosition:newPosition];
//    else{
//        NKAction *boardScroll = [NKAction moveTo:newPosition duration:BOARD_ANIM_DUR];
//        [boardScroll setTimingMode:NKActionTimingEaseOut];
//        [_gameBoardNode runAction:boardScroll];
//    }
//}

// not sure which of these two will be more useful
// both essentially do the same thing...

-(void) incrementGameBoardPosition:(NSInteger)xOffset{
    _gameBoardNodeScrollOffset += xOffset;
    if(_gameBoardNodeScrollOffset < 2) _gameBoardNodeScrollOffset = 2;
    else if (_gameBoardNodeScrollOffset > 15) _gameBoardNodeScrollOffset = 15;
    //  [self repositionGameBoardOnScreenAnimted:YES];
    //    [_uxWindow refreshFieldHUDXOffset:_gameBoardNodeScrollOffset];
}

//-(void) setGameBoardGridPosition:(CGPoint)newFocus{
//    gameBoardViewScrollOffset = newFocus.x;
//    [self repositionGameBoardOnScreenAnimted:YES];
//}

-(CGPoint)zonePositionForLocation:(BoardLocation*)location {
    
    CGPoint newPosition =  CGPointMake((location.x-(BOARD_LENGTH / 2.)+2.5)*TILE_WIDTH, 0);
    return  newPosition;
    
}

-(CGPoint)boardPositionForLocation:(BoardLocation*)location {
    CGPoint zonePosition =  CGPointMake((location.x-(BOARD_LENGTH / 2.)+2.5)*TILE_WIDTH, 0);
    return CGPointMake(-zonePosition.x * boardScale, 0);
}

-(CGPoint)boardPosForSprite:(NKSpriteNode*)sprite{
    
    return CGPointMake(-sprite.position.x * boardScale, 0);
    //return CGPointMake((_gameBoardNodeScrollOffset-(_game.BOARD_LENGTH / 2.)+.5)*TILE_SIZE - sprite.position.x, 0);
    
}

//-(CGPoint)screenPosForBoardSprite:(NKSpriteNode*)sprite{
//    return CGPointMake(sprite.position.y + _camera.position.x, (_gameBoardNodeScrollOffset-(_game.BOARD_LENGTH / 2.)+1.5)*TILE_SIZE - sprite.position.x);
//}

-(CGPoint)windowPosForBoardSprite:(NKSpriteNode*)sprite{
    
    if (_game.me.teamSide) {
        return CGPointMake((ANCHOR_WIDTH - WINDOW_WIDTH*.5) + sprite.position.y, -(_gameBoardNode.position.x + sprite.position.x * boardScale));
    }
    return CGPointMake((ANCHOR_WIDTH - WINDOW_WIDTH*.5) - sprite.position.y, _gameBoardNode.position.x + sprite.position.x * boardScale);
    
}

-(CGPoint)camPosHalfTrack:(NKSpriteNode*)sprite{
    
    CGPoint norm = [self camPosNormal];
    return CGPointMake(norm.x - sprite.position.x*.5, 0);
    
}

-(CGPoint)camPosNormal {
     return CGPointZero;
    //    CGPoint newPosition =  CGPointMake(self.size.width*.64-(1.5)*TILE_SIZE,
    //                                       self.size.height*.5-(_gameBoardNodeScrollOffset-_game.BOARD_LENGTH+.5)*TILE_SIZE);
    //
    //CGPoint newPosition =  CGPointMake((_gameBoardNodeScrollOffset-(BOARD_LENGTH / 2.)+.5)*TILE_WIDTH, 0);
    
    // return CGPointZero;
    
    // NSLog(@"GameScene.m : CamPosNormal (%f, %f) (%d)",newPosition.x, newPosition.y, _gameBoardNodeScrollOffset);
   
    //    NSLog(@"return to normal board position");
    //    CGPoint spriteOffset = CGPointMake(_gameBoardNode.activeZone.position.x, _gameBoardNode.size.height);
    //    NSLog(@"%f, %f",(self.size.width*.5) - (spriteOffset.x), (self.size.height*.466)-gameBoardViewScrollOffset*TILE_SIZE );
    //    return  CGPointMake((self.size.width*.5) - (spriteOffset.x),
    //                        (self.size.height*.466)-gameBoardViewScrollOffset*TILE_SIZE );
    
}



#pragma mark - CALLED FROM GAME ENGINE
//
//-(void)enableSkip {
//    [_uxWindow setActionButtonTo:@"skip"];
//}

-(void)setMyTurn:(BOOL)myTurn {
    if (_gameBoardNode) { // only if we're living
        
        
        if (myTurn) {
            
//            if (_game.canDraw) {
//                [_uxWindow setActionButtonTo:@"draw"];
//            }
//            else {
//                [_uxWindow setActionButtonTo:@"end"];
//            }
//            
            
        }
        else {
           // [_uxWindow setActionButtonTo:nil];
        }
        
        
        
    }
}

-(void)rtIsActive:(BOOL)active {
    
    //    if (!_RTsprite) {
    //        _RTsprite = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"triangle_white"] color:_game.opponent.color size:CGSizeMake(TILE_SIZE/4., TILE_SIZE/4)];
    //        _RTsprite.colorBlendFactor = 1.;
    //        [_RTsprite setZRotation:M_PI];
    //        [_RTsprite setZPosition:Z_INDEX_BOARD];
    //        [_RTsprite setPosition:CGPointMake(self.size.width - TILE_SIZE/6., self.size.height - TILE_SIZE/6.)];
    //    }
    //    if (active) {
    //        [self fadeInChild:_RTsprite];
    //    }
    //
    //    else {
    //        [self fadeOutChild:_RTsprite];
    //    }
    
}

-(void)receiveRTPacket {
    
    
    NKSpriteNode *led = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"spark"] color:nil size:CGSizeMake(TILE_WIDTH/2., TILE_WIDTH/2.)];
    [self addChild:led];
    [led setPosition:_RTSprite.position];
    //[led setPosition:CGPointMake(_gameDelegate.size.width - led.size.width*.5,_gameDelegate.size.height-led.size.height*.5)];
    [led runAction:[NKAction fadeAlphaTo:0. duration:.5] completion:^{
        [led removeFromParent];
    }];
    
}

-(void)setWaiting:(BOOL)waiting {
    
    //    if (!waiting) {
    //        [self removeSepia];
    //    }
    //
    //    else {
    //        [self applySepia];
    //    }
    
}

-(void)endTurn:(NKNode*)sender {
    
    if ([_game shouldEndTurn]) {
        
        
        
        [_game playTouchSound];
    }
    
}

-(void)cleanupGameBoard {
    for (NKSpriteNode *s in playerSprites.allValues)
        [s removeFromParent];
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    //[_uxWindow cleanup];
}

-(void)refreshScoreBoard {
//    [_scoreBoard setScore:_game.score];
//    [_scoreBoard setManager:_game.scoreBoardManager];
}

-(void)setSelectedPlayer:(Player *)selectedPlayer {
    
    for (PlayerSprite *p in playerSprites.allValues) {
        [p setHighlighted:false];
    }
    
    [[playerSprites objectForKey:selectedPlayer] setHighlighted:true];
    
    _selectedPlayer = selectedPlayer;
    
}

#pragma mark - UPDATE CYCLE

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
    [super updateWithTimeSinceLast:dt];
    

}

//-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId {
//
//    if ([super touchUp:location id:touchId] == NKTouchIsFirstResponder) {
//        if (!_miniGameNode) {
//            [self startMiniGame];
//        }
//        return NKTouchIsFirstResponder;
//    };
//
//    return NKTouchNone;
//    
//}

@end
