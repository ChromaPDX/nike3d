//
//  Actions.m
//  ChromaNSFW
//
//  Created by Robby Kraft on 9/30/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import "ModelHeaders.h"


@implementation GameSequence

+(instancetype) action {
    
    GameSequence *newAction = [[GameSequence alloc]init];
    newAction.GameEvents = [NSMutableArray arrayWithCapacity:12];
    
    return newAction;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _wasSuccessful = [decoder decodeBoolForKey:@"wasSuccessful"];
    _boost = [decoder decodeIntForKey:@"boost"];
    _tag = [decoder decodeIntForKey:@"tag"];
    
    _GameEvents = [[decoder decodeObjectForKey:@"events"] mutableCopy];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_tag forKey:@"tag"];
    [encoder encodeInt:_boost forKey:@"boost"];
    [encoder encodeBool:_wasSuccessful forKey:@"wasSuccessful"];
    
    [encoder encodeObject:_GameEvents forKey:@"events"];
    
}

-(float)totalModifier {
    
    float totalModifier = 0.;
    
    if (self.isRunningAction) {
        
        for (int i = 0; i < self.GameEvents.count; i++) {
            GameEvent *e = self.GameEvents[i];
            if(e.totalModifier != 0){
                //if(e.success < e.totalModifier) return 0; // modifiers within one event bring chance of success below 0
                totalModifier += e.totalModifier; // cumulatively reduce chance of success
            }
            
            
        }
        
    }
    
    else {
        totalModifier = [self.GameEvents.lastObject totalModifier];
    }
    
    _totalModifier = totalModifier;

    return _totalModifier;
    
}

-(float)totalSucess {
    
    float totalSuccess = 1.;
    
    if (self.isRunningAction) {
        
        
        for (int i = 0; i < self.GameEvents.count; i++) {
            GameEvent *e = self.GameEvents[i];
            if(e.totalModifier != 0){
                //if(e.success < e.totalModifier) return 0; // modifiers within one event bring chance of success below 0
                totalSuccess *= e.success; // cumulatively reduce chance of success
            }
            
            
        }
        
    }
    
    else {
        totalSuccess = [self.GameEvents.lastObject success];
    }
    
   
    totalSuccess += (_boost * .1);
    
    if (totalSuccess > 1.) {
        totalSuccess = 1.;
    }
    
    else if (totalSuccess < 0.){
        totalSuccess = 0;
    }
    
    _totalSucess = totalSuccess;
    
    return totalSuccess;
}

-(int)totalCost {
    
    int totalCost = 0;
    
    if (self.isRunningAction) {
        
        for (int i = 0; i < self.GameEvents.count; i++) {
            GameEvent *e = self.GameEvents[i];
            totalCost += e.actionCost;
        }
        
    }
    
    else {
        totalCost = [self.GameEvents.lastObject actionCost];
    }
    
    totalCost += _boost;
    
    _totalCost = totalCost;
    
    return _totalCost;
    
}

-(Player*)playerPerformingAction {
    if (_GameEvents.count) {
        
        if (![_GameEvents[0] playerPerformingAction]) {
            NSLog(@"action.m could not infer player from events");
        }
        return [_GameEvents[0] playerPerformingAction];
        
    }
    else {
        NSLog(@"no player yet on this aciton");
        return nil;
    }
}

-(Card*)playerReceivingAction {
    if (_GameEvents.count) {
        
        if (![_GameEvents.lastObject playerPerformingAction]) {
            NSLog(@"action.m could not infer player from events");
        }
        return [_GameEvents.lastObject playerPerformingAction];
    }
    else {
        NSLog(@"no player yet on this aciton");
        return nil;
    }
}

-(BOOL)isRunningAction {
    return [[_GameEvents lastObject] isRunningEvent];
}

-(EventType)type {
    
return [(GameEvent*)[_GameEvents lastObject] type];
    
}

-(NSString*)nameForAction{

    return [[_GameEvents lastObject] nameForAction];
    
}

-(Manager*)manager {
    
    return [[_GameEvents lastObject] manager];
    
}

@end

@implementation GameEvent

+(instancetype) eventForAction:(GameSequence*)action{
    GameEvent *newEvent = [[GameEvent alloc]init];
    newEvent.parent = action;
    newEvent.seed = [newEvent newSeed];
    
    return newEvent;
}

-(BOOL)isRunningEvent {
    
    if (_type == kEventMove || _type == kEventChallenge ) {
        return 1;
    }
    
    else return 0;
}

-(BoardLocation*)scatterLocation {
    
    NSLog(@"calculate failed pass!");
    
    
    int randomX = _location.x + ([_deck randomForIndex:_seed]%3 - 1);
    int randomY = _location.y + ([_deck randomForIndex:_seed+1]%3 - 1);
    
    randomX = MIN(MAX(0, randomX), BOARD_LENGTH-1);
    randomY = MIN(MAX(0, randomY), BOARD_WIDTH-1);
    
    return [BoardLocation pX:randomX Y:randomY];
    
}

//-(BOOL)isDeployEvent {
//    
//    if (_type == kDeployEvent || _type == kSpawnPlayerEvent || _type == kSpawnKeeperEvent) {
//        return 1;
//    }
//    
//    else return 0;
//}



