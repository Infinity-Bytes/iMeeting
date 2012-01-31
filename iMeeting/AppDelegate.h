//
//  AppDelegate.h
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ControlMaestro.h"
#import "Meeting.h"
#import "CustomTabBarController.h"
#import "ServicioGestorDatos.h"
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate>
{
    CustomTabBarController *_controladorPestanias;
    
    NSTimer * timerActualizacion;
    ControlMaestro * controlMaestro;
    ServicioGestorDatos * servicioGestorDatos;
}

-(void) procesaInformacionActual:(NSTimer *) timer;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CustomTabBarController *controladorPestanias;

@end
