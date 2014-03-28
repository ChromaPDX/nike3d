//
//  Manager.m
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "ModelHeaders.h"

@interface Manager ()
@end

@implementation Manager

-(id)initWithGame:(Game*)game{
    self = [super init];
    if(self){
        NSLog(@"new manager init");
        NSMutableArray *playersMutable = [[NSMutableArray alloc]init];
        
        _players = [[Deck alloc]init];
        
        for (int p = 0; p < 3; p++) {
            Player* player = [[Player alloc]initWithManager:self];
            player.name = [NSString stringWithFormat:@"PLAYER %d",p+1];
            player.deck = _players;
            [player generateDefaultCards];
            
            [playersMutable addObject:player];
           
        }
        
        _players.allCards = [playersMutable copy];
    }
    
    return self;
}

-(void)setTeamSide:(int)teamSide {
    _teamSide = teamSide;
    
   // _deck = [[Deck alloc] initWithManager:self];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
   
    if (!self) {
        return nil;
    }
    
    NSLog(@"unarchive manager");
    
  
    
    _teamSide = [decoder decodeIntForKey:@"side"];
    _name = [decoder decodeObjectForKey:@"name"];
    _color = [decoder decodeObjectForKey:@"color"];
   // _deck = [decoder decodeObjectForKey:@"deck"];
    
    _actionPointsEarned = [decoder decodeIntForKey:@"actionPointsEarned"];
    _actionPointsSpent = [decoder decodeIntForKey:@"actionPointsSpent"];
    _attemptedGoals = [decoder decodeIntForKey:@"attemptedGoals"];
    _successfulGoals = [decoder decodeIntForKey:@"successfulGoals"];
    _attemptedPasses = [decoder decodeIntForKey:@"attemptedPasses"];
    _successfulPasses = [decoder decodeIntForKey:@"successfulPasses"];
    _attemptedSteals = [decoder decodeIntForKey:@"attemptedSteals"];
    _successfulSteals = [decoder decodeIntForKey:@"successfulSteals"];
    _playersDeployed = [decoder decodeIntForKey:@"playersDeployed"];
    _cardsDrawn = [decoder decodeIntForKey:@"cardsDrawn"];
    _cardsPlayed = [decoder decodeIntForKey:@"cardsPlayed"];
    
    _players = [decoder decodeObjectForKey:@"players"];
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:_teamSide forKey:@"side"];
  //  [encoder encodeObject:_deck forKey:@"deck"];
    // META
    
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_color forKey:@"color"];
    [encoder encodeInt:_actionPointsEarned forKey:@"actionPointsEarned"];
    [encoder encodeInt:_actionPointsSpent forKey:@"actionPointsSpent"];
    [encoder encodeInt:_attemptedGoals forKey:@"attemptedGoals"];
    [encoder encodeInt:_successfulGoals forKey:@"successfulGoals"];
    [encoder encodeInt:_attemptedPasses forKey:@"attemptedPasses"];
    [encoder encodeInt:_successfulPasses forKey:@"successfulPasses"];
    [encoder encodeInt:_attemptedSteals forKey:@"attemptedSteals"];
    [encoder encodeInt:_successfulSteals forKey:@"successfulSteals"];
    [encoder encodeInt:_playersDeployed forKey:@"playersDeployed"];
    [encoder encodeInt:_cardsDrawn forKey:@"cardsDrawn"];
    [encoder encodeInt:_cardsPlayed forKey:@"cardsPlayed"];

    [encoder encodeObject:_players forKey:@"players"];
}


-(BOOL)isEqual:(id)object {
    return (self.teamSide == [object teamSide]);
}

-(bool)hasPossesion {
    for (Player* p in _players.inGame) {
        if (p.ball) {
            return true;
        }
    }
    return false;
}

-(instancetype)copy {
    
    NSMutableData *data = [[NSMutableData alloc]init];
    
    NSKeyedArchiver *a = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    [a encodeObject:self forKey:@"m"];
    
    [a finishEncoding];
    
    NSKeyedUnarchiver *d = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    
    Manager *m = [d decodeObjectForKey:@"m"];
    
    return m;
}

@end
