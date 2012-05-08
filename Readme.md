This library is designed to use the accelerated vDSP functions for OSX/iOS to perform image correlation by convolution. In short, it allows you to find the location of subimages (or like forms) within a larger sample image without iterating through every pixel in the image. This approach is particularly useful for large sample images, but because of the impressive work done on the Accelerate framework it is applicable to much smaller sizes as well.

[images as examples]

### Correlation by convolution ###

Iterative methods for finding an image within another image are accurate but slow. Fortunately, most image processing applications care more about speed than accuracy and we can achieve th

For a sample image and some subimage (convolution sometimes refers to it as a kernel), we can compute discrete fourier transforms for both images after rotating the kernel by 180˚, multiplying the transformed matrices together and performing an inverse fourier transform on the result. This final matrix has a point of maximum intensity which corresponds to the location of the kernel in the sample image.

Conveniently, the fast fourier transform is often used in digital signal processing and a ton of work has been done to streamline the vector computations used for this purpose. The OSX/iOS Accelerate framework is, according to

### Using the library ###

Most users will probably be satisfied by using the default class method `probablePointsForImage:(NSImage *)kernel inImage:(NSImage *)sample` which makes some assumptions and returns an array of the most likely locations of the kernel image in the sample (likeliest first). The points returned are the likely location of the bottom right corner of the kernel.

(There are some optimizations for faster execution or specific use cases that could be customized for but so far we're optimized for simplicity)

### Credits ###

Many thanks to the Apple Scitech list for answering all sorts of implementation questions, and Thijs Hosman for turning me onto this topic in the first place.

Test images procured from the [USC Signal and Image Processing database](http://sipi.usc.edu/database/database.php).