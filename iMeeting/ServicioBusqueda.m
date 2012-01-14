//
//  ServicioBusqueda.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 13/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ServicioBusqueda.h"

@implementation ServicioBusqueda

@synthesize personalMeeting;


- (void)dealloc {
    [self setPersonalMeeting: nil];
    [_personalMeeting release]; _personalMeeting = nil;
    
    [super dealloc];
}

-(Entrevistador *) buscarEntrevistadorPorIdentificador:(NSString *)identificador {
    return  [_personalMeeting objectForKey: identificador];
}

-(Entrevistador *) buscaraEntrevitador:(Entrevistador *)entrevistador {
    return nil;
}

-(Persona *) buscarPersonaPorIdentificador:(NSString *)identificador {
    return  [_personalMeeting objectForKey: identificador];
}

@end
