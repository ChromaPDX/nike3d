//
//  BoardLocation.h
//  CardDeck
//
//  Created by Robby Kraft on 9/20/13.
//  Copyright (c) 2013 Robby Kraft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(UInt16, BorderMask) {
    
    BorderMaskNone = 0,
    
    BorderMaskLeft = 1 << 1,
    BorderMaskRight = 1 << 2,
    BorderMaskTop = 1 << 3,
    BorderMaskBottom = 1 << 4,
    
    BorderMaskUR = BorderMaskTop | BorderMaskRight,
    BorderMaskUL = BorderMaskTop | BorderMaskLeft,
    BorderMaskBR = BorderMaskBottom | BorderMaskRight,
    BorderMaskBL = BorderMaskBottom | BorderMaskLeft,
    
    BorderMaskVertical = BorderMaskLeft | BorderMaskRight,
    BorderMaskHorizontal = BorderMaskTop | BorderMaskBottom,
    BorderMask3top = BorderMaskLeft | BorderMaskTop | BorderMaskRight,
    BorderMask3bottom = BorderMaskLeft | BorderMaskBottom | BorderMaskRight,
    BorderMask3left = BorderMaskLeft | BorderMaskBottom | BorderMaskTop,
    BorderMask3right = BorderMaskRight | BorderMaskBottom | BorderMaskTop,

    BorderMaskAll = BorderMaskLeft | BorderMaskRight | BorderMaskBottom | BorderMaskTop,
    
};

@interface BoardLocation : NSObject <NSCopying, NSCoding>
{

}
@property NSInteger x;
@property NSInteger y;
@property int borderShape;

+(instancetype)pX:(int)x Y:(int)y;
+(instancetype)pointWithCGPoint:(CGPoint)point;
-(id)initWithX:(NSInteger)x Y:(NSInteger)y;
-(CGPoint)CGPoint;
-(BOOL)isEqual:(BoardLocation*)point;

-(void)setBorderShapeInContext:(NSArray*)arrayOfLocations;

@end
