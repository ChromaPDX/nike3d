//
//  CardTypes.h
//  ChromaNSFW
//
//  Created by Chroma Developer on 11/26/13.
//  Copyright (c) 2013 Chroma. All rights reserved.
//

#ifndef ChromaNSFW_CardTypes_h
#define ChromaNSFW_CardTypes_h

typedef enum CardType {
    kCardTypeNull,
    kCardTypePlayerForward,
    kCardTypePlayerMidFielder,
    kCardTypePlayerDefender,
    kCardTypePlayerKeeper,
    kCardTypeActionHeader,
    kCardTypeActionSlideTackle,
    kCardTypeActionKamikazeKick,
    kCardTypeActionCaptainsBand,
    kCardTypeActionAdrenalBoost,
    kCardTypeActionAdrenalFlood,
    kCardTypeActionMercurialAcceleration,
    kCardTypeActionPredictiveAnalysis1,
    kCardTypeActionPredictiveAnalysis2,
    kCardTypeActionNeuralTriggerFear,
    kCardTypeActionAutoPlayerTrackingSystem,
    kBall
} CardType;

typedef enum ActionType {
    kNullAction,
    kRunningAction,
    kDribbleAction,
    kPassAction,
    kShootAction,
    kChallengeAction,
    kDeployEvent,
    kSpawnPlayerEvent,
    kSpawnKeeperEvent,
    kRemovePlayerAction,
    kEnchantAction,
    kPlayCardAction,
    kDrawAction,
    kTurnDrawAction,
    kStartingAction,
    kEndTurnAction,
    kPurgeEnchantmentsAction,
    kMoveFieldAction,
    kStartTurnAction,
    kShuffleAction,
    kGraveyardShuffleAction,
    kReSuffleAction,
    kSetBallAction,
    kGoalResetAction,
    kGoalKickSetup,
    kRandomDeployAction,
    kGoaliePass
    
} ActionType;

#endif
