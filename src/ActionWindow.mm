
#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"

@interface ActionWindow () {
    NKSpriteNode *fieldHUD;
    NKSpriteNode *fieldHUDSelectionBar;
    CGSize cardSize;
    float w;
    float h;
}
@end

@implementation ActionWindow

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    
    self = [super initWithTexture:Nil color:color size:size];
    
    if (self) {
        
        //self.userInteractionEnabled = YES;
        
        w = size.width;
        h = size.height;
        
        //self.color = [NKColor colorWithRed:.7 green:.7 blue:.7 alpha:1.];
        
        
        
        _myCards = [NSMutableOrderedSet orderedSetWithCapacity:7];
        _opCards = [NSMutableOrderedSet orderedSetWithCapacity:7];
        _cardSprites = [NSMutableDictionary dictionary];
        
        cardSize.width = w;
        cardSize.height = w*1.4;
        
//        
//        NKLabelNode *yourCards = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [yourCards setText:@"YOUR CARDS"];
//        [yourCards setFontSize:TILE_SIZE/4.];
//        [yourCards setFontColor:[UIColor whiteColor]];
//        [yourCards setVerticalAlignmentMode:NKLabelVerticalAlignmentModeTop];
//        [yourCards setPosition:CGPointMake(0, h*.485)];
//        [self addChild:yourCards];
//        
//        // action points window stuff
//        _turnTokensWindow = [[NKSpriteNode alloc] initWithTexture:nil color:color size:CGSizeMake(size.width, size.width*1.2)];
//        
//        NKSpriteNode *bottomShadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"shadowUp"] color:Nil size:CGSizeMake(self.size.width, 20)];
//        [bottomShadow setAlpha:1.];
//        //[bottomShadow setBlendMode:NKBlendModeSubtract];
//        [bottomShadow setPosition:CGPointMake(0,_turnTokensWindow.size.height*.5+10)];
//        [_turnTokensWindow addChild:bottomShadow];
//        
//        
//        _turnTokenCount = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [_turnTokenCount setText:@"#"];
//        [_turnTokenCount setFontSize:TILE_SIZE/2.];
//        [_turnTokenCount setFontColor:[UIColor whiteColor]];
//        [_turnTokenCount setPosition:CGPointMake(_turnTokensWindow.size.width*.28, _turnTokensWindow.size.height*.1)];
        
        //        NKSpriteNode *topShadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"shadowUp"] color:Nil size:CGSizeMake(self.size.width, 20)];
        //        [topShadow setZRotation:M_PI];
        //        [topShadow setAlpha:0.5];
        //        [topShadow setPosition:CGPointMake(0,self.size.height*.4)];
        //        [self addChild:topShadow];
        
//        _opTokenCount = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [_opTokenCount setText:@"#"];
//        [_opTokenCount setFontSize:TILE_WIDTH/4.];
//        [_opTokenCount setFontColor:[UIColor whiteColor]];
//        [_opTokenCount setPosition:CGPointMake(self.scene.size.width - WINDOW_WIDTH*.5 - cardSize.width*.125, self.size.height*.5 - TILE_SIZE/2.)];
//        
//        
//        NKLabelNode *turnTokenDescription = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [turnTokenDescription setFontColor:[UIColor whiteColor]];
//        [turnTokenDescription setText:@"ACTION"];
//        [turnTokenDescription setFontSize:TILE_SIZE/4.];
//        [turnTokenDescription setHorizontalAlignmentMode:NKLabelHorizontalAlignmentModeCenter];
//        [turnTokenDescription setPosition:CGPointMake(-_turnTokensWindow.size.height*.125, _turnTokensWindow.size.height*.23)];
//        [_turnTokensWindow addChild:turnTokenDescription];
//        NKLabelNode *turnTokenDescription2 = [[NKLabelNode alloc] initWithFontNamed:@"TradeGothicLTStd-BdCn20"];
//        [turnTokenDescription2 setFontColor:[UIColor whiteColor]];
//        [turnTokenDescription2 setText:@"POINTS"];
//        [turnTokenDescription2 setHorizontalAlignmentMode:NKLabelHorizontalAlignmentModeCenter];
//        [turnTokenDescription2 setFontSize:TILE_SIZE/4.];
//        [turnTokenDescription2 setPosition:CGPointMake(-_turnTokensWindow.size.height*.125, _turnTokensWindow.size.height*.05)];
//        [_turnTokensWindow addChild:turnTokenDescription2];
//        
//        [_turnTokensWindow addChild:_turnTokenCount];
//        
//        [_turnTokensWindow setPosition:CGPointMake(0, -self.size.height*.5+_turnTokensWindow.size.height*.5)];
//        [self addChild:_turnTokensWindow];
//        
//        
//        
//        [self addChild:_opTokenCount];
//        
//        [_opTokenCount setZPosition:8];
        
        
        ButtonSprite *ap = [ButtonSprite buttonWithNames:@[@"", @""] color:@[[NKColor clearColor],[NKColor clearColor]] type:ButtonTypePush size:CGSizeMake(size.width*.66, cardSize.height/3)];
        [ap setPosition:CGPointMake(0, _turnTokensWindow.size.height*.23)];
        
        ap.delegate = self;
        ap.method = @selector(cheatGetPoints:);
        [_turnTokensWindow addChild:ap];
        
        [_turnTokensWindow setZPosition:8];
        
        
    }
    return self;
}

