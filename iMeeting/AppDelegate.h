//
//  AppDelegate.h
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CustomTabBarController *_controladorPestanias;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CustomTabBarController *controladorPestanias;

@end
