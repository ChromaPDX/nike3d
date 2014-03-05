//
//  PlayerNode.m
//  nike3dField
//
//  Created by Chroma Developer on 3/4/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"

@implementation PlayerNode

-(void)draw {
    ofDisableDepthTest();
    glDisable(GL_CULL_FACE);
    [super draw];
    glEnable(GL_CULL_FACE);
    ofEnableDepthTest();
}
@end
