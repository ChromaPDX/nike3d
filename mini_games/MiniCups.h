//
//  MiniMaze.h
//  MiniNine
//
//  Created by Robby Kraft on 3/3/14.
//
//

#ifndef __MiniGame__MiniCups__
#define __MiniGame__MiniCups__

#include "ofMain.h"

class MiniCupsDelegate {
public:
	virtual void gameDidFinishWithWin() {}
    virtual void gameDidFinishWithLose() {}
};

@protocol MiniCupsObjDelegate <NSObject>
-(void) gameDidFinishWithWin;
-(void) gameDidFinishWithLose;
@end

typedef enum {
    cupsGameStateGetReady,
    cupsGameStateAccelerating,
    cupsGameStateSlowing,
    cupsGameStatePicking,
    cupsGameStateReveal,
    cupsGameStateWinLose
} CupsGameState;

class MiniCups {
    
public:
    MiniCups();
    ~MiniCups();
    void setup(int x, int y, int width, int height);
    void update();
    void draw();
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    
    void touchDownCoords(float x, float y);
    
    MiniCupsDelegate *delegate = NULL;
    id<MiniCupsObjDelegate> objDelegate = NULL;
    
private:
    
    void drawTimer(int centerX, int centerY);
    
    ofTexture backgroundTexture;
    ofTexture white30Texture;
    
    ofTrueTypeFont font;
    
    int w, h, x, y;
    int centerX, centerY;
    int CELLSIZE;
    
    CupsGameState gameState;
    long nextStartTime;
    
    ofTexture ball1Texture, ball2Texture, ball3Texture;
    
//    ofTexture touchTexture;
//    float touchLocation[2];
    
    float ball1Position[2];
    float ball2Position[2];
    float ball3Position[2];
    float ball1Angle, ball2Angle, ball3Angle;
    float angleVelocity;
    float angleAcceleration;
    
    
    bool win = false;
    
    long spinTime;
    
    bool showBall;
    
    bool fingerTouchDown;
    
    float circleHeight, circleWidth;

};

#endif /* defined(__MiniGame__MiniCups__) */
