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
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"sobelground" ofType:@"png"]];
    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"sobelblockrot" ofType:@"png"]];
        
//    NSImage *testone = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"sobelground" ofType:@"png"]];
//    NSBitmapImageRep *samplerep = [NSBitmapImageRep imageRepWithData:[testone TIFFRepresentation]];
//    NSLog(@"testone bpp: %lu",[samplerep bitmapFormat]);
//    
//    NSImage *test = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"sobelground" ofType:@"jpg"]];
//    NSBitmapImageRep *testrep = [NSBitmapImageRep imageRepWithData:[test TIFFRepresentation]];
//    NSLog(@"test bpp: %lu",[testrep bitmapFormat]);

    NSImageView *result = [[NSImageView alloc] initWithFrame:self.view.frame];

    NSArray *points = [NOImageCorrelate probablePointsForImage:kernel inImage:sample];
    
    for (int i = 0; i < [points count]; i++) {
        CGPoint point = [[points objectAtIndex:i] pointValue];
        NSLog(@"point: %f,%f",point.x,point.y);
    }
    
    [result setImage:sample];
    
    [self.view addSubview:result];
}

@end
