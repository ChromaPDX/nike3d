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
        
        _ball = ball;
        
    }
    
    else {
        _ball = Nil;
    }
    
}

#pragma mark - AI CONVENIENCE FUNCTIONS

-(NSArray*)pathToBall{
    BoardLocation *ballLocation = _manager.game.ball.location;
    NSMutableArray *retPath = [[self pathToClosestAdjacentBoardLocation:ballLocation] mutableCopy];
    [retPath addObject:ballLocation];
  //  NSArray* reversedPath = [[retPath reverseObjectEnumerator] allObjects];
    return retPath;
}

-(NSArray*)pathToGoal{
    BoardLocation *goalLocation = _manager.goal;
    NSArray *path = [self pathToClosestAdjacentBoardLocation:goalLocation];
  //  NSArray* reversedPath = [[path reverseObjectEnumerator] allObjects];
    return path;
}

// returns the path to the specified board location, unverified
-(NSArray*)pathToBoardLocation:(BoardLocation *)location{
    if(!location){
        NSLog(@"pathToBoardLocation Error, null location");
        return NULL;
    }
    
    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
   // BoardLocation *goalLocation = _manager.goal;
    
    for (Player* p in [_manager.players inGame]) {
        if(p != self){
            [obstacles addObject:p.location];
        }
    }
    for (Player* p in [_manager.opponent.players inGame]) {
        [obstacles addObject:p.location];
    }
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
   // NSLog(@"in pathToLocation, player = %@ ball = %@", self.location, location);
    NSArray* path = [aStar pathFromAtoB:self.location B:location NeighborhoodType:NeighborhoodTypeMoore];
    
    NSArray* reversedPath = [[path reverseObjectEnumerator] allObjects];
    return reversedPath;
  //  return path;
}


// returns the path to the specified board location, unverified
-(NSArray*)pathFromBoardLocationToBoardLocation:(BoardLocation*)fromLocation toLocation:(BoardLocation *)toLocation{
    if(!fromLocation || !toLocation){
        NSLog(@"pathFromBoardLocationToBoardLocation Error, null location");
        return NULL;
    }
    
    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
    // BoardLocation *goalLocation = _manager.goal;
    
    for (Player* p in [_manager.players inGame]) {
        if(p != self){
            [obstacles addObject:p.location];
        }
    }
    for (Player* p in [_manager.opponent.players inGame]) {
        [obstacles addObject:p.location];
    }
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    // NSLog(@"in pathToLocation, player = %@ ball = %@", self.location, location);
    NSArray* path = [aStar pathFromAtoB:fromLocation B:toLocation NeighborhoodType:NeighborhoodTypeMoore];
    
    NSArray* reversedPath = [[path reverseObjectEnumerator] allObjects];
    return reversedPath;
    //  return path;
}

// returns the path to the specified board location, unverified
-(NSArray*)pathFromBoardLocationToBoardLocationNoObstacles:(BoardLocation*)fromLocation toLocation:(BoardLocation *)toLocation{
    if(!fromLocation || !toLocation){
        NSLog(@"pathFromBoardLocationToBoardLocationNoObstacles Error, null location");
        return NULL;
    }
    
    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    // NSLog(@"in pathToLocation, player = %@ ball = %@", self.location, location);
    NSArray* path = [aStar pathFromAtoB:fromLocation B:toLocation NeighborhoodType:NeighborhoodTypeMoore];
    
    NSArray* reversedPath = [[path reverseObjectEnumerator] allObjects];
    return reversedPath;
    //  return path;
}


-(NSArray*)pathToClosestAdjacentBoardLocation:(BoardLocation *)location{
    if(!location){
        NSLog(@"pathToClosestAdjacentBoardLocation Error, null location");
        return NULL;
    }
    
    NSMutableArray *obstacles = [[NSMutableArray alloc] init];
    // BoardLocation *goalLocation = _manager.goal;
    
    for (Player* p in [_manager.players inGame]) {
        if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
        }
    }
    for (Player* p in [_manager.opponent.players inGame]) {
        if(!([location isEqual:p.location])){
            [obstacles addObject:p.location];
        }
    }
    AStar *aStar = [[AStar alloc]initWithColumns:7 Rows:10 ObstaclesCells:obstacles];
    // NSLog(@"in pathToLocation, player = %@ ball = %@", self.location, location);
    NSArray* path = [aStar pathFromAtoB:self.location B:location NeighborhoodType:NeighborhoodTypeMoore];
    NSMutableArray* reversedPath = [[[path reverseObjectEnumerator] allObjects] mutableCopy];
    [reversedPath removeLastObject];
    if([reversedPath count]){
        return reversedPath;
    }
    else{
        return NULL;
    }
}

-(NSArray *)pathToShootingRange{
}

