//
//  AppDelegate.m
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 Launch Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "NOImageCorrelate.h"
#import <Accelerate/Accelerate.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize view, scrollContent;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"lax-sample" ofType:@"png"]];
    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"plane-kernel" ofType:@"png"]];

    NSBitmapImageRep *sampleRep = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
    NSBitmapImageRep *kernelRep = [NSBitmapImageRep imageRepWithData:[kernel TIFFRepresentation]];
    
    NOImageCorrelate *ic = [[NOImageCorrelate alloc] init];
    NSArray *points = [ic probablePointsForImage:kernel inImage:sample];
    
    if ([points count] > 8) {
        NSLog(@"more than 8 possible points is an unlikely match if looking for a single target");
    }

    // points here are possible locations of the bottom right corner of the kernel
    for (int i = 0; i < [points count]; i++) {
        CGPoint point = [[points objectAtIndex:i] pointValue];
        NSLog(@"matched point: %f,%f",point.x,point.y);
    }

    // for demonstration purposes, surround the kernel with a red box
    CGPoint primary = [[points objectAtIndex:0] pointValue];
    NSColor *red = [NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:1];
    for (int i = 0; i < kernel.size.width+1; i++) {
        [sampleRep setColor:red atX:(primary.x-i) y:primary.y];
        [sampleRep setColor:red atX:(primary.x-i) y:(primary.y-kernel.size.height)];
    }
    for (int i = 0; i < kernel.size.height; i++) {
        [sampleRep setColor:red atX:primary.x y:(primary.y-i)];
        [sampleRep setColor:red atX:(primary.x-kernel.size.width) y:(primary.y-i)];
    }
    
    NSImage *visual = [[NSImage alloc] initWithCGImage:[sampleRep CGImage] size:[sample size]];
    NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, sample.size.width, sample.size.height)];
    [iv setImage:visual];
    
    [scrollContent setDocumentView:iv];
}

@end
