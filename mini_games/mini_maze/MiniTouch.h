//
//  MiniMaze.h
//  MiniNine
//
//  Created by Robby Kraft on 3/3/14.
//
//

#ifndef __MiniTouch__MiniTouch__
#define __MiniTouch__MiniTouch__

#include "ofMain.h"

class MiniTouchDelegate {
public:
	virtual void gameDidFinishWithWin() {}
    virtual void gameDidFinishWithLose() {}
};

@protocol MiniTouchObjDelegate <NSObject>
-(void) gameDidFinishWithWin;
-(void) gameDidFinishWithLose;
@end

typedef enum {
    touchGameStateWaiting,
    touchGameStateRunning,
    touchGameStateWinLose
} TouchGameState;

class MiniTouch {
    
public:
    MiniTouch();
    ~MiniTouch();
    void setup(int x, int y, int width, int height);
    void update();
    void draw();
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    
    void touchDownCoords(float x, float y);
    
    MiniTouchDelegate *delegate = NULL;
    id<MiniTouchObjDelegate> objDelegate = NULL;
    
private:
    
    void drawTimer(int centerX, int centerY);
    
    ofTexture backgroundTexture;
    ofTexture white30Texture;
    ofTexture ballTexture;
    float ballIncrement;
    ofTrueTypeFont font;
    
    ofTexture successTexture, failTexture;
    
    int w, h, x, y;
    int centerX, centerY;
    int CELLSIZE;
    float ballPosition[2];
    
    TouchGameState gameState;
    long nextStartTime;
    
    bool win = false;
    
};

#endif /* defined(__MiniTouch__MiniTouch__) */
