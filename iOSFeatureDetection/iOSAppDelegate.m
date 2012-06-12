//
//  AppDelegate.m
//  iOSFeatureDetection
//
//  Created by Nick O'Neill on 6/1/12.
//  Copyright (c) 2012 Launch Apps. All rights reserved.
//

#import "iOSAppDelegate.h"
#import "LAFeatureDetection.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UIImage *sample = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lax-sample" ofType:@"png"]];
    
    UIImage *kernel = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"plane-kernel" ofType:@"png"]];
    
    NSArray *points = [LAFeatureDetection probablePointsForImage:[kernel CGImage] inImage:[sample CGImage]];
    
    UIGraphicsBeginImageContext(sample.size);
    [sample drawAtPoint:CGPointZero];

    if (points != nil) {
        NSLog(@"points: %@",points);
        
        for (int i = 0; i < [points count]; i++) {
            CGPoint point = [[points objectAtIndex:i] CGPointValue];
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [[UIColor redColor] setStroke];
            CGRect pointRect = CGRectMake(point.x-kernel.size.width, point.y-kernel.size.height, kernel.size.width, kernel.size.height);
            CGContextStrokeRect(ctx, pointRect);
        }
    }
    
    UIImage *resultSample = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *scrollimage = [[UIImageView alloc] initWithImage:resultSample];

    UIViewController *vc = [[UIViewController alloc] init];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.window.frame];
    
    [scroll addSubview:scrollimage];
    [scroll setContentSize:sample.size];

    [vc setView:scroll];
    
    [self.window setRootViewController:vc];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
