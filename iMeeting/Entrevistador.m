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
@synthesize personas;

@synthesize personasEntrevistadas;
@synthesize personasSinEntrevistar;

-(void) dealloc
{
    [self setPermiso: nil];
    [self setZona: nil];
    [self setPersonas: nil];
    
    [self setPersonasEntrevistadas: nil];
    [self setPersonasSinEntrevistar: nil];

    [super dealloc];
}
@end
