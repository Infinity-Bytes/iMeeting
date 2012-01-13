//
//  AppDelegate.m
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "AppDelegate.h"
#import "ControladorScannner.h"
#import "SBJson.h"
#import "Entrevistado.h"
#import "Entrevistador.h"

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
    [self inicializaMeeting];
    
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

- (void) inicializaMeeting {
    // Lectura de archivos de configuración de Meetings
    NSArray * archivosDefinicionMeetings = [AppDelegate definicionMeetings];
    if( [archivosDefinicionMeetings count] > 0 ) {
        for(NSString * archivoDefinicionMeeting in archivosDefinicionMeetings) {
            NSStringEncoding encoding;
            NSError* error;
            NSString * definicionMeeting = [NSString stringWithContentsOfFile: archivoDefinicionMeeting usedEncoding:&encoding error:&error];
            id definicion = [definicionMeeting JSONValue];
            if([definicion isKindOfClass: [NSDictionary class]]) {
                Meeting * meetingInteres = [self generaMeetingDePOCOs: definicion];
                int i = 0;
            }
        }
    }
}

+ (NSArray *) definicionMeetings {
    
    NSMutableArray *retval = [NSMutableArray array];
    
    // Get public docs dir
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *publicDocumentsDir = [paths objectAtIndex:0];   
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return retval;
    }
    
    // Add all sbzs to a list    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"json" options:NSCaseInsensitiveSearch] == NSOrderedSame) {        
            NSString *fullPath = [publicDocumentsDir stringByAppendingPathComponent:file];
            [retval addObject:fullPath];
        }
    }
    
    return retval;
    
}

- (Meeting * ) generaMeetingDePOCOs: (NSDictionary *) objetoPlano {
    Meeting * salida = [[Meeting new] autorelease];
    
    id _nombreMeeting = [objetoPlano objectForKey: @"nombreMeeting"];
    if([_nombreMeeting isKindOfClass: [NSString class]]) { 
        [salida setNombreMeeting: _nombreMeeting];
    }
    
    [salida setPersonal: [self procesaPersonas: objetoPlano]];
        
    return salida;
}

- (void) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase {
    if([objeto respondsToSelector: selector] && [argumento isKindOfClass: clase]) {
        [objeto performSelector: selector withObject: argumento];
    }
}

- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia {
    NSMutableArray * contenedorPersonal = [NSMutableArray new];
    
    id _personal = [objetoReferencia objectForKey:@"personas"];
    if([_personal isKindOfClass: [NSArray class]]) {
        if([_personal count]) {

            for(id persona in _personal) {
                if( [persona isKindOfClass: [NSDictionary class]] ) {
                    Persona * personaInteres = nil;
                    
                    id _tipoPersona = [persona objectForKey: @"tipo"];
                    if([_tipoPersona isKindOfClass: [NSString class]] && [_tipoPersona count] > 0) {
                        personaInteres = [NSClassFromString(_tipoPersona) new];
                    } else {
                        personaInteres = [Entrevistado new];
                    }
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setIdentificador:) conArgumento: [persona objectForKey: @"identificador"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setNombre:) conArgumento: [persona objectForKey: @"nombre"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setZona:) conArgumento: [persona objectForKey: @"zona"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setTelefono:) conArgumento: [persona objectForKey: @"telefono"] deTipo:[NSString class]];
                    
                    if( [personaInteres respondsToSelector: @selector(setPersonas:)] ) {
                        
                        [personaInteres performSelector: @selector(setPersonas:) withObject: [self procesaPersonas: persona]];
                    }
                    
                    if(personaInteres) {
                        if([personaInteres isKindOfClass: [Persona class]]) {
                            [contenedorPersonal addObject: personaInteres];
                        }
                        
                        [personaInteres release];
                    }
                }
            }
        }
    }

    
    return contenedorPersonal;
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
