//
//  Card.m
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ModelHeaders.h"


@interface Card (){
}
@end

@implementation Card

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

-(id)initWithType:(CardType)cType{
    self = [super init];
    if(self){

        _cardType = cType;
        
        _abilities = [[Abilities alloc]init];
        _actionPointEarn = 0;
        _actionPointCost = 0;
        
        if([self isTypeKeeper]){
            _abilities.save = .5 + (arc4random()%2)/5.0-.1;  //   .5  +/-  .1
            _abilities.pass = _abilities.kick = .5;
            _abilities.handling = .5;
            _actionPointCost = 0;
            _actionPointEarn = 2;
        }
        
        if([self isTypePlayer]){
            _actionPointCost = _actionPointEarn = arc4random()%2 + 1;
            
            _abilities.handling = .3 + (_actionPointCost*.1) + (arc4random()%2)*.1;  //   .5  +/-  .1
            _abilities.kick = .3 + (_actionPointCost*.1) + (arc4random()%2)*.1;  //   .5  +/-  .1
            _abilities.pass = _abilities.shoot = _abilities.kick;
            _abilities.dribble = _abilities.challenge = _abilities.handling;
            
            //_actionPointEarn = arc4random()%2 + 1;
        }
        
        if([self isTypeAction]){

            
            _actionPointCost = 2; // DEFAULT, CAN OVERRIDE
            
//            _nearTeamModifiers = [[Abilities alloc] init];
//            _nearOpponentModifiers = [[Abilities alloc] init];
//            _opponentModifiers = [[Abilities alloc] init];
            
            if(_cardType == kCardTypeActionCaptainsBand){
                _teamModifiers = [[Abilities alloc] init];
                _teamModifiers.kick = .1;
                _teamModifiers.handling = .1;
            }
            
            else if(_cardType == kCardTypeActionAdrenalBoost){
                _actionPointCost = 0;
                _actionPointEarn = 2;
            }
            else if(_cardType == kCardTypeActionAdrenalFlood) {
                _actionPointCost = 1;
                _actionPointEarn = 3;
            }
            
            else if(_cardType == kCardTypeActionPredictiveAnalysis1){
                _actionPointCost = 1;
                _abilities.handling += .35;
            }
            
            else if(_cardType == kCardTypeActionPredictiveAnalysis2){
                _actionPointCost = 2;
                _abilities.handling += .4;
            }

        }
    }
    return self;
}

-(id) initWithType:(CardType)cType Manager:(Manager*)m{
    self = [self initWithType:cType];
    if(self){
        //_uid = [[NSUUID UUID] UUIDString];
        self.manager = m;
        //NSLog(@"UID: %@", _uid);
    }
    return self;
}


-(BOOL)isTypePlayer{
    if(_cardType == kCardTypePlayerDefender ||
       _cardType == kCardTypePlayerForward ||
       _cardType == kCardTypePlayerMidFielder)
        return YES;
    return NO;
}

-(BOOL)isTypeKeeper{
    return (_cardType == kCardTypePlayerKeeper);
}

-(BOOL)isTypeBall{
    return (_cardType == kBall);
}

-(BOOL)isTypeAction{
    return !([self isTypePlayer] || [self isTypeKeeper] || [self isTypeBall]);
}


-(BOOL)isTypeSkill { // NOT ENCHANT CARD
    
    if(_cardType == kCardTypeActionHeader) return YES;
    if(_cardType == kCardTypeActionSlideTackle) return YES;
    if(_cardType == kCardTypeActionKamikazeKick) return YES;
    if(_cardType == kCardTypeActionCaptainsBand) return NO;
    if(_cardType == kCardTypeActionAdrenalBoost) return NO;
    if(_cardType == kCardTypeActionAdrenalFlood) return NO;
    if(_cardType == kCardTypeActionMercurialAcceleration) return YES;
    if(_cardType == kCardTypeActionPredictiveAnalysis1) return NO;
    if(_cardType == kCardTypeActionPredictiveAnalysis2) return NO;
    if(_cardType == kCardTypeActionNeuralTriggerFear) return NO;
    if(_cardType == kCardTypeActionAutoPlayerTrackingSystem) return NO;
    
    return NO;
    
}

