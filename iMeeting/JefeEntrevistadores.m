//
//  JefeEntrevistadores.m
//  iMeetingMX
//
//  Created by Luis Alejandro Rangel Sánchez on 27/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "JefeEntrevistadores.h"

@implementation JefeEntrevistadores

@synthesize jefesEntrevistadores;
@synthesize entrevistadores;

- (id)init {
    self = [super init];
    if (self) {
        [self setJefesEntrevistadores: [[NSMutableArray new] autorelease]];
        [self setEntrevistadores: [[NSMutableArray new] autorelease]];
    }
    return self;
}

- (void)dealloc {
    [self setJefesEntrevistadores: nil];
    [self setEntrevistadores: nil];
    
    [super dealloc];
}

@end
