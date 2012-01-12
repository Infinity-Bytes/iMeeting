//
//  CeldaDetalleGrafica.h
//  Grafo
//
//  Created by Jesus Cagide on 04/11/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetalleGrafica.h"
#import "FondoCelda.h"

@interface CeldaDetalleGrafica : UITableViewCell{

    UILabel* _nombreLeyenda;
    UILabel* _porcentaje;
    UILabel* _cantidad;
    FondoCelda * _representacionBarra;
    FondoCelda * _representacionFondoCelda;
    DetalleGrafica * _detalleGrafica;

}

-(void)updateDetails;

- (void)establecerDetalleGrafica:(DetalleGrafica *)nuevoDetalleGrafica;
-(void) establecerPosicion:(CustomCellBackgroundViewPosition) posicion yColor:(UIColor *) color;

@property (nonatomic, retain) IBOutlet UILabel* nombreLeyenda;
@property (nonatomic, retain) IBOutlet UILabel* porcentaje;
@property (nonatomic, retain) IBOutlet UILabel* cantidad;
@property (nonatomic, retain) IBOutlet FondoCelda* representacionBarra;
@property (nonatomic, retain) IBOutlet FondoCelda* representacionFondoCelda;
@property (nonatomic, retain) DetalleGrafica* detalleGrafica;

@end
