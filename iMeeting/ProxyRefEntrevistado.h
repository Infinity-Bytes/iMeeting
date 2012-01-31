//
//  EntrevistadoRef.h
//  iMeetingMX
//
//  Created by Luis Alejandro Rangel Sánchez on 30/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Entrevistador.h"

@interface ProxyRefEntrevistado : Entrevistado

-(Entrevistador *) obtenReferencia;

#pragma Persona
-(NSString *) nombre;

#pragma Entrevistado
-(NSString *) telefono;
-(BOOL) asistio;


@property(nonatomic, assign) NSDictionary * conjuntoEntrevistadores;

@end