-(BOOL)isTypeGear{
    return (![self isTypeSkill] && [self isTypeAction] && ![self isTypeBoost]);
}

-(BOOL)isTypeBoost{
    if(_cardType == kCardTypeActionAdrenalBoost) return YES;
    if(_cardType == kCardTypeActionAdrenalFlood) return YES;
    return NO;
}

-(void)setLocation:(BoardLocation *)location {
    _location = [location copy];
    
    for (Card* c in _enchantments) {
        c.location = location;
    }
    
}



-(ActionType)discardAfterActionType {
    
    if(_cardType == kCardTypeActionPredictiveAnalysis1) return kChallengeAction;
    if(_cardType == kCardTypeActionPredictiveAnalysis2) return kChallengeAction;
    
    
    return kNullAction;
}

-(BOOL)isTemporary {
    if(_cardType == kCardTypeActionPredictiveAnalysis1) return YES;
    if(_cardType == kCardTypeActionPredictiveAnalysis2) return YES;
    return NO;
}


-(NSString*) positionForCard{
    if(_cardType == kBall) return @"the Ball";

    if(_cardType == kCardTypePlayerForward) return @"Forward";
    if(_cardType == kCardTypePlayerMidFielder) return @"MidFielder";
    if(_cardType == kCardTypePlayerDefender) return @"Defender";
    if(_cardType == kCardTypePlayerKeeper) return @"Keeper";
    
    return @"";
}

-(NSString*)nameOrGeneric {
    if (_name) {
        return _name;
    }
    else {
        if(_cardType == kCardTypePlayerForward) return @"Forward";
        if(_cardType == kCardTypePlayerMidFielder) return @"Midfielder";
        if(_cardType == kCardTypePlayerDefender) return @"Defender";
        if(_cardType == kCardTypePlayerKeeper) return @"Keeper";
    }
    return Nil;
}

-(NSString*) nameForCard{
    if(_cardType == kBall) return @"the Ball";
    
    if(_cardType == kCardTypePlayerForward) return [self nameOrGeneric];
    if(_cardType == kCardTypePlayerMidFielder) return [self nameOrGeneric];
    if(_cardType == kCardTypePlayerDefender) return [self nameOrGeneric];
    if(_cardType == kCardTypePlayerKeeper) return [self nameOrGeneric];
    
    if(_cardType == kCardTypeActionHeader) return @"Header";
    if(_cardType == kCardTypeActionSlideTackle) return @"Slide Tackle";
    if(_cardType == kCardTypeActionKamikazeKick) return @"Kamikaze Kick";
    if(_cardType == kCardTypeActionCaptainsBand) return @"Captains Band";
    if(_cardType == kCardTypeActionAdrenalBoost) return @"Adrenal Boost";
    if(_cardType == kCardTypeActionAdrenalFlood) return @"Adrenal Flood";
    if(_cardType == kCardTypeActionMercurialAcceleration) return @"Mercurial Acceleration";
    if(_cardType == kCardTypeActionPredictiveAnalysis1) return @"Predictive Analysis";
    if(_cardType == kCardTypeActionPredictiveAnalysis2) return @"Predictive Analysis";
    if(_cardType == kCardTypeActionNeuralTriggerFear) return @"Neural Trigger Fear";
    if(_cardType == kCardTypeActionAutoPlayerTrackingSystem) return @"Auto Player  Tracking System";
    
    return @"";
}

