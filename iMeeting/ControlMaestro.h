//
//  ControlMaestro.h
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDelegadoControladorLista.h"
#import "iDelegadoControladorNavegacion.h"
#import "iDelegadoControladorScanner.h"

@interface ControlMaestro : NSObject<iDelegadoControladorLista, iDelegadoControladorNavegacion>


#pragma Delegado Control Lista
-(NSDictionary *)obtenerDatosSeparadosPorRegiones;

#pragma Delegado Control Navegacion
//un selector para desglosar informacion en detalle grafica asi mismo elegir a que ventana lo llevara la seleccion
-(void) mostrarPanelSiguienteSegunEntrevistador:(Entrevistador*)entrevistador bajoIdentificador:(NSString*) identificador  usandoControlNavegacion: (UINavigationController*) controlNavegacion;


@end
