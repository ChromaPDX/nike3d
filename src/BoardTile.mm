//
//  BoardTile.m
//  nike3dField
//
//  Created by Chroma Developer on 3/3/14.
//
//

#import "NikeNodeHeaders.h"
#import "BoardLocation.h"

@implementation BoardTile

-(instancetype)initWithTexture:(NKTexture*)texture color:(UIColor *)color size:(CGSize)size {
    self = [super initWithTexture:texture color:color size:size];
    if (self){
      // box = (ofPlanePrimitive*)new ofBoxPrimitive(size.width, size.height, 4);
    }
    return self;
}

-(NSString*)name{
    return [NSString stringWithFormat:@"TILE: %d %d",_location.x,_location.y ];
}

-(NKTouchState)touchUp:(CGPoint)location id:(int)touchId {
    NKTouchState hit = [super touchUp:location id:touchId];
    if (hit == 2) {
        //_delegate touchj
    }
}
@end
