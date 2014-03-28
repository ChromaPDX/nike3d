//
//  MiniMaze.cpp
//  MiniNine
//
//  Created by Robby Kraft on 3/3/14.
//
//

#include "MiniCups.h"

#define X 0
#define Y 1

#define ELASTIC .4f // elastic dampening
#define STATIC .02f // static friction
#define KINETIC .9f // inverse kinetic friction

MiniCups::MiniCups(){

}

MiniCups::~MiniCups(){
}

void MiniCups::setup(int xIn, int yIn, int width, int height){
    x = xIn;
    y = yIn;
    w = width;
    h = height;
    font.loadFont("Avenir.ttf", ofGetWidth() / 22., true, true);   // 4.2
    largeFont.loadFont("Avenir.ttf", ofGetWidth() / 10., true, true);   // 4.2
    
    centerX = x+w*.5;
    centerY = y+h*.6;  // because of the text box
    CELLSIZE = height/9.5f;
    
    ofLoadImage(backgroundTexture, "background.png");
    ofLoadImage(white30Texture, "thirtypercentwhite.png");
    ofLoadImage(ball1Texture, "soccerball.png");
    ofLoadImage(ball2Texture, "soccerball.png");
    ofLoadImage(ball3Texture, "soccerball.png");

    ball1Texture.setAnchorPercent(0.5, 0.5);
    ball2Texture.setAnchorPercent(0.5, 0.5);
    ball3Texture.setAnchorPercent(0.5, 0.5);
    
    ball1Angle = 0;
    ball2Angle = PI*2/3.0;
    ball3Angle = PI*4/3.0;
    
    circleWidth = w*.33;
    circleHeight = circleWidth*.66;
    
    showBall = true;
    fingerTouchDown = false;
    
    angleAcceleration = 0;
    angleVelocity = 0;
    
    gameState = cupsGameStateGetReady;
    nextStartTime = ofGetElapsedTimeMillis() + 1000;
    
    ///
//    ofLoadImage(touchTexture, "theball.png");
//    touchLocation[X] = touchLocation[Y] = 0.0;
    ofLoadImage(successTexture, "success.png");
    ofLoadImage(failTexture, "fail.png");
    
    gameFade = 1.0;
}

