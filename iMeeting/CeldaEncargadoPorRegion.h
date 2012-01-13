//
//  CeldaPlantaTratadora.h
//  INAGUAPP
//
//  Created by Jesus Cagide on 07/12/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entrevistador.h"

/**
 Celda personalizada que representa la información más importante de las plantas tratadoras de agua
 */
@interface CeldaEncargadoPorRegion : UITableViewCell
{
    /**
     Referencia a la etiqueta que contiene el nombre de la planta tratadora de agua
     */
    UILabel * _etiquetaNombre;
    
    /**
     Referencia a la etiqeta que contiene la capacidad en Lps de la planta de interés
     */
    UILabel * _capacidad;
    
    /**
     Referencia a la imagen que representa el porcentaje de la capacidad en el fondo de la celda
     */
    UIImageView * _graficaBarra;
    
    /**
     Referencia a la planta tratadora de agua que representa la celda
     */
    Entrevistador * _entrevistador;

}

/**
 Método de asignación de la planta tratadora de agua a representar
 */
-(void)establecerEntrevistador:(Entrevistador*) entrevistador;

@property(nonatomic, retain) IBOutlet UILabel * etiquetaNombre;
@property(nonatomic, retain) IBOutlet UILabel * capacidad;
@property(nonatomic, retain) IBOutlet UIImageView * graficaBarra;

@property(nonatomic, retain) IBOutlet UILabel * porcentaje;

@property(nonatomic, assign) Entrevistador * entrevistador;

@end
