//
//  GeoidCalculator.h
//  CyclingTestDemo
//
//  Created by Lyons Eric on 2017/7/7.
//  Copyright © 2017年 Lyons Eric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoidCalculator : NSObject

+ (GeoidCalculator *)calculator NS_SWIFT_NAME(defaultManager());

- (double)getHeightFromLat:(double)lat andLon:(double)lon;
- (double)getCurrentHeightOffset;
- (void)updatePositionWithLatitude:(double)lat andLongitude:(double)lon;

@end
