//
//  CardSprite.m
//  cardGame
//
//  Created by Chroma Dev Pod on 9/17/13.
//  Copyright (c) 2013 ChromaGames. All rights reserved.
//

#import "NikeNodeHeaders.h"
#import "ModelHeaders.h"

@implementation CardSprite

-(instancetype) initWithTexture:(NKTexture *)texture color:(UIColor *)color size:(CGSize)size {
    
    self = [super initWithTexture:nil color:nil size:size];
    if (self) {
        
        _shadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Card_Ipad_shadow"] color:[NKColor blackColor]  size:size];
        [_shadow setZPosition:-1];
        [self addChild:_shadow];
        [_shadow setHidden:YES];
        [_shadow setPosition:CGPointMake(-size.width*.075, size.height*.075)];
        
        //NKSpriteNode *dark = [NKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.0 alpha:0.8] size:CGSizeMake(size.width-2, size.height-2)];
        //[self addChild:dark];
        w = size.width;
        h = size.height;
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(NKLabelNode*)styledLabelNode {
    
    NKLabelNode *node = [NKLabelNode labelNodeWithFontNamed:@"TradeGothicLTStd-BdCn20"];
    node.verticalAlignmentMode = NKLabelVerticalAlignmentModeCenter;
    
    node.fontColor = [NKColor blackColor];
    node.fontSize = h/10.;
    return node;
}

-(void)setHasShadow:(BOOL)hasShadow {
    _hasShadow = hasShadow;
    
    [self showShadow:hasShadow withCompletionBlock:^{
        
    }];
    
}

-(void)showShadow:(BOOL)showShadow withCompletionBlock:(void (^)())block {
    
    if (showShadow) {
        [_shadow setHidden:NO];
        [_shadow setAlpha:0.];
        [_shadow runAction:[NKAction scaleTo:1.2 duration:CARD_ANIM_DUR]];
        [_shadow runAction:[NKAction fadeAlphaTo:.4 duration:CARD_ANIM_DUR] completion:^{
            _hovering = YES;
            block();
        }];
    }
    else {
        
        [_shadow runAction:[NKAction scaleTo:1. duration:CARD_ANIM_DUR]];
        [_shadow runAction:[NKAction fadeAlphaTo:0. duration:CARD_ANIM_DUR] completion:^{
            block();
            [_shadow setHidden:YES];
            _hovering = NO;
        }];
    }
}


-(void)setModel:(Card *)model {
    
    if (model) {
        _model = model;
        
        _art = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Card_Player_Male"] color:[NKColor blueColor] size:CGSizeMake(TILE_WIDTH, TILE_WIDTH*1.3)];
        
        [self addChild:_art];
        
        //[_art setPosition:CGPointMake(0, -h*.05)];
        
        //        cardName = [self styledLabelNode];
        //        cardName.fontSize = (int)(h/10.);
        //        [cardName setPosition:CGPointMake(0, h*.25)];
        //        cardName.text = [model.nameForCard uppercaseString];
        
//        _doubleName = [self spritenodecontaininglabelsFromStringcontainingnewlines:[[model.nameForCard uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"\n"]
//                                                                          fontname:@"TradeGothicLTStd-BdCn20"
//                                                                         fontcolor:[NKColor blackColor] fontsize:h/12.
//                                                                    verticalMargin:0 emptylineheight:0];
        
        [self addChild:_doubleName];
        [_doubleName setPosition:CGPointMake(-w*.38, h*.32)];
        
        cost = [self styledLabelNode];
        cost.text = [NSString stringWithFormat:@"%d", (int)(_model.actionPointCost)];
        cost.position = CGPointMake((int)(w*.33), (int)(h*.23));
        
        NKSpriteNode *apIcon = [NKSpriteNode spriteNodeWithTexture:[NKTexture textureWithImageNamed:@"ActionPointsIconSM"] size:CGSizeMake(w*.07,h*.07)];
        apIcon.position = CGPointMake((int)(w*.27), (int)(h*.23));
        
        [self addChild:apIcon];
        [self addChild:cost];
        
        
        actionPoints = [self styledLabelNode];
        actionPoints.text = [NSString stringWithFormat:@"%d", (int)(_model.actionPointEarn)];
        actionPoints.position = CGPointMake((int)(-w*.38), (int)(-h*.4));
        
        [self addChild:actionPoints];
        
        
        [self setCorrectTexture];
        
        if ([_model isTypePlayer]){
            
            kick = [self styledLabelNode];
            kick.text = [NSString stringWithFormat:@"%d / %d", (int)(_model.abilities.kick * 100),  (int)(_model.abilities.handling * 100)];
            kick.position = CGPointMake(0, (int)-h*.32);
            kick.fontSize = (int)(h/6.);
            
            //            dribble = [self styledLabelNode];
            //            dribble.text = [NSString stringWithFormat:@"%d%%", (int)(_model.abilities.handling * 100)];
            //            dribble.position = CGPointMake(w*.2, (int)(-h*.32));
            //            dribble.fontSize = (int)(h/6.);
            
            [self addChild:kick];
            //  [self addChild:dribble];
            
            //            NKSpriteNode *ballIcon = [NKSpriteNode spriteNodeWithTexture:[[_delegate sharedAtlas] textureNamed:@"icon_pass"] size:CGSizeMake(w*.3, w*.3)];
            //            NKSpriteNode *passIcon = [NKSpriteNode spriteNodeWithTexture:[[_delegate sharedAtlas] textureNamed:@"icon_ball"] size:CGSizeMake(w*.3, w*.3)];
            //            [ballIcon setPosition:CGPointMake(-.25*w, .05*w)];
            //            [passIcon setPosition:CGPointMake(-.25*w, -.3*w)];
            //            [self addChild:ballIcon];
            //            [self addChild:passIcon];
            
            
            //            if (_model.female) {
            //                [_art setTexture:[NKTexture textureWithImageNamed:@"Card_Player_Female"]];
            //            }
            //
            //            else {
            //                [_art setTexture:[NKTexture textureWithImageNamed:@"Card_Player_Male"]];
            //            }
            
        }
    }
}

-(void)setCorrectTexture {
    
    if (!_flipped) {
        
        if ([_model isTypePlayer]){ // Player
            if ([_model.manager isEqual:_delegate.game.me]) {
                self.texture = [NKTexture textureWithImageNamed:@"CardPlayerBlue"];
                self.color = V2BLUE;
            }
            else {
                
                self.texture = [NKTexture textureWithImageNamed:@"CardPlayerRed"];
                self.color = V2RED;
            }
            
        }
        else if([_model isTypeAction]){
            
            NKColor *color;
            
            
            if([_model isTypeSkill]){
                self.texture = [NKTexture textureWithImageNamed:@"CardSkill"];
                color = V2SKILL;
            }
            
            else if([_model isTypeGear]){
                self.texture = [NKTexture textureWithImageNamed:@"CardGear"];
                color = V2GEAR;
            }
            
            else if([_model isTypeBoost]){
                self.texture = [NKTexture textureWithImageNamed:@"CardBoost"];
                color = V2BOOST;
            }
            
            
            self.color = color;
            
            
            [_art setTexture:[NKTexture textureWithImageNamed:[NSString stringWithFormat:@"Card_%@", [[_model nameForCard] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]];
            
        }
        
        [_art setColor:self.color];
        [_art setColorBlendFactor:1.];
        //NSLog(@" setting art color: %@", _art.color);
        //self.colorBlendFactor = .05;
        
        
    }
    
    else {
        self.userInteractionEnabled = NO;
        self.texture = [NKTexture textureWithImageNamed:@"CardReplay"];
    }
    
    
    
    
}
-(void)setFlipped:(BOOL)flipped {
    
    _flipped = flipped;
    if (_flipped) {
        
        
        for (NKNode* s in self.children) {
            if (![s isEqual:_shadow]) {
                [s setHidden:YES];
            }
        }
        
    }
    else {
        
        for (NKNode* s in self.children) {
            if (![s isEqual:_shadow]) {
                [s setHidden:NO];
            }
        }
        
    }
    
    [self setCorrectTexture];
    
}

- (id)copyWithZone:(NSZone *)zone{
    // Copying code here.
    return self;
}


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    //   NSLog(@"CardSprite.m : touchesBegan:");
//    
//    _touchOffset = [[touches anyObject] locationInNode:self];
//    [_window cardTouchBegan:self atPoint:[[touches anyObject] locationInNode:self.parent]];
//    
//    
//    
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    [_window cardTouchMoved:self atPoint:[[touches anyObject] locationInNode:self.parent]];
//    
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    [_delegate resetFingerLocation];
//    [_window cardTouchEnded:self atPoint:[[touches anyObject] locationInNode:self.parent]];
//    
//    // TODO: define a pass action
//    //    BoardLocation *loc = [_delegate canPlayCard:_model withTouch:[touches anyObject]];
//    //    if (!loc) {
//    
//    //   }
//}

-(NKAction*)goBack {
    
    NKAction *goBack = [NKAction moveTo:_origin duration:FAST_ANIM_DUR];
    
    [goBack setTimingMode:NKActionTimingEaseIn];
    
    return goBack;
    
}


static inline CGPoint ccp( CGFloat x, CGFloat y )
{
    return CGPointMake(x, y);
}


@end
