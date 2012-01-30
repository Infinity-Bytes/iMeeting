//
//  Meeting.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Meeting.h"

@implementation Meeting

@synthesize nombreMeeting;
@synthesize personal;
@synthesize conjuntoEntrevistados;

@synthesize definicion;
@synthesize encodingDefinicion;

@synthesize urlLocal;
@synthesize urlCloud;
@synthesize registrado;

- (id)init {
    self = [super init];
    if (self) {
        [self setNombreMeeting: @""];
        [self setPersonal: [NSArray array]];
        [self setConjuntoEntrevistados: [[NSDictionary new] autorelease]];
        
        [self setDefinicion:@""];
        
        [self setUrlLocal: nil];
        [self setUrlCloud: nil];
        
        [self setRegistrado: NO];
    }
    return self;
}

- (void)dealloc {
    [self setNombreMeeting: nil];
    [self setPersonal: nil];
    [self setConjuntoEntrevistados: nil];
    
    [self setDefinicion: nil];
    [self setUrlLocal: nil];
    [self setUrlCloud: nil];
    [self setRegistrado: NO];
    
    [super dealloc];
}
@end
