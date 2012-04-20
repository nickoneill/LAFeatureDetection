//
//  AppDelegate.m
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "NOImageCorrelate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize view;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSImage *sample = [NSImage imageNamed:@"screen.png"];
    NSImage *kernel = [NSImage imageNamed:@"reference.png"];

    NSImageView *result = [[NSImageView alloc] initWithFrame:self.view.frame];

    id athing = [NOImageCorrelate probablePointsForImage:kernel inImage:sample];
    if ([athing isKindOfClass:[NSArray class]]) {
        NSArray *points = (NSArray *)athing;
        CGPoint firstPoint = [[points objectAtIndex:0] pointValue];
        NSLog(@"First point: %f,%f",firstPoint.x,firstPoint.y);
        
        [result setImage:sample];
    } else if ([athing isKindOfClass:[NSImage class]]) {
        NSImage *test = (NSImage *)athing;
        
        [result setImage:test];
    }
    
    [self.view addSubview:result];
}

@end
