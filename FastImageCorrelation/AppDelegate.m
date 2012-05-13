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
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"sobelground" ofType:@"jpg"]];
    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"sobelblockrot" ofType:@"png"]];
        
    NSImageView *result = [[NSImageView alloc] initWithFrame:self.view.frame];

    NOImageCorrelate *ic = [[NOImageCorrelate alloc] init];
    [ic setDelegate:self];
    NSArray *points = [ic probablePointsForImage:kernel inImage:sample];
    
    for (int i = 0; i < [points count]; i++) {
        CGPoint point = [[points objectAtIndex:i] pointValue];
        NSLog(@"point: %f,%f",point.x,point.y);
    }
    
    [result setImage:sample];

    [self.view addSubview:result];
}

@end
