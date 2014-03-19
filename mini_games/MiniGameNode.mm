//
//  MiniGameNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NikeNodeHeaders.h"

@implementation MiniGameNode

-(instancetype)initWithSize:(CGSize) size {
    self = [super init];
    
    if (self) {
        self.size = size;
           }
    
    return self;
}

-(void)startMiniGame {
    _miniMaze = new MiniMaze();
    _miniMaze->objDelegate = (GameScene*)self.scene;
    ofRectangle d = [self getDrawFrame];
    _miniMaze->setup(d.x + d.width*.1, d.y + (d.height*.5 - d.width*.4), d.width*.8, d.width*.8);
    
}

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
    _miniMaze->update();
    [super updateWithTimeSinceLast:dt];
}

-(void)customDraw {
    ofDisableDepthTest();
    ofPushMatrix();
    ofRotate(180, 0, 1, 0);
    ofRotate(180, 0, 0, 1);
    ofSetColor(0, 0, 0, 180);
    ofRect([self getDrawFrame]);
    ofSetColor(255);
    _miniMaze->draw();
    ofPopMatrix();
    ofEnableDepthTest();
}

-(void)dealloc {
    delete _miniMaze;
}

@end
