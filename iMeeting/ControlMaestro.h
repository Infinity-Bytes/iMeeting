//
//  ControlMaestro.h
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Meeting.h"
#import "iDelegadoControladorLista.h"
#import "iDelegadoControladorNavegacion.h"
#import "iDelegadoControladorScanner.h"
#import "iServicioBusqueda.h"

@interface ControlMaestro : NSObject<iDelegadoControladorNavegacion, iDelegadoControladorScanner>
{
    Meeting * _meeting;
    Entrevistado * _ultimoEntrevistado;
    
}


#pragma Delegado Control Navegacion
//un selector para desglosar informacion en detalle grafica asi mismo elegir a que ventana lo llevara la seleccion
-(void) mostrarPanelSiguienteSegunEntrevistador:(Entrevistador*)entrevistador bajoIdentificador:(NSString*) identificador  usandoControlNavegacion: (UINavigationController*) controlNavegacion;

#pragma Delegado Gestor Datos
- (void) registraMeeting: (NSNotification *) notificacion;
-(void) registraElementoTrabajadoPorURL: (NSNotification *) notificacion;

-(NSDictionary *) establecerOriginDatos:(NSArray*)arregloDatos bajoNombre:(NSString*)nombre;

- (void) procesaElementoTrabajado: (Entrevistado *) entrevistado;
- (void) obtenEntrevistadoresAcumulador:(NSMutableSet *) acumulador aPartir: (Entrevistador *) entrevistador;
- (void) procesaAcumulado: (NSSet *) acumulador;

@property (nonatomic, retain) id<iServicioBusqueda> servicioBusqueda;

@end
