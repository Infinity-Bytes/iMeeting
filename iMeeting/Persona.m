//
//  Persona.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Persona.h"

@implementation Persona

@synthesize identificador;
@synthesize nombre;
@synthesize lider;

- (id)init {
    self = [super init];
    if (self) {
        [self setIdentificador: nil];
        [self setNombre: nil];
        [self setLider: nil];

    }
    return self;
}

- (void)dealloc {
    [self setIdentificador: nil];
    [self setNombre: nil];
    [self setLider: nil];
    
    [super dealloc];
}

@end