-(void)setActionButtonTo:(NSString *)function {
    
    
//    
//    if (!function) {
//        
//        [self fadeOutSprite:_actionButton time:CARD_ANIM_DUR];
//        return;
//        
//    }
//    
//    BOOL new = YES;
//    
//    if (_actionButton.parent) {
//        new = NO;
//        [_actionButton removeFromParent];
//    }
//    
//    if ([function isEqualToString:@"end"]) {
//        
//        
//        _actionButton = [ButtonSprite buttonWithTextureOn:[NKTexture textureWithImageNamed:@"Button_EndTurnON"] TextureOff:[NKTexture textureWithImageNamed:@"Button_EndTurnOFF"] type:ButtonTypePush size:CGSizeMake(TILE_SIZE*UI_MULT, TILE_SIZE*UI_MULT)];
//        [_actionButton setPosition:CGPointMake(self.size.width-(TILE_SIZE*.5),TILE_SIZE*.5)];
//        _actionButton.delegate = _delegate;
//        _actionButton.method = @selector(endTurn:);
//        
//    }
//    
//    else if ([function isEqualToString:@"draw"]) {
//        
//        
//        _actionButton = [ButtonSprite buttonWithTextureOn:[NKTexture textureWithImageNamed:@"Button_DrawCardON"] TextureOff:[NKTexture textureWithImageNamed:@"Button_DrawCardOFF"] type:ButtonTypePush size:CGSizeMake(TILE_SIZE*UI_MULT, TILE_SIZE*UI_MULT)];
//        [_actionButton setPosition:CGPointMake(self.size.width-(TILE_SIZE*.5),TILE_SIZE*.5)];
//        _actionButton.delegate = _delegate;
//        _actionButton.method = @selector(drawCard:);
//        
//    }
//    
//    [_actionButton setPosition:CGPointMake(0, -_turnTokensWindow.size.height*.25)];
//    
//    if (new) {
//        [_turnTokensWindow fadeInSprite:_actionButton duration:CARD_ANIM_DUR];
//    }
//    else {
//        [_turnTokensWindow addChild:_actionButton];
//    }
    
}

#pragma mark METHODS TO MODEL / DELEGATE

