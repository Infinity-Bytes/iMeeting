//
//  AppDelegate.m
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "AppDelegate.h"
#import "ControladorScannner.h"
#import "Entrevistado.h"
#import "Entrevistador.h"
#import "ControladorListaRegiones.h"
#import "ServicioBusqueda.h"



@implementation AppDelegate

@synthesize window = _window;
//@synthesize controladorPestanias=_controladorPestanias;

- (void)dealloc
{
    
    
    [_window release];
    [timerActualizacion invalidate];
    [controlMaestro release];
    [servicioGestorDatos release];
    [controladorNavegacionPersonas release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DBSession* dbSession =
    [[[DBSession alloc]
      initWithAppKey:@"9fheg8l7y4ppzas"
      appSecret:@"z5loq8yt4xedegu"
      root:kDBRootAppFolder]
     autorelease];
    dbSession.delegate = self;
    [DBSession setSharedSession:dbSession];
    
    controlMaestro  = [ControlMaestro new];
    servicioGestorDatos = [ServicioGestorDatos new];
    
    // Tiempo de actualizacion alto para evitar saturacion de llamadas al API
    timerActualizacion = [NSTimer scheduledTimerWithTimeInterval: 10 target: self selector: @selector(procesaInformacionActual:)  userInfo: nil repeats: YES];
    
    [controlMaestro setServicioBusqueda:[[ServicioBusqueda new] autorelease]];
    
    [servicioGestorDatos cargaMeetingsDeDocumentos];
    [servicioGestorDatos cargaMeetingsDeiTunesFileSharing];
    [servicioGestorDatos cargaMeetingsDeiCloud];
    
    [servicioGestorDatos cargaMeetingsDeiCloud];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    ControladorScannner *controladorScanner = [[[ControladorScannner alloc] initWithNibName:@"ControladorScannner" bundle:[NSBundle mainBundle]] autorelease] ;
    
    
    controladorNavegacionPersonas = [[UINavigationController alloc] initWithRootViewController:controladorScanner];
    controladorNavegacionPersonas.navigationBar.tintColor=[UIColor blackColor];
    
    [controlMaestro setControlNavegacionPrincipal: controladorNavegacionPersonas];
    
    [controladorScanner setControlMaestro:controlMaestro];
    [controladorScanner setDelegadoLogin:controlMaestro];
    [controladorScanner setDelegadoControladorScanner:controlMaestro];
    [[self window] addSubview: [controladorNavegacionPersonas view]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void) procesaInformacionActual:(NSTimer *) timer {
    [servicioGestorDatos cargaMeetingsDeiCloud];
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"Aplicacion enlazada a DB correctamente!");
            
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
    
}

@end
