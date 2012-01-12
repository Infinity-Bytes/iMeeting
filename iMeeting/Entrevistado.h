//
//  Entrevistado.h
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entrevistado : NSObject

@property(nonatomic, retain) NSString *identificador;
@property(nonatomic, retain) NSString *nombre;
@property(nonatomic, retain) NSString *telefono;
@property(nonatomic, assign) BOOL asistio;

@end
