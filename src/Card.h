//
//  Card.h
//  CardDeck
//
//  Created by Robby Kraft on

//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardTypes.h"

#pragma mark NSCODER

#define NSFWKeyType @"type"
#define NSFWKeyManager @"manager"
#define NSFWKeyPlayer @"player"
#define NSFWKeyDeck @"deck"
#define NSFWKeyName @"name"
#define NSFWKeyCardLevel @"cardLevel"
#define NSFWKeyCardRange @"cardRange"
#define NSFWKeyActionPointEarn @"actionPointEarn"
#define NSFWKeyActionPointCost @"actionPointCost"
#define NSFWKeyAbilities @"abilities"
#define NSFWKeyNearOpponentModifiers @"nearOpponentModifiers"
#define NSFWKeyNearTeamModifiers @"nearTeamModifiers"
#define NSFWKeyOpponentModifiers @"opponentModifiers"
#define NSFWKeyTeamModifiers @"teamModifiers"

@class BoardLocation;
@class Manager;
@class Abilities;


@interface Card : NSObject <NSCopying, NSCoding>

-(id) initWithDeck:(Deck*)deck;

-(DeckType)deckType;

// PERSISTENT

@property (nonatomic) CardType cardType;

@property (nonatomic, strong) NSString *name;

@property NSInteger actionPointCost;
@property NSInteger actionPointEarn;
@property NSInteger level;
@property NSInteger range;

@property (nonatomic, strong) BoardLocation *location;
@property (nonatomic,strong) Abilities *abilities;
//@property (nonatomic,strong) Abilities *nearTeamModifiers;
//@property (nonatomic,strong) Abilities *teamModifiers;
//@property (nonatomic,strong) Abilities *nearOpponentModifiers;
//@property (nonatomic,strong) Abilities *opponentModifiers;


-(BOOL)isTemporary;

-(EventType)discardAfterEventType;

-(NSString*) descriptionForCard;

@property (nonatomic, weak) Deck *deck;
@property (nonatomic, weak) Player *enchantee;

-(void)play;
-(void)discard;

@end

@interface Abilities : NSObject <NSCopying, NSCoding>

@property (nonatomic) BOOL persist;
@property (nonatomic) int32_t kick;      // Player
@property (nonatomic) int32_t move;      // Player
@property (nonatomic) int32_t challenge; // Player (handling)

-(void)add:(Abilities*)modifier;

@end