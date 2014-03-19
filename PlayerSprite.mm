//
//  PlayerNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"
#import "ModelHeaders.h"

@implementation PlayerSprite

-(void)draw {
    ofDisableDepthTest();
    glDisable(GL_CULL_FACE);
    [super draw];
    glEnable(GL_CULL_FACE);
    ofEnableDepthTest();
}

-(NKLabelNode*)styledLabelNode {
    NKLabelNode *node = [NKLabelNode labelNodeWithFontNamed:@"TradeGothicLTStd-BdCn20"];
    node.fontColor = _model.manager.color;
    node.fontSize = h/8.;
    return node;
}


-(void)setModel:(Card *)model {
    
    if (model) {
        _model = model;
        //        cardName = [self styledLabelNode];
        //        cardName.fontSize = (int)(h/7.);
        //        [cardName setPosition:CGPointMake(w*.25 * ((model.manager.teamSide*2)-1), h*.1)];
        //        cardName.text = [model.nameForCard substringToIndex:1];
        //        [self addChild:cardName];
        
        if ([_model isTypePlayer] || [_model isTypeKeeper]){
            
            UIColor *playerColor =  [UIColor whiteColor];
            
            if([_model.manager isEqual:_delegate.game.me]){
                playerColor = _model.manager.color;
            }
            
            NKSpriteNode *shadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"PlayerShadow"] color:nil size:CGSizeMake(w, h)];
            [shadow setZPosition:-2];
            [shadow setPosition:CGPointMake(-self.size.width * .03, -self.size.height *.03)];
            [shadow setAlpha:.4];
            [self addChild:shadow];
            
            NKSpriteNode *triangle = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"PlayerPawn"] color:playerColor size:CGSizeMake(w, h)];
            [triangle setZPosition:-1];
            triangle.colorBlendFactor = 1.;
            
            if(model.manager.teamSide){
                [triangle setZRotation:M_PI*.5];
                [shadow setZRotation:M_PI*.5];
            }
            else {
                [triangle setZRotation:-M_PI*.5];
                [shadow setZRotation:-M_PI*.5];
                
            }
            
            
            [self addChild:triangle];
        }
    }
    else NSLog(@"CAN'T ASSIGN NIL MODEL TO CARDSPRITE");
}

-(void)getReadyForPosession:(void (^)())block {
    
    if (!_ball) {
        
        _posession = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo.png"] color:self.model.manager.color size:CGSizeMake(w*.66, w*.66)];
        [_posession setZPosition:-1];
        [_posession setAlpha:.5];
        [_posession setColorBlendFactor:1.];
        [_posession setColor:_model.manager.color];
        
        NKSpriteNode *haloMarks = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo_Marks.png"] color:self.model.manager.color size:CGSizeMake(w*.66, w*.66)];
        [_posession addChild:haloMarks];
        
        _ballTarget = [[NKSpriteNode alloc]initWithColor:nil size:CGSizeMake(2, 2)];
        [_ballTarget setPosition:CGPointMake(0, w*.3)];
        [_posession setZRotation:M_PI/2];
        
        [_posession addChild:_ballTarget];
        
        [self fadeInChild:_posession duration:FAST_ANIM_DUR withCompletion:^{
            
        }];
        
    }
    
    block();
    
    
}

-(void)stealPossesionFromPlayer:(PlayerSprite*)player {
    
    if (!_ball) {
        
        _posession = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo.png"] color:self.model.manager.color size:CGSizeMake(w*.66, w*.66)];
        [_posession setZPosition:-1];
        [_posession setAlpha:.5];
        [_posession setColorBlendFactor:1.];
        [_posession setColor:_model.manager.color];
        
        NKSpriteNode *haloMarks = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo_Marks.png"] color:self.model.manager.color size:CGSizeMake(w*.66, w*.66)];
        [_posession addChild:haloMarks];
        
        _ballTarget = [[NKSpriteNode alloc]initWithColor:nil size:CGSizeMake(2, 2)];
        [_ballTarget setPosition:CGPointMake(0, w*.3)];
        [_posession setZRotation:player.posession.zRotation];
        
        [_posession addChild:_ballTarget];
        
        [_posession removeFromParent];
        
        
    }
    
    
}

-(void)startPossession {
    if (!_ball) {
        
        
        _ball = _delegate.ballSprite;
        _ball.player = self;
        
        [_ball runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:1.]];
        [_posession runAction:[NKAction repeatActionForever:
                               [NKAction sequence:@[[NKAction rotateToAngle:-2*M_PI duration:4.],
                                                    [NKAction rotateToAngle:0 duration:0]
                                                    ]]]];
        
        [_ball runAction:[NKAction repeatActionForever:[NKAction rotateByAngle:6.17 duration:2.]]];
        
    }
    
}

-(CGPoint)ballLoc {
    
    //return [self.parent convertPoint:_ballTarget.position fromNode:self];
    //CGPoint loc = [_ballTarget pos
    
    CGPoint cp = [_posession childLocationIncludingRotation:_ballTarget];
    
    return CGPointMake(self.position.x + cp.x, self.position.y + cp.y);
}


-(void)stopPosession:(void (^)())block {
    
    
    [_ball runAction:[NKAction scaleTo:BALL_SCALE_BIG duration:FAST_ANIM_DUR] completion:^{
        
        
        [_posession removeAllActions];
        
        [_ball removeAllActions];
        _ball.player = nil;
        _ball = nil;
        
        
        
        [self fadeOutChild:_posession duration:FAST_ANIM_DUR withCompletion:^{
            NSLog(@"stopped possesion : %@", _model.nameForCard);
            [_ballTarget removeFromParent];
            _posession = nil;
        }];
        
        block();
        
        
    }];
    
    
    
    
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (touches.count == 1) {
        UILog(@"PlayerSprite.m : touchesBegan");
        
        //  NSLog(@"remove alerts");
        //[_delegate removeAlerts];
        //  NSLog(@"request player");
        
        if ([_delegate requestActionWithPlayer:self]){
            // [_delegate movingPlayer:_model withTouch:[touches anyObject]];
        }
        
    }
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //UILog(@"PlayerSprite.m : touchesMoved");
    if (touches.count == 1) {
        
        
      //  [_delegate movingPlayer:_model withTouch:[touches anyObject]];
        
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    if (touches.count == 1) {
//        
//        UILog(@"PlayerSprite.m : touchesEnded");
//        
//        [_delegate resetFingerLocation];
//        
//        if (![_delegate validatePlayerMove:_model]) {
//            
//            
//            [_delegate.infoHUD setPlayer:_model];
//            
//        }
//        
//    }
//    
}


@end
