This library is designed to use the accelerated vDSP functions for OS X/iOS to perform a fast image correlation by convolution. In short, it allows you to find the location of subimages (or like forms) within a larger sample image without iterating through the entire image. This approach is particularly useful for large sample images, but because of the impressive work done on the Accelerate framework is applicable to much smaller sizes as well.

### Correlation by convolution ###

### Using the library ###

### Credits ###

Many thanks to the Apple Scitech list for answering all sorts of implementation questions, and Thijs Hosman for turning me onto this topic in the first place.

Test images procured from the [USC Signal and Image Processing database](http://sipi.usc.edu/database/database.php).