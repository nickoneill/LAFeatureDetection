//
//  NOImageCorrelate.h
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOImageCorrelate : NSObject

@property (nonatomic, weak) id delegate;

// tweak this value if you're getting too many points back
@property (nonatomic) float relatedPointThreshold;

+ (NSArray*)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample;
- (NSArray*)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample;

@end
