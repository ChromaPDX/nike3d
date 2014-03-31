//
//  Game.m
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ModelHeaders.h"


#define LOAD_TIME 1.0


@interface Game (){
    SystemSoundID touchSound;
    SystemSoundID menuLoop;
}
@end

@implementation Game

-(id) init{
    self = [super init];
    if(self){
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"touch" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &touchSound);
    }
    return self;
}

-(void)playTouchSound{
    AudioServicesPlaySystemSound(touchSound);
}



#pragma mark - GAMEBOARD / INITIAL SETUP

//-(void)startMultiPlayerGame {
//
//    _me = [[Manager alloc] init];
//    _opponent = [[Manager alloc] init];
//
//    _score = [BoardLocation pX:0 Y:0];
//
//    [_me setColor:[UIColor colorWithRed:0.0 green:80/255. blue:249/255. alpha:1.0]];
//    [_opponent setColor:[UIColor colorWithRed:1.0 green:40/255. blue:0 alpha:1.0]];
//    [_me setTeamSide:1];
//    [_opponent setTeamSide:0];
//
//    _me.opponent = _opponent;
//    _opponent.opponent = _me;
//
//    _rtmatchid = arc4random();
//    NSNumber *uid = [NSNumber numberWithUnsignedInteger:_rtmatchid];
//
//
//    _matchInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"turns":@0,
//                                                                 @"current player":_match.currentParticipant.playerID,
//                                                                 @"rtmatchid":uid,
//                                                                 @"boardLength": [NSNumber numberWithInt:BOARD_LENGTH]
//                                                                 }];
//
//
//
//
//    _me.name = @"CHROMA";
//    _opponent.name = @"NIKE";
//
//    self.myTurn = YES;
//
//    [_gameScene setupGameBoard];
//
//    _history = [NSMutableArray array];
//    _thisTurnActions = [NSMutableArray array];
//    players = [NSMutableDictionary dictionary];
//
//    [self setupNewPlayers];
//
//    [self addStartTurnEventsToAction:_currentEventSequence];
//
//    [self refreshGameBoard];
//
//    [self performAction:_currentEventSequence record:YES animate:YES];
//
//
//}

-(void)startSinglePlayerGame {
    
    _me = [[Manager alloc] initWithGame:self];
    _opponent = [[Manager alloc] initWithGame:self];
    
    _score = [BoardLocation pX:0 Y:0];
    
    [_me setColor:[UIColor colorWithRed:0.0 green:80/255. blue:249/255. alpha:1.0]];
    [_opponent setColor:[UIColor colorWithRed:1.0 green:40/255. blue:0 alpha:1.0]];
    
    [_me setTeamSide:1];
    [_opponent setTeamSide:0];
    
    _me.opponent = _opponent;
    _opponent.opponent = _me;
    
    _rtmatchid = arc4random();
    NSNumber *uid = [NSNumber numberWithUnsignedInteger:_rtmatchid];
    
    
    singlePlayer = 1;
    
    
    _matchInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"turns":@0,
                                                                 @"current player":@"single player game",
                                                                 @"rtmatchid":uid,
                                                                 @"boardLength": [NSNumber numberWithInt:BOARD_LENGTH],
                                                                 @"singlePlayerMode": [NSNumber numberWithBool:YES]
                                                                 }];
    
    
    
    
    _me.name = @"HUMAN";
    _opponent.name = @"COMPUTER";
    
    self.myTurn = YES;
    
    [_gameScene setupGameBoard];
    
    NSLog(@"gameboard setup");
    
    _history = [NSMutableArray array];
    _thisTurnActions = [NSMutableArray array];
    _players = [NSMutableDictionary dictionary];
    
    [self setupNewPlayers];
    
    NSLog(@"added new players");
    
    [self addStartTurnEventsToAction:_currentEventSequence];
    [self refreshGameBoard];
    
    NSLog(@"running new game action");
    
    [self performAction:_currentEventSequence record:YES animate:YES];
    
    
}


-(void)startGameWithExistingMatch:(GKTurnBasedMatch*)match {
    
    
    
    if (resumed) {
        NSLog(@"2nd Resume: Bailing!!");
        return;
    }
    else {
        NSLog(@"Game.m : resumeExistingGameWithMatch : unarchiving match");
        resumed = 1;
    }
    
    [_gameScene setWaiting:YES];
    
    _match = match;
    
    [self getSortedPlayerNames];
    
    
    
    [_match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error){
        
        
        [self restoreGameWithData:matchData];
        
        singlePlayer = [[_matchInfo objectForKey:@"singlePlayerMode"] boolValue];
        [_gameScene setupGameBoard];
        
        if (!singlePlayer) {
            [_gcController initRealTimeConnection];
        }
        
        [self replayLastTurn];
        
    }];
    
}





-(void)replayGame:(BOOL)animate {
    
    [_gameScene setWaiting:NO];
    
    self.myTurn = NO;
    
    NSLog(@"Game.m : performActionSequence : starting action sequence");
    
    NSLog(@"Game has %d total actions", [self totalGameSequences]);
    
    _turnHeap = [[NSMutableArray alloc]initWithCapacity:25];
    
    if (_thisTurnActions) {
        [_turnHeap addObject:_thisTurnActions];
    }
    
    if (_history) {
        
        for (int i = 0; i < _history.count; i++)
            [_turnHeap addObject:_history[_history.count - (i + 1)]];
    }
    
    // GET MANAGER FOR TURN
    
    [self wipeBoard];
    
    if (animate) {
        
        [self refreshGameBoard];
        [self enumerateTurnHeapAnimate:YES];
        
    }
    
    else {
        
        [self enumerateTurnHeapAnimate:NO];
        
    }
    
    
}

-(void)replayLastTurn {
    
    [_gameScene setWaiting:NO];
    
    self.myTurn = NO;
    
    NSLog(@"------------ REPLAY HISTORY ------------");
    
    actionIndex = 0;
    
    [self wipeBoard];
    [self refreshGameBoard];
    
    _turnHeap = [[NSMutableArray alloc]initWithCapacity:25];
    
    if (_history) {
        
        NSArray* allButLast = [self allButLastTurn];
        
        if (allButLast.count) {
            for (int i = 0; i < allButLast.count; i++){
                [_turnHeap addObject:allButLast[allButLast.count - (i + 1)]];
            }
        }
        
        NSLog(@"Game has %d total actions", [self totalGameSequences]);
        NSLog(@"non-animate actions %d", [self actionCountForArray:allButLast]);
        NSLog(@"animate actions %d", [[_history lastObject] count] + _thisTurnActions.count);
        
    }
    else {
        NSLog(@"------------ NO HISTORY YET ------------");
    }
    
    
    if (_turnHeap.count) {
        NSLog(@"------------ NON-ANIMATE RESTORE ------------");
        [self enumerateTurnHeapAnimate:NO];
        NSLog(@"------------ REBUILD VISUALS ------------");
        [self buildBoardFromCurrentState];
    }
    
    
    // THEN
    
    
    _turnHeap = [[NSMutableArray alloc]initWithCapacity:25];
    
    NSLog(@"------------ ANIMATE REPLAY ------------");
    NSLog(@"Game has %d total actions", [self totalGameSequences]);
    NSLog(@"already restored %d actions", [self actionCountForArray:[self allButLastTurn]]);
    NSLog(@"animate %d from last turn", [[_history lastObject] count]);
    NSLog(@"animate %d from this turn", [_thisTurnActions count]);
    
    
    
    if (_thisTurnActions.count) {
        [_turnHeap addObject:_thisTurnActions];
    }
    
    
    //NSArray* allButLast = [self allButLastTurn]; // CHECK THAT WE DID HAVE ONE THAT DIDN'T GET PLAYED
    
    if (_history.count) {
        [_turnHeap addObject:[_history lastObject]];
    }
    
    if (_turnHeap.count) { // BETTER BE YES
        NSLog(@"------------ BEGIN ANIMATING ------------");
        [self enumerateTurnHeapAnimate:YES];
    }
    
    else {
        NSLog(@"------------ SOMETHING WENT HORRIBLY WRONG ------------");
        
    }
    
    
}

-(void)replayLastAction {
    
    [_gameScene setWaiting:NO];
    
    self.myTurn = NO;
    
    NSLog(@"------------ REPLAY HISTORY ------------");
    
    actionIndex = 0;
    
    [self wipeBoard];
    [self refreshGameBoard];
    
    NSMutableArray* allActions = [self allActionsLinear];
    
    GameSequence *last = [allActions lastObject];
    
    [allActions removeLastObject];
    
    _actionHeap = [NSMutableArray array];
    
    for (int i = 0; i < allActions.count; i++){
        [_actionHeap addObject:allActions[allActions.count - (i + 1)]];
    }
    
    [self performAction:[_actionHeap lastObject] record:NO animate:NO];
    
    [self buildBoardFromCurrentState];
    
    [self performAction:last record:NO animate:YES];
    
    
}

-(NSMutableArray*)allActionsLinear {
    
    NSMutableArray *allActions = [NSMutableArray array];
    
    for (int i = 0; i < _history.count; i++){
        NSArray* turn = _history[i];
        for (int i = 0; i < turn.count; i++){
            [allActions addObject:turn[i]];
        }
        
    }
    
    for (int i = 0; i < _thisTurnActions.count; i++){
        [allActions addObject:_thisTurnActions[i]];
    }
    
    //NSLog(@"BUILD ACTION ARRAY %d items", allActions.count);
    
    return allActions;
    
}

-(int)totalEvents {
    
    int total = 0;
    for (GameSequence *g in [self allActionsLinear]) {
        for (GameEvent* e in g.GameEvents) {
            total++;
        }
    }
    
    return total;
    
}

-(void)fetchThisTurnActions {
    
    
    [_match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error){
        
        if (!_animating) {
            NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:[matchData gzipInflate]];
            //NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:matchData];
            
            [self loadActionsFromUnarchiver:unarchiver];
            
            [self checkMyTurn];
            [self checkRTConnection];
            
            if ([self catchUpOnActions]){
                
                
                
            }
            
        }
        
        else {
            NSLog(@"animating, wait . . .");
            //            double delayInSeconds = 2.0;
            //            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            //            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //                [self fetchThisTurnActions];
            //            });
        }
        
        
        
    }];
    
    
    
}

-(BOOL)catchUpOnActions {
    
    
    
    if (actionIndex == 0) {
        [self replayLastTurn];
        return 0;
    }
    
    NSLog(@"--- LOADED CURRENT ACTIONS ---");
    
    NSArray *allActions = [self allActionsLinear];
    
    NSLog(@"%d TOTAL, %d ALREADY PERFORMED", allActions.count, actionIndex);
    
    int difference = allActions.count - actionIndex;
    
    if (allActions.count == actionIndex) {
        NSLog(@"FETCH IS CURRENT");
        
        if (!_thisTurnActions) {
            _thisTurnActions = [NSMutableArray array];
        }
        
        if (!_thisTurnActions.count) {
            NSLog(@"NO ACTIONS FOR THIS TURN");
            if ([self checkMyTurn]) {
                // BEGINNING OF MY TURN
                _me.ActionPoints = 0;
                [self startMyTurn];
            }
            
        }
        
        return 1;
    }
    
    else if (allActions.count < actionIndex){
        NSLog(@"FETCH IS OLDER THAN RT, CHECK BACK SHORTLY");
        
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self fetchThisTurnActions];
        });
        
        return 0;
    }
    
    // SOMETHING FOR CATCH UP
    else { // actions > index
        
        NSLog(@"FETCH IS NEW by %d new actions", difference);
        
        _actionHeap = [NSMutableArray array];
        
        NSMutableArray *allActions = [self allActionsLinear];
        
        for (int i = 0; i < difference; i ++){
            
            [_actionHeap addObject:[allActions lastObject]];
            [allActions removeLastObject];
            
        }
        
        [self performAction:[_actionHeap lastObject] record:NO animate:YES];
        
        
    }
    
    //        else {
    //            NSLog(@"FETCH IS REALLY NEW");
    //            [self logCurrentGameData];
    //            [self wipeBoard];
    //            [self refreshGameBoard];
    //            [self restoreGameWithData:_match];
    //            [self replayLastTurn];
    //        }
    
    
    
    return 0;
    
}



// withCompletionBlock:(void (^)())block

-(void)enumerateTurnHeapAnimate:(BOOL)animate {
    
    if (_turnHeap.count) {
        
        [self performTurn:[_turnHeap lastObject] animate:animate];
        
    }
    
    else {
        [self didFinishAllReplays:animate];
    }
    
}


-(void)didFinishAllReplays:(BOOL)animate {
    
    NSLog(@"------------ COMPLETE REPLAY ------------");
    
    _animating = NO;
    
    [self fetchThisTurnActions];
    
    
    
}

