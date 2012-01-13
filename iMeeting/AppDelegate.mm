//
//  AppDelegate.m
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "AppDelegate.h"
#import "ControladorScannner.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize controladorPestanias=_controladorPestanias;

- (void)dealloc
{
    [_window release];
    [_controladorPestanias release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSURL *ubiq = [[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        // TODO: Load document... 
    } else {
        NSLog(@"No iCloud access");
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    //ControladorScannner * controladorScanner =  [[ControladorScannner alloc] initWithNibName:@"ControladorScannner" bundle:[NSBundle mainBundle]]; 
    // Override point for customization after application launch.
    [ self setControladorPestanias: [CustomTabBarController new]];
    
    ControladorScannner * controladorScanner1 =  [[[ControladorScannner alloc] initWithNibName:@"ControladorScannner" bundle:[NSBundle mainBundle]] autorelease]; 
    controladorScanner1.tabBarItem.title = @"Grupos";
    controladorScanner1.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    
    UIViewController * controlador = [[self controladorPestanias] viewControllerWithTabTitle:@"Scanner" image:nil];
    
    ControladorScannner * controladorScanner2 =  [[[ControladorScannner alloc] initWithNibName:@"ControladorScannner" bundle:[NSBundle mainBundle]] autorelease]; 
    controladorScanner2.tabBarItem.title = @"Detalles";
    controladorScanner2.tabBarItem.image = [UIImage imageNamed:@"123-id-card.png"];
    
    [[self controladorPestanias] setViewControllers:
     [NSArray arrayWithObjects:controladorScanner1, controlador, controladorScanner2,nil]];
    
    [[self controladorPestanias] addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"] highlightImage:nil];
    
    [[self window] addSubview: [self.controladorPestanias view]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
