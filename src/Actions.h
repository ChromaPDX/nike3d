//
//  Actions.h
//  ChromaNSFW
//
//  Created by Robby Kraft on 9/30/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardTypes.h"

@class Manager;
@class GameEvent;
@class Card;
@class BoardLocation;

@interface GameSequence : NSObject <NSCoding>

+(instancetype) action;

@property (nonatomic, strong) NSMutableArray *GameEvents;

@property (nonatomic) float totalModifier;
@property (nonatomic) float totalSucess;
@property (nonatomic) int totalCost;
@property (nonatomic) int boost;
@property (nonatomic) int tag;
@property (nonatomic) BOOL wasSuccessful;

@property (nonatomic) float roll;

-(EventType)type;
-(Player*)playerPerformingAction;
-(Player*)playerReceivingAction;

-(BOOL)isRunningAction;
-(Manager*)manager;
-(NSString*)nameForAction;

@end

@interface GameEvent : NSObject <NSCoding>

// NON-PERSISTENT
@property (nonatomic, weak) Player *playerPerformingAction;
@property (nonatomic, weak) Player *playerReceivingAction;

@property (nonatomic, weak) Deck *deck;
@property (nonatomic, weak) Manager *manager;
@property (nonatomic, weak) Card *card;

@property (nonatomic, weak) GameSequence *parent;
@property (nonatomic) float totalModifier;
@property (nonatomic) float success;

//PERSISTENT
@property (nonatomic) EventType type;
@property (nonatomic) int teamSide;
@property (nonatomic) int actionSlot;
@property (nonatomic) int actionCost;
@property (nonatomic, strong) BoardLocation *location;
@property (nonatomic, strong) BoardLocation *startingLocation;
@property (nonatomic, strong) BoardLocation *scatter;
@property (nonatomic) NSInteger seed;
//@property (nonatomic) BOOL wasSuccessful;

+(instancetype) eventForAction:(GameSequence*)action;
-(NSString*)nameForAction;
-(BOOL)isRunningEvent;
-(BOOL)isDeployEvent;

@end
