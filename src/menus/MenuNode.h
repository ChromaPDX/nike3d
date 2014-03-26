//
//  MiniGameNode.h
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NKNode.h"

@interface MenuNode : NKNode

// OF CORE

void setup();
void update();
void draw();
void exit();

void touchDown(ofTouchEventArgs & touch);
void touchMoved(ofTouchEventArgs & touch);
void touchUp(ofTouchEventArgs & touch);
void touchDoubleTap(ofTouchEventArgs & touch);
void touchCancelled(ofTouchEventArgs & touch);

void lostFocus();
void gotFocus();
void gotMemoryWarning();
void deviceOrientationChanged(int newOrientation);


-(instancetype)initWithSize:(CGSize) size;

-(void)startMenu;

@end
