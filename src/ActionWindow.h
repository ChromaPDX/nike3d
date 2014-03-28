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
@class ActionWindow;

@interface PlayerHand : NKNode
{
    CGSize cardSize;
}
    @property (nonatomic, weak) ActionWindow* delegate;
    @property (nonatomic, weak) Player* player;
    @property (nonatomic, strong) NSMutableDictionary *cardSprites;
    @property (nonatomic, strong) NSMutableArray *myCards;
    @property (nonatomic, strong) NKLabelNode *playerName;

    -(instancetype)initWithPlayer:(Player*)p delegate:(ActionWindow*)delegate;
    -(void)addCard:(Card*)card;
    -(void)removeCard:(Card*)card;
    -(void)sortCards;
    -(void)shuffleAroundCard:(CardSprite*)card;
@end

@interface ActionWindow : NKSpriteNode

@property (nonatomic, strong) NSMutableDictionary *playerHands;

@property (nonatomic, weak) GameScene *delegate;
@property (nonatomic, weak) Player* selectedPlayer;
@property (nonatomic, weak) Card* selectedCard;

-(CardSprite*)spriteForCard:(Card*)c;

@property (nonatomic) BOOL enableSubmitButton;
@property (nonatomic, strong) AlertSprite *alert;

-(void)refreshCardsForPlayer:(Player*)p;

-(void)cardTouchMoved:(CardSprite*)card atPoint:(CGPoint)point;
-(void)cardTouchBegan:(CardSprite*)card atPoint:(CGPoint)point;
-(void)cardTouchEnded:(CardSprite*)card atPoint:(CGPoint)point;

-(BoardLocation*)canPlayCard:(Card*)card atPosition:(CGPoint)pos;

-(void)setActionButtonTo:(NSString*)function;
-(void)cleanup;

@end
