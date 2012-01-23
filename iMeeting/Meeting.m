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

- (id)init {
    self = [super init];
    if (self) {
        [self setNombreMeeting: @""];
        [self setPersonal: [NSArray array]];
        [self setConjuntoPersonas: [[NSDictionary new] autorelease]];
        [self setDefinicion:@""];
    }
    return self;
}

- (void)dealloc {
    [self setNombreMeeting: nil];
    [self setPersonal: nil];
    [self setConjuntoPersonas: nil];
    [self setDefinicion: nil];
    
    [super dealloc];
}
@end
