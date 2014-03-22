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

//-(void)draw {
//   // ofDisableDepthTest();
//    //glDisable(GL_CULL_FACE);
//    [super draw];
//    //glEnable(GL_CULL_FACE);
//    //ofEnableDepthTest();
//}

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
            
            UIColor *playerColor =  NKWHITE;
            
            if([_model.manager isEqual:_delegate.game.me]){
                playerColor = _model.manager.color;
            }
            
            NKSpriteNode *shadow = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:NSFWPlayerShadow] color:NKBLACK size:CGSizeMake(w, h)];
            [shadow setAlpha:.4];
            [self addChild:shadow];
             [shadow setPosition3d:ofPoint(-self.size.width * .03, 0, 4)];

            
            NKSpriteNode *triangle = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:NSFWPlayerImage] color:playerColor size:CGSizeMake(w, h)];
      
            [triangle setOrientationEuler:ofVec3f(45,0,0)];
            
            
            [self addChild:triangle];
           
            [triangle setZPosition:h*.33];
            
            self.name = model.nameForCard;
            self.userInteractionEnabled = true;
        }
    }
    else NSLog(@"CAN'T ASSIGN NIL MODEL TO CARDSPRITE");
}

-(void)setHighlighted:(bool)highlighted {
    
    if (highlighted && !_highlighted) {
        NKSpriteNode *crosshairs = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:NSFWPlayerHighlight] color:NKWHITE size:CGSizeMake(w, h)];
        crosshairs.name = @"crosshairs";
        [self addChild:crosshairs];
        [crosshairs setZPosition:6];
    }
    
    else if (!highlighted && _highlighted){
        [self removeChildNamed:@"crosshairs"];
    }
    
    _highlighted = highlighted;
    
}

-(void)getReadyForPosession:(void (^)())block {
    
    if (!_ball) {
        
        if (!_posession) {
            
            _posession = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo.png"] color:self.model.manager.color size:CGSizeMake(h, h)];
            
            //[_posession setAlpha:.5];
            [_posession setColorBlendFactor:1.];
            [_posession setColor:_model.manager.color];
            [_posession setZPosition:h*.25];
            
            NKSpriteNode *haloMarks = [[NKSpriteNode alloc] initWithTexture:[NKTexture textureWithImageNamed:@"Halo_Marks.png"] color:NKWHITE size:CGSizeMake(h, h)];
            [_posession addChild:haloMarks];
            [haloMarks setZPosition:2];
            
            _ballTarget = [[NKSpriteNode alloc]initWithColor:nil size:CGSizeMake(4, 4)];
            
            [_posession addChild:_ballTarget];
            
            [_ballTarget setPosition3d:ofPoint(0, w*.5, 0)];
            
            [self fadeInChild:_posession duration:FAST_ANIM_DUR withCompletion:^{
                
            }];
            
        }
        
    }
    
    block();
    
    
}

-(void)stealPossesionFromPlayer:(PlayerSprite*)player {
    
    [self getReadyForPosession:nil];
    
}

-(void)startPossession {
    if (!_ball) {
        
        _ball = _delegate.ballSprite;
        
        [_ball runAction:[NKAction repeatActionForever:[NKAction rotateByAngle:-45 duration:.2]]];
        
        [_ball runAction:[NKAction scaleTo:BALL_SCALE_SMALL duration:1.] completion:^{
             _ball.player = self;
        }];
        
       
        
        [_posession runAction:[NKAction repeatActionForever:
                               [NKAction group:@[
                                                 [NKAction sequence:@[[NKAction move3dBy:ofVec3f(0,0,h*.33) duration:1.],
                                                                      [NKAction move3dBy:ofVec3f(0,0,-h*.33) duration:1.]]],
                                                 
                                                                      [NKAction rotateByAngle:180 duration:2.]
                                                    ]]]];

    }
    
}
//
//-(ofPoint)ballLoc {
//    
//    //return [self.parent convertPoint:_ballTarget.position fromNode:self];
//    //CGPoint loc = [_ballTarget pos
//    
//    CGPoint cp = [_posession childLocationIncludingRotation:_ballTarget];
//    
//    return ofPoint(self.position3d.x + cp.x, self.position3d.y + cp.y, _posession.position3d.z + self.position3d.z);
//}


-(void)stopPosession:(void (^)())block {
    
    
    [_ball runAction:[NKAction scaleTo:BALL_SCALE_BIG duration:FAST_ANIM_DUR] completion:^{
        
        _ball.player = nil;
        _ball = nil;
        
        
        
        [self fadeOutChild:_posession duration:FAST_ANIM_DUR withCompletion:^{
            NSLog(@"stopped possesion : %@", _model.nameForCard);
            [_ballTarget removeFromParent];
            _posession = nil;
        }];
        
        [_posession removeAllActions];
        [_ball removeAllActions];
        
        block();
        
        
    }];
    
    
    
    
    
    
}

-(bool)touchDown:(CGPoint)location id:(int)touchId {
    
    if ([super touchDown:location id:touchId]){
        if (touches.count == 1) {
            
            
            //  NSLog(@"remove alerts");
            //[_delegate removeAlerts];
            //  NSLog(@"request player");
            

            
        }
    }

    return 1;
    
}


-(bool)touchMoved:(CGPoint)location id:(int)touchId {
    //UILog(@"PlayerSprite.m : touchesMoved");
    if (touches.count == 1) {
        
        [self setPosition:location];
        //[_delegate movingPlayer:_model at
        
    }
    return 1;
}

-(bool)touchUp:(CGPoint)location id:(int)touchId {
    
    if ([super touchUp:location id:touchId]){
        if ([_delegate requestActionWithPlayer:self]){
            // [_delegate movingPlayer:_model withTouch:[touches anyObject]];
            [_delegate setSelectedPlayer:self.model];
        }
    }
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
    return 1;
}


@end
