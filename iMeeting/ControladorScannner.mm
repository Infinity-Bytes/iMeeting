//
//  ControladorScannner.m
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ControladorScannner.h"
#import "QRCodeReader.h"

#import "Entrevistado.h"
#import "Entrevistador.h"
#import "ControladorListaRegiones.h"
#import "ServicioBusqueda.h"
#import "ControladorSesion.h"

@implementation ControladorScannner

@synthesize esCapturador;
@synthesize delegadoControladorScanner;
@synthesize controlMaestro;
@synthesize controladorPestanias=_controladorPestanias;
@synthesize delegadoLogin;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _controladorPestanias=nil;
        widController = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

-(void)dealloc
{
    [_controladorPestanias release];
    [widController release];
    self.controlMaestro = nil;
    self.delegadoControladorScanner = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEsCapturador:false];

    widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    [widController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
    NSSet *readers = [[NSSet alloc ] initWithObjects:qrcodeReader,nil];
    [qrcodeReader release];
    widController.readers = readers;
    [readers release];
   
}

- (void)viewDidUnload
{
    [self setEsCapturador:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)crearVistAdministrador
{
    
    [ self setControladorPestanias: [[CustomTabBarController new] autorelease]  ];
    [[self controladorPestanias] setDelegadoControladorScanner: controlMaestro];
    
    ControladorListaRegiones * controladorListaRegiones =  [[[ControladorListaRegiones alloc] initWithNibName:@"ControladorListaRegiones" bundle:[NSBundle mainBundle]] autorelease]; 
    [controladorListaRegiones setIdentificador:@"ListaRegiones"];
    controladorListaRegiones.tabBarItem.title = @"Personas";
    controladorListaRegiones.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    [controladorListaRegiones setDelegadoControladorNavegacion:controlMaestro];
   
    UIViewController * controlador = [[[self controladorPestanias] viewControllerWithTabTitle:@"Scanner" image:nil] autorelease];
    
    ControladorSesion * controladorSesion =  [[[ControladorSesion alloc] initWithNibName:@"ControladorSesion" bundle:[NSBundle mainBundle]] autorelease]; 
    controladorSesion.tabBarItem.title = @"Detalles";
    controladorSesion.tabBarItem.image = [UIImage imageNamed:@"123-id-card.png"];
    [controladorSesion setControladorLogin:self];
    
    [[self controladorPestanias] setViewControllers:
     
     [NSArray arrayWithObjects:controladorListaRegiones, controlador, controladorSesion,nil]];
    
    [[self controladorPestanias] addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"] highlightImage:nil];

    [[self navigationController] pushViewController:self.controladorPestanias animated:YES];
}

- (IBAction)cmdScanner:(id)sender {
    
    [self presentModalViewController:widController animated:YES ];
}


#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result {
    if (self.isViewLoaded) {
    
        if(self.esCapturador)
        {
            NSString * texto = [ [self  delegadoControladorScanner] obtenerEntrevistado:result];
            UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:result message:texto delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil] autorelease];
            [alertView show];
        }else
        {
            UIAlertView* alertView1;
            NSString * texto1;
            switch ( [[self delegadoLogin] comprobarIdentidad:result]) {
                case 0:
                    self.esCapturador =YES;
                    texto1= @"Bienvenido Capturador";
                    [widController restartServices];
                    break;
                case 1:
                    texto1= @"Bienvenido Administrador";
                    [self dismissModalViewControllerAnimated:YES];
                    self.esCapturador =NO;
                    [self crearVistAdministrador];
                    
                    break;
                default:
                    texto1= @"No Identificado";
                    self.esCapturador=NO;
                    [widController restartServices];
                    break;
            }
            
            alertView1= [[[UIAlertView alloc] initWithTitle:result message:texto1 delegate:nil cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil] autorelease];
            [alertView1 show];

        }
    }           
}

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller {
    [self dismissModalViewControllerAnimated:YES];
    [self setEsCapturador:NO];
}

#pragma mark -
#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.esCapturador)
        [delegadoControladorScanner notificarRespuesta: !buttonIndex];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    [widController restartServices];
}

@end
