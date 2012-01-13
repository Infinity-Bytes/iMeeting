//
//  Entrevistador.m
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Entrevistador.h"

@implementation Entrevistador

@synthesize permiso;
@synthesize zona;
@synthesize entrevistados;

@synthesize personasEntrevistadas;
@synthesize personasSinEntrevistar;

-(void) dealloc
{
    [self setPersonasEntrevistadas: nil];
    [self setPersonasSinEntrevistar: nil];
    
    [self setPermiso: nil];
    [self setZona: nil];
    [self setEntrevistados: nil];

    [super dealloc];
}
@end