-(NSString*) descriptionForCard  {
    
    if(_cardType == kCardTypeActionHeader) return @"GOAL KICK ON \n SUCCESSFUL PASS";
    if(_cardType == kCardTypeActionSlideTackle) return @"Slide Tackle";
    if(_cardType == kCardTypeActionKamikazeKick) return @"Kamikaze Kick";
    
    if(_cardType == kCardTypeActionCaptainsBand) return [NSString stringWithFormat:@"TEAM BONUS \n +%@/ +%@", [self pP:_teamModifiers.kick], [self pP:_teamModifiers.handling]];
    
    if(_cardType == kCardTypeActionAdrenalBoost) return [NSString stringWithFormat:@"GET %d BONUS \n AP", _actionPointEarn];
    if(_cardType == kCardTypeActionAdrenalFlood) return [NSString stringWithFormat:@"GET %d BONUS \n AP", _actionPointEarn];
    
    if(_cardType == kCardTypeActionMercurialAcceleration) return @"Mercurial Acceleration";
    
    if(_cardType == kCardTypeActionPredictiveAnalysis1) return [NSString stringWithFormat:@"CHALLENGE \n WITH +%@", [self pP:_abilities.handling]];
    if(_cardType == kCardTypeActionPredictiveAnalysis2) return [NSString stringWithFormat:@"CHALLENGE \n WITH +%@", [self pP:_abilities.handling]];
    
    if(_cardType == kCardTypeActionNeuralTriggerFear) return @"Neural Trigger Fear";
    if(_cardType == kCardTypeActionAutoPlayerTrackingSystem) return @"Auto Player  Tracking System";
    
    return @"";
    
    
}

-(NSString*) pP:(float)p {
    
    return [NSString stringWithFormat:@"%d%%", (int)(p * 100)];

}

-(void)addEnchantment:(Card*)enchantment {

    
    
    NSMutableArray *enchantmentsMutable;
    
    if (!_enchantments) enchantmentsMutable = [NSMutableArray arrayWithCapacity:3];
    else enchantmentsMutable = [_enchantments mutableCopy];
    
   
    [enchantmentsMutable addObject:enchantment];
    _enchantments = enchantmentsMutable;
    
    enchantment.player = self;
    
}

-(void)removeEnchantment:(Card*)enchantment {
    
    NSMutableArray *enchantmentsMutable = [_enchantments mutableCopy];
    [enchantmentsMutable removeObject:enchantment];
    
    if (!enchantmentsMutable.count) _enchantments = Nil;
    else _enchantments = enchantmentsMutable;
    
}


-(void)removeLastEnchantment {
    
    NSMutableArray *enchantmentsMutable = [_enchantments mutableCopy];
    [enchantmentsMutable removeLastObject];
    _enchantments = enchantmentsMutable;
    
}

-(void)setBall:(Card *)ball {
    
    if (ball) { // not setting to nil
        
        
        if (ball.player && ![ball.player isEqual:self]) {
            [ball.player setBall:nil];
            ball.player = self;
            
        }
        
        else {
            ball.player = self;
        }

        _ball = ball;
        
    }
    
    else {
       _ball = Nil;
    }
    
}

#pragma mark NSCODER

#define NSFWKeyType @"type"
#define NSFWKeyManager @"manager"
#define NSFWKeyName @"name"
#define NSFWKeyActionPointEarn @"actionPointEarn"
#define NSFWKeyActionPointCost @"actionPointCost"
#define NSFWKeyAbilities @"abilities"
#define NSFWKeyNearOpponentModifiers @"nearOpponentModifiers"
#define NSFWKeyNearTeamModifiers @"nearTeamModifiers"
#define NSFWKeyOpponentModifiers @"opponentModifiers"
#define NSFWKeyTeamModifiers @"teamModifiers"

//-(NSArray*)aArray {
//    
//    return @[@"type",               //0
//             @"manager",            //1
//
//             @"name",               //2
//             
//             @"actionPointEarn",    //3
//             @"actionPointCost",    //4
//
//             @"abilities",          //5
//             @"nearOpponentModifiers",//6
//             @"nearTeamModifiers",  //7
//             @"opponentModifiers",  //8
//             @"teamModifiers"];     //9
//}

