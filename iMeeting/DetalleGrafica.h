//
//  DetalleGrafica.h
//  Grafo
//
//  Created by Jesus Cagide on 04/11/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetalleGrafica : NSObject{
    NSString* _nombreLeyenda;
    NSString* _cantidad;
    float _porcentaje;
}

- (id) init;

@property(nonatomic, retain) NSString* nombreLeyenda;
@property(nonatomic, retain) NSString* cantidad;
@property(assign) float  porcentaje;



@end
