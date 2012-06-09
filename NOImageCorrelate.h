//
//  NOImageCorrelate.h
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 Launch Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOImageCorrelate : NSObject

@property (nonatomic, weak) id delegate;
// tweak this value if you're getting too many points back
@property (nonatomic) float relatedPointThreshold;

+ (NSArray*)probablePointsForImage:(CGImageRef)kernel inImage:(CGImageRef)sample;
- (NSArray*)probablePointsForImage:(CGImageRef)kernel inImage:(CGImageRef)sample;

@end