-(void)startMyTurn {
    
    NSLog(@"------------ START MY TURN ------------");
    
    NSLog(@"starting turn %d", _history.count);
    
    _currentEventSequence = [GameSequence action];
    
    [self addStartTurnEventsToAction:_currentEventSequence];
    
    if ([self shouldPerformCurrentAction]) {
        NSLog(@"start turn success");
    }
    else {
        NSLog(@"failed turn start actions");
    }
    
}

-(void)wipeBoard {
    _ball = [[Card alloc] init];
    _ball.cardType = kCardTypeBall;
    
    _players = [NSMutableDictionary dictionary];
    [_gameScene cleanupGameBoard];
}

-(void) addCardToBoard:(Card*)c {
    [_players setObject:[c.location copy] forKey:c];
    [_gameScene addCardToBoardScene:c];
}


//-(void)delegateSetupBoardWithPlayersComplete{
//    // manager who has the most fuel from yesterday goes first
//    myTurn = true;
//    [self playTurn];
//}

-(void) setupNewPlayers{
    
    
    // FIRST SHUFFLE CARDS SO WE HAVE A VALID ORDER
    
    _ball = [[Card alloc] init];
    _ball.cardType = kCardTypeBall;
    
    _currentEventSequence = [GameSequence action];
    
    [self addShuffleEventToAction:_currentEventSequence forDeck:_me.players];
    
    [self addShuffleEventToAction:_currentEventSequence forDeck:_opponent.players];
    
    [self setupCoinTossPositionsForAction:_currentEventSequence];
    
    //MANAGERS- place your first 3 players
    
    [self addSetBallEventForAction:_currentEventSequence location:[BoardLocation pX:3 Y:BOARD_LENGTH/2-1]];
    
    // PLAYER 1 GETS THE BALL. PLACE IT ON THE FIELD
    
//    [self addDrawEventToAction:_currentEventSequence forManager:_me];
//    [self addDrawEventToAction:_currentEventSequence forManager:_me];
//    
//    [self addDrawEventToAction:_currentEventSequence forManager:_opponent];
//    [self addDrawEventToAction:_currentEventSequence forManager:_opponent];
    
    // notify game that setup is done
}

-(void) setupCoinTossPositionsForAction:(GameSequence*)action {
    
    // automated loop, finds your first 3 player cards
    
    // CHECK WE HAVE PLAYERS
    
    for (int i = 0; i<3; i++) {

        GameEvent* spawn = [self addEventToSequence:action fromCardOrPlayer:nil toLocation:[BoardLocation pX:i*2+1 Y:(BOARD_LENGTH/2)+!i] withType:kEventAddPlayer];
        spawn.manager = [self managerForTeamSide:0];
        
        GameEvent* spawn2 = [self addEventToSequence:action fromCardOrPlayer:nil toLocation:[BoardLocation pX:i*2+1 Y:(BOARD_LENGTH/2)-1] withType:kEventAddPlayer];
        spawn2.manager = [self managerForTeamSide:1];

    }
    
}

-(void) buildBoardFromCurrentState{
    
    NSLog(@"---***---*** UI RESTORE ---***---***");
    
    
    NSLog(@"I have %d players on the board", [_me players].inGame.count);
    
    for (Player *p in [_me players].inGame) {
        
        
        
        if ([p.location isEqual:_ball.location]) {
            [p setBall:_ball];
        }
        [self addCardToBoard:p];
        
        
    }
    
    
    NSLog(@"They have %d players on the board", [_me players].inGame.count);
    
    for (Player *p in [_opponent players].inGame) {
        
        if ([p.location isEqual:_ball.location]) {
            [p setBall:_ball];
        }
        [self addCardToBoard:p];
        
        
    }
    
    NSLog(@"-------- FINISH UI RESTORE --------");
    
    [self refreshGameBoard];
    
}

-(void)refreshGameBoard {
    
    // [_gameScene setRotationForManager:_me];
    
    [_gameScene moveBallToLocation:_ball.location];
    
    [_gameScene refreshScoreBoard];
    
}

#pragma mark - UI INTERACTION

-(void)setCurrentAction:(GameSequence *)currentEventSequence {
    
    if (_currentEventSequence && !currentEventSequence) {
        
        [_gameScene cleanUpUIForAction:_currentEventSequence];
        
        //        if (_gameScene.currentCard) {
        //            [_gameScene setCurrentCard:nil];
        //        }
        
        if (_myTurn) {
            [self sendRTPacketWithType:RTMessageCancelAction point:nil];
        }
        
        [_gameScene fadeOutHUD];
        
    }
    
    _currentEventSequence = currentEventSequence;
    
}

-(NSArray*)allBoardLocations {
    NSMutableArray *boardLocations = [NSMutableArray array];
    
    for (int x = 0; x < BOARD_WIDTH; x++) {
        for (int y = 0; y < BOARD_LENGTH; y++) {
            [boardLocations addObject:[BoardLocation pX:x Y:y]];
        }
    }
    
    return boardLocations;
    
}

-(NSArray*)wallsForCard:(Card*)c {

    BoardLocation *center = [c.deck.player.location copy];
    
    NSMutableArray *obstacles = [[self allBoardLocations] mutableCopy];
    
    int range = c.range;
    NSLog(@"obstacles for %d,%d, range %d", center.x, center.y, c.range);
    for (int x = center.x - range; x<=center.x + range; x++){
        
        if (x >= 0 && x < 7) {
            
            for (int y = center.y - range; y<=center.y + range; y++){
            
                if (y >= 0 && y < 10) {
                    
                    [obstacles removeObject:[BoardLocation pX:x Y:y]];
                    
                }
            }
            
        }
        
    }
    
    return obstacles;
    
}

-(void)setSelectedCard:(Card *)selectedCard {
    
    if (_myTurn) {
        
        if (!_animating) {
            
            NSMutableArray* obstacles = [[self wallsForCard:selectedCard] mutableCopy];

            for (Player* p in [_players allKeys]) {
                [obstacles addObject:p.location];
            }
            
            AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
            
            NSArray *path;
            
            if (selectedCard.deckType == DeckTypeMove) {
                  path = [aStar cellsAccesibleFrom:selectedCard.deck.player.location NeighborhoodType:NeighborhoodTypeQueen walkDistance:selectedCard.range];
            }
            if (selectedCard.deckType == DeckTypeKick) {
                path = [aStar cellsAccesibleFrom:selectedCard.deck.player.location NeighborhoodType:NeighborhoodTypeRook walkDistance:selectedCard.range];
            }
            
            [_gameScene showCardPath:path];
            
        }
    }
    
    _selectedCard = selectedCard;
    
}

-(void)setSelectedLocation:(BoardLocation *)selectedLocation {
    
    if (_selectedPlayer) {
        if (_selectedCard) {
            
            _currentEventSequence = [GameSequence action];
            [self addEventToSequence:_currentEventSequence fromCardOrPlayer:_selectedCard toLocation:selectedLocation withType:kEventMove];
            [self performAction:_currentEventSequence record:YES animate:YES];
        }
    }
}

// MOVING PLAYER ON FIELD
-(BOOL)canUsePlayer:(Player*)player {
    
    if (_myTurn) {
        
        if (!_animating) {
            
            if ([player.manager isEqual:_me]) {
                
                if (_currentEventSequence) {
                    [_gameScene cleanUpUIForAction:_currentEventSequence];
                }
                
                [_gameScene refreshActionWindowForPlayer:player withCompletionBlock:nil];
                
                return 1;
                
            }
            
            else {
                
                if (_currentEventSequence) {
                    [_gameScene cleanUpUIForAction:_currentEventSequence];
                }
                
                
            }
            
          
            
        }
        
        _currentEventSequence = nil;
        
    }
    
    return 0;
}




-(GameEvent*)requestPlayerActionAtLocation:(BoardLocation*)location; {
    
    if (!_animating) {
        
        
        //        if (!_currentEventSequence) {
        //            NSLog(@"Game.m : ERROR! MOVING PLAYER WITH NO ALLOCATED ACTION!");
        //            return nil;
        //        }
        //
        //        if (!_currentEventSequence.GameEvents.count) { // deleted all of them
        //            GameEvent *event = [self addPlayerEventToAction:_currentEventSequence from:location to:location withType:kEventSequence];
        //            return event;
        //        }
        //
        //        Card* player;
        //        GameEvent *previousEvent;
        //
        //        if (_currentEventSequence.GameEvents.count) {
        //            player = [self firstEvent].playerPerformingAction;
        //            previousEvent = [_currentEventSequence.GameEvents lastObject];
        //        }
        //
        //
        //        if ([location isEqual:[self goalieForManager:_opponent].location] && [self firstEvent].playerPerformingAction.ball) {
        //
        //            return [self addPlayerEventToAction:_currentEventSequence from:player.location to:location withType:kEventKickGoal];
        //        }
        //
        //
        //        //NSLog(@"Game.m : checkForEventAtLocation (%d,%d)",location.x, location.y);
        //        // check if touched the end of the path or middle
        //        for (GameEvent *event in _currentEventSequence.GameEvents){ // CHECK ALREADY EXISTING
        //
        //            if ([event.location isEqual:location]) {
        //
        //                NSInteger last = _currentEventSequence.GameEvents.count;
        //
        //                if (_currentEventSequence.GameEvents.count > 1) { // CHECK FOR DELETE
        //
        //                    if (![event isEqual:_currentEventSequence.GameEvents.lastObject]) {
        //                        for (int i = event.actionSlot; i <= last; i++){
        //                            [_currentEventSequence.GameEvents removeLastObject];
        //                            //NSLog(@"removing action %d", i);
        //                        }
        //
        //                        if (!_currentEventSequence.GameEvents.count) { // deleted all of them
        //                            GameEvent *event = [self addPlayerEventToAction:_currentEventSequence from:location to:location withType:kEventSequence];
        //                            return event;
        //                        }
        //
        //                        GameEvent *hopefullyAdjacentEvent = _currentEventSequence.GameEvents.lastObject;
        //
        //                        if ([self isAdjacent:hopefullyAdjacentEvent.location to:location]){
        //
        //                            GameEvent *event = [self addPlayerEventToAction:_currentEventSequence from:previousEvent.location to:location withType:[self getPlayerEventTypeForLocation:location]];
        //                            return event;
        //
        //                        }
        //
        //                    }
        //                }
        //
        //
        //                return Nil; // ALREADY HAVE SQUARE AND NOT GOING BACKWARDS
        //            }
        //        }
        //
        //        // CONTINUING CONFIRM ADJACENT
        //        if (_currentEventSequence.GameEvents.count) { // CHECK FOR CONTINUITY
        //            GameEvent *hopefullyAdjacentEvent = _currentEventSequence.GameEvents.lastObject;
        //            if ([self isAdjacent:hopefullyAdjacentEvent.location to:location]){ // OK GOOD PATH, WHAT IS OUR ACTION TYPE
        //
        //                GameEvent *event = [self addPlayerEventToAction:_currentEventSequence from:previousEvent.location to:location withType:[self getPlayerEventTypeForLocation:location]];
        //                return event;
        //
        //            }
        //
        //            return nil;
        //
        //        }
        //
        //        // THEN THIS IS THE FIRST EVENT !!
        //        GameEvent *event = [self addPlayerEventToAction:_currentEventSequence from:location to:location withType:kEventSequence];
        //        return event;
        //    }
        //
        
        
        
        NSLog(@"Game.m : checkForEventAtLocation : return NIL");
        
    }
    return Nil;
    
}

#pragma mark - TB NETWORK EVENTS

