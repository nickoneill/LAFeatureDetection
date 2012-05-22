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
//    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"alcatraz-kernel" ofType:@"png"]];
        

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
    float *sobelArray  = (float *)malloc((n*n) * sizeof(float));
    
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
    
    float xKernel[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
    float yKernel[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1}; //= (float *)malloc(9 * sizeof(float));

    Pixel_F bgColor = 0;
    
    vImage_Buffer buf;
    buf.data = sampleArray;
    buf.height = 256;
    buf.width = 256;
    buf.rowBytes = 256*4;
    
    vImage_Buffer xdest;
    xdest.data = malloc(n*n * sizeof(float));
    xdest.height = 256;
    xdest.width = 256;
    xdest.rowBytes = 256*4;

    vImage_Buffer ydest;
    ydest.data = malloc(n*n * sizeof(float));
    ydest.height = 256;
    ydest.width = 256;
    ydest.rowBytes = 256*4;

//    vImageConvolve_ARGB8888(&buf, &dest, nil, 0, 0, newxKernel, 3, 3, 0, 0, kvImageEdgeExtend);
//    vImageConvolve_ARGBFFFF(&buf, &dest, nil, 0, 0, yKernel, 3, 3, &bgColor, kvImageEdgeExtend);
    vImageConvolve_PlanarF(&buf, &xdest, nil, 0, 0, xKernel, 3, 3, bgColor, kvImageEdgeExtend);
    vImageConvolve_PlanarF(&buf, &ydest, nil, 0, 0, yKernel, 3, 3, bgColor, kvImageEdgeExtend);
    
    NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
    NSBitmapImageRep *imrep = [[NSBitmapImageRep alloc] initWithCGImage:[sampleRep CGImage]];
    
    float *xtemp = xdest.data;
    float *ytemp = ydest.data;
    for (int i = 0; i < 256; i++) {
        for (int j = 0; j < 256; j++) {
            sobelArray[(n*i)+j] = sqrtf(exp2f(xtemp[(n*i)+j])+exp2f(ytemp[(n*i)+j]));
            
            NSUInteger zColourAry[3] = {sobelArray[(n*i)+j],sobelArray[(n*i)+j],sobelArray[(n*i)+j]};
            [imrep setPixel:zColourAry atX:j y:i];
        }
    }
    
    NSImage *img = [[NSImage alloc] initWithCGImage:[imrep CGImage] size:NSMakeSize(256, 256)];
    [iv setImage:img];
    
    [self.view addSubview:iv];
    
    NSLog(@"sobelized!");
}

@end