//-(void) setupHUD{
//    fieldHUD = [[NKSpriteNode alloc] initWithTexture:[_delegate.sharedAtlas textureNamed:@"soccer_field_mini"]  color:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0] size:CGSizeMake(75*1.35, 75)];
//    [fieldHUD setAlpha:0.75];
//    [fieldHUD setPosition:CGPointMake(self.size.width/2. - self.size.height*.4, .2*self.size.height)];
//    [self addChild:fieldHUD];
//    fieldHUDSelectionBar = [[NKSpriteNode alloc] initWithTexture:Nil color:[UIColor colorWithWhite:1.0 alpha:0.33] size:CGSizeMake(fieldHUD.size.width*.1,fieldHUD.size.height)];
//    [fieldHUDSelectionBar setPosition:CGPointMake(fieldHUD.position.x, fieldHUD.position.y)];
//    [self addChild:fieldHUDSelectionBar];
//}
//-(void)refreshFieldHUDXOffset:(NSInteger)xOffset{
//    if(!fieldHUD) [self setupHUD];
//    [fieldHUDSelectionBar setPosition:CGPointMake(fieldHUD.position.x-(8-xOffset)/15.0*fieldHUD.size.width, fieldHUD.position.y)];
//}

-(void)cheatGetPoints:(ButtonSprite*)sender {
    [_delegate.game cheatGetPoints];
}

-(void)shouldPerformAction:(ButtonSprite*)sender {
    [_delegate.game playTouchSound];
    [_delegate shouldPerformCurrentAction];
}

-(void) setEnableSubmitButton:(BOOL)enableSubmitButton{
    _enableSubmitButton = enableSubmitButton;
    if(_enableSubmitButton){
        [_actionButton setOnTexture:[NKTexture textureWithImageNamed:@"Button_Submit_on"]];
        [_actionButton setOffTexture:[NKTexture textureWithImageNamed:@"Button_Submit_off"]];
    }
    else{
        [_actionButton setOnTexture:[NKTexture textureWithImageNamed:@"Button_Submit_gray"]];
        [_actionButton setOffTexture:[NKTexture textureWithImageNamed:@"Button_Submit_gray"]];
    }
    [_actionButton setState:_actionButton.state];
}

#pragma mark METHODS FROM MODEL / DELEGATE

-(void)alertDidCancel {
    
    [self fadeOutChild:_alert duration:1.];
    
    [self setZPosition:Z_BOARD_LOW];
    
    [self sortMyCards:YES WithCompletionBlock:^{ }];
    
    
}



-(void)addStartTurnCard:(Card *)card withCompletionBlock:(void (^)())block{
    
    [self setZPosition:Z_INDEX_FX];
    
    _alert = [[AlertSprite alloc] initWithTexture:[NKTexture textureWithImageNamed:@"YOUR_TURN_BOX"] color:nil size:CGSizeMake(cardSize.width*2.5, cardSize.height*1.6)];
    
    _alert.delegate = self;
    [_alert setZPosition:Z_INDEX_FX];
    
    [_alert setPosition:CGPointMake(0, 0)];
    
    [self fadeInChild:_alert duration:.5];
    
    CardSprite* newCard = [[CardSprite alloc] initWithTexture:nil color:nil size:cardSize ];
    
    newCard.delegate = _delegate;
    newCard.model = card;
    newCard.window = self;
    
    if (![self cardIsMine:card]) {
        [newCard setScale:.5];
        [newCard setFlipped:YES];
    }
    
    [_cardSprites setObject:newCard forKey:card];
    
    [self addChild:newCard];
    
    
    [_myCards addObject:newCard];
    
    
    
    
    [newCard setZPosition:Z_INDEX_FX];
    //[newCard setHasShadow:YES];
    
    [newCard runAction:[NKAction scaleTo:1.3 duration:.15]];
    [newCard runAction:[NKAction sequence:@[[NKAction moveTo:CGPointMake(0, -cardSize.height*.125) duration:.1],
                                            [NKAction moveBy:CGVectorMake(0, 0) duration:.4]]]
            completion:^{
                //                        [self sortMyCards:YES WithCompletionBlock:^{
                //                            block();
                //                        }];
                block();
                
            }];
    
    
    
    
    
    
    
    
    
}


-(void)addCard:(Card *)card {
    
    [self addCard:card animated:NO withCompletionBlock:^{}];
    
}

