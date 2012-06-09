//
//  AppDelegate.m
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 Launch Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "NOImageCorrelate.h"
#import "CGImageToBitmap.h"
#import <Accelerate/Accelerate.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize view, scrollContent;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"shuttle-sample" ofType:@"png"]];
    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"flag-kernel" ofType:@"png"]];
    
    CGImageSourceRef samplesource = CGImageSourceCreateWithData((__bridge CFDataRef)[sample TIFFRepresentation], nil);
    CGImageRef sampleref = CGImageSourceCreateImageAtIndex(samplesource, 0, nil);    

    CGImageSourceRef kernelsource = CGImageSourceCreateWithData((__bridge CFDataRef)[kernel TIFFRepresentation], nil);
    CGImageRef kernelref = CGImageSourceCreateImageAtIndex(kernelsource, 0, nil);
    
    NSArray *points = [[[NOImageCorrelate alloc] init] probablePointsForImage:kernelref inImage:sampleref];
        
    if (points != nil) {
        NSBitmapImageRep *sampleRep = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
        
        if ([points count] > 8) {
            NSLog(@"more than 8 possible points is an unlikely match if looking for a single target");
        }
        
        // points here are possible locations of the bottom right corner of the kernel
        for (int i = 0; i < [points count]; i++) {
            CGPoint point = [[points objectAtIndex:i] pointValue];
            NSLog(@"matched point: %f,%f",point.x,point.y);
            
            NSColor *red = [NSColor colorWithDeviceRed:1 green:0 blue:0 alpha:1];
            for (int i = 0; i < kernel.size.width+1; i++) {
                [sampleRep setColor:red atX:(point.x-i) y:point.y];
                [sampleRep setColor:red atX:(point.x-i) y:(point.y-kernel.size.height)];
            }
            for (int i = 0; i < kernel.size.height; i++) {
                [sampleRep setColor:red atX:point.x y:(point.y-i)];
                [sampleRep setColor:red atX:(point.x-kernel.size.width) y:(point.y-i)];
            }
        }
        
        // for demonstration purposes, surround the kernel with a red box
                
        NSImage *visual = [[NSImage alloc] initWithCGImage:[sampleRep CGImage] size:[sample size]];
        NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, sample.size.width, sample.size.height)];
        [iv setImage:visual];
        
        [scrollContent setDocumentView:iv];
    }    
}

// for debugging results
- (void)showImage:(float*)imageArray forWidth:(int)width andHeight:(int)height
{
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"shuttle-sample" ofType:@"png"]];
    NSBitmapImageRep *imrep = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
    
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            int idx = ((width*i)+j);
            
            NSColor *color;

            color = [NSColor colorWithDeviceRed:imageArray[idx]/255 green:imageArray[idx]/255 blue:imageArray[idx]/255 alpha:1];

            [imrep setColor:color atX:j y:i];
        }
    }
    
    NSImage *img = [[NSImage alloc] initWithCGImage:[imrep CGImage] size:NSMakeSize(width, height)];
    NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [iv setImage:img];
    
    [scrollContent setDocumentView:iv];
}

@end
