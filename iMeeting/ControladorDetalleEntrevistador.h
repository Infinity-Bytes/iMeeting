//
//  ControladorDetalleEntrevistador.h
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entrevistador.h"
#import "CeldaDetalleGrafica.h"
#import "iDelegadoControladorNavegacion.h"

@interface ControladorDetalleEntrevistador : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UINib *_cellNib;
    NSMutableDictionary *_datosEntrevistador; 
    Entrevistador * _entrevistador;
}

- (void) establecerEntrevistador:(Entrevistador*)entrevistador;
- (void) cargaInfo: (Entrevistador *) entrevistador;
- (void) refrescarPantallasConEntrevistador: (NSNotification *) notification;

@property(nonatomic, assign) IBOutlet UILabel * nombreEntrevistador;
@property(nonatomic, assign) IBOutlet UILabel * zona;
@property(nonatomic, assign) IBOutlet UITableView * tablaDatos;

@property(nonatomic, retain) IBOutlet  CeldaDetalleGrafica* celdaDetalleGrafica;

@property(nonatomic, retain) NSArray * colores;
@property(nonatomic, retain) NSArray * detallesDeGrafica;
@property (nonatomic, retain) UINib *cellNib;


@property (nonatomic, assign) id<iDelegadoControladorNavegacion> delegadoControladorNavegacion;

@end
