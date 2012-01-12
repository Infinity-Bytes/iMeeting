//
//  Entrevistado.m
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Entrevistado.h"

@implementation Entrevistado

@synthesize nombre;
@synthesize identificador;
@synthesize voto;
@synthesize telefono;


-(void)dealloc
{
    [self.nombre release]; self.nombre = nil;
    [self.identificador release]; self.identificador =nil;
    [self.telefono release]; self.telefono=nil;
    [super dealloc];
}

@end
