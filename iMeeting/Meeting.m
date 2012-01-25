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
@synthesize conjuntoPersonas;

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
        [self setConjuntoPersonas: [[NSDictionary new] autorelease]];
        
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
    [self setConjuntoPersonas: nil];
    
    [self setDefinicion: nil];
    [self setUrlLocal: nil];
    [self setUrlCloud: nil];
    [self setRegistrado: NO];
    
    [super dealloc];
}
@end
