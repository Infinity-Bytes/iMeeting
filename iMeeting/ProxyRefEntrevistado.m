//
//  EntrevistadoRef.m
//  iMeetingMX
//
//  Created by Luis Alejandro Rangel Sánchez on 30/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ProxyRefEntrevistado.h"

@implementation ProxyRefEntrevistado

@synthesize conjuntoEntrevistadores;

- (id)init {
    self = [super init];
    if (self) {
        [self setConjuntoEntrevistadores: [NSDictionary dictionary]];
        [self setEntrevistable: YES];
    }
    return self;
}

- (void)dealloc {
    [self setConjuntoEntrevistadores: nil];
    
    [super dealloc];
}


-(Entrevistador *) obtenReferencia {
    id salida = [[self conjuntoEntrevistadores] objectForKey: [self identificador]];
    if (salida == nil) {
        NSLog(@"Error en obtencion del origen del proxy");
    }
    return salida;
}

#pragma Persona

-(NSString *) nombre {
    return [[self obtenReferencia] nombre];
}

#pragma Entrevistado
-(NSString *) telefono {
    return [[self obtenReferencia] telefono];
}

@end
