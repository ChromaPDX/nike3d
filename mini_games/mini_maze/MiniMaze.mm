//
//  MiniMaze.cpp
//  MiniNine
//
//  Created by Robby Kraft on 3/3/14.
//
//

#include "MiniMaze.h"

#define X 0
#define Y 1

#define ELASTIC .4f // elastic dampening
#define STATIC .02f // static friction
#define KINETIC .9f // inverse kinetic friction


MiniMaze::MiniMaze(){
    
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
             attitude = ofMatrix3x3(a.m11, a.m21, a.m31,
                                    a.m12, a.m22, a.m32,
                                    a.m13, a.m23, a.m33);
             normalized = attitude * lastAttitude;  // results in the identity matrix plus perturbations between polling cycles
             lastAttitude = attitude;   // store last polling cycle to compare next time around
             lastAttitude.transpose();  //getInverse(attitude);  // transpose is the same as inverse for orthogonal matrices. and much easier
//             log2Matrices3x3(normalized, attitude);
             }];
        }
    }
    else {
        ofLogError("MOTION NOT AVAILABLE");
    }
}

MiniMaze::~MiniMaze(){
    [motionManager stopDeviceMotionUpdates];
}

void MiniMaze::setup(int xIn, int yIn, int width, int height){
    x = xIn;
    y = yIn;
    w = width;
    h = height;
    
    CELLSIZE = height/9.5f;
    
    gameState = gameStateWaiting;
    nextStartTime = 1000;

    ofLoadImage(ballTexture, "theball.png");
    ofLoadImage(backgroundTexture, "background.png");
    ofLoadImage(white30Texture, "thirtypercentwhite.png");
    ofLoadImage(startArrowTexture, "arrowDown.png");
    ofLoadImage(endArrowTexture, "arrowLeft.png");

    ballTexture.setAnchorPercent(.5, .5);
    startArrowTexture.setAnchorPercent(.5, .5);
    endArrowTexture.setAnchorPercent(.5, .5);
    ballRadius = CELLSIZE*.33;
    ballPosition[X] = 0;
    ballPosition[Y] = 0;
    ballVelocity[X] = 0.0f;
    ballVelocity[Y] = 0.0f;
    ballAcceleration[X] = 0.0f;
    ballAcceleration[Y] = 0.3f;
    
    wall[0].x = 0;
    wall[0].y = 0;
    wall[0].width = 5;
    wall[0].height = 1;
    wall[1].x = 0;
    wall[1].y = 1;
    wall[1].width = 1;
    wall[1].height = 4;
    wall[2].x = 4;
    wall[2].y = 1;
    wall[2].width = 1;
    wall[2].height = 6;
    wall[3].x = 0;
    wall[3].y = 6;
    wall[3].width = 3;
    wall[3].height = 1;
    wall[4].x = 2;
    wall[4].y = 4;
    wall[4].width = 1;
    wall[4].height = 2;
    wall[5].x = 1;
    wall[5].y = 2;
    wall[5].width = 2;
    wall[5].height = 1;
    startCell[X] = 3;
    startCell[Y] = 6;
    endCell[X] = -1;
    endCell[Y] = 5;
    
    for(int i = 0; i < 6; i++){
        wall[i].x = x+wall[i].x*CELLSIZE+(w-CELLSIZE*5)*.5;
        wall[i].y = y+wall[i].y*CELLSIZE + CELLSIZE*.5 + h*.17;
        wall[i].width = wall[i].width*CELLSIZE;
        wall[i].height = wall[i].height*CELLSIZE;
    }
    
    centerX = x+w*.5;
    centerY = y+h*.6;  // because of the text box

    ofLoadImage(successTexture, "success.png");
    ofLoadImage(failTexture, "fail.png");

    font.loadFont("Avenir.ttf", ofGetWidth() / 22., true, true);   // 4.2
    largeFont.loadFont("Avenir.ttf", ofGetWidth() / 10., true, true);   // 4.2

    ofLoadImage(successTexture, "success.png");
    ofLoadImage(failTexture, "fail.png");
    
    gameFade = 1.0;
}

