#include "ofApp.h"
#include "NikeNodeHeaders.h"
#include "Game.h"

#include "DevMenu.h"

// HERE IS AN EXAMPLE SUBCLASS OF A TABLE VIEW CELL


//--------------------------------------------------------------

void ofApp::setup(){
    
    ofSetFrameRate(62);
    
    char* extensionList = (char*)glGetString(GL_EXTENSIONS);
    
    ofLogNotice("GL") << string(extensionList);
    
    lastTime = CFAbsoluteTimeGetCurrent();
    
    scene =  [[DevMenu alloc] initWithSize:CGSizeMake(ofGetWidth(), ofGetHeight())];
    
    scene.view = (void*)this;
    
//    game = [[Game alloc] init];
//    
//    scene = [[GameScene alloc]initWithSize:CGSizeMake(ofGetWidth(), ofGetHeight())];
//    
//    game.gameScene = scene;
//    
//    scene.game = game;
//    
//    [game startSinglePlayerGame];
    
//    setupCM();

}

//void ofApp::setupCM(){
//    
//    lastAttitude = ofMatrix3x3(1,0,0,  0,1,0,  0,0,1);
//    
//    if (!motionManager) {
//        
//        motionManager = [[CMMotionManager alloc] init];
//        
//        ofLogNotice("CORE_MOTION") << "INIT CORE MOTION";
//    }
//    if (motionManager){
//        
//        if(motionManager.isDeviceMotionAvailable){
//            
//            ofLogNotice("CORE_MOTION") << "MOTION MANAGER IS AVAILABLE";
//            
//            motionManager.deviceMotionUpdateInterval = 1.0/45.0;
//            
//            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
//                
//                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
//                
//                attitude =
//                ofMatrix3x3(a.m11, a.m21, a.m31,
//                            a.m12, a.m22, a.m32,
//                            a.m13, a.m23, a.m33);
//                
//                normalized = attitude * lastAttitude;  // results in the identity matrix plus perturbations between polling cycles
//                //correctNormalization();  // if near 0 or 1, force into 0 and 1
//                
//                //agent.updateOrientation(attitude, normalized);  // send data to game controller
//                CMQuaternion cm = deviceMotion.attitude.quaternion;
//                
//                lastAttitude = attitude;   // store last polling cycle to compare next time around
//                lastAttitude.transpose(); //getInverse(attitude);  // transpose is the same as inverse for orthogonal matrices. and much easier
//                
//                //ofVec3f euler = ofVec3f(deviceMotion.attitude.pitch, deviceMotion.attitude.yaw, deviceMotion.attitude.roll);
//                
//                int rot = cm.x * -240.;
//                if (rot > -150 && rot < 150){
//                    float cmf = rot / 360.;
//                    sensorientation = ofQuaternion(cmf, 0, 0, cm.w);
//                    [scene setOrientation:sensorientation];
//                }
//                
//            }];
//        }
//    }
//    else {
//        ofLogError("MOTION NOT AVAILABLE");
//    }
//    
//}
//--------------------------------------------------------------
void ofApp::update(){
    
    int dt = (CFAbsoluteTimeGetCurrent() - lastTime) * 1000.;
    [scene updateWithTimeSinceLast:dt];
    lastTime = CFAbsoluteTimeGetCurrent();
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    [scene draw];
}



//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    [scene touchDown:CGPointMake(touch.x, touch.y) id:touch.id];
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    [scene touchMoved:CGPointMake(touch.x, touch.y) id:touch.id];
    touchX = touch.x;
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    [scene touchUp:CGPointMake(touch.x, touch.y) id:touch.id];
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}

// COOL COLOR WHEEL THING

//steps = 120;
//step = TWO_PI/steps;
////top & bottom
//for (int j=0; j<2; j++) {
//    //create vertices and set colors
//    mesh.addColor(j*255);
//    mesh.addVertex(ofVec3f(0,0,j));
//    for (float i=0; i<steps; i++) {
//        mesh.addColor(ofColor::fromHsb(i/steps*255,255,j*255));
//        mesh.addVertex(ofVec3f(sin(i/steps*TWO_PI),cos(i/steps*TWO_PI),j));
//    }
//    //top & bottom triangles
//    for (int k=0,a,b,c; k<steps; k++) {
//        a = j*steps+j;
//        b = j*steps+j+k+1;
//        c = j*steps+j+k+2;
//        if (c>a+steps) c -= steps;
//            mesh.addTriangle(a,b,c);
//            }
//}
////side
//for (float i=1,a,b; i<=steps; i++) {
//    mesh.addTriangle(i,i+1,i+steps+2);
//    mesh.addTriangle(i,i+steps+1,i+steps+2);
//}