- (id)initWithCoder:(NSCoder *)decoder {

    self = [super init];
    
    if (self) {
   
    _cardType = [decoder decodeIntForKey:NSFWKeyType];
    _manager = [decoder decodeObjectForKey:NSFWKeyManager];
    
    _name = [decoder decodeObjectForKey:NSFWKeyName];
        
    _actionPointEarn = [decoder decodeIntForKey:NSFWKeyActionPointEarn];
    _actionPointCost = [decoder decodeIntForKey:NSFWKeyActionPointCost];
        
    _abilities = [decoder decodeObjectForKey:NSFWKeyAbilities];
    _nearOpponentModifiers = [decoder decodeObjectForKey:NSFWKeyNearOpponentModifiers];
    _nearTeamModifiers = [decoder decodeObjectForKey:NSFWKeyNearTeamModifiers]  ;
    _opponentModifiers = [decoder decodeObjectForKey:NSFWKeyOpponentModifiers];
    _teamModifiers = [decoder decodeObjectForKey:NSFWKeyTeamModifiers];
        
    }
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_cardType forKey:NSFWKeyType];
    [encoder encodeObject:_manager forKey:NSFWKeyManager];

    [encoder encodeObject:_name forKey:NSFWKeyName];
    
    [encoder encodeInteger:_actionPointEarn forKey:NSFWKeyActionPointEarn];
    [encoder encodeInteger:_actionPointCost forKey:NSFWKeyActionPointCost];
    
    [self encodeAbilities:_abilities with:encoder forKey:NSFWKeyAbilities];
    [self encodeAbilities:_nearOpponentModifiers with:encoder forKey:NSFWKeyNearOpponentModifiers];
    [self encodeAbilities:_nearTeamModifiers with:encoder forKey:NSFWKeyNearTeamModifiers];
    [self encodeAbilities:_opponentModifiers with:encoder forKey:NSFWKeyOpponentModifiers];
    [self encodeAbilities:_teamModifiers with:encoder forKey:NSFWKeyTeamModifiers];

    
}

-(void)encodeAbilities:(Abilities*)a with:(NSCoder *)encoder forKey:(NSString*)s{
    if (a.persist) {
        [encoder encodeObject:a forKey:s];
    }
}

@end

@implementation Abilities

#pragma mark ABILITIES NSCODER

-(NSArray*)aArray {
    
    return @[@"kick",
             @"handling",
             @"challenge",
             @"dribble",
             @"pass",
             @"shoot",
             @"save"];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _persist = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    BOOL persist = [decoder decodeBoolForKey:@"persist"];
    
    if (!persist) {
        return nil;
    }
         
    self = [super init];
    
    if (self) {
        NSArray *a = [self aArray];
        
        _persist = persist;
        _kick = [decoder decodeFloatForKey:a[0]];
        _handling = [decoder decodeFloatForKey:a[1]];
        _challenge = [decoder decodeFloatForKey:a[2]];
        _dribble = [decoder decodeFloatForKey:a[3]];
        _pass = [decoder decodeFloatForKey:a[4]];
        _shoot = [decoder decodeFloatForKey:a[5]];
        _save = [decoder decodeFloatForKey:a[6]];
        
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    
    if (!_persist) {
        return;
    }
    
    
    NSArray *a = [self aArray];
    
    [encoder encodeBool:YES forKey:@"persist"];
    [encoder encodeFloat:_kick forKey:a[0]];
    [encoder encodeFloat:_handling forKey:a[1]];
    [encoder encodeFloat:_challenge forKey:a[2]];
    [encoder encodeFloat:_dribble forKey:a[3]];
    [encoder encodeFloat:_pass forKey:a[4]];
    [encoder encodeFloat:_shoot forKey:a[5]];
    [encoder encodeFloat:_save forKey:a[6]];
    
}

-(instancetype)copy {
    Abilities *a = [[Abilities alloc] init];
    
    a.kick = _kick;
    a.handling = _handling;
    a.challenge = _challenge;
    a.dribble = _dribble;
    a.pass = _pass;
    a.shoot = _shoot;
    a.save = _save;
    
    return a;
}

-(void)add:(Abilities*)modifier {
    
    _kick += modifier.kick;
    _handling += modifier.handling;
    _challenge += modifier.challenge;
    _dribble += modifier.dribble;
    _pass += modifier.pass;
    _shoot += modifier.shoot;
    _save += modifier.save;
    
}

@end