void MiniMaze::update(){

    //game round stuff
    if(gameState == gameStateWaiting && ofGetElapsedTimeMillis() > nextStartTime){
        // start a new round
        gameState = gameStateRunning;
        ballPosition[X] = x+(.5+startCell[X])*CELLSIZE+(w-CELLSIZE*5)*.5;
        ballPosition[Y] = y+(.5+startCell[Y])*CELLSIZE + CELLSIZE*.5 + h*.17;
        ballVelocity[X] = 0.0f;
        ballVelocity[Y] = 0.0f;
        nextStartTime = ofGetElapsedTimeMillis() + 10000;
        win = false;
    }
    if(gameState == gameStateRunning && ofGetElapsedTimeMillis() > nextStartTime){
        ////////////////
        //  to begin the end of the minigame
        gameState = gameStateWinLose;
        nextStartTime = ofGetElapsedTimeMillis() + 1500;
        ////////////////
        // you lose
    }
    if(gameState == gameStateWinLose && ofGetElapsedTimeMillis() > nextStartTime){
        if(win){
            if(delegate)
                delegate->gameDidFinishWithWin();
            if(objDelegate)
                [objDelegate gameDidFinishWithWin];
        }
        else{
            if(delegate)
                delegate->gameDidFinishWithLose();
            if(objDelegate)
                [objDelegate gameDidFinishWithLose];
        }
    }
    //////////////////
    // fade out, end of game
    if(gameState == gameStateWinLose){
        gameFade = 1.0 - (ofGetElapsedTimeMillis() - (nextStartTime-1500)) / 1000.0;
        if(gameFade < 0.0)
            gameFade = 0.0f;
    }
    //////////////////
    // update ball position, velocity, acceleration
    ballAcceleration[X] = -attitude.g;
    ballAcceleration[Y] = -attitude.h;
    if(ballAcceleration[X] < STATIC && ballAcceleration[X] > -STATIC) ballAcceleration[X] = 0.0f;
    if(ballAcceleration[Y] < STATIC && ballAcceleration[Y] > -STATIC) ballAcceleration[Y] = 0.0f;
    ballVelocity[X] += ballAcceleration[X];
    ballVelocity[Y] += ballAcceleration[Y];
    if(ballPosition[X] > x+(w-CELLSIZE*5)*.5){
        if(gameState == gameStateRunning){
            ballPosition[X] += ballVelocity[X];
            ballPosition[Y] += ballVelocity[Y];
        }
    }
    else{
        if(gameState != gameStateWinLose){
            // you win
            win = true;
            gameState = gameStateWinLose;
            nextStartTime = ofGetElapsedTimeMillis() + 1500;
        }
    }
    
    // collision detection
    // -------------------
    // card boundary
    if(ballPosition[X] > x+w-ballRadius){
        ballPosition[X] = x+w-ballRadius;
        ballVelocity[X] *= -ELASTIC;
    }
    if(ballPosition[X] < x+ballRadius){
        ballPosition[X] = x+ballRadius;
        ballVelocity[X] *= -ELASTIC;
    }
    if(ballPosition[Y] < y+ballRadius){
        ballPosition[Y] = y+ballRadius;
        ballVelocity[Y] *= -ELASTIC;
    }
    if(ballPosition[Y] > y+h-ballRadius){
        ballPosition[Y] = y+h-ballRadius;
        ballVelocity[Y] *= -ELASTIC;
    }
    // individual walls
    for(int i = 0; i < 6; i++){
        if(ballPosition[X] + ballRadius > wall[i].x && ballPosition[X] - ballRadius < wall[i].x+wall[i].width &&
           ballPosition[Y] + ballRadius > wall[i].y && ballPosition[Y] - ballRadius < wall[i].y+wall[i].height){
            
            float left = fabs( wall[i].x - ballPosition[X] - ballRadius );
            float right = fabs( wall[i].x+wall[i].width - ballPosition[X] + ballRadius );
            float top = fabs( wall[i].y - ballPosition[Y] - ballRadius );
            float bottom = fabs( wall[i].y+wall[i].height - ballPosition[Y] + ballRadius);
            
            if( left <= top && left <= bottom && left <= right ){
                ballPosition[X] = wall[i].x-ballRadius; //-= ballVelocity[X];
                ballVelocity[X] *= -ELASTIC;
            }
            else if( right <= top && right <= bottom && right <= left ){
                ballPosition[X] = wall[i].x+wall[i].width+ballRadius; //+= ballVelocity[X];
                ballVelocity[X] *= -ELASTIC;
            }
            else if( top <= right && top <= left && top <= bottom ){
                ballPosition[Y] = wall[i].y - ballRadius; //-= ballVelocity[Y];
                ballVelocity[Y] *= -ELASTIC;
            }
            else if( bottom <= right && bottom <= left && bottom <= top ){
                ballPosition[Y] = wall[i].y+wall[i].height + ballRadius; //+= ballVelocity[Y];
                ballVelocity[Y] *= -ELASTIC;
            }
        }
    }
    // keep it from going outside the entrance
    
    if(ballPosition[Y] > y+7*CELLSIZE-ballRadius + CELLSIZE*.5 + h*.17){
        ballPosition[Y] = y+7*CELLSIZE-ballRadius + CELLSIZE*.5 + h*.17;
        ballVelocity[Y] *= -ELASTIC;
    }
}

