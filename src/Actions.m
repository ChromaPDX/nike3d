//
//  Actions.m
//  ChromaNSFW
//
//  Created by Robby Kraft on 9/30/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import "ModelHeaders.h"


@implementation GameAction

+(instancetype) action {
    
    GameAction *newAction = [[GameAction alloc]init];
    newAction.skillEvents = [NSMutableArray arrayWithCapacity:12];
    
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
    
    _skillEvents = [[decoder decodeObjectForKey:@"events"] mutableCopy];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_tag forKey:@"tag"];
    [encoder encodeInt:_boost forKey:@"boost"];
    [encoder encodeBool:_wasSuccessful forKey:@"wasSuccessful"];
    
    [encoder encodeObject:_skillEvents forKey:@"events"];
    
}

-(float)totalModifier {
    
    float totalModifier = 0.;
    
    if (self.isRunningAction) {
        
        for (int i = 0; i < self.skillEvents.count; i++) {
            SkillEvent *e = self.skillEvents[i];
            if(e.totalModifier != 0){
                //if(e.success < e.totalModifier) return 0; // modifiers within one event bring chance of success below 0
                totalModifier += e.totalModifier; // cumulatively reduce chance of success
            }
            
            
        }
        
    }
    
    else {
        totalModifier = [self.skillEvents.lastObject totalModifier];
    }
    
    _totalModifier = totalModifier;

    return _totalModifier;
    
}

-(float)totalSucess {
    
    float totalSuccess = 1.;
    
    if (self.isRunningAction) {
        
        
        for (int i = 0; i < self.skillEvents.count; i++) {
            SkillEvent *e = self.skillEvents[i];
            if(e.totalModifier != 0){
                //if(e.success < e.totalModifier) return 0; // modifiers within one event bring chance of success below 0
                totalSuccess *= e.success; // cumulatively reduce chance of success
            }
            
            
        }
        
    }
    
    else {
        totalSuccess = [self.skillEvents.lastObject success];
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
        
        for (int i = 0; i < self.skillEvents.count; i++) {
            SkillEvent *e = self.skillEvents[i];
            totalCost += e.actionCost;
        }
        
    }
    
    else {
        totalCost = [self.skillEvents.lastObject actionCost];
    }
    
    totalCost += _boost;
    
    _totalCost = totalCost;
    
    return _totalCost;
    
}

-(Card*)playerPerformingAction {
    if (_skillEvents.count) {
        
        if (![_skillEvents[0] playerPerformingAction]) {
            NSLog(@"action.m could not infer player from events");
        }
        return [_skillEvents[0] playerPerformingAction];
        
    }
    else {
        NSLog(@"no player yet on this aciton");
        return nil;
    }
}

-(Card*)playerReceivingAction {
    if (_skillEvents.count) {
        
        if (![_skillEvents.lastObject playerPerformingAction]) {
            NSLog(@"action.m could not infer player from events");
        }
        return [_skillEvents.lastObject playerPerformingAction];
    }
    else {
        NSLog(@"no player yet on this aciton");
        return nil;
    }
}

-(BOOL)isRunningAction {
    return [[_skillEvents lastObject] isRunningEvent];
}

-(ActionType)type {
    
return [(SkillEvent*)[_skillEvents lastObject] type];
    
}

-(NSString*)nameForAction{

    return [[_skillEvents lastObject] nameForAction];
    
}

-(Manager*)manager {
    
    return [[_skillEvents lastObject] manager];
    
}

@end

@implementation SkillEvent

+(instancetype) eventForAction:(GameAction*)action{
    SkillEvent *newEvent = [[SkillEvent alloc]init];
    newEvent.parent = action;
    newEvent.seed = [newEvent newSeed];
    
    return newEvent;
}

-(BOOL)isRunningEvent {
    
    if (_type == kRunningAction || _type == kDribbleAction || _type == kChallengeAction) {
        return 1;
    }
    
    else return 0;
}

-(BOOL)isDeployEvent {
    
    if (_type == kDeployEvent || _type == kSpawnPlayerEvent || _type == kSpawnKeeperEvent) {
        return 1;
    }
    
    else return 0;
}

-(NSString*)nameForAction{
    
    ActionType actionType = [self type];
    
    if(actionType == kPassAction)
        return @"PASS";
    if(actionType == kDribbleAction)
        return @"DRIBBLE";
    if(actionType == kRunningAction)
        return  @"RUN";
    if(actionType == kChallengeAction)
        return @"CHALL";
    if(actionType == kShootAction)
        return @"SHOOT";
    if(actionType == kDeployEvent)
        return @"DEPLOY";
    if(actionType == kSpawnKeeperEvent)
        return @"SPAWN KEEPER";
    if(actionType == kSpawnPlayerEvent)
        return @"SPAWN PLAYER";
    if(actionType == kDeployEvent)
        return @"DEPLOY";
    if(actionType == kEnchantAction)
        return @"INSTALL";
    if(actionType == kStartingAction)
        return @"BEGIN PLAYER MOVE";
    if(actionType == kPlayCardAction)
        return @"PLAY CARD";
    if(actionType == kEndTurnAction)
        return @"END TURN ACTION";
    if(actionType == kRemovePlayerAction)
        return @"REMOVE PLAYER";
    if(actionType == kDrawAction)
        return @"DRAW CARD";
    if(actionType == kTurnDrawAction)
        return @"START TURN DRAW";
    if(actionType == kStartTurnAction)
        return @"START TURN";
    if(actionType == kSetBallAction)
        return @"SET BALL";
    if(actionType == kShuffleAction)
        return @"SHUFFLE";
    if(actionType == kGoaliePass)
        return @"GOAL KICK!";
    if(actionType == kGraveyardShuffleAction)
        return @"RESHUFFLE";
    if (actionType == kPurgeEnchantmentsAction)
        return @"WIPE TEMP ENCHANTMENTS";
    if (actionType == kMoveFieldAction)
        return @"MOVING ACTIVE ZONE";
    
    
    return @"FAIL!";
    
}

-(void)setPlayerPerformingAction:(Card *)playerPerformingAction {
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
    return [_parent.skillEvents indexOfObject:self];
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