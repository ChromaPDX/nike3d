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
@class SkillEvent;
@class Card;
@class BoardLocation;

@interface GameAction : NSObject <NSCoding>

+(instancetype) action;

@property (nonatomic, strong) NSMutableArray *skillEvents;

@property (nonatomic) float totalModifier;
@property (nonatomic) float totalSucess;
@property (nonatomic) int totalCost;
@property (nonatomic) int boost;
@property (nonatomic) int tag;
@property (nonatomic) BOOL wasSuccessful;

@property (nonatomic) float roll;

-(ActionType)type;
-(Card*)playerPerformingAction;
-(Card*)playerReceivingAction;

-(BOOL)isRunningAction;
-(Manager*)manager;
-(NSString*)nameForAction;

@end

@interface SkillEvent : NSObject <NSCoding>

// NON-PERSISTENT
@property (nonatomic, weak) Card *playerPerformingAction;
@property (nonatomic, weak) Card *playerReceivingAction;
@property (nonatomic, weak) Manager *manager;
@property (nonatomic, weak) GameAction *parent;
@property (nonatomic) float totalModifier;
@property (nonatomic) float success;

//PERSISTENT
@property (nonatomic) ActionType type;
@property (nonatomic) int teamSide;
@property (nonatomic) int actionSlot;
@property (nonatomic) int actionCost;
@property (nonatomic, strong) BoardLocation *location;
@property (nonatomic, strong) BoardLocation *startingLocation;
@property (nonatomic, strong) BoardLocation *scatter;
@property (nonatomic) NSInteger seed;
//@property (nonatomic) BOOL wasSuccessful;

+(instancetype) eventForAction:(GameAction*)action;
-(NSString*)nameForAction;
-(BOOL)isRunningEvent;
-(BOOL)isDeployEvent;

@end