void MiniMaze::drawTimer(int centerX, int centerY){
    ofFill();
    ofSetColor(255, 255, 255, 60);
    ofBeginShape();
    ofVertex(centerX,centerY);
    static float outerRadius = 30;
    static float resolution = 256;
    static float deltaAngle = TWO_PI / resolution;
    float angle = 0;
    float roundProgress = (1-(nextStartTime-ofGetElapsedTimeMillis())/10000.0);
    for(int i = 0; i <= resolution; i++){
        if((float)i/resolution <= roundProgress){
            float x = centerX + outerRadius * sin(angle);
            float y = centerY + outerRadius * cos(angle);
            ofVertex(x,y);
            angle += deltaAngle;
        }
    }
    ofVertex(centerX,centerY);
    ofEndShape();
    ofSetColor(255, 255, 255, 255);
}

void MiniMaze::draw(){

    backgroundTexture.draw(x, y, w, h);
    ofSetColor(255, 255*gameFade);
    for(int i = 0; i < 6; i++)
        white30Texture.draw(wall[i].x, wall[i].y, wall[i].width, wall[i].height);
    ballTexture.draw(ballPosition[X], ballPosition[Y], ballRadius+ballRadius, ballRadius+ballRadius);
    startArrowTexture.draw( x+(.5+startCell[X])*CELLSIZE+(w-CELLSIZE*5)*.5,
                           y+(.5+startCell[Y])*CELLSIZE + CELLSIZE*.5 + h*.17,
                           CELLSIZE*.5, CELLSIZE*.5);
    endArrowTexture.draw( x+(.5+endCell[X])*CELLSIZE+(w-CELLSIZE*5)*.5,
                         y+(.5+endCell[Y])*CELLSIZE + CELLSIZE*.5 + h*.17,
                         CELLSIZE*.5, CELLSIZE*.5);
    if(gameState == gameStateRunning && !win)
        drawTimer(x+w-45, y+h-45);

    ofSetColor(255, 255);

    if(gameState == gameStateRunning)
        font.drawString("tilt maze", centerX - font.stringWidth("tilt maze")*.5, centerY-h*.53);
    
    if(gameState == gameStateWinLose){
        if(win){
            successTexture.draw(centerX-w*.33, centerY-w*.33, w*.66, w*.66);
            largeFont.drawString("SUCCESS", centerX - largeFont.stringWidth("SUCCESS")*.5, centerY-w*.45);
            font.drawString("tap to deploy on field", centerX - font.stringWidth("tap to deploy on field")*.5, centerY-h*.53);
        }
        else{
            failTexture.draw(centerX-w*.33, centerY-w*.33, w*.66, w*.66);
            largeFont.drawString("FAIL", centerX - largeFont.stringWidth("FAIL")*.5, centerY-w*.45);
            font.drawString("tap to return to field", centerX - font.stringWidth("tap to return to field")*.5, centerY-h*.53);
        }
    }
}
