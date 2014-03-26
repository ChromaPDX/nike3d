//
//  Manager.h
//  CardDeck
//
//  Created by Robby Kraft on 9/17/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class Deck;

@interface Manager : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *name;


// Game Engine

@property (nonatomic) int teamSide;
@property (nonatomic) int ActionPoints;

// Meta Data

@property (nonatomic) NSArray *players;
@property (nonatomic) NSMutableArray *playersMutable;
@property (nonatomic) NSMutableArray *cardsInGame;

@property (nonatomic, strong) SKColor *color;

@property (nonatomic) int actionPointsEarned;
@property (nonatomic) int actionPointsSpent;
@property (nonatomic) int attemptedGoals;
@property (nonatomic) int successfulGoals;
@property (nonatomic) int attemptedPasses;
@property (nonatomic) int successfulPasses;
@property (nonatomic) int attemptedSteals;
@property (nonatomic) int successfulSteals;
@property (nonatomic) int playersDeployed;
@property (nonatomic) int cardsDrawn;
@property (nonatomic) int cardsPlayed;

@property (nonatomic, weak) Manager *opponent;

-(bool)hasPossesion;
-(Card*)cardInDeckAtLocation:(BoardLocation*)location;
-(Card*)cardInHandAtlocation:(BoardLocation*)location;

@end