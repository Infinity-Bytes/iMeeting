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
- (void) registraMeeting: (Meeting *) meeting conURLDocumentos: (NSURL *) urlDocumentos yURLCloud: (NSURL *) urliCloud;
- (void) registraElementoTrabajadoPorURL: (NSURL *) urlElementoTrabajado;
- (Meeting *) obtenMeetingDeURL: (NSURL *) urlArchivoDefinicion;
- (void) procesaElementosTrabajadosEnURLMeeting: (NSURL *) urlMeeting enSubdirectorio: (NSString *) subdirectorio;

#pragma Cargado de archivos de directorio local
- (void)cargaMeetingsDeDocumentos;

#pragma Cargado de archivos de iCloud
- (void)cargaMeetingsDeiCloud;
- (void) enviarPendientesATrabajados;
- (void)queryDidFinishGathering:(NSNotification *)notification;
- (void)loadData:(NSMetadataQuery *)query;
- (void) procesaDocumento: (Documento *) doc conPathRelativo: (NSString *) subPath legible: (BOOL) legible;

#pragma Cargado de Meetings a partir de definición dada por iTunes Shared Folder
- (void) cargaMeetingsDeiTunesFileSharing;
- (void) generaEstructuraDeMeeting: (Meeting *) meeting;
- (id) cargaDirectorioMeeting: (Meeting *) meeting enURL: (NSURL *) urlInteres;
- (NSArray *) cargaDefinicionMeetings;
- (Meeting *) generaMeetingDePOCOs: (NSDictionary *) objetoPlano;
- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia usandoAcumulador: (NSMutableDictionary *) acumulador;
- (void) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase;


@property (nonatomic, retain) NSURL * urlDocumentos;
@property (nonatomic, assign) id<iServicioGestorDatosDelegate> delegado;
@property (nonatomic, retain) NSMetadataQuery * metaDataQuery;

@end
