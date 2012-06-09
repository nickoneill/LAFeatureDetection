/*
 * The MIT License
 *
 * This file based on earlier code by:
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 * Modifications Copyright (c) 2011 Joe Osborn, josborn@universalhappymaker.com
 * https://github.com/JoeOsborn/UIImage-Conversion
 *
 * Additional modifications for Feature Recognition by Nick O'Neill, nick.oneill@gmail.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CGImageToBitmap.h"

@implementation CGImageToBitmap

+ (unsigned char *)bitmapARGB8888FromCGImage:(CGImageRef)image
{
    
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint8_t *bitmapData;
	
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
	
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
	
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
	
	// Allocate memory for image data
	bitmapData = (uint8_t *)calloc(bufferLength, sizeof(uint8_t));
	
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
	
    //Changed this to ARGB8888
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst;
	
	//Create bitmap context with this memory block (which we still own, 
	//although we will transfer ownership to the caller on return).
	context = CGBitmapContextCreate(bitmapData, 
                                    width, 
                                    height, 
                                    bitsPerComponent, 
                                    bytesPerRow, 
                                    colorSpace, 
                                    bitmapInfo);	// RGBA
	
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
	
	CGColorSpaceRelease(colorSpace);
	
	if(!context) {
		return NULL;
	}
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, image);
	CGContextRelease(context);
	
	return bitmapData;	
}

@end
