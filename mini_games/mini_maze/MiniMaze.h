//
//  MiniMaze.h
//  MiniNine
//
//  Created by Robby Kraft on 3/3/14.
//
//

#ifndef __MiniNine__MiniMaze__
#define __MiniNine__MiniMaze__

#include <CoreMotion/CoreMotion.h>
#include "ofMain.h"

class MiniMazeDelegate {
public:
	virtual void gameDidFinishWithWin() {}
    virtual void gameDidFinishWithLose() {}
};

@protocol MiniMazeObjDelegate <NSObject>
-(void) gameDidFinishWithWin;
-(void) gameDidFinishWithLose;
@end

typedef enum {
    gameStateWaiting,
    gameStateRunning,
    gameStateWinLose
} GameState;



class MiniMaze {
    
public:
    MiniMaze();
    ~MiniMaze();
    void setup(int x, int y, int width, int height);
    void update();
    void draw();
    
    MiniMazeDelegate *delegate = NULL;
    id<MiniMazeObjDelegate> objDelegate = NULL;
    
private:
    
    void drawTimer(int centerX, int centerY);
    
    CMMotionManager *motionManager;
    ofMatrix3x3 attitude;
    ofMatrix3x3 lastAttitude;
    ofMatrix3x3 normalized;
//    void correctNormalization();
//    void log2Matrices3x3(ofMatrix3x3 m1, ofMatrix3x3 m2);
//    void logAttitude();
//    void logMatrix3x3(ofMatrix3x3 matrix);
    float phoneTiltX;
    float phoneTiltY;
    
    ofTexture backgroundTexture;
    ofTexture white30Texture;
    ofTexture startArrowTexture;
    ofTexture endArrowTexture;
    
    ofTexture ballTexture;
    float ballPosition[2];
    float ballVelocity[2];
    float ballAcceleration[2];
    int ballRadius;

    ofTexture successTexture, failTexture;
    
    ofRectangle wall[6];
    float startCell[2];
    float endCell[2];
    
    int centerX, centerY;
    
    int w, h, x, y;
    int CELLSIZE;
    
    GameState gameState;
    long nextStartTime;
    
    bool win = false;
    
};

#endif /* defined(__MiniNine__MiniMaze__) */
