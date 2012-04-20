//
//  NOImageCorrelate.h
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NOImageCorrelate : NSObject

+ (id)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample;
- (id)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample;

@end
