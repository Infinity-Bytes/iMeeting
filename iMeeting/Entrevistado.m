//
//  Entrevistado.m
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Entrevistado.h"

@implementation Entrevistado

@synthesize asistio;
@synthesize telefono;
@synthesize entrevistable;

- (id)init {
    self = [super init];
    if (self) {
        [self setEntrevistable: NO];
    }
    return self;
}

-(void)dealloc
{
    [self setTelefono: nil];
    [self setAsistio: FALSE];
    
    [super dealloc];
}

@end
