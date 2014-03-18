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

@interface Deck : NSObject <NSCoding, NSCopying>

{
    int shuffleCount;
}
@property (nonatomic,strong) NSArray *allCards;

@property (nonatomic,strong) NSArray *theDeck;
@property (nonatomic,strong) NSArray *discarded;
@property (nonatomic,strong) NSArray *inGame;
@property (nonatomic,strong) NSArray *inHand;

@property (nonatomic,weak) Manager *manager;

@property (nonatomic) NSInteger seed;

-(id)initWithManager:(Manager*)m;

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
