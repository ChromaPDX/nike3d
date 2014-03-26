//
//  MiniGameScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "MiniGameScene.h"

@implementation MiniGameScene


-(instancetype)initWithSize:(CGSize)size {
    
    self = [super initWithSize:size];
    
    if (self) {
        _miniGameNode = [[MiniGameNode alloc] initWithSize:self.size];
        
        [self addChild:_miniGameNode];
        
        [_miniGameNode startMiniGame];
    }
    
    return self;
}

@end
