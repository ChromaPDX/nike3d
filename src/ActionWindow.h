//
//  NKActionWinow.h
//  nike3dField
//
//  Created by Chroma Developer on 3/18/14.
//
//

#import "NKNode.h"

@class GameScene;
@class Card;
@class CardSprite;
@class ButtonSprite;
@class AlertSprite;

@interface ActionWindow : NKSpriteNode

@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Player* player;

@property (nonatomic, strong) NSMutableOrderedSet *myCards;
@property (nonatomic, strong) NSMutableOrderedSet *opCards;

@property (nonatomic, strong) NSMutableDictionary *cardSprites;

@property (nonatomic, strong) ButtonSprite *actionButton;

@property (nonatomic, strong) NKSpriteNode *turnTokensWindow;
@property (nonatomic, strong) NKLabelNode *turnTokenCount;
@property (nonatomic, strong) NKLabelNode *opTokenCount;

@property (nonatomic) BOOL enableSubmitButton;
@property (nonatomic, strong) AlertSprite *alert;

-(void)refreshCardsForPlayer:(Player*)p;

-(void)addCard:(Card*)card;
-(void)removeCard:(Card*)card;

-(void)addCard:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block;
-(void)removeCard:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block;
-(void)addStartTurnCard:(Card *)card withCompletionBlock:(void (^)())block;

-(void)sortCardsForPlayer:(Player*)p animated:(BOOL)animated WithCompletionBlock:(void (^)())block;

-(void)opponentBeganCardTouch:(Card*)c atPoint:(CGPoint)point;
-(void)opponentMovedCardTouch:(Card*)c atPoint:(CGPoint)point;

-(void)cardTouchMoved:(CardSprite*)card atPoint:(CGPoint)point;
-(void)cardTouchBegan:(CardSprite*)card atPoint:(CGPoint)point;
-(void)cardTouchEnded:(CardSprite*)card atPoint:(CGPoint)point;

-(BoardLocation*)canPlayCard:(Card*)card atPosition:(CGPoint)pos;

-(void)setActionButtonTo:(NSString*)function;
-(void)cleanup;

@end