-(void)addCard:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    CardSprite* newCard = [[CardSprite alloc] initWithTexture:nil color:nil size:cardSize ];
    
    newCard.delegate = _delegate;
    newCard.model = card;
    newCard.window = self;
    
    if (![self cardIsMine:card]) {
        [newCard setScale:.5];
        [newCard setFlipped:YES];
    }
    
    [_cardSprites setObject:newCard forKey:card];
    
    [self addChild:newCard];
    
    if ([self cardIsMine:card]) {
        [_myCards addObject:newCard];
        
        
        
        if (animated) {
            
            [newCard setZPosition:Z_INDEX_FX];
            [newCard setHasShadow:YES];
            
            [newCard runAction:[NKAction scaleTo:1.3 duration:.15]];
            [newCard runAction:[NKAction sequence:@[[NKAction moveTo:CGPointMake(0, 0) duration:.1],
                                                    [NKAction moveBy:CGVectorMake(0, 0) duration:.4]]]
                    completion:^{
                        [self sortMyCards:animated WithCompletionBlock:^{
                            block();
                        }];
                        
                    }];
            
        }
        else {
            [self sortMyCards:animated WithCompletionBlock:^{
                block();
            }];
        }
    }
    
    else {
        [_opCards addObject:newCard];
        newCard.position = CGPointMake(0, self.size.height*.5);
        [self sortOpCards:NO WithCompletionBlock:^{
            block();
        }];
    }
    
    
    
}


-(BOOL)cardIsMine:(Card*)card {
    
    if ([card.manager isEqual:_delegate.game.me]) return 1;
    return 0;
}


-(void)removeCard:(Card *)card {
    
    [self removeCard:card animated:NO withCompletionBlock:^{}];
    
}

-(void)removeCard:(Card *)card animated:(BOOL)animated withCompletionBlock:(void (^)())block{
    
    CardSprite *cardToRemove = [_cardSprites objectForKey:card];
    
    if (cardToRemove) {
        
        if ([self cardIsMine:card]){
            [_myCards removeObject:cardToRemove];
            
            [self sortMyCards:animated WithCompletionBlock:^{
                block();
            }];
        }
        else {
            [_opCards removeObject:cardToRemove];
            
            [self sortOpCards:animated WithCompletionBlock:^{
                block();
            }];
        }
        
        [_cardSprites removeObjectForKey:card];
        
        
    }
}

-(void)shuffleAroundCard:(CardSprite*)card {
    
    
    float cardBottom = card.position.y - (card.size.height*.95);
    float toTop = h*.3 - card.position.y;
    float toBottom = cardBottom + h*.35;
    
    for (int i = 0; i < _myCards.count; i++) {
        
        CardSprite *cs = _myCards[i];
        
        if (![cs isEqual:card]) {
            
            [cs setAlpha:1.];
            cs.order = i;
            cs.zPosition = i;
            
            if (cs.order < card.order) {
                
                cs.origin = CGPointMake(0, (h*.3) - (toTop * (i / (float)card.order)));
            }
            
            else {
                
                float newY = (cardBottom) - (toBottom * ((float)(cs.order - (card.order+1)) / (_myCards.count - card.order)));
                if (newY < -h*.35) newY = -h*.35;
                
                cs.origin = CGPointMake(0, newY);
                //cs.origin = CGPointMake(0, card.position.y - (card.size.height) - (cardSize.height*.15 * (i - (card.order + 1))));
            }
            
            NKAction *move = [NKAction moveTo:cs.origin duration:FAST_ANIM_DUR];
            [move setTimingMode:NKActionTimingEaseOut];
            
            [cs runAction:move];
            // [cs setPosition:cs.origin];
        }
        
        
        
    }
    
    
}

