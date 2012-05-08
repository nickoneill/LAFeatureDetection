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
    NSImage *sample = [NSImage imageNamed:@"sobelground.png"];
    NSImage *kernel = [NSImage imageNamed:@"sobelblockrot.png"];
    
    NSBitmapImageRep *testrep = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
    
    NSLog(@"sample bpp: %ld",[testrep bitsPerPixel]);

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
