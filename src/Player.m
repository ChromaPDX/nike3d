//
//  Player.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "ModelHeaders.h"

@implementation Player

-(id) initWithManager:(Manager*)m {
    self = [super initWithDeck:m.players];
    if (self) {
        _manager = m;
    }
    return self;
}

-(void)generateDefaultCards {
    
    _moveDeck = [[Deck alloc]initWithPlayer:self type:DeckTypeMove];
    _kickDeck = [[Deck alloc]initWithPlayer:self type:DeckTypeKick];
    _challengeDeck = [[Deck alloc]initWithPlayer:self type:DeckTypeChallenge];
    _specialDeck = [[Deck alloc]initWithPlayer:self type:DeckTypeSpecial];
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_manager forKey:NSFWKeyManager];
    [aCoder encodeObject:_moveDeck forKey:@"moveDeck"];
    [aCoder encodeObject:_kickDeck forKey:@"kickDeck"];
    [aCoder encodeObject:_challengeDeck forKey:@"challengeDeck"];
    [aCoder encodeObject:_specialDeck forKey:@"specialDeck"];
    
}

-(void)setLocation:(BoardLocation *)location {
    
    [super setLocation:location];
    
    for (Card* c in _enchantments) {
        c.location = location;
    }
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if (self) {
     
        _manager = [decoder decodeObjectForKey:NSFWKeyManager];
        _kickDeck = [decoder decodeObjectForKey:@"kickDeck"];
        _challengeDeck = [decoder decodeObjectForKey:@"challengeDeck"];
        _moveDeck = [decoder decodeObjectForKey:@"moveDeck"];
        _specialDeck = [decoder decodeObjectForKey:@"specialDeck"];
    }
    
    return self;
}


-(void)addEnchantment:(Card*)enchantment {
    
    
    
    NSMutableArray *enchantmentsMutable;
    
    if (!_enchantments) enchantmentsMutable = [NSMutableArray arrayWithCapacity:3];
    else enchantmentsMutable = [_enchantments mutableCopy];
    
    
    [enchantmentsMutable addObject:enchantment];
    _enchantments = enchantmentsMutable;
    
    enchantment.enchantee = self;
    
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

-(NSArray*)allCardsInHand {
    return [[[_moveDeck.inHand arrayByAddingObjectsFromArray:_kickDeck.inHand]arrayByAddingObjectsFromArray:_challengeDeck.inHand]arrayByAddingObjectsFromArray:_specialDeck.inHand];
}

-(NSArray*)allCardsInDeck {
    return [[[_moveDeck.theDeck arrayByAddingObjectsFromArray:_kickDeck.theDeck]arrayByAddingObjectsFromArray:_challengeDeck.theDeck]arrayByAddingObjectsFromArray:_specialDeck.theDeck];
}

-(Card*)cardInHandAtlocation:(BoardLocation*)location {
    
    for (Card* inHand in [self allCardsInHand]) {
        if ([inHand.location isEqual:location]) {
            return inHand;
        }
    }
    return Nil;
}

-(Card*)cardInDeckAtLocation:(BoardLocation*)location {
    
    for (Card* inDeck in [self allCardsInDeck]) {
        if ([inDeck.location isEqual:location]) {
            return inDeck;
        }
    }
    return Nil;
}


-(void)setBall:(Card *)ball {
    
    if (ball) { // not setting to nil
        
        if (ball.enchantee && ![ball.enchantee isEqual:self]) {
            [ball.enchantee setBall:nil];
            ball.enchantee = self;
            
        }
        
        else {
            ball.enchantee = self;
        }
        
        ball.location = self.location;
        
        _ball = ball;
        
    }
    
    else {
        _ball = Nil;
    }
    
}

@end
