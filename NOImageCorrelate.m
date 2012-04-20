//
//  NOImageCorrelate.m
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NOImageCorrelate.h"

@implementation NOImageCorrelate

typedef struct {
	unsigned char redByte, greenByte, blueByte, alphaByte;
} RGBAPixel;

typedef struct {
	unsigned char redByte, greenByte, blueByte;
} RGBPixel;

+ (id)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample
{
    NOImageCorrelate *correlate = [[NOImageCorrelate alloc] init];
    
    return [correlate probablePointsForImage:kernel inImage:sample];
}

- (id)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample
{
    uint32_t    log2n;
    uint32_t    n, nnOver2;
    float       *sampleArray,*kernelArray;
    
    NSBitmapImageRep *sampleRep = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
    NSBitmapImageRep *kernelRep = [NSBitmapImageRep imageRepWithData:[kernel TIFFRepresentation]];
    NSBitmapImageRep *display = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
    
    int max_dimension = MAX(MAX(MAX([sampleRep pixelsHigh], [sampleRep pixelsWide]), [kernelRep pixelsHigh]), [kernelRep pixelsWide]);
    
    if (max_dimension <= 128) {
        NSLog(@"Use iteration for sample images smaller than 128");
        return [NSArray arrayWithObject:[NSValue valueWithPoint:CGPointMake(0, 0)]];
    }
    if (max_dimension > 2048) {
        NSLog(@"Large image! Not quite supported yet.");
        return [NSArray arrayWithObject:[NSValue valueWithPoint:CGPointMake(0, 0)]];
    }
    
    if (max_dimension > 128 && max_dimension <= 256) {
        log2n = 8;
    }
    else if (max_dimension > 256 && max_dimension <= 512) {
        log2n = 9;
    }
    else if (max_dimension > 512 && max_dimension <= 1024) {
        log2n = 10;
    }
    else if (max_dimension > 1024 && max_dimension <= 2048) {
        log2n = 11;
    }
    
    NSLog(@"max dimension is: %d",max_dimension);
    
    n = (1 << log2n);
    nnOver2 = (n*n) / 2;
    
    NSLog(@"total pixel count: %d",n*n);
    
    // allocate memory
    sampleArray = (float *)malloc((n*n) * sizeof(float));
    kernelArray = (float *)malloc((n*n) * sizeof(float));

    // transfer pixels to grayscale array
    // zero all pixels that are outside of data
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (i < [sampleRep pixelsHigh] && j < [sampleRep pixelsWide]) {
                RGBAPixel *samplePixel = (RGBAPixel *)&[sampleRep bitmapData][(n*i)+j];
                
                unsigned char gray = ((samplePixel->redByte*0.2989) + (samplePixel->greenByte*0.5870) + (samplePixel->blueByte*0.1140));
                
                sampleArray[(n*i)+j] = (float)gray;
            } else {
                sampleArray[(n*i)+j] = 0.0;
            }
            
            if (i < [kernelRep pixelsHigh] && j < [kernelRep pixelsWide]) {
                RGBAPixel *kernelPixel = (RGBAPixel *)&[kernelRep bitmapData][(n*i)+j];
                
                unsigned char gray = ((kernelPixel->redByte*0.2989) + (kernelPixel->greenByte*0.5870) + (kernelPixel->blueByte*0.1140));
                
                kernelArray[(n*i)+j] = (float)gray;
                [display setColor:[NSColor colorWithDeviceWhite:gray alpha:1] atX:j y:i];
            } else {
                kernelArray[(n*i)+j] = 0.0;
                [display setColor:[NSColor colorWithDeviceWhite:0 alpha:1] atX:j y:i];
            }
        }
    }
    
    NSImage *new = [[NSImage alloc] initWithCGImage:[display CGImage] size:[display size]];
    return new;
    
    return [NSArray arrayWithObject:[NSValue valueWithPoint:CGPointMake(0, 0)]];
}

@end
