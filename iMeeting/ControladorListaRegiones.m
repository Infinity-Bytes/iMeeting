//
//  PlantaTratadoraDeAgua.m
//  INAGUAPP
//
//  Created by Jesus Cagide on 07/12/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import "ControladorListaRegiones.h"

@implementation ControladorListaRegiones

@synthesize nombre = _nombre;
@synthesize localidad = _localidad;
@synthesize municipio = _municipio;
@synthesize capacidad = _capacidad;
@synthesize tipoDePlanta = _tipoDePlanta;


-(void) dealloc
{
    [_nombre release];
    [_localidad release];
    [_municipio release];
    [_capacidad release];
    [_tipoDePlanta release];
    [super dealloc];
}

@end
 