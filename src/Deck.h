//
//  Deck.h
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Card;
@class Manager;
@class Player;

typedef NS_ENUM(int, DeckType){
    
    DeckTypeKick,
    DeckTypeChallenge,
    DeckTypeMove,
    DeckTypeSpecial
    
};

@interface Deck : NSObject <NSCoding, NSCopying>

{
    int shuffleCount;
}

-(id)initWithPlayer:(Player*)p type:(DeckType)type;

// PERSISTENT
@property (nonatomic,strong) NSArray *allCards;
@property (nonatomic,weak) Player *player;
@property (nonatomic) DeckType type;

// NON-PERSISTENT
@property (nonatomic,strong) NSArray *theDeck;
@property (nonatomic,strong) NSArray *discarded;
@property (nonatomic,strong) NSArray *inGame;
@property (nonatomic,strong) NSArray *inHand;

@property (nonatomic,strong) NSString *name;

@property (nonatomic) NSInteger seed;

-(BOOL)discardCardFromGame:(Card*)card;
-(BOOL)discardCardFromDeck:(Card*)card;
-(BOOL)discardCardFromHand:(Card*)card;

-(BOOL)playCardFromHand:(Card*)card;
-(BOOL)playCardFromDeck:(Card*)card;

-(int) randomForIndex:(int)index;
-(NSInteger)newSeed;

-(void)shuffleWithSeed:(NSInteger)seed fromDeck:(NSArray*)deck;
-(void)revertToSeed:(NSInteger)seed fromDeck:(NSArray*)deck;

-(Card*)turnOverNextCard;

@end