-(BOOL)checkMyTurn{
    
    if (!_animating) {
        
        if ([_match.currentParticipant.playerID
             isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            // It's your turn!
            
            self.myTurn = YES;
            
            return NO;
            
        } else {
            // It's not your turn, just display the game state.
            
            self.myTurn = NO;
            
            
            
        }
        
    }
    
    return NO;
    
}

#pragma mark - RT NETWORK EVENTS

-(void)rtIsActive:(BOOL)active {
    
    rtIsActive = active;
    
    if (active) {
        
    }
    
    
    
}

-(void)setRtmatch:(GKMatch *)rtmatch {
    
    if (!_rtmatch && rtmatch) {
        [self fetchThisTurnActions];
    }
    
    _rtmatch = rtmatch;
    
    
}

-(BOOL)checkRTConnection {
    
    if (_rtmatch) {
        
        if (_rtmatch.playerIDs.count) {
            NSLog(@"RT IS INACTIVE");
            [_gameScene rtIsActive:YES];
            return 1;
        }
        
    }
    
    NSLog(@"RT IS INACTIVE, FIRING UP");
    
    [_gcController initRealTimeConnection];
    
    [_gameScene rtIsActive:NO];
    return 0;
    
}

-(void)receiveRTPacket:(NSData*)packet {
    
    
    if (!_animating) {
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:packet];
        
        RTMessageType type = [unarchiver decodeIntForKey:@"type"];
        
        //NSLog(@"receiving packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
        
        [_gameScene receiveRTPacket];
        
        if (type == RTMessageNone) {
            return;
        }
        
        else if (type == RTMessagePerformAction) {
            
            
            
            
            GameSequence *action = [unarchiver decodeObjectForKey:@"action"];
            
            
            
            
            if (action.tag == actionIndex+1) { // WE ARE CURRENT
                
                [self setUpPointersForActionArray:action];
                
                
                
                [self performAction:action record:NO animate:YES];
                
            }
            
            else {
                NSLog(@"NOT IN SYNC - CATCHING UP IF POSSIBLE LATEST ACTION");
                [self fetchThisTurnActions];
                
            }
            
            
            
            
        }
        else if (type == RTMessageShowAction) {
            
            
            GameSequence *action = [unarchiver decodeObjectForKey:@"action"];
            
            [self setUpPointersForActionArray:action];
            
            for (GameEvent* e in action.GameEvents) {
                [self getPlayerPointersForEvent:e];
            }
            
            _currentEventSequence = action;
            
            [_gameScene addNetworkUIForEvent:[_currentEventSequence.GameEvents lastObject]];
            
            
        }
        
        else if (type == RTMessageCancelAction){
            
            [self setCurrentAction:Nil];
            
        }
        
        else if (type == RTMessageCheckTurn){
            
            
            [self fetchThisTurnActions];
            
            
        }
        
        else if (type == RTMessageSortCards){
            
            
            [_gameScene sortHandForManager:_opponent animated:YES];
            
            
        }
        
        else if (type == RTMessageBeginCardTouch || type == RTMessageMoveCardTouch){
            
//            BoardLocation *location = [unarchiver decodeObjectForKey:@"location"];
//            //Card *c = [self cardInHandForManager:_opponent location:location];
//            
//            CGPoint touch = [unarchiver decodeCGPointForKey:@"touch"];
//            CGSize inSize = [unarchiver decodeCGSizeForKey:@"bounds"];
//            CGSize outSize = [[UIScreen mainScreen] bounds].size;
//            
//            float xScale = outSize.width / inSize.width;
//            float yScale = outSize.height / inSize.height;
//            
//            CGPoint pos = CGPointMake(touch.x * xScale, touch.y * yScale);
//            
//            if (type == RTMessageBeginCardTouch) {
//                
//                [_gameScene opponentBeganCardTouch:c atPoint:pos];
//                
//            }
//            
//            else if (type == RTMessageMoveCardTouch) {
//                
//                [_gameScene opponentMovedCardTouch:c atPoint:pos];
//                
//            }
            
        }
        
        else if (type == RTMessagePlayer) {
            
        }
        
    }
    
    else {
        
        NSLog(@"already animating, check back later . . .");
    }
    
    
}


