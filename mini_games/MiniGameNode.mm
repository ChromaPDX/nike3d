//
//  MiniGameNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NikeNodeHeaders.h"

@interface MiniGameNode (){
    int activeMiniGame; // 1:maze, 2:touch, 3:cups
    bool loader;  // do not run updates while loading in progress
}

@end

@implementation MiniGameNode

-(instancetype)initWithSize:(CGSize) size {
    self = [super init];
    
    if (self) {
        loader = false;
        activeMiniGame = 0;
        self.size = size;
        [self setUserInteractionEnabled:YES];
        self.name = @"miniGame Node";
    }
    
    return self;
}

-(void)startMiniGame {
    loader = true;
    if(activeMiniGame){   // dealloc last game
        if(activeMiniGame == 1)      delete _miniMaze;
        else if(activeMiniGame == 2) delete _miniTouch;
        else if(activeMiniGame == 3) delete _miniCups;
    }
    activeMiniGame = arc4random()%3 + 1;
    ofRectangle d = [self getDrawFrame];
    if(activeMiniGame == 1){
        _miniMaze = new MiniMaze();
        _miniMaze->objDelegate = (id)self.scene;
        _miniMaze->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8 * 1.17);
    }
    else if(activeMiniGame == 2){
        _miniTouch = new MiniTouch();
        _miniTouch->objDelegate = (id)self.scene;
        _miniTouch->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8 * 1.17);
    }
    else if(activeMiniGame == 3){
        _miniCups = new MiniCups();
        _miniCups->objDelegate = (id)self.scene;
        _miniCups->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8 * 1.17);
    }
    loader = false;
}

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
    if(!loader){
        if(activeMiniGame == 1)
            _miniMaze->update();
        else if(activeMiniGame == 2)
            _miniTouch->update();
        else if(activeMiniGame == 3)
            _miniCups->update();
        [super updateWithTimeSinceLast:dt];
    }
}

-(void)customDraw {
    if(!loader){
        ofDisableDepthTest();
        glDisable(GL_CULL_FACE);
        ofDisableNormalizedTexCoords();
        ofPushMatrix();
        //ofRotate(180, 0, 1, 0);
        //ofRotate(180, 0, 0, 1);
        ofSetColor(0, 0, 0, 180);
        ofRect([self getDrawFrame]);
        ofSetColor(255);
        if(activeMiniGame == 1)
            _miniMaze->draw();
        else if(activeMiniGame == 2)
            _miniTouch->draw();
        else if(activeMiniGame == 3)
            _miniCups->draw();
        ofPopMatrix();
        ofEnableNormalizedTexCoords();
        glEnable(GL_CULL_FACE);
        ofEnableDepthTest();
    }
}

-(NKTouchState)touchDown:(CGPoint)location id:(int)touchId {
    NKTouchState touchState = [super touchDown:location id:touchId]; // this queries children first returns 2 if no children, 1 if active child
    if (!loader && touchState == 2){
        NSLog(@"TOUCH X:%.1f  Y:%.1f",location.x, location.y);
        if(activeMiniGame == 1)
            ;//_miniMaze->touchDownCoords(location.x, location.y);
        else if(activeMiniGame == 2)
            _miniTouch->touchDownCoords(location.x, location.y);
        else if(activeMiniGame == 3)
            _miniCups->touchDownCoords(location.x, location.y);
    }
    return touchState;
}

-(void)dealloc {
    loader = true;
    if(activeMiniGame == 1)
        delete _miniMaze;
    else if(activeMiniGame == 2)
        delete _miniTouch;
    else if(activeMiniGame == 3)
        delete _miniCups;
}

@end
