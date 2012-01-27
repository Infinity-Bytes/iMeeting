//
//  Persona.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Persona : NSObject

@property(nonatomic, retain) NSString * identificador;
@property(nonatomic, retain) NSString * nombre;
@property(nonatomic, assign) id lider;

@end
