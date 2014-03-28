//
//  MenuNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "../NikeNodeHeaders.h"

@interface MenuNode (){
}

@end

@implementation MenuNode

-(instancetype)initWithSize:(CGSize) size {
    self = [super init];
    
    if (self) {
        self.size = size;
        [self setUserInteractionEnabled:YES];
        self.name = @"Menu Node";
    }
    
    
    return self;
}

-(void)startMenu {
    
    char* extensionList = (char*)glGetString(GL_EXTENSIONS);
    
    ofLogNotice("GL") << string(extensionList);
    
    NKScrollNode* table = [[NKScrollNode alloc] initWithColor:nil size:self.size];
    [self addChild:table];
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
    image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_a.png"]];
    [subTable setTexture:image];
    [subTable setHighlightColor:highlightColor];
    [subTable setName:@"1"];
    
    //ofPoint df = subTable.getGlobalPosition();
    //ofRectangle drawFrame = [subTable getDrawFrame];
    //NSLog(@"drawFrame1 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);
    
    NKScrollNode *subTable2 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.13];
    [table addChild:subTable2];
    subTable2.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    subTable2.scrollingEnabled = true;
    [subTable2 setHighlightColor:highlightColor];
    image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_b.png"]];
    [subTable2 setTexture:image];
    [subTable2 setName:@"2"];
    //df = subTable2.node->getPosition();
    //drawFrame = [subTable2 getDrawFrame];
    //NSLog(@"drawFrame2 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);
    
    NKScrollNode *subTable3 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.125];
    [table addChild:subTable3];
    subTable3.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    [subTable3 setHighlightColor:highlightColor];
    subTable3.scrollingEnabled = true;
    image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_c.png"]];
    [subTable3 setTexture:image];
    //drawFrame = [subTable3 getDrawFrame];
    //df = subTable3.node->getPosition();
    //NSLog(@"drawFrame3 = %f,%f %fx%f", df.x, df.y, drawFrame.width, drawFrame.height);
    [subTable3 setName:@"3"];
    
    NKScrollNode *subTable4 = [[NKScrollNode alloc] initWithParent:table autoSizePct:.125];
    [table addChild:subTable4];
    subTable4.color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
    [subTable4 setHighlightColor:highlightColor];
    subTable4.scrollingEnabled = true;
    image = [NKTexture textureWithImageNamed:[NSString stringWithFormat:@"menu1_d.png"]];
    [subTable4 setTexture:image];
    [subTable4 setName:@"4"];
    
    // setupCM();
    //subTable.node->setOrientation(ofVec3f(0,1,0));
    

    
}

-(void)updateWithTimeSinceLast:(NSTimeInterval)dt {
      [super updateWithTimeSinceLast:dt];
}

-(void)customDraw {
    ofEnableDepthTest();
}

-(NKTouchState)touchDown:(CGPoint)location id:(int)touchId {
    NKTouchState touchState = [super touchDown:location id:touchId]; // this queries children first returns 2 if no children, 1 if active child
    if (touchState == 2){
        location.y = -location.y;
        NSLog(@"TOUCH X:%.1f  Y:%.1f",location.x, location.y);
    }
    return touchState;
}

-(void)dealloc {
   	
}

@end
