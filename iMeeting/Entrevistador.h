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
@property(nonatomic, retain) NSArray* personasEntrevistadas;
@property(nonatomic, retain) NSArray* personasSinEntrevistar;
@property(nonatomic, retain) NSArray* entrevistados;
@property(nonatomic, retain) NSString *permiso;
@property(nonatomic, retain) NSString *zona;


@end
