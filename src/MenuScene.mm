//
//  MenuScene.m
//  nike3dField
//
//  Created by Chroma Developer on 3/25/14.
//
//

#import "MenuScene.h"

@implementation MenuScene


-(instancetype)initWithSize:(CGSize)size {
    
    self = [super initWithSize:size];
    
    if (self) {
        _MenuNode = [[MenuNode alloc] initWithSize:self.size];
        
        [self addChild:_MenuNode];
        
        [_MenuNode startMenu];
    }
    
    return self;
}
@end
