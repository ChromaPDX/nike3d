#include "mainMenu.h"


// HERE IS AN EXAMPLE SUBCLASS OF A TABLE VIEW CELL


//--------------------------------------------------------------

void mainMenu::setup(){
    
    char* extensionList = (char*)glGetString(GL_EXTENSIONS);
    
    ofLogNotice("GL") << string(extensionList);
    
    //ofSetLogLevel(OF_LOG_VERBOSE);
    
    lastTime = CFAbsoluteTimeGetCurrent();
    
    // SCENE!
    scene = [[NKSceneNode alloc]initWithSize:CGSizeMake(ofGetWidth(), ofGetHeight())];
    
   // pivot = [[NKNode alloc]init];
   // pivot.size = scene.size;
   // [scene addChild:pivot];
    
   // pivot.userInteractionEnabled = true;
   // [pivot set3dPosition:ofPoint(0,500,-500)];
    scene.name = @"scene";
    
    table = [[NKScrollNode alloc] initWithColor:nil size:scene.size];
    [scene addChild:table];
    [table setVerticalPadding:0];
    [table setHorizontalPadding:0];
    table.scrollingEnabled = true;
    table.scale = 1.02;  // to correct for image...this needs to be fixed
    table.name = @"table";
    //ofVec3f rot =
    //table.node->setOrientation
    
    NKTexture *image;
    UIColor *highlightColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.5];
    
    NKScrollNode *subTable = [[NKScrollNode alloc] initWithParent:table autoSizePct:.62];
    [table addChild:subTable];
    subTable.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    subTable.scrollingEnabled = true;
    image = [NKTexture textureNamed:[NSString stringWithFormat:@"images.bundle/menu1_a.png"]];
    [subTable setTexture:image];
    [subTable setHighlightColor:highlightColor];
    [subTable setName:@"1"];
    
    ofPoint df = subTable.node->getPosition();
    ofRectangle drawFrame = [subTable getDrawFrame];
    NSLog(@"drawFrame1 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);

    NKScrollNode *subTable2 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.13];
    [table addChild:subTable2];
    subTable2.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    subTable2.scrollingEnabled = true;
    [subTable2 setHighlightColor:highlightColor];
    image = [NKTexture textureNamed:[NSString stringWithFormat:@"images.bundle/menu1_b.png"]];
    [subTable2 setTexture:image];
    [subTable2 setName:@"2"];
    df = subTable2.node->getPosition();
    drawFrame = [subTable2 getDrawFrame];
    NSLog(@"drawFrame2 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);
    
    NKScrollNode *subTable3 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.125];
    [table addChild:subTable3];
    subTable3.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    [subTable3 setHighlightColor:highlightColor];
    subTable3.scrollingEnabled = true;
    image = [NKTexture textureNamed:[NSString stringWithFormat:@"images.bundle/menu1_c.png"]];
    [subTable3 setTexture:image];
    drawFrame = [subTable3 getDrawFrame];
    df = subTable3.node->getPosition();
    NSLog(@"drawFrame3 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);
    [subTable3 setName:@"3"];

    NKScrollNode *subTable4 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.125];
    [table addChild:subTable4];
    subTable4.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    [subTable4 setHighlightColor:highlightColor];
    subTable4.scrollingEnabled = true;
    image = [NKTexture textureNamed:[NSString stringWithFormat:@"images.bundle/menu1_d.png"]];
    [subTable4 setTexture:image];
    drawFrame = [subTable4 getDrawFrame];
    df = subTable4.node->getPosition();
    //NSLog(@"drawFrame4 = %f,%f %fx%f", drawFrame.x, drawFrame.y, drawFrame.width, drawFrame.height);
    NSLog(@"drawFrame4 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);
    [subTable4 setName:@"4"];

    setupCM();
    //subTable.node->setOrientation(ofVec3f(0,1,0));
    
}


