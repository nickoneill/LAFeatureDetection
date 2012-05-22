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
@synthesize view;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"ground" ofType:@"png"]];
    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"alcatraz-kernel" ofType:@"png"]];
        

//    NOImageCorrelate *ic = [[NOImageCorrelate alloc] init];
//    [ic setDelegate:self];
//    NSArray *points = [ic probablePointsForImage:kernel inImage:sample];
//    
//    for (int i = 0; i < [points count]; i++) {
//        CGPoint point = [[points objectAtIndex:i] pointValue];
//        NSLog(@"point: %f,%f",point.x,point.y);
//    }
    
    [self sobelize:sample];
}

typedef struct {
	unsigned char redByte, greenByte, blueByte, alphaByte;
} RGBAPixel;

typedef struct {
	unsigned char redByte, greenByte, blueByte;
} RGBPixel;

- (void)sobelize:(NSImage*)image
{
    NSBitmapImageRep *sampleRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    RGBAPixel *sampleAlphaPixels = (RGBAPixel *)[sampleRep bitmapData];
    int n = 256;
    float *sampleArray = (float *)malloc((n*n) * sizeof(float));
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (i < [sampleRep pixelsHigh] && j < [sampleRep pixelsWide]) {
                RGBAPixel *sampleAlphaPixel;
                unsigned char gray;
                
                sampleAlphaPixel = (RGBAPixel *)&sampleAlphaPixels[([sampleRep pixelsWide]*i)+j];
                gray = ((sampleAlphaPixel->redByte*0.2989) + (sampleAlphaPixel->greenByte*0.5870) + (sampleAlphaPixel->blueByte*0.1140));
                
                sampleArray[(n*i)+j] = (float)gray;
            } else {
                
                sampleArray[(n*i)+j] = 0.0;
            }
        }
    }
    
//    float *xKernel = (float *)malloc(9 * sizeof(float));
//    xKernel[0] = -1;
//    xKernel[1] = 0;
//    xKernel[2] = 1;
//    xKernel[3] = -2.0;
//    xKernel[4] = 0.0;
//    xKernel[5] = 2.0;
//    xKernel[6] = -1.0;
//    xKernel[7] = 0.0;
//    xKernel[8] = 1.0;
    
    int16_t newxKernel[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};

    float *yKernel = (float *)malloc(9 * sizeof(float));
    yKernel[0] = -1;
    yKernel[1] = -2;
    yKernel[2] = -1;
    yKernel[3] = 0;
    yKernel[4] = 0;
    yKernel[5] = 0;
    yKernel[6] = 1;
    yKernel[7] = 2;
    yKernel[8] = 1;

    Pixel_F bgColor = 0.0;
    
    vImage_Buffer buf;
    buf.data = sampleArray;
    buf.height = 256;
    buf.width = 256;
    buf.rowBytes = 256*4;
    
    vImage_Buffer dest;
    dest.data = malloc(n*n * sizeof(float));
    dest.height = 256;
    dest.width = 256;
    dest.rowBytes = 256*4;
    
    vImageConvolve_PlanarF(&buf, &dest, nil, 0, 0, newxKernel, 3, 3, bgColor, kvImageEdgeExtend);
    
    NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
    NSBitmapImageRep *imrep = [[NSBitmapImageRep alloc] initWithCGImage:[sampleRep CGImage]];
    
    float *temp = dest.data;
    for (int i = 0; i < 256; i++) {
        for (int j = 0; j < 256; j++) {
            NSUInteger zColourAry[3] = {temp[(n*i)+j],temp[(n*i)+j],temp[(n*i)+j]};
            [imrep setPixel:zColourAry atX:j y:i];
        }
    }
    
    NSImage *img = [[NSImage alloc] initWithCGImage:[imrep CGImage] size:NSMakeSize(256, 256)];
    [iv setImage:img];
    
    [self.view addSubview:iv];
    
    NSLog(@"sobelized!");
}

@end