-(void)sendAction:(GameSequence*)action perform:(BOOL)perform {
    
    if (_myTurn || perform) {
        
        
        if (_rtmatch) {
            
            NSMutableData* packet = [[NSMutableData alloc]init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packet];
            
            int type;
            
            if (perform) {
                type = RTMessagePerformAction;
            }
            else {
                type = RTMessageShowAction;
            }
            
            [archiver encodeInt:type forKey:@"type"];
            [archiver encodeObject:action forKey:@"action"];
            
            [archiver finishEncoding];
            
            NSLog(@"sending packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
            
            [_rtmatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:nil];
            
        }
        
        
    }
    
}


-(void)sendRTPacketWithType:(RTMessageType)type point:(BoardLocation*)location {
    
    if (_myTurn) {
        if (_rtmatch) {
            
            NSMutableData* packet = [[NSMutableData alloc]init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packet];
            
            [archiver encodeInt:type forKey:@"type"];
            [archiver encodeObject:location forKey:@"location"];
            
            [archiver finishEncoding];
            NSLog(@"sending packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
            
            [_rtmatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:nil];
            
            
        }
    }
    
}

-(void)sendRTPacketWithCard:(Card*)c point:(CGPoint)touch began:(BOOL)began{
    
    if (_myTurn) {
        
        if (_rtmatch) {
            
            RTMessageType type;
            if (began) {
                type = RTMessageBeginCardTouch;
            }
            else{
                type = RTMessageMoveCardTouch;
            }
            
            NSMutableData* packet = [[NSMutableData alloc]init];
            
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:packet];
            
            [archiver encodeInt:type forKey:@"type"];
            [archiver encodeObject:c.location forKey:@"location"];
            [archiver encodeCGPoint:touch forKey:@"touch"];
            [archiver encodeCGSize:[[UIScreen mainScreen] bounds].size forKey:@"bounds"];
            
            [archiver finishEncoding];
            NSLog(@"sending packet of type: %@ size %d", [self stringForMessageType:type], packet.length);
            
            [_rtmatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:nil];
            
        }
    }
    
}

-(NSString*)stringForMessageType:(RTMessageType)type {
    NSString *stype;
    
    if (type == RTMessagePlayer) {
        stype = @"RTMessagePlayer";
    }
    else if (type == RTMessageBeginCardTouch) {
        stype = @"RTMessageBeginCardTouch";
    }
    else if (type == RTMessageMoveCardTouch) {
        stype = @"RTMessageMoveCardTouch";
    }
    else if (type == RTMessagePerformAction) {
        stype = @"RTMessagePerformAction";
    }
    else if (type == RTMessageShowAction) {
        stype = @"RTMessageShowAction";
    }
    else if (type == RTMessageCancelAction) {
        stype = @"RTMessageCancelAction";
    }
    else if (type == RTMessageCheckTurn) {
        stype = @"RTMessageCheckTurn";
    }
    
    else {
        stype = @"RT-TYPE-UNKNOWN";
    }
    return stype;
    
}
#pragma mark - CREATING EVENTS

-(void)getPlayerPointersForEvent:(GameEvent*)event {
    
    if (event.type == kEventSequence) {
        event.playerPerformingAction = [self playerAtLocation:event.location];
    }
    
    else if (event.isRunningEvent) {
        
        int index = [event.parent.GameEvents indexOfObject:event];
        
        for (int i = index; i >= 0; i--){
            GameEvent* testEvent = event.parent.GameEvents[i];
            if (testEvent.type == kEventSequence) {
                event.playerPerformingAction = testEvent.playerPerformingAction;
            }
        }
        
        if (event.type == kEventChallenge) {
            event.playerReceivingAction = [self playerAtLocation:event.location];
        }
        
    }
    
    else if (event.type == kEventPlayCard){
        
        event.card = [event.playerPerformingAction cardInHandAtlocation:event.location];
        
        if (!event.card) {
            NSLog(@"play card with no card in hand");
        }
        
    }
    
    else if (event.type == kEventAddPlayer){

    }
    
    else if (event.type == kEventRemovePlayer) {
        
        event.playerPerformingAction = [self playerAtLocation:event.location];
        
    }
    
    else if (event.type == kEventAddSpecial) {
        
        int index = event.actionSlot;
        
        for (int i = index; i >= 0; i--){
            GameEvent* testEvent = event.parent.GameEvents[i];
            
            if (testEvent.type == kEventPlayCard) {
                event.playerPerformingAction = testEvent.playerPerformingAction;
                NSLog(@"found player from 'play card action'");
            }
            
        }
        
        if (!event.playerPerformingAction) {
            NSLog(@"no player for deploy or enchant");
        }
        
        
        if (event.type == kEventAddSpecial) {
            event.playerReceivingAction = [self playerAtLocation:event.location];
        }
        
    }
    
    else if (event.type == kEventKickGoal || event.type == kEventKickPass) {
        
        event.playerPerformingAction = [self playerAtLocation:event.startingLocation];
        
        event.playerReceivingAction = [self playerAtLocation:event.location];
    }
    
    
}

-(GameEvent*)addEventToSequence:(GameSequence*)sequence fromCardOrPlayer:(Card*)card toLocation:(BoardLocation*)location withType:(EventType)type {
    
    NSLog(@"CARD'S DECK LOCATION IS %d %d", card.location.x, card.location.y);
    

    GameEvent *event = [GameEvent eventForAction:sequence];
    
    if ([card isKindOfClass:[Player class]]) { // IS A PLAYER
        event.playerPerformingAction = (Player*)card;
        event.manager = event.playerPerformingAction.manager;
        event.deck = nil;
        event.type = kEventAddPlayer;
        NSLog(@"adding deploy event");
    }
    
    else if (card){ // IS CARD
        event.deck = card.deck;
        event.manager = event.deck.player.manager;
        event.playerPerformingAction = card.deck.player;
        event.card = card;
    }
    
    event.type = type;
    event.startingLocation = [card.deck.player.location copy];
    event.location = [location copy];
    
    [sequence.GameEvents addObject:event];
    
    //event.actionSlot = action.GameEvents.count;
    
    event.actionCost = 0;
    
    [self getPlayerPointersForEvent:event];

    return event;
    
}

-(GameEvent*)addGeneralEventToAction:(GameSequence*)action forManager:(Manager*)m withType:(EventType)type {
    
    action.boost = 0;
    
    GameEvent *event = [GameEvent eventForAction:action];
    
    event.manager = m;
    
    [action.GameEvents addObject:event];
    
    //event.actionSlot = action.GameEvents.count;
    
    event.type = type;
    
    event.actionCost = 0;
    
    event.totalModifier = 0.;
    
    return event;
    
}

-(GameEvent*)addPlayerEventToAction:(GameSequence*)action from:(BoardLocation *)startLocation to:(BoardLocation*)location withType:(EventType)type {
    
    // FIX THIS
    
    
//    action.boost = 0;
//    
    GameEvent *event = [GameEvent eventForAction:action];
//    
//    event.location = [location copy];
//    event.startingLocation = [startLocation copy];
//    
//    event.type = type;
//    
//    // EDGE CASE FIX FOR OVERRIDING PASS
//    
//    if (event.isRunningEvent) {
//        GameEvent* e = [action.GameEvents lastObject];
//        
//        if (e.type == kEventKickPass || e.type == kEventKickGoal) {
//            e.type = kDribbleAction;
//            e.actionCost = 1;
//            GameEvent *previous = action.GameEvents[e.actionSlot - 1];
//            
//            Abilities *tempPlayer = [self playerAbilitiesWithMod:e.playerPerformingAction];
//            
//            e.startingLocation = previous.location;
//            
//            e.totalModifier += [self checkLocationForDribbleModifiers:location forTeam:_opponent];
//            e.success = tempPlayer.dribble + event.totalModifier;
//            
//            NSLog(@"REWRITING PASS TO DRIBBLE EVENT");
//        }
//    }
//    
//    if (event.type == kEventKickPass || event.type == kEventKickGoal) {
//        event.startingLocation = [[action.GameEvents[0] startingLocation] copy];
//    }
//    
//    // BACK TO IT
//    
//    [action.GameEvents addObject:event];
//    
//    //event.actionSlot = action.GameEvents.count;
//    
//    [self getPlayerPointersForEvent:event];
//    
//    // SET GENERIC COST
//    
//    event.actionCost = 1;
//    event.totalModifier = 0.;
//    
//    // CONFIGURE INDIVIDUAL COST / MODIFIER
//    Abilities *tempPlayer = [self playerAbilitiesWithMod:event.playerPerformingAction];
//    
//    event.totalModifier = 0.;
//    
//    
//    
//    
//    if (event.type == kEventSequence) {
//        event.actionCost = 0.;
//        event.totalModifier = 0.;
//        event.success = 1.;
//    }
//    
//    else if (event.type == kRunningAction) {
//        event.totalModifier = 0.;
//    }
//    
//    else if (event.type == kChallengeAction){
//        event.totalModifier += [self checkLocationForChallengeModifiers:location forTeam:_opponent];
//        event.success = tempPlayer.handling + event.totalModifier;
//    }
//    
//    else if (event.type == kDribbleAction) {
//        GameEvent *previous = action.GameEvents[event.actionSlot - 1];
//        event.totalModifier += [self checkLocationForDribbleModifiers:previous.location forTeam:_opponent];
//        event.success = tempPlayer.dribble + event.totalModifier;
//    }
//    
//    else if (event.type == kEventKickPass){
//        event.totalModifier += [self checkLocationForPassModifiers:location forTeam:_opponent];
//        event.success = tempPlayer.kick + event.playerReceivingAction.abilities.handling + event.totalModifier;
//    }
//    
//    else if (event.type == kEventKickGoal){
//        event.totalModifier += [self checkLocationForShootModifiers:location forTeam:_opponent];
//        event.success = tempPlayer.kick + event.totalModifier;
//    }
//    else if (event.type == kEventAddPlayer) {
//        event.actionCost = 0;
//        event.totalModifier = 0.;
//        event.success = 1.;
//    }
//    
//    else if (event.type == kEventPlayCard) {
//        event.actionCost = event.playerPerformingAction.actionPointCost;
//        event.totalModifier = 0.;
//        event.success = 1.;
//    }
//    
//    else if (event.type == kEnchantAction) {
//        event.actionCost = 0;
//        event.totalModifier = 0.;
//        event.success = 1.;
//    }
//    
//    else {
//        event.actionCost = 1;
//        NSLog(@"must be a draw action!");
//    }
//    
//    
//    // CALCULATE TOTAL COST
//    //NSLog(@"temp player %f / %f", tempPlayer.kick, tempPlayer.handling);
//    
//    //NSLog(@"event modifier %f : success %f", event.totalModifier, event.parent.totalSucess);
//    
    
    return event;
    
}

-(GameEvent*)addDrawEventToAction:(GameSequence*)action forManager:(Manager*)m {
    
    GameEvent *draw = [GameEvent eventForAction:action];
    draw.type = kEventDraw;
    draw.manager = m;
    [action.GameEvents addObject:draw];
    //draw.actionSlot = action.GameEvents.count;
    
    return draw;
    
}


-(GameEvent*)addShuffleEventToAction:(GameSequence*)action forDeck:(Deck*)d {
    
    GameEvent *shuffle = [GameEvent eventForAction:action];
    shuffle.deck = d;
    shuffle.playerPerformingAction = d.player;
    shuffle.manager = d.player.manager;
    shuffle.type = kEventShuffleDeck;
    
    
    [action.GameEvents addObject:shuffle];
    
    //shuffle.actionSlot = action.GameEvents.count;
    
    return shuffle;
    
}



-(BOOL)validatePlayerMove:(Card*)player { // AKA VALIDATE ACTION
    
#pragma mark - MOVE LOGIC NEEDS HERE::
    
//    if (_myTurn) {
//        
//        if (_currentEventSequence.GameEvents.count) {
//            
//            GameEvent *last = [_currentEventSequence.GameEvents lastObject];
//            
//            BoardLocation *location = [last location];
//            
//            // DRIBBLE
//            if (last.type == kEventSequence) {
//                return 0;
//            }
//            if ([location isEqual:player.location]) {
//                self.currentEventSequence = Nil;
//                return 0;
//            }
//            
//            Card* player = _currentEventSequence.playerPerformingAction;
//            
//            // GOALIE RULES
//            if (player.isTypeKeeper) {
//                
//                for (GameEvent *e in _currentEventSequence.GameEvents) {
//                    if (e.type == kChallengeAction) {
//                        if ([self isAdjacent:e.location to:player.location]) {
//                            return 1;
//                        }
//                    }
//                    
//                    if (e.type == kEventKickPass) {
//                        return 1;
//                    }
//                    
//                }
//                
//                
//                self.currentEventSequence = Nil;
//                return 0;
//            }
//            
//            else {
//                for (GameEvent *e in _currentEventSequence.GameEvents) {
//                    if (e.type == kChallengeAction) {
//                        if ([self playerAtLocation:e.startingLocation]) {
//                            if (![[self playerAtLocation:e.startingLocation] isEqual:_currentEventSequence.playerPerformingAction]) {
//                                NSLog(@"can't challenge from occupied square");
//                                self.currentEventSequence = Nil;
//                                return 0;
//                            }
//                        }
//                    }
//                }
//                
//                
//                if ([_currentEventSequence isRunningAction]){
//                    
//                    for (Card *c in [[_opponent deck] inGame]) { // CHECK OPPONENT CARDS
//                        if ([c.location isEqual:location]) {
//                            if (c.ball){
//                                return 1;
//                            }
//                            self.currentEventSequence = Nil;
//                            return 0;
//                        }
//                    }
//                    
//                    for (Card *c in [[_me deck] inGame]) { // CHECK MY CARDS
//                        if ([c.location isEqual:location]) {
//                            self.currentEventSequence = Nil;
//                            return 0;
//                        }
//                    }
//                }
//            }
//            
//            return 1;
//            
//        }
//        
//        return 0;
//    }
//    
//    return -1;
    return -1;
}

-(GameSequence*)endTurnAction {
    
    GameSequence* endTurn = [GameSequence action];
    
    // this did wipe the board of out of zone players
    
//    for (Card* p in players.allKeys) {
//        
//        if ([p isTypePlayer]) {
//            
//            if (p.location.x < _activeZone.x || p.location.x > _activeZone.y) {
//                
//                GameEvent *e = [GameEvent eventForAction:endTurn];
//                e.location = [p.location copy];
//                e.playerPerformingAction = p;
//                e.type = kRemovePlayerAction;
//                [endTurn.GameEvents addObject:e];
//                //e.actionSlot = endTurn.GameEvents.count;
//                
//            }
//            
//        }
//        
//    }
    
    
    GameEvent *e2 = [GameEvent eventForAction:endTurn];
    e2.type = kEventRemoveSpecial;
    e2.manager = _me;
    [endTurn.GameEvents addObject:e2];
    
    
    GameEvent *e3 = [GameEvent eventForAction:endTurn];
    e3.type = kEventEndTurn;
    e3.manager = _me;
    [endTurn.GameEvents addObject:e3];
    //e.actionSlot = endTurn.GameEvents.count;
    
    
    
    return endTurn;
    
}

-(void)fullFieldWipeForAction:(GameSequence*)action {
    
    for (Player* p in _players.allKeys) {
            GameEvent *e = [GameEvent eventForAction:action];
            e.location = [p.location copy];
            e.type = kEventRemovePlayer;
            e.playerPerformingAction = p;
            
            [action.GameEvents addObject:e];
            //e.actionSlot = action.GameEvents.count;
        }
    
    
}

-(void)addGoalResetToAction:(GameSequence*)goal {
    
    
    [self fullFieldWipeForAction:goal];
    
    [self setupCoinTossPositionsForAction:goal];
    
    if (_me.teamSide) {
        [self addSetBallEventForAction:goal location:[BoardLocation pX:BOARD_LENGTH/2-1 Y:1]];
    }
    else {
        [self addSetBallEventForAction:goal location:[BoardLocation pX:BOARD_LENGTH/2 Y:1]];
    }
    
    GameEvent *e2 = [GameEvent eventForAction:goal];
    e2.type = kEventRemoveSpecial;
    e2.manager = _me;
    [goal.GameEvents addObject:e2];
    
    
    GameEvent *e3 = [GameEvent eventForAction:goal];
    e3.type = kEventEndTurn;
    e3.manager = _me;
    [goal.GameEvents addObject:e3];
    //e.actionSlot = endTurn.GameEvents.count;

    
}

//-(void)addGoalKickToAction:(GameSequence*)goal {
//    
//    
//    [self fullFieldWipeForAction:goal];
//    
//    GameEvent *r = [GameEvent eventForAction:goal];
//    r.type = kGoalResetAction;
//    r.manager = _me;
//    [goal.GameEvents addObject:r];
//    //r.actionSlot = goal.GameEvents.count;
//    
//    [self setupCoinTossPositionsForAction:goal];
//    
//    // [self addSetBallEventForAction:goal location:[[self goalieForManager:_opponent].location copy]];
//    
//    GameEvent* goalKick = [GameEvent eventForAction:goal];
//    
//    goalKick.type = kGoaliePass;
//    
//    goalKick.startingLocation = [[self goalieForManager:_opponent].location copy];
//    
//    if (_me.teamSide) {
//        goalKick.location = [BoardLocation pX:BOARD_LENGTH/2-1 Y:1];
//    }
//    else {
//        goalKick.location = [BoardLocation pX:BOARD_LENGTH/2 Y:1];
//    }
//    
//    [goal.GameEvents addObject:goalKick];
//    //goalKick.actionSlot = goal.GameEvents.count;
//    
//    GameEvent *e = [GameEvent eventForAction:goal];
//    e.type = kMoveFieldAction;
//    e.manager = _me;
//    [goal.GameEvents addObject:e];
//    
//    GameEvent *e2 = [GameEvent eventForAction:goal];
//    e2.type = kPurgeEnchantmentsAction;
//    e2.manager = _me;
//    [goal.GameEvents addObject:e2];
//    
//    
//    GameEvent *e3 = [GameEvent eventForAction:goal];
//    e3.type = kEventEndTurn;
//    e3.manager = _me;
//    [goal.GameEvents addObject:e3];
//    //e.actionSlot = endTurn.GameEvents.count;
//    
//    //e.actionSlot = goal.GameEvents.count;
//    
//    
//}

-(GameEvent*)addSetBallEventForAction:(GameSequence*)action location:(BoardLocation*)location {
    
    GameEvent *set = [GameEvent eventForAction:action];
    set.type = kEventSetBallLocation;
    set.manager = _me;
    set.location = [location copy];
    [action.GameEvents addObject:set];
    //set.actionSlot = action.GameEvents.count;
    
    return set;
}

-(void)addStartTurnEventsToAction:(GameSequence*)action {
    
    GameEvent* ap = [GameEvent eventForAction:action];
    ap.type = kEventStartTurn;
    ap.manager = _me;
    ap.actionCost = 0;
    [action.GameEvents addObject:ap];
    
    GameEvent* draw = [self addDrawEventToAction:action forManager:_me];
    draw.type = kEventStartTurnDraw;
    draw.actionCost = 0;
    
    
    //ap.actionSlot = action.GameEvents.count;
    
    
    
}

//-(EventType)getPlayerEventTypeForLocation:(BoardLocation*)location {
//    
//    // INHERIT PLAYER FROM kEventSequence
//    
//    Card* playerPerformingAction = [_currentEventSequence playerPerformingAction];
//    
//    if (playerPerformingAction.ball){
//        
//        for (Card *player in [[playerPerformingAction.manager deck] inGame]) {
//            if ([player.location isEqual:location]) { // SHOULD PASS
//                if (![player isEqual:_currentEventSequence.playerPerformingAction]) {
//                    NSLog(@"pass to: %@ : %d %d", player.name, location.x, location.y);
//                    return kEventKickPass;
//                }
//            }
//        }
//        
//    }
//    
//    if (![self willHaveBallForCurrentAction]) {
//        
//        for (Card *player in [[_opponent deck] inGame]) {
//            if ([player.location isEqual:location]) { // SHOULD CHALLENGE
//                if (player.ball) {
//                    return kChallengeAction;
//                }
//            }
//        }
//        
//        return kRunningAction;
//    }
//    
//    
//    return kDribbleAction;
//}

#pragma mark - PERFORMING EVENTS

-(void)performAction:(GameSequence*)action record:(BOOL)shouldRecordSequence animate:(BOOL)animate{
    
    
   // [_gameScene cleanUpUIForAction:action];
    [self setCurrentAction:nil];
    
    if (animate) {
        _animating = YES;
    }
    
    
    
    // BAD - BUT NEED THIS FOR REMOVE PLAYER EVENTS TO PROCESS ??
    if (action.type == kEventEndTurn) {

    }
    
    if (shouldRecordSequence) {
        
//        // FILTER MIDDLE EVENTS FOR PASS AND SHOOT
//        
//        
//        if (action.type == kEventKickGoal || action.type == kEventKickPass) { // FIRST AND LAST FILTER
//            
//            NSMutableArray *firstAndLast = [[NSMutableArray alloc]init];
//            
//            [firstAndLast addObject:action.GameEvents.firstObject];
//            [firstAndLast addObject:action.GameEvents.lastObject];
//            
//            action.GameEvents = firstAndLast;
//            
//        }
//        
//        // NOW ROLL THAT SHIT !!
//        
//        [_thisTurnActions addObject:action];
//        
//        action.tag = [self totalGameSequences];
//        action.wasSuccessful = [self rollAction:action];
//        
//        
//        // HERE IS WHERE TO DO SUCCESS BASED MODIFICATIONS TO THE ACTION, BEFORE PARSING THE EVENT LOOP
//        
//        
//        if (action.wasSuccessful) {
//            
//            if (action.type == kEventKickGoal) {
//                
//                [self addGoalResetToAction:action];
//            }
//            
//        }
//        else { // NOT SUCCESSFUL
//            
//            if (action.type == kEventKickGoal) {
//                [self addGoalResetToAction:action];
//            }
//            
//            if (action.isRunningAction) {
//                
//                NSMutableArray *new = [NSMutableArray array];
//                
//                [new addObject:action.GameEvents[0]];
//                [new addObject:action.GameEvents[1]];
//                
//                if (action.GameEvents.count > 2) {
//                    
//                    for (int a = 2; a < action.GameEvents.count; a++){
//                        
//                        GameEvent *ev = action.GameEvents[a];
//                        
//                        bool op = NO;
//                        
//                        for (Card *c in _players.allKeys) {
//                            if ([c.location isEqual:ev.startingLocation]) {
//                                op = YES;
//                            }
//                        }
//                        
//                        if (op) {
//                            [new addObject:ev];
//                        }
//                        
//                        else break;
//                        
//                        
//                    }
//                    
//                    NSLog(@"failed run, removing %d events", action.GameEvents.count - new.count);
//                    
//                }
//                
//                action.GameEvents = new;
//                
//            }
//        }
//        
        
        // OK GOOD TO GO?
        // THEN SEND IT
        
        // log meta
        
        
        [self processMetaDataForAction:action];
        
        [self sendAction:action perform:YES];
        
    }
    
    else if (action.tag <= actionIndex) {
        
        if (_actionHeap.count) {
            NSLog(@"bailing for already played action");
            [_actionHeap removeObject:action];
            [self performAction:[_actionHeap lastObject] record:shouldRecordSequence animate:animate];
        }
        
        else {
            NSLog(@"bailed and no more actions");
        }
        
        return;
    }
    
    
    _scoreBoardManager = action.manager;
    
    action.manager.ActionPoints -= action.totalCost;
    //action.manager.ActionPoints -= action.boost;
    
    NSLog(@"---- %d -- ACTION -- %d ----", action.tag, action.GameEvents.count);
    
    actionIndex = action.tag;
    
    // [_gameScene refreshScoreBoard];
    
    // MAKE EVENT HEAP- reverse order copy of event array
    
    _eventHeap = [[NSMutableArray alloc]initWithCapacity:5];
    
    for (int i = 0; i < action.GameEvents.count; i++){
        [_eventHeap addObject:action.GameEvents[action.GameEvents.count - (i + 1)]];
    }
    
    
    
    [self enumerateEventHeapForAction:action record:shouldRecordSequence animate:animate];
    
    
}


-(void)performTurn:(NSArray*)turn animate:(BOOL)animate { // ONLY PLAYBACK
    
    
    
    if (turn) {
        
        _actionHeap = [[NSMutableArray alloc]initWithCapacity:5];
        
        NSLog(@"Game.m : performActionSequence : starting action sequence");
        
        for (int i = 0; i < turn.count; i++){
            [_actionHeap addObject:turn[turn.count - (i + 1)]];
        }
        
        [self performAction:[_actionHeap lastObject] record:NO animate:animate];
        
        
    }
    
    else {
        NSLog(@"###error### trying to perform nil turn");
    }
    
    // GET MANAGER FOR TURN
    
    
    
    
}

-(BOOL)shouldPerformCurrentAction {
    
    if (_myTurn && [self canPerformCurrentAction]) {
        
        
        _actionHeap = [[NSMutableArray alloc]initWithCapacity:5];
        [_actionHeap addObject:_currentEventSequence];
        
        [self performAction:_currentEventSequence record:YES animate:YES];
        
        
        return 1;
        
    }
    
    return 0;
    
    
}

-(BOOL)canPerformCurrentAction {
    
    if (_currentEventSequence.GameEvents.count) {
        GameEvent *last = [_currentEventSequence.GameEvents lastObject];
        
        if (last.type != kEventSequence) {
            if (_currentEventSequence.totalCost <= _currentEventSequence.manager.ActionPoints) {
                return 1;
            }
        }
    }
    
    return 0;
    
    
}





-(void)enumerateEventHeapForAction:(GameSequence*)action record:(BOOL)shouldRecordSequence animate:(BOOL)animate{
    
    if (_eventHeap.count) {
        
        GameEvent* event = [_eventHeap lastObject];
        
        
        [self performEvent:event];
        
        if (animate) {
            
            
            [_gameScene animateEvent:event withCompletionBlock:^{
                
                [_eventHeap removeLastObject];
                
                [self enumerateEventHeapForAction:action record:shouldRecordSequence animate:animate];
                
                
            }];
            
            
        }
        
        else {
            
            [_eventHeap removeLastObject];
            
            [self enumerateEventHeapForAction:action record:shouldRecordSequence animate:animate];
            
        }
        
        
        
        
    }
    
    else { // AT END OF ACTION
        
        [self endAction:action record:shouldRecordSequence animate:animate];
        
    }
}

-(void)endAction:(GameSequence*)action record:(BOOL)shouldRecordSequence animate:(BOOL)animate{
    
    if (shouldRecordSequence){
        
        [_gameScene cleanUpUIForAction:action];
        
        if (shouldWin) {
            [_gameScene animateBigText:@"YOU WON !!" withCompletionBlock:^{
                [self endTurn];
            }];
            
        }
        else if (shouldLose){
            [_gameScene animateBigText:@"YOU LOST !!" withCompletionBlock:^{
                [self endTurn];
            }];
            
        }
        
        else if (action.type == kEventEndTurn) {
            
            //[self sendAction:action perform:YES];
            
            [self endTurn];
            
            
            
        }
        
        else { // END ACTION LOOK FOR MORE
            
            if (_actionHeap) {
                
                [_actionHeap removeObject:action];
                
                if (_actionHeap.count) {
                    
                    [self performAction:[_actionHeap lastObject] record:shouldRecordSequence animate:animate];
                    
                    return;
                }
                
                
            }
            
            if (animate) {
                
                
                [_gameScene finishActionsWithCompletionBlock:^{
                    
                    _animating = NO;
                    
                    //
                    
                    if (action.manager.teamSide == 1) {
                        [self endActionForEricWithManager:action.manager.opponent]; // new?
                    }
                    
                    [self saveTurnWithCompletionBlock:^{
                        
               
                        [self checkMyTurn];
                        
                    }];
                }];
            }
            
            else {
                _animating = NO;
                
                [self saveTurnWithCompletionBlock:^{
                    
                }];
                
            }
            
            
            
            
        }
        
        
        
    }
    
    else { // REPLAY
        
        if (_actionHeap) {
            
            [_actionHeap removeLastObject];
            
            if (_actionHeap.count) {
                [self performAction:[_actionHeap lastObject] record:shouldRecordSequence animate:animate];
                return;
            }
            
        }
        
        if (shouldWin) {
            NSLog(@"game.m : endActionForMAnager : ending game !!!");
            [_gameScene animateBigText:@"YOU WON !!" withCompletionBlock:^{}];
            if (_match.status != GKTurnBasedMatchStatusEnded) {
                [self endGameWithWinner:YES];
            }
            
        }
        else if (shouldLose){
            [_gameScene animateBigText:@"YOU LOST !!" withCompletionBlock:^{}];
            if (_match.status != GKTurnBasedMatchStatusEnded) {
                [self endGameWithWinner:NO];
            }
        }
        
        else {
            NSLog(@"completed action sequence");
            
            [_turnHeap removeLastObject];
            
            //            if (!_turnHeap.count) {
            //                [self fetchThisTurnActions];
            //            }
            
            if (animate) {
                
                [_gameScene finishActionsWithCompletionBlock:^{
                    [self enumerateTurnHeapAnimate:animate];
                }];
                
            }
            
            
            else {
                [self enumerateTurnHeapAnimate:animate];
            }
            
        }
        
        
    }
    
}

-(BOOL)rollAction:(GameSequence*)action {
    
    if(action.totalModifier == 0.0)
        return 1;
    
    action.roll = (arc4random()%100)/100.0;
    
    if (action.roll < action.totalSucess) {
        NSLog(@"%s : success! %f / %f", __func__, action.roll, action.totalSucess);
        return 1;
    }
    else {
        NSLog(@"%s : failure! %f / %f", __func__, action.roll, action.totalSucess);
        return 0;
    }
    
    
}

-(void)logEvent:(GameEvent*)event{
    
    if (event.playerPerformingAction) {
        NSLog(@">>%d %@ is %@ >> %d,%d to %d,%d", event.actionSlot, event.playerPerformingAction.name, event.nameForAction, event.startingLocation.x, event.startingLocation.y, event.location.x, event.location.y);
    }
    else if (event.startingLocation) {
        NSLog(@">>%d %@ for %@ from %d %d", event.actionSlot, event.nameForAction, event.manager.name, event.startingLocation.x, event.startingLocation.y);
    }
    else {
        NSLog(@">>%d %@ for %@", event.actionSlot, event.nameForAction, event.manager.name);
    }
    
}

-(id)previousObjectInArray:(NSArray*)array thisObject:(id)object {
    
    int index = [array indexOfObject:object];
    
    if (index == 0) {
        return nil;
    }
    
    return array[index-1];
    
}


-(BOOL)performEvent:(GameEvent*)event {
    
    // FIRST INHERIT WHO IS INVOLVED FROM PERSISTENT LOCATIONS
    
    [self getPlayerPointersForEvent:event];
    
    //event.manager.ActionPoints -= event.actionCost;
    
#pragma mark - CARD / SYSTEM EVENTS
    
    
    if (event.type == kEventStartTurn){
        
        //NSLog(@"performing start turn");
        // event.manager.ActionPoints = [self getActionPointsForManager:event.manager];
        
        
        //        [self assignBallIfPossible];
        //        [self updateActiveZone];
        
        //NSLog(@"%@ has %d AP",event.manager.name, event.manager.ActionPoints);
        

        
    }
    
    else if (event.type == kEventDraw || event.type == kEventStartTurnDraw) {
        
        for (Player* p in event.manager.players.inGame) {
            [p.moveDeck turnOverNextCard];
            [p.kickDeck turnOverNextCard];
            [p.challengeDeck turnOverNextCard];
            [p.specialDeck turnOverNextCard];
            [p.specialDeck turnOverNextCard];
        }
        
//        if (event.manager.deck.inHand.count < 7) {
//            
//            if (!event.manager.deck.theDeck.count) {
//                
//                NSLog(@"re-shuffle from graveyard");
//                
//                [event.manager.deck shuffleWithSeed:event.seed fromDeck:event.manager.deck.discarded];
//                event.manager.deck.discarded = @[];
//                
//                NSLog(@"shuffled new deck for %@, %d cards", event.manager.name, event.manager.deck.theDeck.count);
//            }
//            
//            
//            Card *newCard = [[event.manager deck] turnOverNextCard];
//            event.playerPerformingAction = newCard;
//            event.startingLocation = newCard.location;
//            
//        }
        
        //NSLog(@"Game.m : drawing card %@ for:%@", newCard.name, event.manager.name);
        
    }
    
    else if (event.type == kEventSetBallLocation) {
        
        if (_ball.enchantee) {
            [_ball.enchantee setBall:nil];
        }
        
        _ball.location = event.location;
        
        //NSLog(@"Game.m : performEvent : setting inital ball carrier");
        
        [[self playerAtLocation:event.location] setBall:_ball];
        
    }
    
    else if (event.type == kEventAddPlayer){
        
        Player *newPlayer = [event.manager.players.theDeck lastObject];
        
        if ([event.manager.players playCardFromDeck:newPlayer]){
            NSLog (@"putting player on field, shufflingcards");
            [newPlayer.moveDeck shuffleWithSeed:event.seed fromDeck:newPlayer.moveDeck.allCards];
            [newPlayer.kickDeck shuffleWithSeed:event.seed fromDeck:newPlayer.kickDeck.allCards];
            [newPlayer.challengeDeck shuffleWithSeed:event.seed fromDeck:newPlayer.challengeDeck.allCards];
            [newPlayer.specialDeck shuffleWithSeed:event.seed fromDeck:newPlayer.specialDeck.allCards];
        }
        
        event.playerPerformingAction = newPlayer;
        
        event.playerPerformingAction.location = [event.location copy];
        
        [_players setObject:[event.location copy] forKey:event.playerPerformingAction];
        
    }
    
    else if (event.type == kEventRemovePlayer) {
        
        //NSLog(@"**should discard player**");
        
        event.playerPerformingAction = [self playerAtLocation:event.location];
        
        Player *p = event.playerPerformingAction;
        
        //NSLog(@">> %d discarding player: %@", event.actionSlot, p.name);
        
        for (Card *e in p.enchantments) {
            [e discard];
        }
        
        p.enchantments = nil;
        
        [_players removeObjectForKey:p];
        
        
    }
    
    else if (event.type == kEventPlayCard) {
        //NSLog(@">> %d, Game.m Play card event!", event.actionSlot);
        if (![event.card.deck playCardFromHand:event.card]){
            NSLog(@"Game.m : failed to get card from hand, maybe already in play?");
        }
        
    }
    
    else if (event.type == kEventAddSpecial) {
        
        Player *enchantee = event.playerReceivingAction;
        
        if (!enchantee) {
            NSLog(@"somehow player dissapeared! enchant fail");
        }
        
        if (event.card.actionPointEarn) { // DISCARD IMMEDIATELY
            // NSLog(@"Game.m : enchant! boost + %d", enchantment.actionPointEarn);
//            event.manager.ActionPoints += enchantment.actionPointEarn;
//            [event.card.deck discardCardFromGame:enchantment];
//            
        }
        
        else { // CARD ENCHANTMENT
            //NSLog(@"Game.m : enchant player: %@", enchantee.name);
            [enchantee addEnchantment:event.card]; // PlayerPerformingAction is the enchantment, not the enchantee
        }
        
    }
    

    else if (event.type == kEventEndTurn){
        
        for (Player *p in event.manager.players.inGame) {
            for (Card* c in [p allCardsInHand]) {
                [c discard];
            }
            
        }
        //[self updateActiveZone];
        
        //NSLog(@"performing end turn event");
        [self purgeTemporaryEnchantments];
        
    }

    else if (event.type == kEventResetPlayers){
        
        // NSLog(@"resetting coin toss position");
        
        _ball.location = nil;
        _ball.enchantee = nil;
        
        
    }
    

    
    else if (event.type == kEventShuffleDeck) {
        
       // NSLog(@"shuffling %@'s deck", event.manager);
        
        [event.deck shuffleWithSeed:event.seed fromDeck:event.deck.allCards];
        
        // START TEST
        
        //        event.manager.deck.theDeck = event.manager.deck.allCards;
        //
        //        int seeds[7] = {2342, 234235, 123124, 6456, 12314, 5435435, 456456};
        //
        //        for (int i = 0; i < 7; i++) {
        //            [event.manager.deck shuffleWithSeed:seeds[i] fromDeck:event.manager.deck.theDeck];
        //
        //        }
        //
        //        for (int i = 6; i >= 0; i--) {
        //            [event.manager.deck revertToSeed:seeds[i] fromDeck:event.manager.deck.theDeck];
        //
        //        }
        //
        
        // END TEST
        
        
    }
    
    [self logEvent:event];
    
    
#pragma mark SUCCESSFUL SKILL EVENT
    
    if (event.parent.wasSuccessful) {
        
        if (event.type == kEventSequence ) {
            
            //NSLog(@"%d Game.m : Start Player Events", event.actionSlot);
            
            if (!_ball.enchantee) { // NO ONE HAS BALL, PICK UP IF THERE
                
                if ([_ball.location isEqual:event.location]) {
                    // NSLog(@"Take Posession");
                    [event.playerPerformingAction setBall:_ball];
                }
            }
            
            
        }
        
        else if (event.isRunningEvent) {
            
            // DRIBBLE
            
            if (event.playerPerformingAction.ball) { // HAVE BALL, BRING IT WITH ME
                _ball.location = [event.location copy];
            }
            
            // CHALLENGE
            
            if (event.type == kEventChallenge) {
                
                //NSLog(@">> %d Game.m : challengeAction : SUCCEEDED", event.actionSlot);
                
                event.playerPerformingAction.ball = _ball;
                
                // MOVE OPPONENT TO MY SQUARE
                
                event.playerReceivingAction.location = [event.startingLocation copy];
                [_players setObject:[event.startingLocation copy] forKey:event.playerReceivingAction];
                
            }
            
            else {
                //NSLog(@">> %d Game.m : run/dribble SUCCEEDED %ld %ld", event.actionSlot, (long)event.location.x, (long)event.location.y);
            }
            
            // RUN
            
            if (!_ball.enchantee) { // NO ONE HAS BALL, PICK UP IF THERE
                
                if ([_ball.location isEqual:event.location]) {
                    //NSLog(@"Game.m : performEvent : picking up ball");
                    [event.playerPerformingAction setBall:_ball];
                }
                
            }
            
            // UNIVERSAL
            
            
            
            
            event.playerPerformingAction.location = [event.location copy];
            [_players setObject:event.location forKey:event.playerPerformingAction];
            
            [self assignBallIfPossible];
            
        }
        
        else if (event.type == kEventKickPass){ // PASS
            //NSLog(@"pass!");
            [event.playerPerformingAction setBall:Nil];
            
            event.playerReceivingAction = [self playerAtLocation:event.location];
            
            Player *p = event.playerReceivingAction;
            [p setBall:_ball];
        }
        
        else if (event.type == kEventKickGoal){ // SHOOT
            //NSLog(@"shoot!");
            
            //for (int i = 0; i < 5; i++) {
            //NSLog(@"GOAL !!!!!!! %@ !!!!!", event.manager.name);
            //}
            
            if (event.manager.teamSide)
                [_ball setLocation:[BoardLocation pX:-1 Y:1]];
            else
                [_ball setLocation:[BoardLocation pX:BOARD_LENGTH Y:1]];
            
            if (!_score) {
                _score = [BoardLocation pX:0 Y:0];
            }
            
            if (event.manager.teamSide) _score.y += 1;
            else _score.x += 1;
            
            
            [_gameScene refreshScoreBoard];
            
            
        }
        
        
        
        return 1;
    }
    
#pragma mark FAILED SKILL EVENT
    
    else { // NOT SUCCESSFUL
        
        if (event.isRunningEvent) {
            
            if (event.type != kEventChallenge) {
                event.playerPerformingAction.location = [event.location copy];
                [_players setObject:event.location forKey:event.playerPerformingAction];
                //NSLog(@"moving to location %d %d", event.location.x, event.location.y);
            }
            else {
                NSLog(@"challenge fail !!");
            }
            
            //
            
            if (event.playerPerformingAction.ball) {
                
                [event.playerPerformingAction setBall:Nil];
                _ball.enchantee = Nil;
                
            }
            
            
        }
        
        else if (event.type == kEventKickGoal){ // FAILED SHOT
//            // NSLog(@"No GOAL :(   :(   :(   :(");
//            //ball go to location of goalie
//            if (event.manager.teamSide)
//                [_ball setLocation:[BoardLocation pX:0 Y:1]];
//            else
//                [_ball setLocation:[BoardLocation pX:BOARD_LENGTH-1 Y:1]];
//            
//            [self assignBallIfPossible];

            //[self endTurn];
        }
        
        else if (event.type == kEventKickPass){ // FAILED PASS
            [event.playerPerformingAction setBall:Nil];
            _ball.enchantee = Nil;
            _ball.location = [self passFail:event];
            
        }
        
        return 0;
        
    }
    
    
}


#pragma mark - META DATA

-(void)endActionForEricWithManager:(Manager*)m{
    NSLog(@"hi eric, this is: %@",m.name);
   // NSDictionary *players = [m playersClosestToBall];
   // NSLog(@"Players closest to ball:");
   // for(Player* p in players) {
   //     NSLog(@"name = %@", p.name);
   // }
}

-(void)processMetaDataForAction:(GameSequence*)action {
    
    action.manager.actionPointsSpent += action.totalCost;
    
    for (GameEvent *e in action.GameEvents) {
        
        Manager* m = e.manager;
        
        [self getPlayerPointersForEvent:e];
        
        // FIRST GENERAL
        
        
        switch (e.type) {
                
            case kEventStartTurn:
                break;
                
            case kEventPlayCard:
                m.cardsPlayed++;
                break;
                
            case kEventKickGoal:
                m.attemptedGoals++;
                break;
                
            case kEventChallenge:
                m.attemptedSteals++;
                break;
                
            case kEventKickPass:
                m.attemptedPasses++;
                break;
                
            case kEventDraw:
                m.cardsDrawn++;
                break;
                
            case kEventAddPlayer:
                m.playersDeployed++;
                break;
                
            default:
                break;
        }
        
        // NOW SUCCESSFUL
        
        if (action.wasSuccessful) {
            
            switch (e.type) {
                    
                case kEventKickGoal:
                    m.successfulGoals++;
                    break;
                    
                case kEventChallenge:
                    m.successfulSteals++;
                    break;
                    
                case kEventKickPass:
                    m.successfulPasses++;
                    break;
                    
                default:
                    break;
            }
            
        }
        
        // NOW FAILED
        
        
    }
    
    
    //NSLog(@"META FOR %@", [self metaDataForManager:action.manager]);
    
    
}


-(NSDictionary*)metaDataForManager:(Manager*)m{
    
    NSDictionary *meta = @{@"Team Name": m.name,
                           @"Cards Drawn": [NSNumber numberWithInt:m.cardsDrawn],
                           @"Cards Played": [NSNumber numberWithInt:m.cardsPlayed],
                           @"Players Deployed": [NSNumber numberWithInt:m.playersDeployed],
                           @"Action Points Earned": [NSNumber numberWithInt:m.actionPointsEarned],
                           @"Action Points Spent": [NSNumber numberWithInt:m.actionPointsSpent],
                           @"Attempted Goals": [NSNumber numberWithInt:m.attemptedGoals],
                           @"Successful Goals": [NSNumber numberWithInt:m.successfulGoals],
                           @"Attempted Passes": [NSNumber numberWithInt:m.attemptedPasses],
                           @"Successful Passes": [NSNumber numberWithInt:m.successfulPasses],
                           @"Attempted Steals": [NSNumber numberWithInt:m.attemptedSteals],
                           @"Successful Steals": [NSNumber numberWithInt:m.successfulSteals],
                           };
    
    return meta;
    
}

//-(void)showMetaData {
//    [_gcController showMetaDataForMatch:_match];
//}

#pragma mark - INTEROGATION CONVENIENCE

-(BoardLocation*)passFail:(GameEvent*)event {
    
    NSLog(@"calculate failed pass!");
    
    
    int randomX = event.location.x + ([event.deck randomForIndex:event.seed]%3 - 1);
    int randomY = event.location.y + ([event.deck randomForIndex:event.seed+1]%3 - 1);
    
    //    while ([[BoardLocation pX:randomX Y:randomY] isEqual:event.location]) {
    //       randomX = event.location.x + ([event.manager.deck randomForIndex:event.seed]%3 - 1);
    //       randomY = event.location.y + ([event.manager.deck randomForIndex:event.seed+1]%3 - 1);
    //    }
    
    randomX = MIN(MAX(0, randomX), BOARD_LENGTH-1);
    randomY = MIN(MAX(0, randomY), BOARD_WIDTH-1);
    
    return [BoardLocation pX:randomX Y:randomY];
    
}

-(NSSet*)temporaryEnchantments {
    NSMutableSet *temp = [NSMutableSet set];
    
    for (Player* player in _players.allKeys) {
        
        for (Card* e in player.enchantments) {
            if (e.isTemporary) {
                [temp addObject:e];
            }
        }
        
        
    }
    
    return temp;
    
}

-(void)purgeTemporaryEnchantments {
    
    for (Player* player in _players.allKeys) {
        
        NSMutableSet *rem;
        
        for (Card* e in player.enchantments) {
            if (e.isTemporary) {
                if (!rem ) {
                    rem = [NSMutableSet set];
                }
                [rem addObject:e];
                [e discard];
            }
        }
        
        for (Card *c in rem) {
            [player removeEnchantment:c];
        }
        
    }
    
}

//-(void)updateActiveZone {
//    
//    if (!_activeZone) {
//        _activeZone = [BoardLocation pX:(BOARD_LENGTH/2)-1 Y:(BOARD_LENGTH/2)+3];
//        
//    }
//    
//    if (_ball) {
//        
//        if (_ball.player) {
//            
//            if (_ball.player.manager.teamSide) {
//                _activeZone.x = _ball.player.location.x - 3;
//                _activeZone.y = _ball.player.location.x + 1;
//                NSLog(@"Game.m : updateActiveZone : player 1 has ball");
//            }
//            else {
//                
//                _activeZone.x = _ball.player.location.x - 1;
//                _activeZone.y = _ball.player.location.x + 3;
//                NSLog(@"Game.m : updateActiveZone : player 0 has ball");
//            }
//            
//            _zoneActive = YES;
//            
//        }
//        
//        else {
//            _zoneActive = NO;
//        }
//        
//        
//    }
//    
//    if (_activeZone.x <= 0) {
//        _activeZone.x = 0;
//        _activeZone.y = 4;
//    }
//    
//    else if (_activeZone.y >= BOARD_LENGTH) {
//        _activeZone.y = BOARD_LENGTH;
//        _activeZone.x = BOARD_LENGTH - 4;
//    }
//    
//    NSLog(@"zone is : %d %d", _activeZone.x, _activeZone.y);
//    
//}

-(BOOL)requireEmptyLocation:(BoardLocation*)location {
    return ![self requirePlayerAtLocation:location];
}

-(BOOL)requirePlayerAtLocation:(BoardLocation*)location {
    if ([self playerAtLocation:location]) {
        return 1;
    }
    return 0;
}

-(Player*)playerAtLocation:(BoardLocation*)location {
    for (Player* inPlay in [_players allKeys]) {
        if ([inPlay.location isEqual:location]) {
            return inPlay;
        }
    }
    return Nil;
}


-(BOOL)requirePossesion:(Manager*)m {
    return m.hasPossesion;
}

-(BOOL)requireLastActionSucessful {
    
    GameSequence *lastAction = [self lastAction];
    if (lastAction.wasSuccessful) {
        return YES;
    }
    
    return NO;
}

-(BOOL)requireLastEventType:(EventType)type {
    GameSequence *lastAction = [self lastAction];
    if (lastAction.type == type) {
        return YES;
    }
    
    return NO;
}

-(GameSequence*)lastAction {
    return [_thisTurnActions lastObject];
    return nil;
}

-(Player*)lastActionPlayer {
    
    GameSequence *lastAction = [self lastAction];
    
    if (lastAction.type != kEventAddSpecial) {
        
        if ([lastAction isRunningAction]) {
            return lastAction.playerPerformingAction;
        }
        else if (lastAction.type == kEventKickPass){
            return lastAction.playerReceivingAction;
        }
        
    }
    
    return Nil;
}

-(GameEvent*)firstEvent {
    
    return _currentEventSequence.GameEvents[0];
    
}

-(void)assignBallIfPossible {
    
    for (Player *p in [_players allKeys]){
        if ([p.location isEqual:_ball.location]) {
            [p setBall:_ball];
        }
    }

}

//-(BOOL)canDraw {
//    if (_me.ActionPoints >= 1) {
//        if (_me.deck.theDeck.count && _me.deck.inHand.count < 7) {
//            return 1;
//        }
//    }
//    return 0;
//}

//-(BOOL)requestDrawAction {
//    
//    if (_myTurn) {
//        
//        if ([self canDraw]) {
//            
//            _currentEventSequence = [GameSequence action];
//            NSLog(@"Game.m : requestDrawAction");
//            
//            GameEvent* draw = [self addDrawEventToAction:_currentEventSequence forManager:_me];
//            
//            if (draw) {
//                
//                draw.actionCost = 1;
//                
//                if ([self shouldPerformCurrentAction]){
//                    return 1;
//                }
//            }
//            
//        }
//        
//        
//        
//    }
//    
//    
//    return 0;
//}

-(BOOL)willHaveBallForCurrentAction {
    for (GameEvent *e in _currentEventSequence.GameEvents) { // Will have successfully picked up or challenged
        if ([e.location isEqual:_ball.location]) {
            // NSLog(@"found event with ball is : %d : %d current", e.actionSlot, event.actionSlot);
            // return e.actionSlot < event.actionSlot;
            return YES;
            
        }
    }
    return 0;
}

-(BOOL)willHaveBallDuringEvent:(GameEvent*)event {
    
    for (GameEvent *e in event.parent.GameEvents) { // Will have successfully picked up or challenged
        if ([e.location isEqual:_ball.location]) {
            NSLog(@"found event with ball is : %d : %d current", e.actionSlot, event.actionSlot);
            return e.actionSlot < event.actionSlot;
            
        }
    }
    
    return 0;
    
}

-(BOOL)boostAction {
    
    if (_currentEventSequence) {
        
        if ([self canPerformCurrentAction]) {
            
            if (_currentEventSequence.boost < 5) {
                
                _currentEventSequence.boost++;
                
            }
            
            if (![self canPerformCurrentAction]) {
                _currentEventSequence.boost--;
                return 0;
            }
            
            return 1;
            
            // NSLog(@"Game.m : boostAction :mod %f: success :%f", event.parent.totalModifier, event.parent.totalSucess);
            
        }
        
    }
    return 0;
    
}

//-(int)getActionPointsForManager:(Manager*)m {
//    
//    int ap = 0;
//    for (Card* c in m.deck.inGame) {
//        ap += c.actionPointEarn;
//    }
//    
//    return ap;
//    
//}


-(Abilities*)playerAbilitiesWithMod:(Player*)player {
    
    Abilities *temp = [player.abilities copy];
    
    for (Card *e in player.enchantments) {
        [temp add:e.abilities];
    }
    
//    for (Card *c in player.manager.cardsInGame) {
//        if ([self isAdjacent:c.location to:player.location]) {
//            [temp add:c.nearTeamModifiers];
//            
//            //            for (Card *e in c.enchantments) {
//            //                [temp add:e.nearTeamModifiers];
//            //            }
//            
//        }
//        [temp add:c.teamModifiers];
//        
//        //        for (Card *e in c.enchantments) {
//        //            [temp add:e.teamModifiers];
//        //        }
//        
//    }
//    
//    Manager *op = [self opponentForManager:player.manager];
//    
//    for (Card *c in op.cardsInGame) {
//        if ([self isAdjacent:c.location to:player.location]) {
//            [temp add:c.nearOpponentModifiers];
//        }
//        [temp add:c.opponentModifiers];
//    }
    
    return temp;
    
}

-(int)isAdjacent:(BoardLocation*)a to:(BoardLocation*)b {
    if ([a isEqual:b]) {
        return -1;
    }
    else if (a.x == b.x) { // SAME ROW
        if (abs(a.y - b.y) == 1) { // Column neighbor
            return 1;
        }
    }
    else if (a.y == b.y) { // SAME COLUMN
        if (abs(a.x - b.x) == 1) { // ROW NEIGHBOR
            return 1;
        }
    }
    return 0;
}

-(float)checkCardForModifiers:(Card*)card {
    float modifier = 0.;
    return modifier;
}


-(void)setCurrentManagerFromMatch {
    
    NSString *player = _match.currentParticipant.playerID;
    
    if ([[GKLocalPlayer localPlayer].playerID isEqualToString:player]) {
        
        NSLog(@"Game.m : current Manager is : %@", _me.name);
        _scoreBoardManager =  _me;
    }
    else {
        
        NSLog(@"Game.m : current Manager is : %@", _opponent.name);
        _scoreBoardManager = _opponent;
    }
    
    
}

-(Manager*)managerForTeamSide:(int)teamSide{
    
    if (_me.teamSide == teamSide) {
        return _me;
    }
    return _opponent;
    
}

-(Manager*)opponentForManager:(Manager*)m {
    Manager *op;
    
    if ([_opponent isEqual:m]) {
        op = _me;
    }
    else {
        op = _opponent;
    }
    return op;
}

-(NSString*)myId {
    return [GKLocalPlayer localPlayer].playerID;
}

-(NSString*)opponentID {
    
    for (GKPlayer *p in _match.participants) {
        if (![p.playerID isEqualToString:[self myId]]) {
            if (p.playerID) {
                return p.playerID;
            }
            else return NEWPLAYER;
        }
    }
    
    return NEWPLAYER;
    
}

-(int)actionCountForArray:(NSArray*)array {
    int actions = 0;
    for (NSArray* turn in array) {
        actions += turn.count;
    }
    return actions;
}

-(int)totalGameSequences {
    int actions = [self actionCountForArray:_history];
    actions += _thisTurnActions.count;
    return actions;
}

-(NSArray*)allButLastTurn {
    NSMutableArray* all = [_history mutableCopy];
    [all removeLastObject];
    return all;
}

#pragma mark - LOCATION INTERROGATION

-(CGPoint) indexPointFromScreen:(CGPoint)point{
    return CGPointMake((int)point.x/TILE_WIDTH, (int)point.y/TILE_HEIGHT);
}
-(BoardLocation*) indexForIndex:(CGPoint)indexPoint{
    return [BoardLocation pX:(int)indexPoint.x Y:(int)indexPoint.y];
}
-(BoardLocation*)indexFromScreen:(CGPoint)point{
    int xIndex = point.x/TILE_WIDTH;
    int yIndex = point.y/TILE_HEIGHT;
    return [BoardLocation pX:xIndex Y:yIndex];
}
-(NSDictionary*)IndexesAndIntersectionsFromPoint:(CGPoint)start To:(CGPoint)end{
    
    float width = TILE_WIDTH;
    float height = TILE_HEIGHT;
    
    NSMutableSet *intersections = [[NSMutableSet alloc] init];
    NSMutableSet *result = [[NSMutableSet alloc] init];
    CGFloat dx = end.x - start.x;
    CGFloat dy = end.y - start.y;
    CGFloat slope = (end.y - start.y) / (end.x - start.x);
    CGPoint here = CGPointMake((int)start.x/width, (int)start.y/height);
    CGPoint there = CGPointMake((int)end.x/width, (int)end.y/height);
    
    // if only one cell is selected, return
    if((int)here.x == (int)there.x && (int)here.y == (int)there.y){
        [result addObject:[self indexForIndex:here] ];
        return @{@"indexes":result};
    }
    // vertical line
    if((int)there.x == (int)here.x){
        //add starting and ending cells
        [result addObject:[self indexForIndex:here] ];
        [result addObject:[self indexForIndex:there] ];
        int inc = (there.y > here.y)*2-1;
        int i = here.y;
        while(i != (int)there.y){
            [result addObject:[self indexForIndex:CGPointMake(here.x, i)] ];
            i+=inc;
        }
        return @{@"indexes":result};
    }
    // horizontal line
    else if((int)there.y == (int)here.y){
        //add starting and ending cells
        [result addObject:[self indexForIndex:here] ];
        [result addObject:[self indexForIndex:there] ];
        int i = here.x;
        int inc = (there.x > here.x)*2-1;
        while(i != (int)there.x){
            [result addObject:[self indexForIndex:CGPointMake(i, here.y)] ];
            i+=inc;
        }
        return @{@"indexes":result};
    }
    //diagonal line
    else {
        //CGFloat halfCell = TILE_SIZE/2.0;
        CGFloat firstX = start.x-here.x*width;
        CGFloat firstY = start.y-here.y*width;
        CGPoint firstXIntersect, firstYIntersect;
        if(dy > 0)
            firstXIntersect = CGPointMake(start.x+(width-firstY)/slope,start.y+(width-firstY));
        else
            firstXIntersect = CGPointMake(start.x-firstY/slope,start.y-firstY);
        if(dx > 0)
            firstYIntersect = CGPointMake(start.x+(width-firstX),start.y+(height-firstX)*slope);
        else
            firstYIntersect = CGPointMake(start.x-firstX,start.y-firstX*slope);
        
        // X intersects
        if(dy>0){
            int i = 0;
            while(firstXIntersect.y + height*i < end.y){
                CGPoint next = CGPointMake(firstXIntersect.x + width/slope*i, firstXIntersect.y +height*i);
                [intersections addObject:[NSValue valueWithCGPoint:next]];
                [result addObject:[self indexFromScreen:CGPointMake(next.x, next.y+height*.5)] ];
                [result addObject:[self indexFromScreen:CGPointMake(next.x, next.y-height*.5)] ];
                i++;
            }
        }
        else{
            int i = 0;
            while(firstXIntersect.y - height*i > end.y){
                CGPoint next = CGPointMake(firstXIntersect.x - width/slope*i, firstXIntersect.y - height*i);
                [intersections addObject:[NSValue valueWithCGPoint:next]];
                [result addObject:[self indexFromScreen:CGPointMake(next.x, next.y+height*.5)] ];
                [result addObject:[self indexFromScreen:CGPointMake(next.x, next.y-height*.5)] ];
                i++;
            }
        }
        // Y intersects
        if(dx > 0){
            int i = 0;
            while(firstYIntersect.x + width*i < end.x){
                CGPoint next = CGPointMake(firstYIntersect.x + width*i, firstYIntersect.y + height*slope*i);
                [intersections addObject:[NSValue valueWithCGPoint:next]];
                [result addObject:[self indexFromScreen:CGPointMake(next.x+width*.5, next.y)] ];
                [result addObject:[self indexFromScreen:CGPointMake(next.x-width*.5, next.y)] ];
                i++;
            }
        }
        else{
            int i = 0;
            while(firstYIntersect.x - width*i > end.x){
                CGPoint next = CGPointMake(firstYIntersect.x - width*i, firstYIntersect.y - height*slope*i);
                [intersections addObject:[NSValue valueWithCGPoint:next]];
                [result addObject:[self indexFromScreen:CGPointMake(next.x+width*.5, next.y)] ];
                [result addObject:[self indexFromScreen:CGPointMake(next.x-width*.5, next.y)] ];
                i++;
            }
        }
        return @{@"indexes":result,@"intersections":intersections};
    }
}

-(NSSet*)digitalDifferentialAnalysisFrom:(BoardLocation*) here To:(BoardLocation*)there{
    float width = TILE_WIDTH;
    float height = TILE_HEIGHT;
    
    CGPoint start = CGPointMake(here.x*width + width*.5, here.y*height+height/2.0);
    CGPoint end = CGPointMake(there.x*width+width/2.0, there.y*height+height/2.0);
    return [[self IndexesAndIntersectionsFromPoint:start To:end] objectForKey:@"indexes"];
}

//-(float)checkLocationForDribbleModifiers:(BoardLocation*)location forTeam:(Manager*)manager{
//    float modifier = 0.;
//    
//    if (location) {
//        for (Card* card in manager.deck.inGame) {
//            if ([self isAdjacent:card.location to:location] == -1) {
//                modifier = -0.2;
//            }
//            else if ([self isAdjacent:card.location to:location] == 1){
//                modifier = -0.1;
//            }
//        }
//    }
//    //    // FORCE FIRST DRIBBLE TO 0
//    //    if ([location isEqual:_currentEventSequence.playerPerformingAction.location]) {
//    //        modifier = 0.;
//    //    }
//    
//    return modifier;
//}

//-(float)checkLocationForPassModifiers:(BoardLocation*)location forTeam:(Manager*)manager{
//    NSInteger playersInTheWay = 0.;
//    NSSet *obstacles = [self digitalDifferentialAnalysisFrom:_currentEventSequence.playerPerformingAction.location To:location];
//    NSMutableArray *verifiedObstacles = [NSMutableArray array];
//    for (Card* card in _opponent.deck.inGame){
//        if([obstacles containsObject:card.location]){
//            playersInTheWay++;
//            [verifiedObstacles addObject:[BoardLocation pX:card.location.x Y:card.location.y]];
//        }
//    }
//    //    [_gameScene setTilesToAlert:verifiedObstacles];
//    // NSLog(@"Game.m : checkLocationForPassModifiers : # players to pass through:%d",playersInTheWay);
//    //    for (Card* card in manager.deck.inGame) {
//    //        if ([self isAdjacent:card.location to:location] == -1) {
//    //            modifier = -0.2;
//    //        }
//    //        else if ([self isAdjacent:card.location to:location] == 1){
//    //            modifier = -0.1;
//    //        }
//    //    }
//    float obstacleMod = -.1*playersInTheWay;
//    float threatMod = [self checkLocationForDribbleModifiers:_currentEventSequence.playerPerformingAction.location forTeam:manager];
//    float xMod = -.1*(abs(_currentEventSequence.playerPerformingAction.location.x - location.x));
//    float yMod = -.1*(abs(_currentEventSequence.playerPerformingAction.location.y - location.y));
//    NSLog(@"obst: %1f, threat: %1f, x:%1f, y:%1f", obstacleMod,threatMod,xMod,yMod);
//    return obstacleMod + threatMod + xMod + yMod;
//    
//}

//-(float)checkLocationForShootModifiers:(BoardLocation*)location forTeam:(Manager*)manager{
//    
//    return [self checkLocationForPassModifiers:location forTeam:manager];
//    
//    //    float obstacleMod = -.1*playersInTheWay;
//    //    float threatMod = [self checkLocationForDribbleModifiers:_currentEventSequence.playerPerformingAction.location forTeam:manager];
//    //    float xMod = -.1*(abs(_currentEventSequence.playerPerformingAction.location.x - location.x));
//    //    float yMod = -.1*(abs(_currentEventSequence.playerPerformingAction.location.y - location.y));
//    //    NSLog(@"obst: %1f, threat: %1f, x:%1f, y:%1f", obstacleMod,threatMod,xMod,yMod);
//    //    return threatMod + xMod + yMod;
//    
//}
//
//-(float)checkLocationForChallengeModifiers:(BoardLocation*)location forTeam:(Manager*)manager{
//    float modifier = 0.;
//    
//    modifier -= [[self playerAtLocation:location] abilities].handling;
//    
//    for (Card* card in manager.opponent.deck.inGame) {
//        if ([self isAdjacent:card.location to:location]) {
//            if (![card isEqual:_currentEventSequence.playerPerformingAction]) {
//                modifier += .1;
//            }
//            
//        }
//    }
//    
//    return modifier;
//}


#pragma mark - ARCHIVING

-(void)appendMatchData:(NSData*)data {
    
}

- (void)restoreGameWithData:(NSData*)comp {
    
    NSLog(@"compressed size: %d", comp.length);
    NSData *data = [comp gzipInflate];
    
    //NSData *data = comp;
    NSLog(@"uncompressed size: %d", data.length);
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    _matchInfo = [[unarchiver decodeObjectForKey:@"matchInfo"] mutableCopy];
    
    [_matchInfo setObject:[NSNumber numberWithInt:_history.count] forKey:@"turns"];
    
    _rtmatchid = [[_matchInfo objectForKey:@"rtmatchid"]unsignedIntegerValue];
    //BOARD_LENGTH = [[_matchInfo objectForKey:@"boardLength"]intValue];
    
    NSLog(@"(* (* (* unpack rt id %lu *) *) *)", (unsigned long)_rtmatchid);
    
    [self checkRTConnection];
    
    for (GKTurnBasedParticipant *p in _match.participants) {
        if (p.playerID) {
            
            if ([p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                _me = [unarchiver decodeObjectForKey:[GKLocalPlayer localPlayer].playerID];
            }
            
            else {
                _opponent = [unarchiver decodeObjectForKey:p.playerID];
            }
        }
        
    }
    
    if (!_opponent) {
        _opponent = [unarchiver decodeObjectForKey:NEWPLAYER];
        
    }
    
    else if (!_me) {
        _me = [unarchiver decodeObjectForKey:NEWPLAYER];
    }
    
    _opponent.opponent = _me;
    _me.opponent = _opponent;
    
    [self loadActionsFromUnarchiver:unarchiver];
    
    
    
}

-(void)loadActionsFromUnarchiver:(NSKeyedUnarchiver*)unarchiver {
    
    _history = [[unarchiver decodeObjectForKey:@"history"] mutableCopy];
    _thisTurnActions = [[unarchiver decodeObjectForKey:@"thisTurnActions"] mutableCopy];
    
    for (NSArray* turn in _history) {
        for (GameSequence *action in turn) {
            [self setUpPointersForActionArray:action];
        }
    }
    for (GameSequence *action in _thisTurnActions) {
        [self setUpPointersForActionArray:action];
    }
    
    if (!_thisTurnActions) {
        _thisTurnActions = [NSMutableArray array];
    }
    
}

-(void)setUpPointersForActionArray:(GameSequence*)action{
    
    for (int i =0; i<action.GameEvents.count; i++) {
        GameEvent *e = action.GameEvents[i];
        e.parent = action;
        e.manager = [self managerForTeamSide:e.teamSide];
    }
    
    
}

-(void)saveTurnWithCompletionBlock:(void (^)())block {
    
    [_match saveCurrentTurnWithMatchData:[self saveGameToData] completionHandler:^(NSError *error){
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSLog(@"**** FINISH SAVING GAME STATE ****");
        [self logCurrentGameData];
        
        [self sendRTPacketWithType:RTMessageCheckTurn point:nil];
        
        block();
        
    }];
    
}

- (NSData*)saveGameToData {
    
    NSMutableData* data = [[NSMutableData alloc] init];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    for (GKTurnBasedParticipant *p in _match.participants) {
        
        
        if ([p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            [archiver encodeObject:_me forKey:[GKLocalPlayer localPlayer].playerID];
            [_matchInfo setObject:[self metaDataForManager:_me] forKey:[GKLocalPlayer localPlayer].playerID];
            //NSLog(@"archiving %@ me to: %@", key, [NSString stringWithFormat:@"%@%@",key,[GKLocalPlayer localPlayer].playerID]);
        }
        
        else {
            if (p.playerID) {
                [_matchInfo setObject:[self metaDataForManager:_opponent] forKey:p.playerID];
                [_matchInfo removeObjectForKey:NEWPLAYER];
                
                [archiver encodeObject:_opponent forKey:p.playerID];
                //  NSLog(@"archiving %@ op to: %@", key, [NSString stringWithFormat:@"%@%@",key,p.playerID]);
            }
            else {
                [_matchInfo setObject:[self metaDataForManager:_opponent] forKey:NEWPLAYER];
                [archiver encodeObject:_opponent forKey:NEWPLAYER];
                //NSLog(@"archiving %@ op to: %@", key, [NSString stringWithFormat:@"%@%@",key,NEWPLAYER]);
            }
            
        }
        
    }
    
    NSLog(@"------ SAVING . . .");
    [self logCurrentGameData];
    
    
    [archiver encodeObject:_history forKey:@"history"];
    [archiver encodeObject:_thisTurnActions forKey:@"thisTurnActions"];
    
    
    
    // MATCH DATA
    
    [_matchInfo setObject:[NSNumber numberWithInt:_history.count] forKey:@"turns"];
    
    [archiver encodeObject:_matchInfo forKey:@"matchInfo"];
    
    
    
    [archiver finishEncoding];
    
    NSLog(@"match data size: %d", data.length);
    
    //return data;
    
    return [data gzipDeflate];
    
}

-(void)logCurrentGameData {
    NSLog(@"**--**-- CURRENT GAME DATA --**--**");
    NSLog(@"history is %d turns", _history.count);
    NSLog(@"this turn has %d actions", _thisTurnActions.count);
    NSLog(@"**** TOTAL ACTIONS: %d EVENTS:%d ****", [self totalGameSequences], [self totalEvents]);
    NSString *realtime = @"INACTIVE";
    
    if (rtIsActive) {
        realtime = @"** ACTIVE **";
    }
    //NSLog(@"REAL-TIME IS %@", realtime);
    
    
}

-(BOOL)shouldEndTurn {
    if (_myTurn) {
        self.myTurn = NO;
        [self performAction:[self endTurnAction] record:YES animate:YES];
        return 1;
    }
    return 0;
}



-(NSArray*)copyActionsFrom:(NSArray*)src {
    
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:10];
    
    for (GameSequence* a in src) {
        
        [tmp addObject:a];
        
    }
    
    return tmp;
    
}

-(void)prepEndTurn {
    
    [_matchInfo setObject:_opponent.name forKey:@"current player"];
    
    [_history addObject:[_thisTurnActions copy]];
    
    _thisTurnActions = Nil;
    
}

-(void)endTurn {
    
    _animating = NO;
    
    [self prepEndTurn];
    
    NSUInteger currentIndex = [_match.participants
                               indexOfObject:_match.currentParticipant];
    
    GKTurnBasedParticipant *nextParticipant;
    
    nextParticipant = [_match.participants objectAtIndex:
                       ((currentIndex + 1) % [_match.participants count ])];
    
    [_match endTurnWithNextParticipants:@[nextParticipant] turnTimeout:GKTurnTimeoutNone matchData:[self saveGameToData] completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSLog(@"Game.m : endTurn : ENDING TURN: NEXT IS: %@", nextParticipant.playerID);
        NSLog(@"**** ACTIONS: %d EVENTS:%d ****", [self totalGameSequences], [self totalEvents]);
        
        _myTurn = NO;
        [self setCurrentManagerFromMatch];
        
        [_gameScene refreshScoreBoard];
        
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self sendRTPacketWithType:RTMessageCheckTurn point:nil];
        });
        
    }];
    
}




