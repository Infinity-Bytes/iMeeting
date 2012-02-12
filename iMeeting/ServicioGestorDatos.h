//
//  ServicioGestorDatos.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 19/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

#import "Meeting.h"
#import "Entrevistador.h"
#import "Documento.h"

@interface ServicioGestorDatos : NSObject <DBRestClientDelegate>
{
    @private
    DBRestClient * restClient;
    NSMutableDictionary * _meetingsPorNombre;
    NSMutableDictionary * _meetingsPorPathDefinicion;
    
    NSMutableSet * _elementoTrabajadoPorPath;
    
    NSMutableSet * _archivoGestionadoPorPath;
    NSMutableDictionary * _revisionPorPath;
    BOOL enviarPendientes;
    
    NSDateFormatter *_dateFormatter;
    BOOL recolectaInfo;
}

- (DBRestClient *) restClient;

- (void) procesaElementoTrabajado: (NSNotification *) theNotification;
- (void) especificadoPermiso: (NSNotification *) theNotification;

- (void) registraMeeting: (Meeting *) meeting conURLDocumentos: (NSURL *) urlDocumentos yURLCloud: (NSURL *) urliCloud;
- (void) registraElementoTrabajadoPorURL: (NSURL *) urlElementoTrabajado;
- (Meeting *) obtenMeetingDeURL: (NSURL *) urlArchivoDefinicion;
- (void) procesaElementosTrabajadosEnURLMeeting: (NSURL *) urlMeeting enSubdirectorio: (NSString *) subdirectorio;
- (NSString *) obtenSubPath: (NSURL *) url;

#pragma Cargado de archivos de directorio local
- (void)cargaMeetingsDeDocumentos;

#pragma Cargado de archivos de iCloud
- (void)cargaMeetingsDeiCloud;
- (void) enviarPendientesATrabajados;

#pragma Cargado de Meetings a partir de definición dada por iTunes Shared Folder
- (void) cargaMeetingsDeiTunesFileSharing;
- (void) generaEstructuraDeMeeting: (Meeting *) meeting conURLOrigen: (NSURL *) urlOrigen;
- (id) cargaDirectorioMeeting: (Meeting *) meeting enURL: (NSURL *) urlInteres yURLOrigen: (NSURL *) urlOrigen;
- (NSArray *) cargaDefinicionMeetings;
- (Meeting *) generaMeetingDePOCOs: (NSDictionary *) objetoPlano;
- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia conIdentificadorDeConjunto: (NSString *) identificadorConjunto usandoAcumuladorEntrevistados: (NSMutableDictionary *) acumulador
    acumuladorEntrevistadores:(NSMutableDictionary *) acumuladorEntrevistadores
               yPersonaOrigen:(id) lider;
- (BOOL) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase;


@property (nonatomic, retain) NSURL * urlDocumentos;

@end