-(void)sortMyCards:(BOOL)animated WithCompletionBlock:(void (^)())block{
    
    //NSLog(@"I HAVE %d CARD SPRITES IN MY HAND", _myCards.count);
    // MYCARDS
    
    if (_delegate.game.myTurn) {
        [_delegate.game sendRTPacketWithType:RTMessageSortCards point:nil];
    }
    
    for (int i = 0; i < _myCards.count; i++) {
        
        CardSprite *cs = _myCards[i];
        
        cs.order = i;
        cs.zPosition = i;
        if (cs.hasShadow) {
            [cs setHasShadow:NO];
        }
        
        [cs setAlpha:1.];
        
        
        cs.origin = CGPointMake(0, (h*.3) - ((cardSize.height*.15 + (h*.125)* (2./_myCards.count) ) * i));
        
        if (animated) {
            
            if (cs.hasActions){
                [cs removeAllActions];
            }
            
            [cs runAction:[NKAction scaleTo:1. duration:CARD_ANIM_DUR]];
            NKAction *move = [NKAction moveTo:cs.origin duration:CARD_ANIM_DUR];
            [move setTimingMode:NKActionTimingEaseIn];
            [cs runAction:move];
        }
        
        else {
            [cs setPosition:cs.origin];
        }
        
    }
    
    if (animated) {
        
        [self runAction:[NKAction moveByX:0 y:0 duration:FAST_ANIM_DUR] completion:^{
            block();
        }];
    }
    
    else {
        block();
    }
    
    
}

-(void)sortOpCards:(BOOL)animated WithCompletionBlock:(void (^)())block{
    
    // OPPONENTS CARDS
    
    for (int i = 0; i < _opCards.count; i++) {
        CardSprite *cs = _opCards[i];
        cs.order = i;
        cs.zPosition = i + 2;
        //cs.origin = CGPointMake(self.scene.size.width - WINDOW_WIDTH*.5 - cardSize.width*.125, self.size.height*.5 - cardSize.height*.125);
        cs.origin = CGPointMake(self.scene.size.width,0);
        
        if (animated) {
            [cs runAction:[NKAction moveTo:cs.origin duration:FAST_ANIM_DUR]];
        }
        
        else {
            [cs setPosition:cs.origin];
        }
        
    }
    
    if (animated) {
        [self runAction:[NKAction moveByX:0 y:0 duration:FAST_ANIM_DUR] completion:^{
            block();
        }];
    }
    
    else {
        block();
    }
    
    
}


-(void)swapCard:(CardSprite*)c withCard:(CardSprite*)c2 {
    
}

-(void)cleanup {
    
    for (CardSprite *c in _cardSprites.allValues) {
        [_cardSprites removeObjectForKey:c.model];
        [c removeFromParent];
    }
    
    _myCards = [NSMutableOrderedSet orderedSetWithCapacity:7];
    _opCards = [NSMutableOrderedSet orderedSetWithCapacity:7];
    _cardSprites = [NSMutableDictionary dictionary];
    
}

-(void)opponentBeganCardTouch:(Card*)c atPoint:(CGPoint)point {
    
    CardSprite *card = [_cardSprites objectForKey:c];
    
    _delegate.selectedCard = c;
    
    card.realPosition = CGPointMake(self.scene.size.width-point.x, -point.y);
    
    card.touchOffset = CGPointMake(0, 0);
    
    [card setZPosition:Z_INDEX_HUD];
    
    [card setHasShadow:NO];
    
    [card runAction:[NKAction customActionWithDuration:FAST_ANIM_DUR actionBlock:^(NKNode *node, CGFloat elapsedTime){
        
        //float xmod = 0;
        
        //        if (card.realPosition.x > WINDOW_WIDTH*.5) {
        //            xmod = card.realPosition.x - WINDOW_WIDTH*.5;
        //        }
        
        [card setPosition:CGPointMake((self.scene.size.width - cardSize.width*.125), card.origin.y * (1.-(elapsedTime/FAST_ANIM_DUR)))];
        
    }]];
    
    
}

-(void)opponentMovedCardTouch:(Card*)c atPoint:(CGPoint)point {
    
    //   if (point.x > WINDOW_WIDTH*.5) {
    
    CardSprite *card = [_cardSprites objectForKey:c];
    
    card.realPosition = CGPointMake(self.scene.size.width-point.x, -point.y);
    
    if (!card.hasActions) {
        [card setPosition:card.realPosition];
    }
    
    
    //   }
    
    
    
}


