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
    centerY = y+h*.6;  // because of the text box
    CELLSIZE = height/9.5f;
    font.loadFont("Avenir.ttf", ofGetWidth() / 22., true, true);   // 4.2
    largeFont.loadFont("Avenir.ttf", ofGetWidth() / 10., true, true);   // 4.2
    
    gameState = touchGameStateWaiting;
    nextStartTime = 1000;
    ballIncrement = 0;

    ofLoadImage(backgroundTexture, "background.png");
    ofLoadImage(white30Texture, "thirtypercentwhite.png");
    ofLoadImage(ballTexture, "theball.png");
    ballTexture.setAnchorPercent(0.5, 0.5);
    
    ballPosition[X] = centerX;
    ballPosition[Y] = centerY;
    
    ofLoadImage(successTexture, "success.png");
    ofLoadImage(failTexture, "fail.png");
    
    gameFade = 1.0;
}

void MiniTouch::update(){

    //game round stuff
    if(gameState == touchGameStateWaiting && ofGetElapsedTimeMillis() > nextStartTime){
        // start a new round
        gameState = touchGameStateRunning;
        nextStartTime = ofGetElapsedTimeMillis() + 10000;
        gameFade = 1.0;
        win = false;
//        ballIncrement = 0;
    }
    if(gameState == touchGameStateRunning){
        ballIncrement += .125;
        ballPosition[X] = centerX + sin(ballIncrement) * w*.42;
        ballPosition[Y] = centerY + -cos(ballIncrement*2) * w*.05;
    }
    //////////////////
    // fade out, end of game
    if(gameState == touchGameStateWinLose){
        gameFade = 1.0 - (ofGetElapsedTimeMillis() - (nextStartTime-1500)) / 1000.0;
        if(gameFade < 0.0)
            gameFade = 0.0f;
    }
    //////////////////
    if(gameState == touchGameStateWinLose && ofGetElapsedTimeMillis() > nextStartTime){
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
}

void MiniTouch::touchDownCoords(float x, float y){
    ofTouchEventArgs nilObj;
    touchDown(nilObj);
}

void MiniTouch::touchDown(ofTouchEventArgs &touch){
    if(gameState == touchGameStateRunning){
        if(ballPosition[X] < centerX + 75 && ballPosition[X] > centerX - 75){
            printf("WIN\n");
            // you win
            win = true;
        }
        else{
            printf("LOSE\n");
            // you lose
        }

        ////////////////
        //  to begin the end of the minigame
        gameState = touchGameStateWinLose;
        nextStartTime = ofGetElapsedTimeMillis() + 1000;
        ////////////////
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
//    if(win)
//        ofClear(0, 100, 0);
    backgroundTexture.draw(x, y, w, h);
    ofSetColor(255, 100*gameFade);
    ballTexture.draw(centerX, centerY-w*.05, 150, 150);
    ofSetColor(255, 255*gameFade);
    ballTexture.draw(ballPosition[X], ballPosition[Y], 60, 60);
    
    ofSetColor(255, 255);
    if(gameState == touchGameStateRunning)
        font.drawString("quick reflexes", centerX - font.stringWidth("quick reflexes")*.5, centerY-h*.53);
    if(gameState == touchGameStateWinLose){
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