-(NSArray*)pathToKickRange:(Player *)player{
    NSArray *retPath;
    NSArray *kickPath;
    NSArray *movePath;
    Card* kickCard;
    if(player.kickDeck.inHand && [player.kickDeck.inHand count]){
        kickCard = player.kickDeck.inHand[0];
    }
    else{
        return NULL;
    }
    
    if(kickCard){
        kickPath = kickCard.selectionSet;
    }
    else{
        return retPath;
    }
    if(kickPath){
        Card* moveCard;
        if(self.moveDeck.inHand && [player.moveDeck.inHand count]){
            moveCard = self.moveDeck.inHand[0];
        }
        else{
            return NULL;
        }
        if(moveCard){
            movePath = moveCard.selectionSet;
            if(movePath){
                // NSArray *intersectPath = [BoardLocation setIntersect:movePath withSet:kickPath];
                NSArray *intersectPath = [BoardLocation  tileSetIntersect:movePath withTileSet:kickPath];
                if(intersectPath){
                    BoardLocation *closestLocation = [self closestLocationInTileSet:intersectPath];
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

-(NSArray*)pathToChallenge:(Player *)player{
    NSMutableArray *retPath;
    retPath = [NSMutableArray arrayWithArray:[self pathToClosestAdjacentBoardLocation:player.location]];
    if(!retPath && [retPath count]){
        return NULL;
    }
    else{
        return retPath;
    }
}


-(NSArray*)pathToOpenFieldClosestToLocation:(BoardLocation *)location{
    Card *moveCard = self.moveDeck.inHand[0];
    if(!moveCard) return NULL;
    
    NSArray *moveSet = moveCard.validatedSelectionSet;
    //NSLog(@"pathToOpenFieldClosestToLocation, moveSet.count = %d", [moveSet count]);
    if(!moveSet){
        return NULL;
    }
    //int maxSpace = 0;
    
    // compute the minimum distances to each temmate
    // and the minum distances to the location for each player
   // NSMutableDictionary *minTeammateDistances = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *locationDistances = [[NSMutableDictionary alloc]init];

    for(BoardLocation *thisLoc in moveSet){
        int distanceToTeammate = [self distanceAfterMoveToClosestTeammate:thisLoc];
     //   [minTeammateDistances setObject:[NSNumber numberWithInt:distanceToTeammate] forKey:thisLoc];
        NSArray *pathToTarget = [self pathFromBoardLocationToBoardLocationNoObstacles:thisLoc toLocation:location];
      //  NSLog(@"distanceToTeammate = %d", distanceToTeammate);
        if(pathToTarget && distanceToTeammate >= 2){
       //     NSLog(@"adding %@ to the list with pathToTarget.count = %d", thisLoc, [pathToTarget count]);
            [locationDistances setObject:[NSNumber numberWithInt:[pathToTarget count]] forKey:thisLoc];
        }
        else{
         //   NSLog(@"removing %@ from location list, below threshold for min distance to teammates", thisLoc);
        }

        // NSLog(@"pathToOpenFieldClosestLocation - thisSpace distance = %d", thisSpace);
       // if(thisSpace > maxSpace){
       //     retLoc = loc;
       //     maxSpace = thisSpace;
       // }
    }
    
   // NSArray *myPathToLoc = [self pathFromBoardLocationToBoardLocationNoObstacles:self.location toLocation:location];
    
    BoardLocation *retLoc = NULL;

    // remove any location that is under our threshold distance for distance to teammates
   // for(BoardLocation *thisLoc in moveSet){
   //     int distanceToTeammate = [minTeammateDistances objectForKey:thisLoc];
   //     if(distanceToTeammate < 2){
   //         [locationDistances removeObjectForKey:thisLoc];
   //     }
   // }
    
    int minDistance = 10000;
    NSArray *keys = [locationDistances allKeys];
    for(id key in keys){
       // BoardLocation *thisLoc = [locationDistances objectForKey:key];
        int distanceToTarget = [[locationDistances objectForKey:key] intValue];
       // NSLog(@"distanceToTarget = %d", distanceToTarget);
        if(distanceToTarget < minDistance){
            retLoc = key;
            minDistance = distanceToTarget;
        }
    }
    
    NSArray *retPath = [moveCard validatedPath:[self pathToBoardLocation:retLoc]];
    if(retPath){
        return retPath;
    }
    else{
        return NULL;
    }
}

-(BoardLocation*)closestLocationInTileSet:(NSArray*)tileSet{
    int minPath = 100000;
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

-(BOOL)isInShootingRange{
    Card *kickCard;
    if(self.kickDeck.inHand && [self.kickDeck.inHand count]){
        kickCard = self.kickDeck.inHand[0];
        NSArray *kickSelect = [kickCard validatedSelectionSet];
        if([kickSelect containsObject:self.manager.goal]){
            return TRUE;
        }
        else{
            return FALSE;
        }

    }
    else{
        return FALSE;
    }
}

-(NSArray*)playersInPassRange{
    NSMutableArray* retPlayers = [NSMutableArray array];
    NSArray* players = [self.manager playersClosestToBall];
    Card *passCard = self.kickDeck.inHand[0];
    for(Player *p in players){
        NSArray *pathToPlayer = [self pathToBoardLocation:p.location];
        if(p != self && [pathToPlayer count] <= passCard.range){
            [retPlayers addObject:p];
        }
    }
    return retPlayers;
}

-(Player *)passToAvailablePlayerInShootingRange{
    NSArray *playersInPassRange = [self playersInPassRange];
    NSArray *playersInShootingRange = [self.manager playersInShootingRange];
    NSLog(@"passToPlayerInShootingRange -- playersInPassRange[count] = %d, playersInShootingRange[count] = %d", [playersInPassRange count], [playersInShootingRange count]);
    NSArray *playersIntersect = [BoardLocation tileSetIntersect:playersInShootingRange withTileSet:playersInPassRange];
    if(playersIntersect){
        for(Player *p in playersIntersect){
            if(p != self && !p.used){
                return playersIntersect[0];
            }
        }
    }
    return NULL;
}

-(NSArray *)playersAvailableCloserToGoal{
    NSArray *players = self.manager.players.inGame;
    NSArray *myPath = [self pathToGoal];
    NSMutableArray *retPlayers = [[NSMutableArray alloc] init];
    for(Player *p in players){
        if(p != self){
            NSArray *path = [p pathToGoal];
            if([path count] < [myPath count]){
                [retPlayers addObject:p];
            }
        }
    }
    return retPlayers;
}
-(NSArray *)playersAvailableInKickRangeCloserToGoal{
    NSArray *closerToGaol = [self playersAvailableCloserToGoal];
    if(closerToGaol){
        NSArray *playersInPassRange = [self playersInPassRange];
        if(playersInPassRange) {
            return [BoardLocation tileSetIntersect:closerToGaol withTileSet:playersInPassRange];
        }
    }
    else{
        return NULL;
    }
}

-(BOOL)canMoveToChallenge{
    NSArray* pathToChallenge = [self pathToClosestAdjacentBoardLocation:_ball.location];
    Card* moveCard = self.moveDeck.inHand[0];
    if(!pathToChallenge){
        return FALSE;
    }
    if([moveCard validatedPath:pathToChallenge]){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

// returns a dictionary of Player->Path pairs that correspond to the board after self moves to location
-(NSDictionary*)playersDistanceAfterMove:(BoardLocation*)location{
    NSMutableArray *allPlayers = [self.manager.players.inGame mutableCopy];
    [allPlayers addObjectsFromArray:self.manager.opponent.players.inGame];
    [allPlayers removeObject:self];
    
    NSMutableDictionary *playersDict = [[NSMutableDictionary alloc] init];
    for(Player *p in allPlayers){
        NSArray *path = [p pathToBoardLocation:location];
        if(path){
            [playersDict setObject:path forKey:p];
        }
    }
    return playersDict;
}


-(int)distanceAfterMoveToClosestPlayer:(BoardLocation *)location{
    NSDictionary *playersDistanceDict = [self playersDistanceAfterMove:location];
    NSArray *players = [playersDistanceDict allKeys];
    int count = -1;
    for(Player *p in players){
        NSArray *path = [playersDistanceDict objectForKey:p];
        if(path){
            if(count == -1 || [path count] < count){
                count = [path count];
            }
        }
    }
    return count;
}


-(int)distanceAfterMoveToClosestOpponent:(BoardLocation *)location{
    NSDictionary *playersDistanceDict = [self playersDistanceAfterMove:location];
    NSArray *players = [playersDistanceDict allKeys];
    int count = -1;
    for(Player *p in players){
        if(p.manager.teamSide != self.manager.teamSide){
            NSArray *path = [playersDistanceDict objectForKey:p];
            if(path){
                if(count == -1 || [path count] < count){
                    count = [path count];
                }
            }
        }
    }
    return count;
}


-(int)distanceAfterMoveToClosestTeammate:(BoardLocation *)location{
    NSDictionary *playersDistanceDict = [self playersDistanceAfterMove:location];
    NSArray *players = [playersDistanceDict allKeys];
    int count = -1;
    for(Player *p in players){
        if(p.manager.teamSide == self.manager.teamSide){
            NSArray *path = [playersDistanceDict objectForKey:p];
            if(path){
                if(count == -1 || [path count] < count){
                    count = [path count];
                }
            }
        }
    }
    return count;
}


@end