-(void)cardTouchBegan:(CardSprite*)card atPoint:(CGPoint)point {
    
    if (_alert) {
        [self fadeOutChild:_alert duration:1.];
        [card runAction:[NKAction scaleTo:1. duration:.15]];
        [card setHasShadow:YES];
        card.hovering = YES;
        
    }
    
    if ([self cardIsMine:card.model]) {
        
        [_delegate.game setCurrentAction:Nil];
        
        if (point.x > self.size.width*.5) {
            [self setZPosition:Z_INDEX_BOARD];
            [card setZPosition:Z_INDEX_HUD];
        }
        else {
            [self shuffleAroundCard:card];
        }
        
        card.origin = card.position;
        card.realPosition = card.origin;
        
        _delegate.currentCard = card.model;
        
        [_delegate.game sendRTPacketWithCard:card.model point:point began:YES];
        
    }
    
    
}

-(void)cardTouchMoved:(CardSprite*)card atPoint:(CGPoint)point {
    
    if ([self cardIsMine:card.model]) {
        
        
        
        if (point.x > self.size.width*.75) {
            
            card.realPosition = point;
            
            
            if (!card.hasShadow) {
                [card setZPosition:Z_INDEX_HUD];
                
                [card setHasShadow:YES];
                
                [card runAction:[NKAction customActionWithDuration:CARD_ANIM_DUR actionBlock:^(NKNode *node, CGFloat elapsedTime){
                    float complete = 0.;
                    
                    
                    complete = (elapsedTime / CARD_ANIM_DUR);
                    //NSLog(@"complete %f", complete);
                    
                    
                    
                    float xAn = card.realPosition.x * complete;
                    
                    float yDiff = card.realPosition.y - card.origin.y;
                    
                    float YAn = (card.origin.y + (yDiff * complete));
                    
                    [card setPosition:CGPointMake(xAn, YAn)];
                    
                }] completion:^{
                    card.hovering = YES;
                }
                 
                 ];
                
            }
            
            if (card.hovering) {
                if ([_delegate canPlayCard:card.model atPosition:point]) {
                    
                }
                else {
                    [card setPosition:card.realPosition];
                    [_delegate.game sendRTPacketWithCard:card.model point:point began:NO];
                }
                
                
            }
            
            
        }
        
        else if (card.hovering && point.x < self.size.width*.7) {
            
            [_delegate resetFingerLocation];
            
            card.hovering = NO;
            
            [card setHasShadow:NO];
            
            card.realPosition = CGPointMake(point.x - card.touchOffset.x, point.y - card.touchOffset.y);
            card.origin = CGPointMake(0, card.realPosition.y);
            
            [card runAction:[NKAction fadeAlphaTo:1. duration:.1]];
            
            [card runAction:[NKAction moveTo:card.origin duration:FAST_ANIM_DUR] completion:^{
            }];
            
            if (_delegate.game.currentAction) {
                [_delegate.game setCurrentAction:nil];
                [_delegate fadeOutChild:_delegate.infoHUD duration:1.];
            }
            
        }
        
        else if (point.x < self.size.width*.7){
            
            if (!card.hasActions) {
                
                
                card.realPosition = CGPointMake(point.x - card.touchOffset.x, point.y - card.touchOffset.y);
                card.origin = CGPointMake(0, card.realPosition.y);
                
                
                [card setPosition:card.origin];
                
                [self shuffleAroundCard:card];
                
            }
            
            
        }
        
        
        
    }
    
}

-(void)cardTouchEnded:(CardSprite*)card atPoint:(CGPoint)point {
    
    //    if (point.x < WINDOW_WIDTH*.3) {
    //
    //        [_delegate setCurrentCard:nil];
    //        //[card returnToHand];
    //
    //
    //    }
    
    
    [_delegate resetFingerLocation];
    
}



#pragma mark-TOUCHES
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"Touches:Action Window");
//    [_delegate touchesBegan:touches withEvent:event];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    //NSLog(@"moved");
//    [_delegate touchesMoved:touches withEvent:event];
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    [_delegate touchesEnded:touches withEvent:event];
//    
//}

@end

