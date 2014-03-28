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

-(id)initWithDeck:(Deck*)deck {
    self = [super init];
    if(self){
        _deck = deck;
        _abilities = [[Abilities alloc]init];
        _level = rand()%3 + 1;
        _range = rand()%5 + 1;
        _actionPointEarn = 0;
        _actionPointCost = 0;
    }
    return self;
}

-(DeckType)deckType{
    return _deck.type;
}

-(void)setDeck:(Deck *)deck {
    _deck = deck;
}

-(void)setLocation:(BoardLocation *)location {
    _location = [location copy];
}


-(EventType)discardAfterEventType {

    return kNullAction;
}

-(BOOL)isTemporary {

    return NO;
}

-(NSString*)nameOrGeneric {
    if (_name) {
        return _name;
    }
    
    else {
        switch (self.deckType) {
            case DeckTypeKick:
                return @"KICK";
                break;
                
            case DeckTypeMove:
                return @"MOVE";
                break;
                
            case DeckTypeChallenge:
                return @"CHALLENGE";
                break;
                
            case DeckTypeSpecial:
                return @"SPECIAL";
                break;

            default:
                return @"ERROR, fix name or generic";
                break;
        }
   
    }

}

-(void)play {
    if ([_deck.inHand containsObject:self]){
        [_deck playCardFromHand:self];
    }
    else if ([_deck.theDeck containsObject:self]){
        [_deck playCardFromDeck:self];
    }
}

-(void)discard {
    
    if ([_deck.inGame containsObject:self]) {
          [_deck discardCardFromGame:self];
    }
    else if ([_deck.inHand containsObject:self]){
           [_deck discardCardFromHand:self];
    }
    else if ([_deck.theDeck containsObject:self]){
        [_deck discardCardFromDeck:self];
    }
    else {
        NSLog(@"discarding card that isn't located anywhere . . .");
    }
  
}

-(NSString*)name {
    return [self nameOrGeneric];
}

-(NSString*) descriptionForCard  {
    
//    if(_cardType == kCardTypeActionHeader) return @"GOAL KICK ON \n SUCCESSFUL PASS";
//    if(_cardType == kCardTypeActionSlideTackle) return @"Slide Tackle";
//    if(_cardType == kCardTypeActionKamikazeKick) return @"Kamikaze Kick";
//      if(_cardType == kCardTypeActionAdrenalBoost) return [NSString stringWithFormat:@"GET %d BONUS \n AP", _actionPointEarn];
//    if(_cardType == kCardTypeActionAdrenalFlood) return [NSString stringWithFormat:@"GET %d BONUS \n AP", _actionPointEarn];
//    
//    if(_cardType == kCardTypeActionMercurialAcceleration) return @"Mercurial Acceleration";
//    
//    if(_cardType == kCardTypeActionPredictiveAnalysis1) return [NSString stringWithFormat:@"CHALLENGE \n WITH +%@", [self pP:_abilities.handling]];
//    if(_cardType == kCardTypeActionPredictiveAnalysis2) return [NSString stringWithFormat:@"CHALLENGE \n WITH +%@", [self pP:_abilities.handling]];
//    
//    if(_cardType == kCardTypeActionNeuralTriggerFear) return @"Neural Trigger Fear";
//    if(_cardType == kCardTypeActionAutoPlayerTrackingSystem) return @"Auto Player  Tracking System";
//    
    return @"add card descriptions";
    
    
}

-(NSString*) pP:(float)p {
    
    return [NSString stringWithFormat:@"%d%%", (int)(p * 100)];

}




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
    _deck = [decoder decodeObjectForKey:NSFWKeyPlayer];
    
    _name = [decoder decodeObjectForKey:NSFWKeyName];
        
    _actionPointEarn = [decoder decodeIntForKey:NSFWKeyActionPointEarn];
    _actionPointCost = [decoder decodeIntForKey:NSFWKeyActionPointCost];
    _level = [decoder decodeIntForKey:NSFWKeyCardLevel];
    _range = [decoder decodeIntForKey:NSFWKeyCardRange];
        
    _abilities = [decoder decodeObjectForKey:NSFWKeyAbilities];

        
    }
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_cardType forKey:NSFWKeyType];
    [encoder encodeObject:_deck forKey:NSFWKeyPlayer];

    [encoder encodeObject:_name forKey:NSFWKeyName];
    
    [encoder encodeInteger:_actionPointEarn forKey:NSFWKeyActionPointEarn];
    [encoder encodeInteger:_actionPointCost forKey:NSFWKeyActionPointCost];
    [encoder encodeInteger:_level forKey:NSFWKeyCardLevel];
    [encoder encodeInteger:_range forKey:NSFWKeyCardRange];
    
    [self encodeAbilities:_abilities with:encoder forKey:NSFWKeyAbilities];

    
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
             @"move",
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
        _kick = [decoder decodeInt32ForKey:a[0]];
        _move = [decoder decodeInt32ForKey:a[1]];
        _challenge = [decoder decodeInt32ForKey:a[2]];
        
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    
    if (!_persist) {
        return;
    }
    
    
    NSArray *a = [self aArray];
    
    [encoder encodeBool:YES forKey:@"persist"];
    [encoder encodeInt32:_kick forKey:a[0]];
    [encoder encodeInt32:_move forKey:a[1]];
    [encoder encodeInt32:_challenge forKey:a[2]];

    
}

-(instancetype)copy {
    Abilities *a = [[Abilities alloc] init];
    
    a.kick = _kick;
    a.move = _move;
    a.challenge = _challenge;

    
    return a;
}

-(void)add:(Abilities*)modifier {
    
    _kick += modifier.kick;
    _move += modifier.move;
    _challenge += modifier.challenge;
    
}

@end