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
    _pivot.node->setOrientation(orientation);
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
        
//        _actionWindow = [[ActionWindow alloc] initWithTexture:nil color:[NKColor colorWithRed:45/255. green:45/255. blue:45/255. alpha:1.] size:CGSizeMake(WINDOW_WIDTH, self.size.height)];
//        
//        [_actionWindow setPosition:CGPointMake(WINDOW_WIDTH*.5, self.size.height / 2.)];
//        _actionWindow.delegate = self;
//        [self addChild:_actionWindow];
//        [_actionWindow setZPosition:Z_INDEX_BOARD];
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
    }
    
    return self;
}
-(void)setupGameBoard {
    
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    _gameTiles = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    _pivot = [[NKNode alloc]init];
    
    [self addChild:_pivot];

    
//    NKSpriteNode *logo = [[NKSpriteNode alloc]initWithTexture:[NKTexture textureWithImageNamed:@"GAMELOGO.png"] color:nil size:CGSizeMake(TILE_WIDTH*4, TILE_WIDTH*5.2)];
//    [_pivot addChild:logo];
//    [logo setZPosition:-3];

    
    _boardScroll = [[NKScrollNode alloc] initWithColor:nil size:CGSizeMake(BOARD_WIDTH*TILE_WIDTH + (TILE_WIDTH*.7), BOARD_LENGTH*TILE_HEIGHT + (TILE_HEIGHT*.5))];
    
    [_pivot addChild:_boardScroll];
    
    //_boardScroll.userInteractionEnabled = false;
    
    _gameBoardNode = [[GameBoardNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Background_Field.png"] color:Nil size:CGSizeMake(BOARD_WIDTH*TILE_WIDTH + (TILE_WIDTH*.7), BOARD_LENGTH*TILE_HEIGHT + (TILE_HEIGHT*.5))];
    
    [_boardScroll addChild:_gameBoardNode];
    
    _gameBoardNode.userInteractionEnabled = true;
    _gameBoardNode.name = @"Game Board";
    
    for(int i = 0; i < BOARD_WIDTH; i++){
        for(int j = 0; j < BOARD_LENGTH; j++){
            BoardTile *square = [[BoardTile alloc] initWithTexture:Nil color:nil size:CGSizeMake(TILE_WIDTH-2, TILE_HEIGHT-2)];
            
            [square setLocation:[BoardLocation pX:i Y:j]];
            
            [_gameBoardNode addChild:square];
            [_gameTiles setObject:square forKey:square.location];
            
            [square setPosition3d:ofPoint((i+.5)*TILE_WIDTH - (TILE_WIDTH*BOARD_WIDTH*.5), ((j+.5)*TILE_HEIGHT) - (TILE_HEIGHT*BOARD_LENGTH*.5),2) ];
        }
    }
    
    NKSpriteNode *lines = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer01.png"] color:nil size:_gameBoardNode.size];
    
    [_gameBoardNode addChild:lines];
    [lines setPosition3d:ofPoint(0,0,4)];
    
    NKSpriteNode *glow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Field_Layer02.png"] color:nil size:_gameBoardNode.size];
    
    [_gameBoardNode addChild:glow];
    [glow setPosition3d:ofPoint(0,0,6)];
    
    
    //[self loadShader:[[NKDrawDepthShader alloc] initWithNode:self paramBlock:nil]];
    //
    
//    [_pivot runAction:[NKAction repeatActionForever:[NKAction sequence:@[[NKAction moveByX:100 y:0 duration:1.] ,
//                                                                         [NKAction moveByX:-100 y:0 duration:1.] ,
//                                                                         [NKAction moveByX:0 y:100 duration:1.] ,
//                                                                         [NKAction moveByX:0 y:-100 duration:1.] ,
//                                                                         
//                                                                         ]
//                                                                         
//                                                     ]]];
    
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
        
        NSLog(@"CAN USE PLAYER: %@", player.model.nameForCard);
        
//        [_infoHUD setPlayer:player.model];
//        [_infoHUD setZPosition:Z_BOARD_LOW];
  //      [_gameBoardNode fadeInSprite:_infoHUD];
        
        return YES;
    }
    
    else {
        
        NSLog(@"NOPE NOT FOR PLAYER: %@", player.model.nameForCard);
        
//        [_infoHUD setPlayer:player.model];
//        [_infoHUD setZPosition:Z_BOARD_LOW];
//        [_gameBoardNode fadeInSprite:_infoHUD];
        
        return NO;
    }
}

// ADD ACTION STATISTICS TO GAME TILE VIEWS
// convert finger position to BoardLocation,
// get tile, add stuff to it



-(void)movingPlayer:(Card *)card atPoint:(CGPoint)point {
    
//    //CGPoint screenPosition = [scene screenPosition];
//    
//    if (screenPosition.y > self.size.height * .85){
//        
//        BoardTile *n;
//        
//        if (card.manager.teamSide) {
//            n = [_gameTiles objectForKey:[BoardLocation pX:0 Y:1]];
//        }
//        else {
//            n = [_gameTiles objectForKey:[BoardLocation pX:_game.BOARD_LENGTH-1 Y:1]];
//        }
//        if (n) {
//            NSLog(@"touching goal at : %d %d", n.location.x, n.location.y);
//        }
//        
//        if ([self isNewLocation:n.location]) {
//            SkillEvent* event = [_game requestPlayerActionAtLocation:n.location];
//            
//            if (event) {
//                [self addUIForEvent:event];
//                [_game sendAction:_game.currentAction perform:NO];
//                n.isHighlighted = YES;
//            }
//        }
//        
//    }
//    
//    
//    
//    else {
//        
//        BoardLocation *newfingerLocationOnBoard = [self locationOnBoard:t];
//        
//        
//        
//        if ([self isNewLocation:newfingerLocationOnBoard]) {
//            
//            BoardTile *n = [_gameTiles objectForKey:newfingerLocationOnBoard];
//            
//            SkillEvent* event = [_game requestPlayerActionAtLocation:n.location];
//            
//            NSLog(@"REQUESTING PLAYER ACTION AT %d, %d", n.location.x, n.location.y);
//            
//            
//            if (event) {
//                NSLog(@"PLAYER IS: %@", event.playerPerformingAction.nameForCard);
//                NSLog(@"EVENT IS:%@", event.nameForAction);
//                [self addUIForEvent:event];
//                [_game sendAction:_game.currentAction perform:NO];
//                n.isHighlighted = YES;
//            }
//            
//            else {
//                NSLog(@"EVENT IS NULL");
//                //  [_infoHUD setPlayer:card];
//            }
//            
//        }
//    }
    
    
    
    
}


-(BOOL)validatePlayerMove:(Card *)card {
    
    if ([_game validatePlayerMove:card]) {
        NSLog(@"action is valid!");
        
        if ([_game canPerformCurrentAction]) {
//            [_infoHUD validate:YES];
//            [_infoHUD setZPosition:Z_INDEX_HUD];
//            [_infoHUD enableBoost];
        }
        
        return 1;
    }
    
    else {
        
        NSLog(@"GameScene.m : shouldMovePlayer : remove action UI");
//        [_infoHUD setZPosition:Z_BOARD_LOW];
//        [_infoHUD validate:NO];
        
    }
    
    return 0;
    
}

#pragma mark - CREATE CARD EVENTS

#pragma mark - !! ALL TOUCH METHODS NEED UPDATED !!

-(BoardLocation*)locationOnBoard:(UITouch*)t {
    
    CGPoint position;
    
    return [BoardLocation pointWithCGPoint:CGPointMake((position.x + _gameBoardNode.size.width/2.) / TILE_WIDTH,(position.y + _gameBoardNode.size.height/2.) /TILE_HEIGHT)];
    
}



-(BoardLocation*)locationOnBoardFromPoint:(CGPoint)position {
    
    return [BoardLocation pointWithCGPoint:CGPointMake((position.x + _gameBoardNode.size.width/2.) / TILE_WIDTH,(position.y + _gameBoardNode.size.height/2.) /TILE_HEIGHT)];
    
}

-(BOOL)isNewLocation:(BoardLocation*)loc {
    
    if ([loc isEqual:fingerLocationOnBoard]) {
        return 0;
    }
    
    fingerLocationOnBoard = [loc copy];
    
    return 1;
    
}

-(BoardLocation*)canPlayCard:(Card*)card atPosition:(CGPoint)pos {
    
    CGPoint position = pos;
    
    
    BoardLocation *newfingerLocationOnBoard = [self locationOnBoardFromPoint:position];
    
    if ([self isNewLocation:newfingerLocationOnBoard]) {
        
        BoardTile *n = [_gameTiles objectForKey:newfingerLocationOnBoard];
        
        SkillEvent *event = [_game canPlayCard:card atLocation:n.location];
        
        if (event) {
            
            CardSprite *sprite = [[_actionWindow cardSprites] objectForKey:card];
            
            [sprite runAction:[NKAction fadeAlphaTo:.2 duration:FAST_ANIM_DUR]];
            
            
           // [self addUIForEvent:event];
            
            if ([_game canPerformCurrentAction]) {
//                [_infoHUD validate:YES];
//                [_infoHUD setZPosition:Z_INDEX_HUD];
//                [_actionWindow setZPosition:Z_BOARD_LOW];
//                [_infoHUD enableBoost];
            }
            
            [_game sendAction:_game.currentAction perform:NO];
            
    //        n.isHighlighted = YES;
            //NSLog(@"GameScene.m :: Deploy New Player");
            return [event.location copy];
        }
        
        else {
            
            CardSprite *sprite = [[_actionWindow cardSprites] objectForKey:card];
            
            [sprite runAction:[NKAction fadeAlphaTo:1. duration:FAST_ANIM_DUR]];
            
            SkillEvent *event = [_game.currentAction.skillEvents lastObject];
            return event.location;
        }
        
    }
    
    else if ([_game.currentAction.skillEvents lastObject]){
        SkillEvent *event = [_game.currentAction.skillEvents lastObject];
        return event.location;
    }
    
    return nil;
    
}

-(float)rotationForManager:(Manager*)m {
    if (m.teamSide) {
        return M_PI*.5;
    }
    else
        return -M_PI*.5;
}

-(void)setRotationForManager:(Manager*)m {
    
    if (m.teamSide) {
        
        [_pivot setZRotation:-M_PI*.5];
        }
    
    else {
        
        [_pivot setZRotation:M_PI*.5];

    }
    
    
}

#pragma mark - ANIMATIONS !!! AKA SOCCER_STAR_GALACTICA

-(void)animateEvent:(SkillEvent*)event withCompletionBlock:(void (^)())block {
    
    float MOVE_SPEED = .35;
    float BALL_SPEED = .2;
    
    
    [self refreshActionPoints];
    
    PlayerSprite* player = [playerSprites objectForKey:event.playerPerformingAction];
    
    if (event.type == kStartTurnAction || event.type == kSetBallAction) {
        
        [_gameBoardNode fadeInChild:_ballSprite duration:.3];
        //[self cameraShouldFollowSprite:Nil withCompletionBlock:^{}];
        
        if (_game.ball.player) {
 
            PlayerSprite* p = [playerSprites objectForKey:_game.ball.player];
            
            [p getReadyForPosession:^{
                [_ballSprite runAction:[NKAction move3dTo:[p ballLoc] duration:BALL_SPEED] completion:^{
                    //[_ballSprite removeAllActions];
                    [p startPossession];
                    NSLog(@"ball actions : %d", [_ballSprite hasActions]);
                    block();
                }];
            }];
            
        }
        
        else {
            block();
        }
        
    }
    
    else if (event.type == kStartingAction) {
        
        SkillEvent *last = [event.parent.skillEvents lastObject];
        
        
        if (event.playerPerformingAction.ball) {
            // [self dollyTowards:[_gameTiles objectForKey:last.location] duration:CAM_SPEED*2.];
            
            
            [player getReadyForPosession:^{
                [_ballSprite runAction:[NKAction move3dTo:[player ballLoc] duration:BALL_SPEED] completion:^{
                    [player startPossession];
                    block();
                }];
            }];
        }
        else {
            block();
        }
        
        
        
        
        
    }
    
    else if (event.type == kRunningAction){
        [player runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            
            if (event.playerPerformingAction.ball) {
                [player getReadyForPosession:^{
                    [_ballSprite runAction:[NKAction move3dTo:[player ballLoc] duration:BALL_SPEED] completion:^{
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
    
    else if (event.type == kDribbleAction) {
        
        if (event.playerPerformingAction.ball) {
            //
            //            [_ballSprite runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            //            }];
            
        }
        else {
            [player stopPosession:^{
                
            }];
        }
        
        [player runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            block();
        }];
        
    }
    
    else if (event.type == kChallengeAction) {
        
        PlayerSprite* receiver = [playerSprites objectForKey:event.playerReceivingAction];
        
        
        NKEmitterNode *glow = [self ballGlowWithColor:receiver.model.manager.color];
        
        [_ballSprite addChild:glow];
        
        [glow runAction:[NKAction scaleTo:1. * PARTICLE_SCALE duration:CAM_SPEED*.5] completion:^{}];
        
        [player runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.location] position] duration:MOVE_SPEED] completion:^(){
            
            if (event.parent.wasSuccessful) {
                
                NKEmitterNode *glow2 = [self ballGlowWithColor:player.model.manager.color];
                [_ballSprite addChild:glow2];
                
                [glow2 runAction:[NKAction scaleTo:2. * PARTICLE_SCALE duration:.01] completion:^{
                    
                    [receiver stopPosession:^{
                        
                        [receiver runAction:[NKAction moveTo:[[_gameTiles objectForKey:event.startingLocation] position] duration:MOVE_SPEED]];
                        
                        [glow removeFromParent];
                        [receiver addChild:glow];
                        [glow setPosition3d:[receiver ballLoc]];
                        
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
    
    else if (event.type == kPassAction || event.type == kGoaliePass || event.type == kShootAction) {
        
         NKEmitterNode *enchant = [[NKEmitterNode alloc] init];
        
//        NKEmitterNode *enchant = [NNKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Install" ofType:@"sks"]];
//        NKKeyframeSequence *seq = [[NKKeyframeSequence alloc] initWithKeyframeValues:@[[NKColor blackColor], event.manager.color] times:@[@0,@.2]];
//        enchant.particleColorSequence = seq;
        
        [_ballSprite addChild:enchant];
        [enchant setZPosition:Z_INDEX_FX];
        [enchant setScale:.01];
        
        
        if (event.type == kGoaliePass) {
          //  [self dollyTowards:player duration:CAM_SPEED];
        }
        
        PlayerSprite* receiver = [playerSprites objectForKey:event.playerReceivingAction];
        
        float locScale = .5;
        if (event.type == kShootAction) {
            locScale = 1.;
        }
        
        [enchant runAction:[NKAction scaleTo:2. * PARTICLE_SCALE * locScale duration:CAM_SPEED*.75] completion:^{
            
            [player stopPosession:^{
                
                if ((event.type == kPassAction && event.parent.wasSuccessful) || event.type == kGoaliePass || (event.type == kShootAction && !event.parent.wasSuccessful)) {
                    
                    // SUCESSFULL PASS OR FAILED GOAL
                    
                    [receiver getReadyForPosession:^{
                        
                        if (event.type == kGoaliePass) {
                           // [self dollyTowards:receiver duration:CAM_SPEED*.25];
                           // [_gameBoardNode.activeZone runAction:[NKAction fadeAlphaTo:1. duration:CARD_ANIM_DUR]];
                        }
                        // [self dollyTowards:receiver duration:CAM_SPEED*.25];
                        
                        NKAction *move = [NKAction move3dTo:receiver.ballLoc duration:BALL_SPEED];
                        
                        [move setTimingMode:NKActionTimingEaseOut];
                        
                        [_ballSprite runAction:move completion:^(){
                            
                            
                            [receiver startPossession];
                            
                            if (event.type == kShootAction) {
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
                
                else if (event.parent.wasSuccessful && event.type == kShootAction) {
                    
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
                        
                        [_ballSprite runAction:move completion:^(){
                            
                            NSLog(@"GameScene.m : animateEvent : GOAL");
                            
                            [self animateBigText:@"GOAL !!!" withCompletionBlock:^{
                                
                                [enchant runAction:[NKAction scaleTo:.01 duration:CAM_SPEED] completion:^{
                                    [enchant removeFromParent];
                                    _followNode = Nil;
                                    
                                    [self fadeOutChild:_ballSprite duration:.3];
                                    
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
                    
                    [_ballSprite runAction:move completion:^(){
                        
                        [_ballSprite runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:CARD_ANIM_DUR]];
                        
                        [enchant runAction:[NKAction scaleTo:.01 duration:CARD_ANIM_DUR*2] completion:^{
                            [enchant removeFromParent];
                            block();
                        }];
                        
                    }];
                    
                    
                    
                    
                }
                
                
            }];
            
        }];
        
    }
    
    
    else if (event.type == kGoalResetAction) {

        block();
        
    }
    
    
    
    
    
    
    
    else if (event.type == kPlayCardAction){
        
        // [self cameraShouldFollowSprite:nil withCompletionBlock:^{}];
        
        CardSprite* card = [_actionWindow.cardSprites objectForKey:event.playerPerformingAction];
        
        //            [card removeFromParent];
        //            [_gameBoardNode addChild:card];
        //            [card setZRotation:[self rotationForManager:_game.me]];
        [card setHasShadow:YES];
        
        [card setZPosition:Z_INDEX_HUD];
        
        [_actionWindow removeCard:card.model animated:YES withCompletionBlock:^{}];
        
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
                        [_actionWindow fadeOutChild:card duration:FAST_ANIM_DUR];
                    }];
                }];
                
            }];
            
            
        }];
        
        
        
    }
    
    
    else if (event.isDeployEvent) {
        
        NSLog(@"GameScene.m : animateEvent : deploy");
        
        // [self dollyTowards:[_gameTiles objectForKey:event.location] duration:CAM_SPEED];
        
        [self addCardToBoardScene:event.playerPerformingAction animated:YES withCompletionBlock:^{
            block();
        }];
        
    }
    
    else if (event.type == kRemovePlayerAction) {
        
        // [self cameraShouldFollowSprite:nil withCompletionBlock:^{   }];
        
        
        NSLog(@"GameScene.m : animateEvent : remove player");
        
        
        PlayerSprite* p = [playerSprites objectForKey:event.playerPerformingAction];
        
        [self removePlayerFromBoard:p animated:YES withCompletionBlock:^{
            block();
            
        }];
        
        
        
    }
    
    else if (event.type == kEnchantAction) {
        
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
    
    else if (event.type == kTurnDrawAction) {
        
        
//        if (event.playerPerformingAction) {
//            
//            if (_game.myTurn) {
//                
//                
//                if ([event.manager isEqual:_game.me]) {
//                    
//                    if (_game.thisTurnActions.count < 2) { // ONLY TURN START
//                        NSLog(@"GameScene.m : animate TURN START : draw");
//                        
//                        [_actionWindow addStartTurnCard:event.playerPerformingAction withCompletionBlock:^{
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
//            [_actionWindow addCard:event.playerPerformingAction animated:YES withCompletionBlock:^{
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
    else if (event.type == kDrawAction) {
        
        
//        if (event.playerPerformingAction) {
//            
//            NSLog(@"GameScene.m : animateEvent : draw");
//            [_actionWindow addCard:event.playerPerformingAction animated:YES withCompletionBlock:^{
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
    
    else if (event.type == kShuffleAction) {
        NSLog(@"GameScene.m : animateEvent : shuffle");
        block();
    }
    
    else if (event.type == kPurgeEnchantmentsAction) {
        
        
        NSSet *enchantments = [_game temporaryEnchantments];
        
        if (enchantments.count) {
            
            NSLog(@"GameScene purging enchantments");
            
            for (Card *c in enchantments) {
                
                PlayerSprite *p = [playerSprites objectForKey:c.player];
                
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
    
    else if (event.type == kMoveFieldAction) {
        
        //[self dollyTowards:_ballSprite duration:.2];
        //[self cameraShouldFollowSprite:nil withCompletionBlock:^{
        
        //}];

        
        
        
        
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

-(void)finishActionsWithCompletionBlock:(void (^)())block {
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


-(void)refreshActionWindowForManager:(Manager*)m withCompletionBlock:(void (^)())block {
    
    [_actionWindow cleanup];
    
    for (Card* c in m.deck.inHand) {
        [_actionWindow addCard:c];
    }
    
    for (Card* c in m.opponent.deck.inHand) {
        [_actionWindow addCard:c];
    }
    
    [self refreshActionPoints];
    
}

-(void)refreshActionPoints {
    
    [_actionWindow.turnTokenCount setText:[NSString stringWithFormat:@"%d", _game.me.ActionPoints]];
    [_actionWindow.opTokenCount setText:[NSString stringWithFormat:@"%d", _game.opponent.ActionPoints]];
    
}


-(void)rollAction:(GameAction*)action withCompletionBlock:(void (^)())block {
    if (!action.wasSuccessful) {
        
        float width = TILE_WIDTH*3;
        float height = TILE_HEIGHT;
        
        NKSpriteNode *rollNode = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:0. green:0. blue:0. alpha:1.] size:CGSizeMake(width, height)];
        [rollNode setAlpha:.7];
        
        [self addChild:rollNode];
        [rollNode setPosition:CGPointMake(self.size.width/2. - width/2., self.size.height/2. - height/2.)];
        [rollNode setAnchorPoint:CGPointZero];
        
        NKSpriteNode *difficulty = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:0. green:1. blue:0. alpha:.7] size:CGSizeMake(width, height/2)];
        NKSpriteNode *roll = [[NKSpriteNode alloc]initWithColor:[NKColor colorWithRed:1. green:0. blue:.2 alpha:.7] size:CGSizeMake(width, height/2)];
        
        [roll setAnchorPoint:CGPointZero];
        [difficulty setAnchorPoint:CGPointZero];
        
        [rollNode addChild:difficulty];
        [rollNode addChild:roll];
        
        [difficulty setPosition:CGPointMake(0, height/2.)];
        [roll setPosition:CGPointMake(0, 0)];
        
        [difficulty setSize:CGSizeMake(10, height/2.)];
        [roll setSize:CGSizeMake(10, height/2.)];
        
        [difficulty runAction:[NKAction resizeToWidth:(width*action.totalSucess) height:height/2 duration:.2]];
        //[difficulty runAction:[NKAction moveTo:CGPointMake(-width*event.success/2., height/4.) duration:.5]];
        
        [roll runAction:[NKAction resizeToWidth:(width*action.roll) height:height/2 duration:1.] completion:^{
            //[roll runAction:[NKAction moveTo:CGPointMake((-width*event.roll)/2., -height/4.) duration:1.5] completion:^{
            
            [roll removeFromParent];
            [difficulty removeFromParent];
            
            if (action.wasSuccessful) {
                [rollNode setColor:[NKColor greenColor]];
            }
            else {
                [rollNode setColor:[NKColor redColor]];
            }
            [rollNode runAction:[NKAction fadeAlphaTo:.5 duration:.5] completion:^{
                [rollNode runAction:[NKAction fadeAlphaTo:0. duration:.5] completion:^{
                    [rollNode removeFromParent];
                    
                }];
                block();
            }];
        }];
        
    }
    else {
        NSLog(@"GameScene.m : rollEvent : SUCCESS, NO ROLL");
        block();
    }
}

-(void)addCardToBoardScene:(Card *)card{
    
    [self addCardToBoardScene:card animated:NO withCompletionBlock:^{}];
    
}

-(void)addCardToBoardScene:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    PlayerSprite *person = [[PlayerSprite alloc] initWithTexture: Nil color:[NKColor colorWithRed:0. green:0. blue:0. alpha:.01] size:CGSizeMake(TILE_WIDTH, TILE_HEIGHT)];
    
    person.delegate = self;
    
    [person setModel:card];
    
    [playerSprites setObject:person forKey:person.model];
    
    BoardTile* tile = [_gameTiles objectForKey:card.location];
    
    [_gameBoardNode addChild:person];
    
    //[person setZPosition:Z_BOARD_PLAYER];
    
    if (!animated || !card.isTypePlayer){
        
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
            
            [person runAction:[NKAction scaleXTo:1. duration:.3] completion:^{
            }];
            
            block();
            
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
    [_actionWindow addCard:card];
}

-(void)removeCardFromHand:(Card *)card {
    [_actionWindow removeCard:card];
}


-(void)moveBallToLocation:(BoardLocation *)location {
    
    if (!_ballSprite) {
        _ballSprite = [[BallSprite alloc]init];
    }
    
    [_ballSprite setScale:BALL_SCALE_BIG];
    
    if (!_ballSprite.parent) {
        [_gameBoardNode addChild:_ballSprite];
    }
    
    [_ballSprite setZPosition:Z_BOARD_BALL];
    [_ballSprite setPosition:[[_gameTiles objectForKey:location] position]];
    
    NSLog(@"GameScene.m :: moving ball to: %d %d", location.x, location.y);
}

-(void)fadeOutHUD {
    
}

-(void)cleanUpUIForAction:(GameAction *)action {
    
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
    //    [_actionWindow refreshFieldHUDXOffset:_gameBoardNodeScrollOffset];
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
//    [_actionWindow setActionButtonTo:@"skip"];
//}

-(void)setMyTurn:(BOOL)myTurn {
    if (_gameBoardNode) { // only if we're living
        
        
        if (myTurn) {
            
//            if (_game.canDraw) {
//                [_actionWindow setActionButtonTo:@"draw"];
//            }
//            else {
//                [_actionWindow setActionButtonTo:@"end"];
//            }
//            
            
        }
        else {
           // [_actionWindow setActionButtonTo:nil];
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
-(void)drawCard:(NKNode*)sender {
    
    if ([self shouldDrawCard]) {
        [_game playTouchSound];
    }
    
}

-(void)cleanupGameBoard {
    for (NKSpriteNode *s in playerSprites.allValues)
        [s removeFromParent];
    playerSprites = [NSMutableDictionary dictionaryWithCapacity:(BOARD_LENGTH * BOARD_WIDTH)];
    
    //[_actionWindow cleanup];
}

-(void)refreshScoreBoard {
//    [_scoreBoard setScore:_game.score];
//    [_scoreBoard setManager:_game.scoreBoardManager];
}


-(void)shouldPerformCurrentAction {
    
    if ( [_game shouldPerformCurrentAction]) {
        if (_selectedCard) {
            [self setSelectedCard:nil];
        }
    }
    
}

-(BOOL)shouldDrawCard {
    if ([_game requestDrawAction]) return 1;
    return 0;
}

-(void)setSelectedPlayer:(Card *)selectedPlayer {
    for (PlayerSprite *p in playerSprites.allValues) {
        [p setHighlighted:false];
    }
    
    [[playerSprites objectForKey:selectedPlayer] setHighlighted:true];
    
}

-(void)setSelectedCard:(Card *)selectedCard {
    
    
    if (_selectedCard && !selectedCard) { // SETTING TO NIL
        
        //[_actionWindow setZPosition:Z_INDEX_BOARD];
        
        if (_selectedCard) {
        
        }
        
    }

    _selectedCard = selectedCard;
    
}

#pragma mark - UPDATE CYCLE

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
    [super updateWithTimeSinceLast:dt];
    

}

//-(bool)touchUp:(CGPoint)location id:(int)touchId {
//    if (!_miniGameNode) {
//        [self startMiniGame];
//    }
//    return [super touchUp:location id:touchId];
//    
//}

@end