-(NSString*)nameForAction{
    
    EventType actionType = [self type];
    
    switch (actionType) {
            case kNullAction: return @"NULL";
            // Player Actions
            case kEventAddPlayer: return @"ADD PLAYER";
            case kEventRemovePlayer: return @"REMOVE PLAYER";

            // Field Actions
            case kEventSetBallLocation: return @"MOVE BALL";
            case kEventResetPlayers: return @"RESET PLAYERS";
            case kEventGoalKick: return @"GOALIE KICK";
            
            // Cards / Card Actions
            case kEventDraw: return @"DRAW A CARD";
            case kEventPlayCard: return @"PLAY A CARD";
            case kEventKickPass: return @"PASSES !";
            case kEventKickGoal: return @"SHOOTS !!";
            case kEventChallenge: return @"CHALLENGING !";
            case kEventMove: return @"MOVING";
            case kEventAddSpecial: return @"SPECIAL CARD";
            case kEventRemoveSpecial: return @"REMOVE SPECIAL";
            
            // Deck
            case kEventShuffleDeck: return [NSString stringWithFormat:@"SHUFFLING %@", self.deck.name];
            case kEventReShuffleDeck: return [NSString stringWithFormat:@"RE-SHUFFLING %@", self.deck.name];
            
            // Turn State
            case kEventStartTurn: return @"START TURN";
            case kEventStartTurnDraw: return @"START DRAW CARDS";

            case kEventEndTurn: return @"END TURN";
            
            // Camera
            case kEventMoveCamera: return @"MOVING CAMERA";
            case kEventMoveBoard: return @"MOVING CAMERA";
            
            
         
    }
    
    return @"FAIL!";
    
}

-(void)setCard:(Card *)card {
    _deck = card.deck;
    _playerPerformingAction = card.deck.player;
    self.manager = _playerPerformingAction.manager;
}

-(void)setPlayerPerformingAction:(Player *)playerPerformingAction {
    _playerPerformingAction = playerPerformingAction;
    self.manager = playerPerformingAction.manager;
}

-(void)setLocation:(BoardLocation *)location {
    _location = [location copy];
    
}

-(void)setManager:(Manager *)manager {
    _manager = manager;
    _teamSide = manager.teamSide;
}

-(int)actionSlot {
    return [_parent.GameEvents indexOfObject:self];
}

//
//-(void)setPlayerReceivingAction:(Card *)playerReceivingAction {
//    _playerReceivingAction = playerReceivingAction;
//    _receiverUID = playerReceivingAction.uid;
//}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    

    _type = [decoder decodeIntForKey:@"type"];
    _teamSide = [decoder decodeIntForKey:@"teamSide"];
    _seed = [decoder decodeIntForKey:@"seed"];
    _actionCost = [decoder decodeIntForKey:@"actionCost"];
    
    int x = [decoder decodeIntForKey:@"x"];
    int y = [decoder decodeIntForKey:@"y"];
    int sx = [decoder decodeIntForKey:@"sx"];
    int sy = [decoder decodeIntForKey:@"sy"];
    
    _location = [BoardLocation pX:x Y:y];
    _startingLocation = [BoardLocation pX:sx Y:sy];
    
    // NON-PERSISTENT
    
    //_wasSuccessful = [decoder decodeBoolForKey:@"wasSuccessful"];
    //_actionSlot = [decoder decodeIntForKey:@"actionSlot"];
    //_parent = [decoder decodeObjectForKey:@"parent"];
    //_manager = [decoder decodeObjectForKey:@"manager"];
    //_playerReceivingAction = [decoder decodeObjectForKey:@"playerReceivingAction"];
    //_playerPerformingAction = [decoder decodeObjectForKey:@"playerPerformingAction"];
    
    
    return self;
}



- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_teamSide forKey:@"teamSide"];
    [encoder encodeInt:_type forKey:@"type"];
    [encoder encodeInt:_actionCost forKey:@"actionCost"];
    [encoder encodeInt:_seed forKey:@"seed"];
    
    [encoder encodeInt:_location.x forKey:@"x"];
    [encoder encodeInt:_location.y forKey:@"y"];
    [encoder encodeInt:_startingLocation.x forKey:@"sx"];
    [encoder encodeInt:_startingLocation.y forKey:@"sy"];
    
   // [encoder encodeObject:_location forKey:@"location"];
   // [encoder encodeObject:_startingLocation forKey:@"startingLocation"];

    
    // NON-PERSISTENT
        //[encoder encodeInt:_actionSlot forKey:@"actionSlot"];
    //[encoder encodeObject:_parent forKey:@"parent"];
    //[encoder encodeObject: _playerReceivingAction forKey:@"playerReceivingAction"];
    //[encoder encodeObject: _playerPerformingAction forKey:@"playerPerformingAction"];
    //[encoder encodeObject:_manager forKey:@"manager"];
    
    
}

-(NSInteger)newSeed{
    
    NSUInteger newSeed = arc4random() % 9600;
    //NSLog(@"new seed: %ld", newSeed);
    return newSeed;
    
}

@end