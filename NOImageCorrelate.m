//
//  NOImageCorrelate.m
//  FastImageCorrelation
//
//  Created by Nick O'Neill on 4/15/12.
//  Copyright (c) 2012 Launch Apps. All rights reserved.
//

#import "NOImageCorrelate.h"
#import "AppDelegate.h"

#include <Accelerate/Accelerate.h>

@implementation NOImageCorrelate

@synthesize delegate;

@synthesize relatedPointThreshold;

typedef struct {
	unsigned char redByte, greenByte, blueByte, alphaByte;
} RGBAPixel;

typedef struct {
	unsigned char redByte, greenByte, blueByte;
} RGBPixel;

- (id)init
{
    if (self = [super init]) {
        relatedPointThreshold = 0.95;
    }
    
    return self;
}

+ (NSArray*)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample
{
    NOImageCorrelate *correlate = [[NOImageCorrelate alloc] init];
    
    return [correlate probablePointsForImage:kernel inImage:sample];
}

- (NSArray*)probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample
{
    COMPLEX_SPLIT   sampleComplex,kernelComplex,resultComplex;
    FFTSetup        setupReal;
    uint32_t        log2n;
    uint32_t        n,nOver2,nnOver2;
    float           *sampleArray,*kernelArray,*resultArray;
    float           scale;
        
    NSBitmapImageRep *sampleRep = [NSBitmapImageRep imageRepWithData:[sample TIFFRepresentation]];
    NSBitmapImageRep *kernelRep = [NSBitmapImageRep imageRepWithData:[kernel TIFFRepresentation]];
    
    // grab image info so we can get pixel values properly
    CGImageAlphaInfo sampleInfo = CGImageGetAlphaInfo([sampleRep CGImage]);
    BOOL sampleHasAlpha = ((sampleInfo == kCGImageAlphaPremultipliedLast) || 
                           (sampleInfo == kCGImageAlphaLast) ? YES : NO);
    CGImageAlphaInfo kernelInfo = CGImageGetAlphaInfo([kernelRep CGImage]);
    BOOL kernelHasAlpha = ((kernelInfo == kCGImageAlphaPremultipliedLast) || 
                           (kernelInfo == kCGImageAlphaLast) ? YES : NO);

    RGBAPixel *sampleAlphaPixels;
    RGBPixel  *samplePixels;
    RGBAPixel *kernelAlphaPixels;
    RGBPixel  *kernelPixels;
        
    if (sampleHasAlpha) {
        sampleAlphaPixels = (RGBAPixel *)[sampleRep bitmapData];
    } else {
        samplePixels = (RGBPixel *)[sampleRep bitmapData];
    }
    
    if (kernelHasAlpha) {
        kernelAlphaPixels = (RGBAPixel *)[kernelRep bitmapData];
    } else {
        kernelPixels = (RGBPixel *)[kernelRep bitmapData];
    }
        
    NSLog(@"sample size is: %ldx%ld",[sampleRep pixelsWide],[sampleRep pixelsHigh]);
    NSLog(@"kernel size is: %ldx%ld",[kernelRep pixelsWide],[kernelRep pixelsHigh]);
    int max_dimension = MAX(MAX(MAX([sampleRep pixelsHigh], [sampleRep pixelsWide]), [kernelRep pixelsHigh]), [kernelRep pixelsWide]);
    NSLog(@"max dimension is: %d",max_dimension);
    
    // Check for images that are tiny or big (more big sizes should be easily supported)
    if (max_dimension <= 128) {
        NSLog(@"Use iteration for sample images smaller than 128");
        return [NSArray arrayWithObject:[NSValue valueWithPoint:CGPointMake(0, 0)]];
    }
    if (max_dimension > 8192) {
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
    else if (max_dimension > 2048 && max_dimension <= 4096) {
        log2n = 12;
    }
    else if (max_dimension > 4096 && max_dimension <= 8192) {
        log2n = 13;
    }
    
    n = (1 << log2n);
    nOver2 = n / 2;
    nnOver2 = (n*n) / 2;
    
    NSLog(@"adjusted dimension to %d per side",n);
    NSLog(@"total pixel count: %d",n*n);
    
    // allocate memory
    sampleComplex.realp = (float *) malloc(nnOver2 * sizeof(float));
    sampleComplex.imagp = (float *) malloc(nnOver2 * sizeof(float));
    kernelComplex.realp = (float *) malloc(nnOver2 * sizeof(float));
    kernelComplex.imagp = (float *) malloc(nnOver2 * sizeof(float));
    resultComplex.realp = (float *) malloc(nnOver2 * sizeof(float));
    resultComplex.imagp = (float *) malloc(nnOver2 * sizeof(float));

    sampleArray = (float *)malloc((n*n) * sizeof(float));
    kernelArray = (float *)malloc((n*n) * sizeof(float));
    resultArray = (float *)malloc((n*n) * sizeof(float));
        
    // transfer pixels to grayscale array
    // zero all pixels that are outside of data
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (i < [sampleRep pixelsHigh] && j < [sampleRep pixelsWide]) {
                RGBAPixel *sampleAlphaPixel;
                RGBPixel *samplePixel;
                unsigned char gray;
                
                if (sampleHasAlpha) {
                    sampleAlphaPixel = (RGBAPixel *)&sampleAlphaPixels[([sampleRep pixelsWide]*i)+j];
                    gray = ((sampleAlphaPixel->redByte*0.2989) + (sampleAlphaPixel->greenByte*0.5870) + (sampleAlphaPixel->blueByte*0.1140));
                } else {
                    samplePixel = (RGBPixel *)&samplePixels[([sampleRep pixelsWide]*i)+j];
                    gray = ((samplePixel->redByte*0.2989) + (samplePixel->greenByte*0.5870) + (samplePixel->blueByte*0.1140));
                }
                
                sampleArray[(n*i)+j] = (float)gray;
            } else {
                
                sampleArray[(n*i)+j] = 0.0;
            }
            
            if (i < [kernelRep pixelsHigh] && j < [kernelRep pixelsWide]) {
                RGBAPixel *kernelAlphaPixel;
                RGBPixel *kernelPixel;
                unsigned char gray;
                
                // i and j are inverted here to produce a 180 degree rotation
                if (kernelHasAlpha) {
                    kernelAlphaPixel = (RGBAPixel *)&kernelAlphaPixels[([kernelRep pixelsWide]*([kernelRep pixelsHigh]-i))+([kernelRep pixelsWide]-j)];
                    gray = ((kernelAlphaPixel->redByte*0.2989) + (kernelAlphaPixel->greenByte*0.5870) + (kernelAlphaPixel->blueByte*0.1140));
                } else {
                    kernelPixel = (RGBPixel *)&kernelPixels[([kernelRep pixelsWide]*([kernelRep pixelsHigh]-i))+([kernelRep pixelsWide]-j)];
                    gray = ((kernelPixel->redByte*0.2989) + (kernelPixel->greenByte*0.5870) + (kernelPixel->blueByte*0.1140));
                }
                
                kernelArray[(n*i)+j] = (float)gray;
            } else {

                kernelArray[(n*i)+j] = 0.0;
            }
        }
    }
    
    kernelArray = [self applySobel:kernelArray forN:n];
    sampleArray = [self applySobel:sampleArray forN:n];
        
    // transfer pixel arrays to split complex format
    vDSP_ctoz((COMPLEX *)sampleArray, 2, &sampleComplex, 1, nnOver2);
    vDSP_ctoz((COMPLEX *)kernelArray, 2, &kernelComplex, 1, nnOver2);

    // create special fftsetup for our particular size
    setupReal = vDSP_create_fftsetup(log2n, kFFTRadix2);

    // run 2d accelerated fft on both complex arrays
    vDSP_fft2d_zrip(setupReal, &sampleComplex, 1, 0, log2n, log2n, kFFTDirection_Forward);
    vDSP_fft2d_zrip(setupReal, &kernelComplex, 1, 0, log2n, log2n, kFFTDirection_Forward);

    // tricky part: once the complex split value has been run through fft, it's in a very particular format
    // which is defined here: http://bit.ly/JHnC0q
    // for our multiplication to work properly, we have to multiply the real and imaginary parts of the
    // 0 column and real and imaginary parts of 0,0 and 1,0 seperately
    
    // first, multiply everything which works for most of the data
    vDSP_zvmul(&sampleComplex, 1, &kernelComplex, 1, &resultComplex, 1, (n/2)*(n/2), 1);

    // move the real column to new split complex arrays for fast multiplication
    DSPSplitComplex sampleRealColumn;
    sampleRealColumn.realp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    sampleRealColumn.imagp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    DSPSplitComplex kernelRealColumn;
    kernelRealColumn.realp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    kernelRealColumn.imagp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    DSPSplitComplex resultRealColumn;
    resultRealColumn.realp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    resultRealColumn.imagp = (float *) malloc(((nOver2-2)/2) * sizeof(float));

    for (int i=0; i < ((nOver2-2)/2); i++) {
        int j = (i*2)+2;
        
        sampleRealColumn.realp[i] = sampleComplex.realp[nOver2*j];
        sampleRealColumn.imagp[i] = sampleComplex.realp[nOver2*(j+1)];
        
        kernelRealColumn.realp[i] = kernelComplex.realp[nOver2*j];
        kernelRealColumn.imagp[i] = kernelComplex.realp[nOver2*(j+1)];
    }
    
    vDSP_zvmul(&sampleRealColumn, 1, &kernelRealColumn, 1, &resultRealColumn, 1, ((nOver2-2)/2), 1);

    for (int i=0; i < ((nOver2-2)/2); i++) {
        int j = (i*2)+2;
        
        resultComplex.realp[nOver2*j] = resultRealColumn.realp[i];
        resultComplex.realp[nOver2*(j+1)] = resultRealColumn.imagp[i];
    }
    
    // move the imag column to new split complex arrays for fast multiplication
    DSPSplitComplex sampleImagColumn;
    sampleImagColumn.realp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    sampleImagColumn.imagp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    DSPSplitComplex kernelImagColumn;
    kernelImagColumn.realp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    kernelImagColumn.imagp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    DSPSplitComplex resultImagColumn;
    resultImagColumn.realp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    resultImagColumn.imagp = (float *) malloc(((nOver2-2)/2) * sizeof(float));
    
    for (int i=0; i < ((nOver2-2)/2); i++) {
        int j = (i*2)+2;
        
        sampleImagColumn.realp[i] = sampleComplex.imagp[nOver2*j];
        sampleImagColumn.imagp[i] = sampleComplex.imagp[nOver2*(j+1)];
        
        kernelImagColumn.realp[i] = kernelComplex.imagp[nOver2*j];
        kernelImagColumn.imagp[i] = kernelComplex.imagp[nOver2*(j+1)];
    }
    
    vDSP_zvmul(&sampleImagColumn, 1, &kernelImagColumn, 1, &resultImagColumn, 1, ((nOver2-2)/2), 1);
    
    for (int i=0; i < ((nOver2-2)/2); i++) {
        int j = (i*2)+2;
        
        resultComplex.imagp[nOver2*j] = resultImagColumn.realp[i];
        resultComplex.imagp[nOver2*(j+1)] = resultImagColumn.imagp[i];
    }

    // multiply our four real elements normally
    resultComplex.realp[0] = sampleComplex.realp[0] * kernelComplex.realp[0];
    resultComplex.imagp[0] = sampleComplex.imagp[0] * kernelComplex.imagp[0];
    resultComplex.realp[(n/2)] = sampleComplex.realp[(n/2)] * kernelComplex.realp[(n/2)];
    resultComplex.imagp[(n/2)] = sampleComplex.imagp[(n/2)] * kernelComplex.imagp[(n/2)];

    // invert the fft on our result
    vDSP_fft2d_zrip(setupReal, &resultComplex, 1, 0, log2n, log2n, kFFTDirection_Inverse);

    // vdsp scales values when computing fft and inverse fft, we need to unscale them
    scale = (float) 1.0 / (n * n * n);
    vDSP_vsmul(resultComplex.realp, 1, &scale, resultComplex.realp, 1, nnOver2);
    vDSP_vsmul(resultComplex.imagp, 1, &scale, resultComplex.imagp, 1, nnOver2);
    
    // move out of split complex format into a regular array
    vDSP_ztoc(&resultComplex, 1, (COMPLEX *)resultArray, 2, nnOver2);
    
    // determine max value location
    NSMutableArray *points = [NSMutableArray array];
    float max,min = 0;
    int maxindex,limit = 0;
    for (int i = 0; i < n*n; i++) {
        if (resultArray[i] >= max) {
            max = resultArray[i];
            maxindex = i;
        }
        if (resultArray[i] < min) {
            min = resultArray[i];
        }
    }
    
    // determine valid points over threshold
    limit = floor(max*relatedPointThreshold);
    for (int i = 0; i < n*n; i++) {
        if (resultArray[i] >= limit) {
            int row = floor(i/n);
            int col = i-(row*n);

            [points addObject:[NSValue valueWithPoint:CGPointMake(row, col)]];
        }
    }
    
    // free malloc'd memory
    vDSP_destroy_fftsetup(setupReal);
    free(sampleComplex.realp);
    free(sampleComplex.imagp);
    free(kernelComplex.realp);
    free(kernelComplex.imagp);
    free(resultComplex.realp);
    free(resultComplex.imagp);
    free(sampleArray);
    free(kernelArray);
    free(resultArray);
    free(sampleRealColumn.realp);
    free(sampleRealColumn.imagp);
    free(kernelRealColumn.realp);
    free(kernelRealColumn.imagp);
    free(resultRealColumn.realp);
    free(resultRealColumn.imagp);
    free(sampleImagColumn.realp);
    free(sampleImagColumn.imagp);
    free(kernelImagColumn.realp);
    free(kernelImagColumn.imagp);
    free(resultImagColumn.realp);
    free(resultImagColumn.imagp);
    
    return points;
}

