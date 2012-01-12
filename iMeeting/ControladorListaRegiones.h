//
//  PlantaTratadoraDeAgua.h
//  INAGUAPP
//
//  Created by Jesus Cagide on 07/12/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Entidad que representa a las plantas tratadoras de agua del estado de Aguascalientes
 */
@interface ControladorListaRegiones : NSObject
{
    /**
     Nombre de la planta tratadora de agua
     */
    NSString * _nombre;
    
    /**
     Localidad a la que pertence la planta tratadora de agua
     */
    NSString * _localidad;
    
    /**
     Municipio al que pertenece la planta tratadora de agua
     */
    NSString * _municipio;
    
    /**
     Capacidad en Lps de tratamiento que tiene la planta tratadora de agua
     */
    NSString * _capacidad;
    NSMutableArray * _tipoDePlanta;
}


@property(nonatomic, retain)  NSString * nombre;
@property(nonatomic, retain)  NSString * localidad;
@property(nonatomic, retain)  NSString * municipio;
@property(nonatomic, retain)  NSString * capacidad;
@property(nonatomic, retain)  NSMutableArray * tipoDePlanta;


@end