-(void)endGame{
    
    
    // CHECK VICTORY
    [self prepEndTurn];
    
    
    BOOL victory = NO;
    
    if (_me.teamSide) {
        if (_score.y > _score.x) {
            victory = YES;
        }
    }
    else {
        if (_score.x > _score.y) {
            victory = YES;
        }
    }
    
    
    [self endGameWithWinner:victory];
    
    
}

-(void)endGameWithWinner:(BOOL)victory {
    
    
    NSLog(@"game.m : endGame : victory %d", victory);
    
    // DO GAME CENTER SHIT
    
    NSString *opID;
    GKScore *opScore;
    
    for (GKTurnBasedParticipant *p in _match.participants) {
        if (![p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID ]) { // Opponent
            opID = p.playerID;
            
            opScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"nsfwLeaders" forPlayer:opID];
            
            if (victory) {
                p.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
            else {
                p.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            
        }
        else { // me
            if (victory) {
                p.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            else {
                p.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
            
        }
    }
    
    GKScore *meScore = [[GKScore alloc] initWithLeaderboardIdentifier:@"nsfwLeaders"];
    
    
    if (_me.teamSide) {
        [meScore setValue:_score.y];
        [opScore setValue:_score.x];
    }
    else {
        [meScore setValue:_score.x];
        [opScore setValue:_score.y];
    }
    
    if (opID) {
        NSLog(@"game.m : endGame : ending without valid Opponent!");
        [_match endMatchInTurnWithMatchData:[self saveGameToData] scores:@[meScore, opScore] achievements:Nil completionHandler:^(NSError *error){
            [_match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error){
                _myTurn = NO;
            }];
            
        }];
    }
    
    else {
        NSLog(@"game.m : endGame : ending with valid Opponent!");
        [_match endMatchInTurnWithMatchData:[self saveGameToData] scores:@[meScore] achievements:Nil completionHandler:^(NSError *error){
            _myTurn = NO;
        }];
    }
    
#warning lame o work around for game center
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //    SKViewController *rootViewController = (SKViewController*)window.rootViewController;
    //    [rootViewController performSelector:@selector(showGK) withObject:Nil afterDelay:2.0];
    
}

-(void)setMyTurn:(BOOL)myTurn {
    _myTurn = myTurn;
    [_gameScene setMyTurn:myTurn];
}


-(void)getSortedPlayerNames {
    
    NSMutableArray *ids = [NSMutableArray array];
    
    for (GKPlayer *p in _match.participants) {
        if (p.playerID) {
            [ids addObject:p.playerID];
        }
    }
    
    [GKPlayer loadPlayersForIdentifiers:ids withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil)
        {
            NSLog(@"Error receiving player data");
            // Handle the error.
        }
        if (players != nil)
        {
            
            NSString *myName;
            NSString *opponentName;
            
            for (GKPlayer *p in players) {
                
                if ([p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                    
                    myName = p.displayName;
                    
                }
            }
            
            for (GKPlayer *p in players) {
                
                if (![p.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
                    
                    opponentName = p.displayName;
                    
                }
            }
            
            if (_me) {
                if (!opponentName) opponentName = NEWPLAYER;
                if (_me.teamSide == 0) {
                    _playerNames = @[myName, opponentName];
                }
                else {
                    _playerNames = @[opponentName, myName];
                }
                
            }
            
            NSLog(@"player names %@", _playerNames);
            
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    [_gameScene setWaiting:NO];
    
    if (buttonIndex) {
        
        [self replayGame:YES];
        
    }
    
    else {
        
        [self replayGame:NO];
        
        
    }
    
}


-(void)cheatGetPoints {
    if (CHEATS) {
        _me.ActionPoints += 3;
        [_gameScene refreshActionPoints];
    }
}

@end

