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
    [self.personasEntrevistadas release]; self.personasEntrevistadas = nil;
    [self.personasSinEntrevistar release]; self.personasSinEntrevistar = nil;
    
    [self.permiso release]; self.permiso = nil;
    [self.zona release]; self.zona= nil;
    [self.entrevistados release]; self.entrevistados = nil;
    [super dealloc];
}
@end
