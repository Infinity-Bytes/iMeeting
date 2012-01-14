//
//  Entrevistador.h
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entrevistado.h"

@interface Entrevistador : Entrevistado

@property(nonatomic, retain) NSMutableArray* personasEntrevistadas;
@property(nonatomic, retain) NSMutableArray* personasSinEntrevistar;


@property(nonatomic, retain) NSString *permiso;
@property(nonatomic, retain) NSString *zona;
@property(nonatomic, retain) NSArray *personas;

@end
