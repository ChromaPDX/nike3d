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
    
    centerX = x+w*.5;
    centerY = y+h*.42;  // because of the text box
    CELLSIZE = height/9.5f;
    
    ofLoadImage(backgroundTexture, "background.png");
    ofLoadImage(white30Texture, "thirtypercentwhite.png");
    ofLoadImage(ball1Texture, "theball.png");
    ofLoadImage(ball2Texture, "theball.png");
    ofLoadImage(ball3Texture, "theball.png");

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
    
    angleVelocity = 0;
    
    gameState = cupsGameStateWaiting;
    nextStartTime = 3000;
}

void MiniCups::update(){
    
    if(gameState == cupsGameStateWaiting && ofGetElapsedTimeMillis() > nextStartTime){
        angleVelocity = 0;
        angleAcceleration = .005;
        spinTime = ofRandom(1000, 1200);
        gameState = cupsGameStateAccelerating;
        nextStartTime = ofGetElapsedTimeMillis() + spinTime;
        showBall = false;
    }
    if(gameState == cupsGameStateAccelerating && ofGetElapsedTimeMillis() > nextStartTime){
        gameState = cupsGameStateSlowing;
        angleAcceleration = -.005;
        nextStartTime = ofGetElapsedTimeMillis() + spinTime;
    }
    if(gameState == cupsGameStateSlowing && ofGetElapsedTimeMillis() > nextStartTime){
        gameState = cupsGameStatePicking;
        angleAcceleration = 0;
        angleVelocity = 0;
        nextStartTime = ofGetElapsedTimeMillis() + 3000;
    }
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
    if(gameState == cupsGameStatePicking){
        gameState = cupsGameStateWaiting;
        nextStartTime = ofGetElapsedTimeMillis() + 1000;
        showBall = true;
    }
    fingerTouchDown = true;
}

void MiniCups::touchDown(ofTouchEventArgs &touch){
    
    if(gameState == cupsGameStatePicking){
        gameState = cupsGameStateWaiting;
        nextStartTime = ofGetElapsedTimeMillis() + 1000;
        showBall = true;
    }
    fingerTouchDown = true;
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

    if(showBall){
        ofSetColor(255, 100);
        ball2Texture.draw(ball2Position[X], ball2Position[Y]);
        ball3Texture.draw(ball3Position[X], ball3Position[Y]);
        ofSetColor(255, 255);
        ball1Texture.draw(ball1Position[X], ball1Position[Y]);
    }
    else{
        ofSetColor(255, 255);
        ball1Texture.draw(ball1Position[X], ball1Position[Y]);
        ball2Texture.draw(ball2Position[X], ball2Position[Y]);
        ball3Texture.draw(ball3Position[X], ball3Position[Y]);
    }

}
