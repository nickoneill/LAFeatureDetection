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
    NSImage *sample = [NSImage imageNamed:@"sobelground.jpg"];
    NSImage *kernel = [NSImage imageNamed:@"sobelblockrot.jpg"];

    NSImageView *result = [[NSImageView alloc] initWithFrame:self.view.frame];

//    [[[NOImageCorrelate alloc] init] fft:sample andRef:kernel];

    id athing = [NOImageCorrelate probablePointsForImage:kernel inImage:sample];
    if ([athing isKindOfClass:[NSArray class]]) {
        NSArray *points = (NSArray *)athing;
        
        for (int i = 0; i < [points count]; i++) {
            CGPoint point = [[points objectAtIndex:i] pointValue];
            NSLog(@"point: %f,%f",point.x,point.y);
        }
        
        [result setImage:sample];
    } else if ([athing isKindOfClass:[NSImage class]]) {
        NSImage *test = (NSImage *)athing;
        
        [result setImage:test];
        [result setFrame:NSMakeRect(0, 0, test.size.width, test.size.height)];
    }
    
    [self.view addSubview:result];
}

@end
