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

@synthesize plantaTratadora = _plantaTratadora;


-(void) dealloc 
{
    
    [_etiquetaNombre release];
    [_capacidad release];
    [_graficaBarra release];
    
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

    // Configure the view for the selected state
}


-(void)establecerPlantaTratadora:(ControladorListaRegiones*) planta;
{
    [self setPlantaTratadora:planta];
    CGRect bar = [[self graficaBarra] frame];
    NSString * capacidad = [[self plantaTratadora] capacidad];
    float ancho = (([capacidad floatValue] * 100) / 300);
    if(ancho < 0 || ancho > 100)
        ancho = 0.0f;
	bar.size = CGSizeMake(320.0f * 0.01f * ancho, bar.size.height);
	[[self graficaBarra] setFrame:bar];
    [[self capacidad ] setText:[NSString stringWithFormat:@"%.1f Lps", [capacidad floatValue] ]];
    [[self etiquetaNombre] setText: [[self plantaTratadora] nombre]];
}

@end
