//
//  Card.h
//  CardDeck
//
//  Created by Robby Kraft on

//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardTypes.h"

@class BoardLocation;




@class Manager;
@class Abilities;

@interface Card : NSObject <NSCopying, NSCoding>

-(id) initWithType:(CardType)cType;
-(id) initWithType:(CardType)cType Manager:(Manager*)m;



// PERSISTENT


@property (nonatomic) CardType cardType;

@property (nonatomic, strong) NSString *name;

@property NSInteger actionPointCost;
@property NSInteger actionPointEarn;

@property (nonatomic, strong) BoardLocation *location;
@property (nonatomic,strong) Abilities *abilities;
@property (nonatomic,strong) Abilities *nearTeamModifiers;
@property (nonatomic,strong) Abilities *teamModifiers;
@property (nonatomic,strong) Abilities *nearOpponentModifiers;
@property (nonatomic,strong) Abilities *opponentModifiers;

@property (nonatomic) BOOL female;

// NON-PERSISTENT

@property (nonatomic, weak) Manager *manager;

// INTERROGATION

-(BOOL)isTypePlayer;
-(BOOL)isTypeKeeper;
-(BOOL)isTypeAction;

-(BOOL)isTypeBoost;
-(BOOL)isTypeSkill;
-(BOOL)isTypeGear;
-(BOOL)isTemporary;
-(ActionType)discardAfterActionType;

-(NSString*) nameForCard;
-(NSString*) descriptionForCard;
-(NSString*) positionForCard;


// this shit's new, and not plugged into anything yet
@property (nonatomic, weak) Card *ball;  // if I'm a player, do i have the ball? (or, NIL)
@property (nonatomic, weak) Card *player;  // if I'm a player, do i have the ball? (or, NIL)
@property (nonatomic, strong) NSArray *enchantments; // array of (Card*) types, cards currently modifying a player card. only used ifTypePlayer

// Enchantment Methods

-(void)addEnchantment:(Card*)enchantment;
-(void)removeEnchantment:(Card*)enchantment;
-(void)removeLastEnchantment;

@end

@interface Abilities : NSObject <NSCopying, NSCoding>

@property (nonatomic) BOOL persist;
@property (nonatomic) float kick;      // Player
@property (nonatomic) float handling;  // Player
@property (nonatomic) float challenge; // Player (handling)
@property (nonatomic) float dribble;   // Player (handling)
@property (nonatomic) float pass;      // Player (kick)
@property (nonatomic) float shoot;     // Player (kick)
@property (nonatomic) float save;      // Keeper

-(void)add:(Abilities*)modifier;

@end