//
//  ControladorPlantasTratadoras.h
//  INAGUAPP
//
//  Created by Jesus Cagide on 07/12/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CeldaEncargadoPorRegion.h"
#import "iDelegadoControladorLista.h"
#import "iDelegadoControladorNavegacion.h"

/**
 Controlador de vista que representa el listado de las diferentes administradores del estado
 */
@interface ControladorListaRegiones : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    /**
     Referencia a la tabla que contiene el listado en cuestión
     */
    UITableView *_tablaDatos;
    
    /**
     Conjunto encargados por region
     */
    NSDictionary * _encargadosPorRegion;
    
    /**
     Referencia al patrón de la celda que se usa en el listado
     */
    CeldaEncargadoPorRegion * _celda;
    
    /**
     Referencia al NIB que contiene el patrón de las celdas del listado
     @see _celda
     */
    UINib *_cellNib;
    
}

@property(nonatomic, retain) IBOutlet  UITableView *tablaDatos;
@property(nonatomic, retain) IBOutlet  CeldaEncargadoPorRegion* celda;
@property(nonatomic, retain) NSDictionary * encargadosPorRegion;
@property (nonatomic, retain) UINib *cellNib;

@property (nonatomic, retain) NSString *identificador;
//Delegados

@property (nonatomic, assign) id<iDelegadoControladorLista> delegadoControladorLista;
@property (nonatomic, assign) id<iDelegadoControladorNavegacion> delegadoControladorNavegacion;

@end
