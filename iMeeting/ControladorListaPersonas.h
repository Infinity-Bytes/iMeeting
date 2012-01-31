//
//  ControladorListaPersonas.h
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entrevistador.h"

@interface ControladorListaPersonas : UIViewController<UITableViewDelegate, UITableViewDataSource>

- (void) cargaInfo;

@property(nonatomic, assign) IBOutlet  UITableView * tablaDatos;

@property(nonatomic, retain) NSArray * datos;

@property(nonatomic, retain) NSSet * origenDatos;
@property(nonatomic, retain) Entrevistador * entrevistador;

@end
