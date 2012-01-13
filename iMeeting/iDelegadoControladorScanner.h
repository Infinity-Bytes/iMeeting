//
//  iDelegadoControladorScanner.h
//  iMeeting
//
//  Created by Jesus Cagide on 13/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entrevistado.h"
@protocol iDelegadoControladorScanner <NSObject>

-(NSString*) obtenerEntrevistado:(NSString*)identificador;
-(void) notificarRespuesta:(BOOL)respuesta;

@end
