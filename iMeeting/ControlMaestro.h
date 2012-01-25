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
#import "iServicioGestorDatos.h"

@interface ControlMaestro : NSObject<iDelegadoControladorLista, iDelegadoControladorNavegacion, iDelegadoControladorScanner, iServicioGestorDatosDelegate>
{
    Meeting * _meeting;
    Entrevistado * _ultimoEntrevistado;
}

#pragma Delegado Control Lista
-(NSDictionary *)obtenerDatosSeparadosPorRegionesUsandoDefinicionOrden: (NSMutableArray * ) definicionOrden;

#pragma Delegado Control Navegacion
//un selector para desglosar informacion en detalle grafica asi mismo elegir a que ventana lo llevara la seleccion
-(void) mostrarPanelSiguienteSegunEntrevistador:(Entrevistador*)entrevistador bajoIdentificador:(NSString*) identificador  usandoControlNavegacion: (UINavigationController*) controlNavegacion;

#pragma Delegado Gestor Datos


@property (nonatomic, retain) id<iServicioBusqueda> servicioBusqueda;
@property (nonatomic, retain) id<iServicioGestorDatos> servicioGestorDatos;

@end
