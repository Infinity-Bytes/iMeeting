//
//  iServicioGestorDatosDelegate.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 20/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Meeting.h"
#import "Documento.h"

@protocol iServicioGestorDatosDelegate <NSObject>

-(void) asignarMeeting: (Meeting *) meeting;

@end
