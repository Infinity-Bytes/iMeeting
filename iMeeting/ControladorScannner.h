//
//  ControladorScannner.h
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"
#import "iDelegadoControladorScanner.h"

#import "ControlMaestro.h"
#import "Meeting.h"
#import "CustomTabBarController.h"
#import "ServicioGestorDatos.h"
#import <DropboxSDK/DropboxSDK.h>
#import "iDelegadoLogin.h"

@interface ControladorScannner : UIViewController <ZXingDelegate, UIAlertViewDelegate>
{
    ZXingWidgetController *widController;
    CustomTabBarController *_controladorPestanias;
}

- (IBAction)cmdScanner:(id)sender;


-(void)crearVistAdministrador;

#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result;

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller;


#pragma mark -
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


@property(nonatomic, assign) ControlMaestro* controlMaestro;
@property(nonatomic, assign) id<iDelegadoControladorScanner> delegadoControladorScanner;
@property(nonatomic, assign)id<iDelegadoLogin> delegadoLogin;
@property (nonatomic, retain) CustomTabBarController *controladorPestanias;
@property (nonatomic, assign) BOOL esCapturador;

@end