- (float*)applySobel:(float*)imageArray forN:(int)n
{
    // sobel is a simple edge detection filter, good for images with some contrast
    
    float xKernel[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
    float yKernel[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};
    
    Pixel_F bgColor = 0;
    
    vImage_Buffer buf;
    buf.data = imageArray;
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
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            // calculate combined magnitude of both vertical and horizontal directions
            imageArray[(n*i)+j] = sqrtf(powf(xtemp[(n*i)+j],2)+powf(ytemp[(n*i)+j],2));
        }
    }
    
    free(xdest.data);
    free(ydest.data);

    return imageArray;
}

- (void)displayTestImage
{
//    NSImageView *iv = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 256, 256)];
//    NSBitmapImageRep *imrep = [[NSBitmapImageRep alloc] initWithCGImage:[sampleRep CGImage]];
//    
//    for (int i = 0; i < 256; i++) {
//        for (int j = 0; j < 256; j++) {
//            NSUInteger zColourAry[3] = {kernelArray[(n*i)+j],kernelArray[(n*i)+j],kernelArray[(n*i)+j]};
//            [imrep setPixel:zColourAry atX:j y:i];
//        }
//    }
//    NSImage *img = [[NSImage alloc] initWithCGImage:[imrep CGImage] size:NSMakeSize(256, 256)];
//    
//    [iv setImage:img];
//    
//    [[(AppDelegate *)self.delegate view] addSubview:iv];
}

@end