void MiniCups::update(){
    
    if(gameState == cupsGameStateGetReady && ofGetElapsedTimeMillis() > nextStartTime){
        angleVelocity = 0;
        angleAcceleration = .005;
        gameFade = 1.0;
        fullSpeedCount = 0;
        fullSpeedRandomTime = ofRandom(10, 40);
        spinTime = ofRandom(1000, 1200);
        gameState = cupsGameStateAccelerating;
        accelerationBeginTime = ofGetElapsedTimeMillis();
        nextStartTime = ofGetElapsedTimeMillis() + spinTime;
        showBall = false;
        win = false;
    }
    // 0.355000  -  probably too hard
    // 0.325000  -  challenging but accomplishable
    if(gameState == cupsGameStateAccelerating && angleVelocity > 0.315000){  // based on speed instead of time
//    if(gameState == cupsGameStateAccelerating && ofGetElapsedTimeMillis() > nextStartTime){
        angleAcceleration = 0;
        fullSpeedCount++;
        if(fullSpeedCount > fullSpeedRandomTime){
            gameState = cupsGameStateSlowing;
            angleAcceleration = -.005;
            nextStartTime = ofGetElapsedTimeMillis() + spinTime;
        }
    }
    if(gameState == cupsGameStateSlowing && ofGetElapsedTimeMillis() > nextStartTime){
        gameState = cupsGameStatePicking;
        angleAcceleration = 0;
        angleVelocity = 0;
        nextStartTime = ofGetElapsedTimeMillis() + 3000;
    }
    // repeat game
    if(gameState == cupsGameStateWinLose && ofGetElapsedTimeMillis() > nextStartTime){
//        gameState = cupsGameStateGetReady;
//        nextStartTime = ofGetElapsedTimeMillis() + 1000;
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
    if(gameState == cupsGameStateWinLose){
        gameFade = 1.0 - (ofGetElapsedTimeMillis() - (nextStartTime-1500)) / 1000.0;
        if(gameFade < 0.0)
            gameFade = 0.0f;
    }
    //////////////////

    angleVelocity += angleAcceleration;
    
    ball1Angle += angleVelocity;
    ball2Angle += angleVelocity;
    ball3Angle += angleVelocity;
    
    ball1Position[X] = centerX + cos(ball1Angle) * circleWidth;
    ball1Position[Y] = centerY + sin(ball1Angle) * circleHeight;
    ball2Position[X] = centerX + cos(ball2Angle) * circleWidth;
    ball2Position[Y] = centerY + sin(ball2Angle) * circleHeight;
    ball3Position[X] = centerX + cos(ball3Angle) * circleWidth;
    ball3Position[Y] = centerY + sin(ball3Angle) * circleHeight;
    
//    // you lose
//    if(delegate)
//        delegate->gameDidFinishWithLose();
//        // you win
//        win = true;
//        if(delegate)
//            delegate->gameDidFinishWithWin();
    
}

void MiniCups::touchDownCoords(float x, float y){
//    touchLocation[X] = x;
//    touchLocation[Y] = y;
    int ballSelection = 0;
    float TOUCH_SIZE = 75.;
    float r1 = sqrt( pow( x-ball1Position[X], 2 ) + pow( y-ball1Position[Y], 2 ) );
    float r2 = sqrt( pow( x-ball2Position[X], 2 ) + pow( y-ball2Position[Y], 2 ) );
    float r3 = sqrt( pow( x-ball3Position[X], 2 ) + pow( y-ball3Position[Y], 2 ) );
    if(r1 < TOUCH_SIZE)
        ballSelection = 1;
    if(r2 < TOUCH_SIZE)
        ballSelection = 2;
    if(r3 < TOUCH_SIZE)
        ballSelection = 3;
    printf("RADIUSES(%d): %f, %f, %f\n",ballSelection,r1, r2, r3);
    
    if(ballSelection != 0){
        if(ballSelection == 1){ // you win
            printf("WIN\n");
            win = true;
        }
        else if (ballSelection == 2 || ballSelection == 3){ // you lose
            printf("LOSE\n");
        }

        if(gameState == cupsGameStatePicking){
            ////////////////
            //  to begin the end of the minigame
            gameState = cupsGameStateWinLose;
            nextStartTime = ofGetElapsedTimeMillis() + 1000;
            ////////////////
            showBall = true;
        }
    }
    fingerTouchDown = true;
}

void MiniCups::touchDown(ofTouchEventArgs &touch){
    
    //touchDownCoords(xtouch, ytouch);
}

void MiniCups::touchMoved(ofTouchEventArgs &touch){
    
}

void MiniCups::touchUp(ofTouchEventArgs &touch){
    fingerTouchDown = false;
}

void MiniCups::drawTimer(int centerX, int centerY){
    ofFill();
    ofSetColor(255, 255, 255, 60);
    ofBeginShape();
    ofVertex(centerX,centerY);
    static float outerRadius = 20;
    static float resolution = 256;
    static float deltaAngle = TWO_PI / resolution;
    float angle = 0;
    float roundProgress = (1-(nextStartTime-ofGetElapsedTimeMillis())/10000.0);
    for(int i = 0; i <= resolution; i++){
        if((float)i/resolution <= roundProgress){
            float x = centerX + outerRadius * sin(angle);
            float y = centerY + outerRadius * -cos(angle);
            ofVertex(x,y);
            angle += deltaAngle;
        }
    }
    ofVertex(centerX,centerY);
    ofEndShape();
    ofSetColor(255, 255, 255, 255);
}

void MiniCups::draw(){
    backgroundTexture.draw(x, y, w, h);

//    touchTexture.draw(touchLocation[X], touchLocation[Y], 40, 40);
    if(showBall){
        ofSetColor(255, 100*gameFade);
        ball2Texture.draw(ball2Position[X], ball2Position[Y]);
        ball3Texture.draw(ball3Position[X], ball3Position[Y]);
        ofSetColor(255, 55, 55, 255*gameFade);
        ball1Texture.draw(ball1Position[X], ball1Position[Y]);
    }
    else{
        ofSetColor(255, 255*gameFade);
        ball2Texture.draw(ball2Position[X], ball2Position[Y]);
        ball3Texture.draw(ball3Position[X], ball3Position[Y]);
        if(gameState == cupsGameStateAccelerating){
            float time = (ofGetElapsedTimeMillis() - accelerationBeginTime)/1000.0;
            if(time < 0) time = 0;
            if(time > 1.0) time = 1.0;
            ofSetColor(255, 55 + 200.0*time, 55 + 200.0*time, 255*gameFade);
        }
        ball1Texture.draw(ball1Position[X], ball1Position[Y]);
    }
    ofSetColor(255, 255);
    if(gameState == cupsGameStateGetReady)
        font.drawString("follow the red ball", centerX - font.stringWidth("follow the red ball")*.5, centerY-h*.53);
    if(gameState == cupsGameStatePicking)
        font.drawString("which one?", centerX - font.stringWidth("which one?")*.5, centerY-h*.53);
    if(gameState == cupsGameStateWinLose){
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
