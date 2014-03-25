//
//  MiniMaze.cpp
//  MiniNine
//
//  Created by Robby Kraft on 3/3/14.
//
//

#include "MiniTouch.h"

#define X 0
#define Y 1

#define ELASTIC .4f // elastic dampening
#define STATIC .02f // static friction
#define KINETIC .9f // inverse kinetic friction

MiniTouch::MiniTouch(){

}

MiniTouch::~MiniTouch(){

}

void MiniTouch::setup(int xIn, int yIn, int width, int height){
    x = xIn;
    y = yIn;
    w = width;
    h = height;
    
    centerX = x+w*.5;
    centerY = y+h*.42;  // because of the text box
    CELLSIZE = height/9.5f;
    
    gameState = touchGameStateWaiting;
    nextStartTime = 1000;
    ballIncrement = 0;

    ofLoadImage(backgroundTexture, "background.png");
    ofLoadImage(white30Texture, "thirtypercentwhite.png");
    ofLoadImage(ballTexture, "theball.png");
    ballTexture.setAnchorPercent(0.5, 0.5);
    
    ballPosition[X] = centerX;
    ballPosition[Y] = centerY;
}

void MiniTouch::update(){

    //game round stuff
    if(gameState == touchGameStateWaiting && ofGetElapsedTimeMillis() > nextStartTime){
        // start a new round
        gameState = touchGameStateRunning;
        nextStartTime = ofGetElapsedTimeMillis() + 10000;
        win = false;
//        ballIncrement = 0;
    }
    if(gameState == touchGameStateRunning){
        ballIncrement += .125;
        ballPosition[X] = centerX + sin(ballIncrement) * w*.33;
        ballPosition[Y] = centerY + cos(ballIncrement*2) * w*.05;
    }
}

void MiniTouch::touchDownCoords(float x, float y){
    ofTouchEventArgs nilObj;
    touchDown(nilObj);
}

void MiniTouch::touchDown(ofTouchEventArgs &touch){
    if(gameState == touchGameStateRunning){
        if(ballPosition[X] < centerX + 25 && ballPosition[X] > centerX - 25){
            printf("WIN\n");
            // you win
            win = true;
            if(delegate)
                delegate->gameDidFinishWithWin();
            if(objDelegate)
                [objDelegate gameDidFinishWithWin];
        }
        else{
            printf("LOSE\n");
            // you lose
            if(delegate)
                delegate->gameDidFinishWithLose();
            if(objDelegate)
                [objDelegate gameDidFinishWithLose];
        }

        gameState = touchGameStateWaiting;
        nextStartTime = ofGetElapsedTimeMillis() + 1000;
    }
}
void MiniTouch::touchMoved(ofTouchEventArgs &touch){
    
}

void MiniTouch::touchUp(ofTouchEventArgs &touch){

}

void MiniTouch::drawTimer(int centerX, int centerY){
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

void MiniTouch::draw(){
    if(win)
        ofClear(0, 100, 0);
    backgroundTexture.draw(x, y, w, h);
    ofSetColor(255, 100);
    ballTexture.draw(centerX, centerY+w*.05, 60, 60);
    ofSetColor(255, 255);
    ballTexture.draw(ballPosition[X], ballPosition[Y], 30, 30);
}