void mainMenu::setupCM(){
    
    lastAttitude = ofMatrix3x3(1,0,0,  0,1,0,  0,0,1);
    
    if (!motionManager) {
        
        motionManager = [[CMMotionManager alloc] init];
        
        ofLogNotice("CORE_MOTION") << "INIT CORE MOTION";
    }
    if (motionManager){
        
        if(motionManager.isDeviceMotionAvailable){
            
            ofLogNotice("CORE_MOTION") << "MOTION MANAGER IS AVAILABLE";
            
            motionManager.deviceMotionUpdateInterval = 1.0/45.0;
            
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
                
                CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
                
                attitude =
                ofMatrix3x3(a.m11, a.m21, a.m31,
                            a.m12, a.m22, a.m32,
                            a.m13, a.m23, a.m33);
                
                normalized = attitude * lastAttitude;  // results in the identity matrix plus perturbations between polling cycles
                //correctNormalization();  // if near 0 or 1, force into 0 and 1
                
                //agent.updateOrientation(attitude, normalized);  // send data to game controller
                CMQuaternion cm = deviceMotion.attitude.quaternion;
                
                lastAttitude = attitude;   // store last polling cycle to compare next time around
                lastAttitude.transpose(); //getInverse(attitude);  // transpose is the same as inverse for orthogonal matrices. and much easier
                
                //ofVec3f euler = ofVec3f(deviceMotion.attitude.pitch, deviceMotion.attitude.yaw, deviceMotion.attitude.roll);
                
                int rot = cm.x * -360.;
                float cmf = rot / 360.;
                sensorientation = ofQuaternion(cmf, 0, 0, cm.w);
                
                table.node->setOrientation(sensorientation);
                //scene.node->setOrientation(euler);
                
            }];
        }
    }
    else {
        ofLogError("MOTION NOT AVAILABLE");
    }
    
}
//--------------------------------------------------------------
void mainMenu::update(){
    
    
    
//    int dis = random()%60;
//    
//    if (dis > 50){
//        NKPrimitiveNode *sphere = [[NKPrimitiveNode alloc]initWith3dPrimitive:new ofSpherePrimitive(2,20) fillColor:nil];
//        
//        sphere.wireFrameColor = [UIColor colorWithRed:1. green:1. blue:rand()%100 / 100. alpha:1.];
//        //sphere.fillColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:.9];
//        //sphere.blendMode = OF_BLENDMODE_ADD;
//        
//        [emitter addChild:sphere];
//        
//        float dur = (rand()%1000/1000.) + 1.;
//        
//        [sphere runAction:[NodeAction group:@[[NodeAction move3dBy:ofVec3f(rand()%2000 - 1000, rand()%2000 - 1000, rand()%1000+500) duration:dur],
//                                              [NodeAction rotateYByAngle:90 duration:3.],
//                                              [NodeAction scaleBy:100. duration:dur]
//                                              ]
//                           ]
//               completion:^{
//                   [sphere removeFromParent];
//               }];
//    }
    
    int dt = (CFAbsoluteTimeGetCurrent() - lastTime) * 1000.;
    [scene updateWithTimeSinceLast:dt];
    lastTime = CFAbsoluteTimeGetCurrent();
    
}

//--------------------------------------------------------------
void mainMenu::draw(){
    ofClear(0,0,0,255);
    [scene draw];
}


//--------------------------------------------------------------
void mainMenu::exit(){
    
}

//--------------------------------------------------------------
void mainMenu::touchDown(ofTouchEventArgs & touch){
    [scene touchDown:CGPointMake(touch.x, touch.y) id:touch.id];
}

//--------------------------------------------------------------
void mainMenu::touchMoved(ofTouchEventArgs & touch){
    [scene touchMoved:CGPointMake(touch.x, touch.y) id:touch.id];
    touchX = touch.x;
}

//--------------------------------------------------------------
void mainMenu::touchUp(ofTouchEventArgs & touch){
    [scene touchUp:CGPointMake(touch.x, touch.y) id:touch.id];
    
    CGPoint touchXForm = CGPointMake(touch.x-scene.size.width/2, touch.y-scene.size.height/2);
    //CGPoint touchXForm = CGPointMake(touch.x, touch.y);
    
    NSLog(@"Calling nodeAtPoints from mainMenu, input touch coords = %f,%f", touchXForm.x, touchXForm.y);
    //NKNode *selectedCell = [scene nodeAtPoint:touchXForm];
    NSArray *selectedCells = [scene nodesAtPoint:touchXForm];
    if(selectedCells){
        NSLog(@"selected cells: ");
        for(NKNode* cell in selectedCells){
            NSLog(@"name = %@", cell.name);
        }
    }
    else{
        NSLog(@"no cell selected");
    }
}

//--------------------------------------------------------------
void mainMenu::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void mainMenu::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void mainMenu::lostFocus(){
    
}

//--------------------------------------------------------------
void mainMenu::gotFocus(){
    
}

//--------------------------------------------------------------
void mainMenu::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void mainMenu::deviceOrientationChanged(int newOrientation){
    
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
