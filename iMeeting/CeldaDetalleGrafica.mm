//
//  CeldaDetalleGrafica.m
//  Grafo
//
//  Created by Jesus Cagide on 04/11/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import "CeldaDetalleGrafica.h"

//continuar

@implementation CeldaDetalleGrafica

@synthesize nombreLeyenda = _nombreLeyenda;
@synthesize porcentaje = _porcentaje;
@synthesize cantidad = _cantidad;
@synthesize representacionBarra = _representacionBarra;
@synthesize representacionFondoCelda = _representacionFondoCelda;
@synthesize detalleGrafica = _detalleGrafica;

- (void)dealloc
{
	[_nombreLeyenda release];
    [_porcentaje release];
    [_cantidad release];
    [_representacionBarra release];
    [_detalleGrafica release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}
//y Color
-(void) establecerPosicion:(CustomCellBackgroundViewPosition) posicion yColor:(UIColor *) color
{
    [[self representacionBarra] setPosition:posicion];
    [[self representacionBarra] setBorderColor:color];
    [[self representacionBarra] setFillColor:color];
    
    [[self representacionFondoCelda] setBorderColor:[UIColor grayColor]];
    [[self representacionFondoCelda] setFillColor:[UIColor whiteColor]];
    [[self representacionFondoCelda] setPosition:posicion];
    
    [self setBackgroundView:[self representacionFondoCelda]];
    
    
}

- (void)establecerDetalleGrafica:(DetalleGrafica *)nuevoDetalleGrafica
{
    [self setDetalleGrafica:nuevoDetalleGrafica];
    [self updateDetails];
}

-(void)updateDetails
{
	NSString *valorPorcentaje = [ NSString stringWithFormat:@"%.1f\%",[[self detalleGrafica] porcentaje] ];
	CGRect bar = [[self representacionBarra] frame];
    float ancho = [[self detalleGrafica] porcentaje];
    if(ancho < 0 || ancho > 100)
        ancho = 0.0f;
	bar.size = CGSizeMake(320.0f * 0.01f * ancho, bar.size.height);
	[[self representacionBarra] setFrame:bar];
	[[self  nombreLeyenda] setText:[[self detalleGrafica] nombreLeyenda]];
    [[self  cantidad] setText:[[self detalleGrafica] cantidad]];
    [[self  porcentaje] setText:valorPorcentaje];
}

@end
