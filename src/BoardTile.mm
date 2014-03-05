//
//  BoardTile.m
//  nike3dField
//
//  Created by Chroma Developer on 3/3/14.
//
//

#import "NikeNodeHeaders.h"

@implementation BoardTile

-(instancetype)initWithTexture:(ofTexture*)texture color:(UIColor *)color size:(CGSize)size {
    self = [super initWithTexture:texture color:color size:size];
    if (self){
      // box = (ofPlanePrimitive*)new ofBoxPrimitive(size.width, size.height, 4);
    }
    return self;
}

@end
