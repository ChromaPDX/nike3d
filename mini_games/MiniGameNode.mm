//
//  MiniGameNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NikeNodeHeaders.h"

@interface MiniGameNode (){
    int activeMiniGame; // 0:maze, 1:touch, 2:cups
}

@end

@implementation MiniGameNode

-(instancetype)initWithSize:(CGSize) size {
    self = [super init];
    
    if (self) {
        self.size = size;
        [self setUserInteractionEnabled:YES];
    }
    
    return self;
}

-(void)startMiniGame {
    activeMiniGame = arc4random()%3;
    ofRectangle d = [self getDrawFrame];
    if(activeMiniGame == 0){
        _miniMaze = new MiniMaze();
        _miniMaze->objDelegate = (id)self.scene;
        _miniMaze->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8);
    }
    else if(activeMiniGame == 1){
        _miniTouch = new MiniTouch();
        _miniTouch->objDelegate = (id)self.scene;
        _miniTouch->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8);
    }
    else if(activeMiniGame == 2){
        _miniCups = new MiniCups();
        _miniCups->objDelegate = (id)self.scene;
        _miniCups->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8);
    }
}

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
    if(activeMiniGame == 0)
        _miniMaze->update();
    else if(activeMiniGame == 1)
        _miniTouch->update();
    else if(activeMiniGame == 2)
        _miniCups->update();
    [super updateWithTimeSinceLast:dt];
}

-(void)customDraw {
    ofDisableDepthTest();
    glDisable(GL_CULL_FACE);
    ofPushMatrix();
    ofRotate(180, 0, 1, 0);
    ofRotate(180, 0, 0, 1);
    ofSetColor(0, 0, 0, 180);
    ofRect([self getDrawFrame]);
    ofSetColor(255);
    if(activeMiniGame == 0)
        _miniMaze->draw();
    else if(activeMiniGame == 1)
        _miniTouch->draw();
    else if(activeMiniGame == 2)
        _miniCups->draw();
    ofPopMatrix();
    glEnable(GL_CULL_FACE);
    ofEnableDepthTest();
}

-(bool)touchDown:(CGPoint)location id:(int)touchId {
    if ([super touchDown:location id:touchId]){
        NSLog(@"TOUCH X:%.1f  Y:%.1f",location.x, location.y);
        if(activeMiniGame == 0)
            ;//_miniMaze->touchDownCoords(location.x, location.y);
        else if(activeMiniGame == 1)
            _miniTouch->touchDownCoords(location.x, location.y);
        else if(activeMiniGame == 2)
            _miniCups->touchDownCoords(location.x, location.y);
    }
    return true;
}

-(void)dealloc {
    if(activeMiniGame == 0)
        delete _miniMaze;
    else if(activeMiniGame == 1)
        delete _miniTouch;
    else if(activeMiniGame == 2)
        delete _miniCups;
}

@end
