//
//  ServicioGestorDatos.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 19/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iServicioGestorDatos.h"
#import "Meeting.h"

@interface ServicioGestorDatos : NSObject <iServicioGestorDatos>

- (void) estableceDelegado: (id<iServicioGestorDatosDelegate>) delegadoInteres;

#pragma Cargado de archivos de iCloud
- (void)cargaMeetings;
- (void)queryDidFinishGathering:(NSNotification *)notification;
- (void)loadData:(NSMetadataQuery *)query;

#pragma Cargado de Meetings a partir de definición dada por iTunes Shared Folder
- (void) inicializaMeeting;
- (NSArray *) cargaDefinicionMeetings;
- (Meeting *) generaMeetingDePOCOs: (NSDictionary *) objetoPlano;
- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia usandoAcumulador: (NSMutableDictionary *) acumulador;
- (void) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase;

@property (nonatomic, assign) id<iServicioGestorDatosDelegate> delegado;
@property (nonatomic, retain) NSMetadataQuery * metaDataQuery;

@end
