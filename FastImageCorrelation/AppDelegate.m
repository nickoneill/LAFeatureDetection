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
    NSImage *sample = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"lax-sample" ofType:@"png"]];
    NSImage *kernel = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"plane-kernel" ofType:@"png"]];
        

    NOImageCorrelate *ic = [[NOImageCorrelate alloc] init];
    NSArray *points = [ic probablePointsForImage:kernel inImage:sample];
    
    for (int i = 0; i < [points count]; i++) {
        CGPoint point = [[points objectAtIndex:i] pointValue];
        NSLog(@"point: %f,%f",point.x,point.y);
    }
}

typedef struct {
	unsigned char redByte, greenByte, blueByte, alphaByte;
} RGBAPixel;

typedef struct {
	unsigned char redByte, greenByte, blueByte;
} RGBPixel;

- (void)altsobelize:(NSImage*)image
{
    NSBitmapImageRep *sampleRep = [[image representations] objectAtIndex:0];
    RGBAPixel *sampleAlphaPixels = (RGBAPixel *)[sampleRep bitmapData];

}

- (void)sobelize:(NSImage*)image
{
    NSBitmapImageRep *sampleRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
    RGBAPixel *sampleAlphaPixels = (RGBAPixel *)[sampleRep bitmapData];
    int n = 1024;
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
    
    NSLog(@"%f %f %f %f %f %f %f %f %f %f",sampleArray[0],sampleArray[1],sampleArray[2],sampleArray[3],sampleArray[4],sampleArray[5],sampleArray[6],sampleArray[7],sampleArray[8],sampleArray[9]);
    NSLog(@"%f %f %f %f %f %f %f %f %f %f",sampleArray[1024],sampleArray[1024+1],sampleArray[1024+2],sampleArray[1024+3],sampleArray[1024+4],sampleArray[1024+5],sampleArray[1024+6],sampleArray[1024+7],sampleArray[1024+8],sampleArray[1024+9]);
    NSLog(@"%f %f %f %f %f %f %f %f %f %f",sampleArray[2048],sampleArray[2048+1],sampleArray[2048+2],sampleArray[2048+3],sampleArray[2048+4],sampleArray[2048+5],sampleArray[2048+6],sampleArray[2048+7],sampleArray[2048+8],sampleArray[2048+9]);

        
    float xKernel[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
    float yKernel[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};

    Pixel_F bgColor = 0;
    
    vImage_Buffer buf;
    buf.data = sampleArray;
    buf.height = n;
    buf.width = n;
    buf.rowBytes = n*sizeof(float);
    
    vImage_Buffer xdest;
    xdest.data = malloc(n*n * sizeof(float));
    xdest.height = n;
    xdest.width = n;
    xdest.rowBytes = n*sizeof(float);

    vImage_Buffer ydest;
    ydest.data = malloc(n*n * sizeof(float));
    ydest.height = n;
    ydest.width = n;
    ydest.rowBytes = n*sizeof(float);

    vImageConvolve_PlanarF(&buf, &xdest, nil, 0, 0, xKernel, 3, 3, bgColor, kvImageBackgroundColorFill);
    vImageConvolve_PlanarF(&buf, &ydest, nil, 0, 0, yKernel, 3, 3, bgColor, kvImageBackgroundColorFill);
    
    float *xtemp = xdest.data;
    float *ytemp = ydest.data;
    
    float *ttemp = xdest.data;

    NSLog(@"post convolve:");
    NSLog(@"%f %f %f %f %f %f %f %f %f %f",ttemp[0],ttemp[1],ttemp[2],ttemp[3],ttemp[4],ttemp[5],ttemp[6],ttemp[7],ttemp[8],ttemp[9]);
    NSLog(@"%f %f %f %f %f %f %f %f %f %f",ttemp[1024],ttemp[1024+1],ttemp[1024+2],ttemp[1024+3],ttemp[1024+4],ttemp[1024+5],ttemp[1024+6],ttemp[1024+7],ttemp[1024+8],ttemp[1024+9]);
    
    NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, n, n)];
    NSBitmapImageRep *imrep = [[NSBitmapImageRep alloc] initWithCGImage:[sampleRep CGImage]];
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
//            float gradient = atan2(ytemp[(n*i)+j],xtemp[(n*i)+j]);
//            
//            if (gradient >= 0) {
//                sobelArray[(n*i)+j] = 1;
//                NSUInteger zColourAry[3] = {255,255,255};
//                [imrep setPixel:zColourAry atX:j y:i];
//
//            } else {
//                sobelArray[(n*i)+j] = 0;
//                NSUInteger zColourAry[3] = {0,0,0};
//                [imrep setPixel:zColourAry atX:j y:i];
//
//            }

            sobelArray[(n*i)+j] = sqrtf(powf(xtemp[(n*i)+j],2)+powf(ytemp[(n*i)+j],2));
//            
//            if (i > 0 && i < 10 && j > 0 && j < 10) {
//                NSLog(@"value: %f",xtemp[(n*i)+j]);
//            }            
            
            NSUInteger zColourAry[3] = {sobelArray[(n*i)+j],sobelArray[(n*i)+j],sobelArray[(n*i)+j]};
            [imrep setPixel:zColourAry atX:j y:i];
        }
    }
    
    NSImage *img = [[NSImage alloc] initWithCGImage:[imrep CGImage] size:NSMakeSize(n, n)];
    [iv setImage:img];
    
    [self.view addSubview:iv];
    
    NSLog(@"sobelized!");
}

@end
