//
//  AppDelegate.h
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meeting.h"
#import "CustomTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CustomTabBarController *_controladorPestanias;
}

- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia;
- (Meeting *) generaMeetingDePOCOs: (NSDictionary *) objetoPlano;
- (void) inicializaMeeting;
+ (NSArray *) definicionMeetings;
- (void) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CustomTabBarController *controladorPestanias;

@end
