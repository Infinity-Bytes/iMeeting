//
//  iServicioGestorDatos.h
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iServicioGestorDatosDelegate.h"

@protocol iServicioGestorDatos <NSObject>

- (void)cargaMeetingsDeDocumentos;
- (void)cargaMeetingsDeiCloud;

@end
