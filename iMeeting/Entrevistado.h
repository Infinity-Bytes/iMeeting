//
//  Entrevistado.h
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Persona.h"

@interface Entrevistado : Persona

@property(nonatomic, retain) NSString * telefono;
@property(nonatomic, assign) BOOL asistio;
@property(nonatomic, assign) BOOL entrevistable;

@end
