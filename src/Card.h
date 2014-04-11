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

enum AI_ACTION_TYPE {
    NONE,
    MOVE_TO_GOAL,
    SHOOT_ON_GOAL,
    PASS_TO_PLAYER_IN_SHOOTING_RANGE,
    PASS_TO_GOAL,
    CHALLENGE,
    MOVE_TO_CHALLENGE,
    MOVE_TO_DEFENDGOAL,
    MOVE_TO_BALL
};

@class BoardLocation;
@class Manager;
@class Abilities;
@class Game;

@interface Card : NSObject <NSCopying, NSCoding>

-(id) initWithDeck:(Deck*)deck;



// PERSISTENT
-(CardCategory)category;
@property (nonatomic) CardCategory specialCategory;

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

// INTEROGATION

-(BOOL)isTemporary;
-(EventType)discardAfterEventType;
-(NSString*) descriptionForCard;
-(Game*)game;
-(NSArray*)validatedSelectionSet;
-(NSArray*)selectionSet;

@property (nonatomic, weak) Deck *deck;
@property (nonatomic, weak) Player *enchantee;

-(void)play;
-(void)discard;

@property (nonatomic) enum AI_ACTION_TYPE aiActionType;

@end

@interface Abilities : NSObject <NSCopying, NSCoding>

@property (nonatomic) BOOL persist;
@property (nonatomic) int32_t kick;      // Player
@property (nonatomic) int32_t move;      // Player
@property (nonatomic) int32_t challenge; // Player (handling)

-(void)add:(Abilities*)modifier;

@end