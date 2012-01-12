//
//  iDelegadoControladorNavegacion.h
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entrevistador.h"

@protocol iDelegadoControladorNavegacion <NSObject>

-(void) mostrarPanelSiguienteSegunEntrevistador:(Entrevistador*)entrevistador bajoIdentificador:(NSString*) identificador  usandoControlNavegacion: (UINavigationController*) controlNavegacion;

@end
