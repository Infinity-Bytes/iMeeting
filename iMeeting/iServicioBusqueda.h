//
//  iServicioBusqueda.h
//  iMeeting
//
//  Created by Jesus Cagide on 13/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Persona.h"
#import "Entrevistador.h"

@protocol iServicioBusqueda <NSObject>

-(Entrevistador *) buscarEntrevistadorPorIdentificador:(NSString *)identificador;
-(Entrevistador *) buscaraEntrevitador:(Entrevistador *)entrevistador;
-(Persona *) buscarPersonaPorIdentificador:(NSString *)identificador;

@property (nonatomic, retain) NSArray * personalMeeting;

@end
