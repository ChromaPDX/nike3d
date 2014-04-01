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
    ofTexture titleTexture;
    ofTrueTypeFont titleFont;
    ofTrueTypeFont font;
    NKMeshNode *meshNode;
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
// hardcode setting the title of the card
        _cardTypeTitle = @"MOVE CARD";
        ofLoadImage(titleTexture, "twitch_label.png");
        printf("HEIGHT OF FRAME %f",[self getDrawFrame].width*.8 * 1.17);
        titleFont.loadFont("Avenir.ttf", 17);
        font.loadFont("Avenir.ttf", 10);
        
        ofVec3f vec3 = ofVec3f(100.0f, 100.0f, 100.0f);
        meshNode = [[NKMeshNode alloc] initWithObjFileNamed:@"earth" texture:[NKTexture textureWithImageNamed:@"ball_Texture"] size:vec3];
        
        [meshNode runAction:[NKAction repeatActionForever:[NKAction rotate3dByAngle:ofVec3f(0,90,0) duration:1.]]];
        
        [self addChild:meshNode];
        NSLog(@"MESH NODE GROUPS COUNT>: %d",meshNode.mesh.groups.count);

    }
//    @property (nonatomic, retain) NSString *sourceObjFilePath;
//    @property (nonatomic, retain) NSString *sourceMtlFilePath;
//    @property (nonatomic, retain) NSDictionary *materials;
//    @property (nonatomic, retain) NSMutableArray *groups;
//    @property Vertex3D currentPosition;
//    @property Rotation3D currentRotation;
    
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

//-(void) customDraw{
//    
//    // mesh node test
//    ofPushMatrix();
//    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
//    [meshNode draw];
//    ofPopMatrix();
//
//}

//-(void)customDraw {
//    if(!loader){
//        ofDisableDepthTest();
//        glDisable(GL_CULL_FACE);
//        ofDisableNormalizedTexCoords();
//        ofPushMatrix();
//        //ofRotate(180, 0, 1, 0);
//        //ofRotate(180, 0, 0, 1);
//        ofSetColor(0, 0, 0, 180);
//        ofRect([self getDrawFrame]);
//        ofSetColor(255);
//        if(activeMiniGame == 1)
//            _miniMaze->draw();
//        else if(activeMiniGame == 2)
//            _miniTouch->draw();
//        else if(activeMiniGame == 3)
//            _miniCups->draw();
//        ofPopMatrix();
//        ofPushMatrix();
//        ofTranslate([self getDrawFrame].x + [self getDrawFrame].width*.1,  [self getDrawFrame].width*.4 * 1.17 + /*height of image */ 45);
//        titleTexture.draw(0,0);//, [self getDrawFrame].width*.8 * 1.17);
//        ofSetColor(0, 168, 171);
//        titleFont.drawString([_cardTypeTitle cStringUsingEncoding:NSUTF8StringEncoding], 5, 33);
//        font.drawString("LEVEL 2 CARD", 5, 7);
//        font.drawString("COST +200", 130, 7);
//        ofSetColor(255, 255, 255);
//        ofPopMatrix();
//        ofEnableNormalizedTexCoords();
//        glEnable(GL_CULL_FACE);
//        ofEnableDepthTest();
//    }
//}

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
