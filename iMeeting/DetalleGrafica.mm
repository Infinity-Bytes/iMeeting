//
//  DetalleGrafica.m
//  Grafo
//
//  Created by Jesus Cagide on 04/11/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import "DetalleGrafica.h"

@implementation DetalleGrafica

@synthesize nombreLeyenda = _nombreLeyenda;
@synthesize cantidad = _cantidad;
@synthesize porcentaje = _porcentaje;



- (id) init
{
    self = [super init];
    if(self) {
        [self setPorcentaje:0.0f];
        [self setCantidad:@""];
        [self setNombreLeyenda:@""];
    }
    return self;
}

-(void) dealloc{

    [_nombreLeyenda release];
    [_cantidad release];
    [super dealloc];
}

@end
