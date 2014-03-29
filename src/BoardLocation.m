//
//  BoardLocation.m
//  CardDeck
//
//  Created by Robby Kraft on 9/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import "BoardLocation.h"

@implementation BoardLocation

-(id)initWithX:(NSInteger)x Y:(NSInteger)y{
    self = [super init];
    if(self){
        [self setX:x];
        [self setY:y];
    }
    return self;
}

+(instancetype)pointWithCGPoint:(CGPoint)point {
    return [[BoardLocation alloc] initWithX:point.x Y:point.y];
}

+(instancetype)pX:(int)x Y:(int)y{
    return [[BoardLocation alloc] initWithX:x Y:y];
}

-(CGPoint)CGPoint {
    return CGPointMake(_x, _y);
}

-(BOOL)isEqual:(id)other {
    if (_x == [(BoardLocation*)other x] && _y == [(BoardLocation*)other y]) {
        return 1;
    }
    return 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"BoardLocation: X:%d Y:%d",_x,_y];
}

-(NSUInteger) hash;{
    return 1;
}

-(instancetype)copy {
    return [BoardLocation pX:self.x Y:self.y];
}

- (id)copyWithZone:(NSZone *)zone{
    id copy = [[[self class] allocWithZone:zone] init];
    [copy setX:[self x]];
    [copy setY:[self y]];
    return copy;
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _x = [decoder decodeIntegerForKey:@"_x"];
    _y = [decoder decodeIntegerForKey:@"_y"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:_x forKey:@"_x"];
    [encoder encodeInteger:_y forKey:@"_y"];
    
}

-(void) setBorderShapeInContext:(NSArray *)arrayOfLocations{
    bool left =  ![arrayOfLocations containsObject:[BoardLocation pX:_x-1 Y:_y]];
    bool right = ![arrayOfLocations containsObject:[BoardLocation pX:_x+1 Y:_y]];
    bool above = ![arrayOfLocations containsObject:[BoardLocation pX:_x Y:_y+1]];
    bool below = ![arrayOfLocations containsObject:[BoardLocation pX:_x Y:_y-1]];
    if(!above && !right && !below && !left) _borderShape = 0;
    if( above && !right && !below && !left) _borderShape = 1;
    if(!above &&  right && !below && !left) _borderShape = 2;
    if( above &&  right && !below && !left) _borderShape = 3;
    if(!above && !right &&  below && !left) _borderShape = 4;
    if( above && !right &&  below && !left) _borderShape = 5;
    if(!above &&  right &&  below && !left) _borderShape = 6;
    if( above &&  right &&  below && !left) _borderShape = 7;
    if(!above && !right && !below &&  left) _borderShape = 8;
    if( above && !right && !below &&  left) _borderShape = 9;
    if(!above &&  right && !below &&  left) _borderShape = 10;
    if( above &&  right && !below &&  left) _borderShape = 11;
    if(!above && !right &&  below &&  left) _borderShape = 12;
    if( above && !right &&  below &&  left) _borderShape = 13;
    if(!above &&  right &&  below &&  left) _borderShape = 14;
    if( above &&  right &&  below &&  left) _borderShape = 15;
}

@end
