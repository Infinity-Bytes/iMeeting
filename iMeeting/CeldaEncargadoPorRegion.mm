//
//  CeldaPlantaTratadora.m
//  INAGUAPP
//
//  Created by Jesus Cagide on 07/12/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import "CeldaEncargadoPorRegion.h"

@implementation CeldaEncargadoPorRegion

@synthesize etiquetaNombre = _etiquetaNombre;
@synthesize capacidad = _capacidad;
@synthesize graficaBarra = _graficaBarra;
@synthesize entrevistador = _entrevistador;
@synthesize porcentaje;

-(void) dealloc 
{
    
    [_etiquetaNombre release];
    [_capacidad release];
    [_graficaBarra release];
    
    self.entrevistador=nil;
    self.porcentaje = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)establecerEntrevistador:(Entrevistador*) entrevistador;
{
    [self setEntrevistador:entrevistador];
    CGRect bar = [[self graficaBarra] frame];

    int personasEncargadas = self.entrevistador.numeroPersonasASuCargo;
    float ancho = personasEncargadas ? (( self.entrevistador.numeroPersonasEntrevistadas * 100) / personasEncargadas) : 0;
    if(ancho < 0 || ancho > 100)
        ancho = 0.0f;
    
    NSString * capacidad = [NSString stringWithFormat: @"%d", personasEncargadas];
	bar.size = CGSizeMake(320.0f * 0.01f * ancho, bar.size.height);
	[[self graficaBarra] setFrame:bar];
    [[self capacidad ] setText:[NSString stringWithFormat:@"%@", capacidad]];
    [[self etiquetaNombre] setText: self.entrevistador.nombre ];
    [[self porcentaje] setText:[NSString stringWithFormat: @"%.1f%%", ancho]];
}
@end
