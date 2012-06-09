**Notes: The project only builds on OSX at the moment, an iOS build target is in the works.**

This library is designed to use the accelerated vDSP functions for OSX/iOS to perform image correlation by convolution. In short, it allows you to find the location of subimages (or like forms) within a larger sample image without iterating through every pixel in the image. This approach is particularly useful for large sample images, but because of the speed of the Accelerate framework it is applicable to much smaller sizes as well.

[images as examples]

### Correlation by convolution ###

Iterative methods for finding an image within another image are accurate but slow. Fortunately, most image processing applications care more about speed than pixel-level accuracy. In fact, the simplest iterative method matches exact pixel values which requires that you know the exact pixel values you're looking for. Convolutions via fourier transform provide an interesting alternative solution.

Convolution is an image processing term describing a fourier transform of two images, point multiplying the two transforms and performing an inverse fourier transform on the result. It effectively applies a kernel filter to an entire sample image and is the basis for the coloring effects found in Photo Booth and plenty of image filters in Photoshop.

Conveniently, if we convolve a subimage with its parent image, the result matrix has a point of maximum intensity that describes the location of the subimage in the parent. Applying an edge-detection or other appropriate filter in advance gives a general solution to finding things that "look like" a subimage - the fuzziness we often desire in image processing.

The fast fourier transform is often used in digital signal processing and a ton of work has been done to streamline the vector computations used for this purpose. The OSX/iOS Accelerate framework has some of the fastest fourier transforms available but it can be a bit obtuse to understand and use because of the technical steps taken to achieve such speed.

The goal of this library is to allow anyone with basic Objective-C knowledge to run fast convolutions and find image-within-image data.

### Using the library ###

Most users will probably be satisfied by using the default class method `probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample` which makes some assumptions and returns an array of the most likely locations of the kernel image in the sample (likeliest first). The points returned are the likely location of the bottom right corner of the kernel.

### Contributions ###

I'm open to suggestions or pull requests. Or you can just track progress on [Trello](https://trello.com/board/image-fft-correlation/4f74e20243c8990d7528b36a).

### Credits ###

Many thanks to the Apple Scitech list for answering all sorts of implementation questions, and Thijs Hosman for introducing me to the concept.

Test images procured from the [USC Signal and Image Processing database](http://sipi.usc.edu/database/database.php).