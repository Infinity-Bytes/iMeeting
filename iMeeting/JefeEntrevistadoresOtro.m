//
//  JefeEntrevistadoresOtro.m
//  iMeetingMX
//
//  Created by Luis Rangel on 03/02/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "JefeEntrevistadoresOtro.h"

@implementation JefeEntrevistadoresOtro

- (id)init {
    self = [super init];
    if (self) {
        [self setNumeroPersonasASuCargo: 0];
        [self setNumeroPersonasEntrevistadas: 0];
        [self setEntrevistable: YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector: @selector(elementoRegistrado:) 
                                                     name: @"refrescarPantallasConEntrevistador" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super dealloc];
}

- (void) elementoRegistrado: (NSNotification *) notification {
    [self setNumeroPersonasASuCargo: [self numeroPersonasASuCargo] + 1];
}

- (id) lider {
    return self;
}

- (BOOL) asistio {
    return NO;
}

- (NSMutableSet *) personasEntrevistadas {
    return nil;
}

- (NSMutableSet *) personasSinEntrevistar {
    return nil;
}

- (NSMutableArray *) jefesEntrevistadores {
    return nil;
}

- (NSMutableArray *) entrevistadores {
    return nil;
}

@end
