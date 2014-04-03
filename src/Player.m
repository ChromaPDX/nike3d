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
    
    _cardSlots = 4;
    
    _moveDeck = [[Deck alloc]initWithPlayer:self type:CardCategoryMove];
    _kickDeck = [[Deck alloc]initWithPlayer:self type:CardCategoryKick];
    _challengeDeck = [[Deck alloc]initWithPlayer:self type:CardCategoryChallenge];
    _specialDeck = [[Deck alloc]initWithPlayer:self type:CardCategorySpecial];
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeInt32:_cardSlots forKey:@"cardSlots"];
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
     
        _cardSlots = [decoder decodeInt32ForKey:@"cardSlots"];
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

#pragma mark - AI FUNCTIONS

-(NSArray*)pathToBall{
    BoardLocation *ballLocation = _manager.game.ball.location;
    return [self pathToBoardLocation:ballLocation];
}

-(NSArray*)pathToGoal{
    BoardLocation *goalLocation = _manager.goal;
    return [self pathToBoardLocation:goalLocation];
}

-(NSArray*)pathToBoardLocation:(BoardLocation *)location{

    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
   // BoardLocation *goalLocation = _manager.goal;
    
    for (Player* p in [_manager.players allCards]) {
        // add all players that aren't on the ball to the obstacles
        if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
        }
    }
    for (Player* p in [_manager.opponent.players allCards]) {
        // add all players that aren't on the ball to the obstacles
        if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
        }
    }
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    // NSLog(@"in pathToBall, player = %@ goal = %@", self.location, goalLocation);
    NSArray* path = [aStar pathFromAtoB:self.location B:location NeighborhoodType:NeighborhoodTypeMoore];
    
    return path;
}

-(NSArray*)pathToKickRange:(Player *)player{
    NSArray *retPath;
    NSArray *kickPath;
    NSArray *movePath;
    
    Card* kickCard = player.kickDeck.inHand[0];
    
    if(kickCard){
        kickPath = kickCard.selectionSet;
    }
    else{
        return retPath;
    }
    if(kickPath){
        Card* moveCard = self.moveDeck.inHand[0];
        if(moveCard){
            movePath = moveCard.selectionSet;
            if(movePath){
                // NSArray *intersectPath = [BoardLocation setIntersect:movePath withSet:kickPath];
                NSArray *intersectPath = [BoardLocation  tileSetIntersect:movePath withTileSet:kickPath];
                if(intersectPath){
                    BoardLocation *closestLocation = [self closestLocation:intersectPath];
                    if(closestLocation){
                        retPath = [self pathToBoardLocation:closestLocation];
                    }
                }
            }
        }
        else{
            return retPath;
        }
        
    }
    return retPath;
}

-(BoardLocation*)closestLocation:(NSArray*)tileSet{
    int minPath = 10000;
    BoardLocation* retVal;
    for(BoardLocation* location in tileSet){
        NSArray *path = [self pathToBoardLocation:location];
        if(path.count < minPath){
            minPath = path.count;
            retVal = location;
        }
        
    }
    return retVal;
}

@end
