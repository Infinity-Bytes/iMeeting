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
    }
    return self;
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

- (int) numeroPersonasASuCargo {
    return [self numeroPersonasEntrevistadas];
}

@end
