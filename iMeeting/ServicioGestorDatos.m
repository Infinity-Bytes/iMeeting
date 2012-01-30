//
//  ServicioGestorDatos.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 19/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "SBJson.h"


#import "ServicioGestorDatos.h"
#import "Documento.h"

#import "Persona.h"
#import "Entrevistado.h"
#import "EntrevistadoRef.h"

#pragma Macros Control
#define REGENERARESTRUCTURA YES
#define BORRARDEFINICIONMEETING NO

#pragma Macro de Apoyo
#define PATRONARCHIVOS(x) [NSString stringWithFormat:@"%@", x]
#define SINPATRONARCHIVOS(x) x

#pragma Macros de Constantes
#define ARCHIVODEFINICIONMEETING PATRONARCHIVOS(@"Definicion.json")
#define DIRECTORIOTRABAJADO @"trabajado"
#define DIRECTORIOPENDIENTE @"pendiente"
#define EXTENSIONMEETING @"-meeting"

#pragma Implementación ServicioGestorDatos

// TODO Evitar generar nuevos archivos de elementos que ya se encuentran previamente en la nube
@implementation ServicioGestorDatos

@synthesize urlDocumentos;


- (id)init {
    self = [super init];
    if (self) {
        _meetingsPorNombre = [NSMutableDictionary new];
        _meetingsPorPathDefinicion = [NSMutableDictionary new];
        _elementoTrabajadoPorPath = [NSMutableSet new];
        _archivoGestionadoPorPath = [NSMutableSet new];
        _revisionPorPath = [NSMutableDictionary new];

        enviarPendientes = NO;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self setUrlDocumentos: [[[NSURL alloc] initFileURLWithPath: [paths objectAtIndex: 0]  isDirectory: YES] autorelease]];
        
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(procesaElementoTrabajado:) 
                                                     name: @"registraElementoTrabajado" 
                                                   object: nil];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [_meetingsPorNombre release]; _meetingsPorNombre = nil;
    [_meetingsPorPathDefinicion release]; _meetingsPorPathDefinicion = nil;
    [_elementoTrabajadoPorPath release]; _elementoTrabajadoPorPath = nil;
    [_archivoGestionadoPorPath release]; _archivoGestionadoPorPath = nil;
    [_revisionPorPath release]; _revisionPorPath = nil;
    
    [self setUrlDocumentos: nil];
    
    [super dealloc];
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void) procesaElementoTrabajado: (NSNotification *) theNotification {
    NSLog(@"procesaElementoTrabajado: %@", [theNotification name]);
    
    Meeting * meeting = [[theNotification userInfo] objectForKey:@"meeting"];
    Entrevistado * entrevistado = [[theNotification userInfo] objectForKey:@"elementoTrabajado"];
    if(meeting && entrevistado && [meeting urlLocal]) {
        // Generacion de fichero correspondiente
        NSError * error;
        NSURL * urlPendientesLocal = [[meeting urlLocal] URLByAppendingPathComponent: DIRECTORIOPENDIENTE isDirectory: YES]; 
        NSURL * urlLocal = [ urlPendientesLocal URLByAppendingPathComponent: PATRONARCHIVOS([entrevistado identificador]) isDirectory: NO];
        
        if([[NSFileManager defaultManager] createDirectoryAtURL: urlPendientesLocal 
                 withIntermediateDirectories:YES attributes:nil error: &error]) {
            
            Documento * documentoAlmacenar = [[Documento alloc] initWithFileURL: urlLocal];
            [documentoAlmacenar setNoteContent: @""];
            [documentoAlmacenar saveToURL: [documentoAlmacenar fileURL] 
                         forSaveOperation: REGENERARESTRUCTURA ? UIDocumentSaveForOverwriting : UIDocumentSaveForCreating
                        completionHandler:^(BOOL success) {
                            NSLog(@"Elemento %@ pendiente publicado: %@", [documentoAlmacenar fileURL], success ? @"correctamente" : @"incorrectamente");
                        }];
            
            [documentoAlmacenar release];
        } else {
            NSLog(@"Error en generación de directorio pendiente %@, procesaElementoTrabajado:", error);
        }
    }
}

- (void) registraMeeting: (Meeting *) meeting conURLDocumentos: (NSURL *) urlMeetingDocumentos yURLCloud: (NSURL *) urlMeetingiCloud {
    // Revisar si el Meeting ya fue previamente registrado (por sus PATH) sino, registrarlo al delegado
    
    if(![meeting urlCloud] && urlMeetingiCloud) {
        [meeting setUrlCloud: urlMeetingiCloud];
    }
    
    if(![meeting urlLocal] && urlMeetingDocumentos) {
        [meeting setUrlLocal: urlMeetingDocumentos];
    }
    
    if(![meeting registrado]) {
        [meeting setRegistrado: YES];
        
        NSNotification * myNotification =
        [NSNotification notificationWithName:@"RegistraMeeting" object:self userInfo: [NSDictionary dictionaryWithObjectsAndKeys:meeting, @"meeting", urlMeetingDocumentos, @"urlMeetingDocumentos", urlMeetingiCloud, @"urlMeetingiCloud", nil]];
        
        [[NSNotificationQueue defaultQueue] enqueueNotification: myNotification
                                                   postingStyle: NSPostWhenIdle
                                                   coalesceMask: NSNotificationNoCoalescing
                                                       forModes: nil];
        
        NSLog(@"RegistraMeeting: %@ conURLDocumentos: %@ yURLCloud: %@", [meeting nombreMeeting], urlMeetingDocumentos, urlMeetingiCloud);
    }
}

- (void) registraElementoTrabajadoPorURL: (NSURL *) urlElementoTrabajado {

    // Obtener elementos publicados por URL de manera singleton (evitar trabajo por cada llamada de iCloud)
    NSString * subPathElementoTrabajado = [self obtenSubPath: urlElementoTrabajado];
    subPathElementoTrabajado = [subPathElementoTrabajado stringByReplacingOccurrencesOfString: DIRECTORIOPENDIENTE withString: DIRECTORIOTRABAJADO];
    
    if(![_elementoTrabajadoPorPath containsObject: subPathElementoTrabajado]) {
        [_elementoTrabajadoPorPath addObject: subPathElementoTrabajado];
        
        // Registrar elemento trabajado para Meeting específico
        NSString * elementoTrabajado = SINPATRONARCHIVOS([urlElementoTrabajado lastPathComponent]);
        
        NSString * pathDefinicion = [[[subPathElementoTrabajado componentsSeparatedByString: @"/"] objectAtIndex: 0] 
                                     stringByAppendingPathComponent: ARCHIVODEFINICIONMEETING];
        Meeting * meetingInteres = [_meetingsPorPathDefinicion objectForKey: pathDefinicion];
        
        if(meetingInteres) {
            NSLog(@"Meeting %@ tiene elemento trabajado: %@", [meetingInteres nombreMeeting], elementoTrabajado);
            
            NSNotification * myNotification =
            [NSNotification notificationWithName:@"registraElementoTrabajadoPorURL" object:self userInfo: [NSDictionary dictionaryWithObjectsAndKeys:meetingInteres, @"meeting", urlElementoTrabajado, @"urlElementoTrabajado", elementoTrabajado, @"elementoTrabajado", nil]];
            
            [[NSNotificationQueue defaultQueue] enqueueNotification: myNotification
                                                       postingStyle: NSPostWhenIdle
                                                       coalesceMask: NSNotificationNoCoalescing
                                                           forModes: nil];
        }
    }
    
    NSLog(@"registraElementoTrabajadoPorURL: %@", urlElementoTrabajado);
}

- (Meeting *) obtenMeetingDeURL: (NSURL *) urlArchivoDefinicion {
    Meeting * meetingInteres = nil;
    
    NSString * subPathArchivoDefinicion = [self obtenSubPath: urlArchivoDefinicion];
    if(!(meetingInteres = [_meetingsPorPathDefinicion objectForKey: subPathArchivoDefinicion])) {
        
        NSStringEncoding encoding;
        NSError * error;
        NSString * definicionMeeting = [NSString stringWithContentsOfURL: urlArchivoDefinicion usedEncoding:&encoding error:&error];
        id definicion = [definicionMeeting JSONValue];
        if([definicion isKindOfClass: [NSDictionary class]]) {
            NSString * nombreMeeting = [definicion objectForKey: @"nombreMeeting"];
            
            if(nombreMeeting) {
                if(!(meetingInteres = [_meetingsPorNombre objectForKey: nombreMeeting])) {
                    meetingInteres = [self generaMeetingDePOCOs: definicion];
                    [meetingInteres setEncodingDefinicion: encoding];
                    [meetingInteres setDefinicion: definicionMeeting];
                    
                    // Registrar Meeting creado
                    [_meetingsPorNombre setObject: meetingInteres forKey: nombreMeeting];

                    if(subPathArchivoDefinicion)
                        [_meetingsPorPathDefinicion setObject: meetingInteres forKey: subPathArchivoDefinicion];
                }
            }
        }
    }
    return meetingInteres;
}

- (void) procesaElementosTrabajadosEnURLMeeting: (NSURL *) urlMeeting enSubdirectorio: (NSString *) subdirectorio {
    BOOL directorio;
    NSError *error;
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    
    // Registrar elementos ya trabajados
    NSURL * urlTrabajado = [urlMeeting URLByAppendingPathComponent: subdirectorio];
    if([defaultManager fileExistsAtPath: [urlTrabajado path] isDirectory: &directorio]) {
        if(directorio) {
            NSArray * elementosTrabajados = [defaultManager contentsOfDirectoryAtURL: urlTrabajado
                                                          includingPropertiesForKeys:[NSArray array] 
                                                                             options:0 
                                                                               error:&error];
            for(NSURL * urlElementoTrabajado in elementosTrabajados) {
                [self registraElementoTrabajadoPorURL: urlElementoTrabajado];
            }
        }
    }
}

- (void)cargaMeetingsDeDocumentos {
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray * elementosEnDocumentos = [defaultManager contentsOfDirectoryAtURL: [self urlDocumentos] 
                  includingPropertiesForKeys:[NSArray array] 
                                     options:0 
                                       error:&error];
    for (NSURL *url in elementosEnDocumentos) {
        if([[url lastPathComponent] hasSuffix: EXTENSIONMEETING]) {
            NSURL * urlDefinicion = [url URLByAppendingPathComponent: ARCHIVODEFINICIONMEETING isDirectory: NO];
            BOOL directorio;
            if([defaultManager fileExistsAtPath: [urlDefinicion path] isDirectory: &directorio]) {
                if(!directorio) {
                    Meeting * meeting = [self obtenMeetingDeURL: urlDefinicion];
                    if(meeting) {
                        [self registraMeeting: meeting conURLDocumentos: url yURLCloud: nil];
                        [self procesaElementosTrabajadosEnURLMeeting: url enSubdirectorio: DIRECTORIOTRABAJADO];
                        [self procesaElementosTrabajadosEnURLMeeting: url enSubdirectorio: DIRECTORIOPENDIENTE];
                    }
                }
            }
        }
    }
}

- (NSString *) obtenSubPath: (NSURL *) url {
    NSString * salida = nil;
    
    NSURL * urlInteres = url;
    NSString * pathURL = [url path];
    NSString * lastPathComponent = nil;
    do {
        lastPathComponent = [urlInteres lastPathComponent];
        if([lastPathComponent hasSuffix: EXTENSIONMEETING]) {
            NSURL * urlBase = [urlInteres URLByDeletingLastPathComponent];
            salida = [pathURL substringFromIndex: [[urlBase path] length] + 1];
        }
        urlInteres = [urlInteres URLByDeletingLastPathComponent];
    } while(lastPathComponent && ![lastPathComponent isEqualToString: @"/"] && !salida);
    
    return salida;
}

#pragma Cargado de archivos de iCloud

- (void)cargaMeetingsDeiCloud {
    
    // Revisar acceso a Cloud
    if([[DBSession sharedSession] isLinked]) {
        [[self restClient] loadMetadata: @"/"];
        
        // Se descargan las versiones de cada archivo antes de enviar archivos locales
        if(enviarPendientes == YES) {
            // Aquellos elementos trabajados que se encuentren en pendientes buscar envirles a iCloud
            [self enviarPendientesATrabajados];
        }
    }
}

- (void) enviarPendientesATrabajados {
    NSFileManager * defaultManager = [NSFileManager defaultManager];

    NSError *error;
    NSArray * elementosEnDocumentos = [defaultManager contentsOfDirectoryAtURL: [self urlDocumentos] 
                                                    includingPropertiesForKeys:[NSArray array] 
                                                                       options:0 
                                                                         error:&error];
    for (NSURL *url in elementosEnDocumentos) {
        if( [[url lastPathComponent] hasSuffix: EXTENSIONMEETING] ) {
            
            // Enviar elemento de definicion si no existe registrado en Web
            NSURL * urlElementoDefinicionLocal = [url URLByAppendingPathComponent: ARCHIVODEFINICIONMEETING isDirectory: NO];
            if([defaultManager fileExistsAtPath: [urlElementoDefinicionLocal path] isDirectory: NO]) {
                
                NSString * subPathDefinicion = [@"/" stringByAppendingString:[self obtenSubPath: urlElementoDefinicionLocal]];
                if(![_archivoGestionadoPorPath containsObject: subPathDefinicion]) {
                    [_archivoGestionadoPorPath addObject: subPathDefinicion];
                    
                    NSString * subPath = [self obtenSubPath: [urlElementoDefinicionLocal URLByDeletingLastPathComponent]];
                    NSString * localPath = [urlElementoDefinicionLocal path];
                    NSString * filename = [urlElementoDefinicionLocal lastPathComponent];
                    NSString * destDir = [@"/" stringByAppendingString: subPath];
                    
                    [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
                }
            }
            
            // Se envian pendientes si existen
            NSURL * urlPendientes = [url URLByAppendingPathComponent: DIRECTORIOPENDIENTE isDirectory: YES];
            BOOL directorio;
            if([defaultManager fileExistsAtPath: [urlPendientes path] isDirectory: &directorio]) {
                if(directorio) {
                    
                    NSArray * elementosEnPendientes = [defaultManager contentsOfDirectoryAtURL: urlPendientes 
                                                                    includingPropertiesForKeys:[NSArray array] 
                                                                                       options:0 
                                                                                         error:&error];
                    for(NSURL * urlElementoEnDocumentosPendientes in elementosEnPendientes) {
                        
                        // Generar Path de Pendientes a Trabajados y para iCloud
                        NSString * subPath = [[self obtenSubPath: [urlElementoEnDocumentosPendientes URLByDeletingLastPathComponent]] 
                                   stringByReplacingOccurrencesOfString: DIRECTORIOPENDIENTE withString: DIRECTORIOTRABAJADO];

                        
                        NSString * localPath = [urlElementoEnDocumentosPendientes path];
                        NSString * filename = [urlElementoEnDocumentosPendientes lastPathComponent];
                        NSString * destDir = [@"/" stringByAppendingString: subPath];
                        
                        [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
                    }
                }
            }
        }
    }
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSError * error;
    
    if (metadata.isDirectory) {
        for (DBMetadata * file in metadata.contents) {
            
            if(!file.isDirectory) {
                
                // Evitar descargar multiples veces el mismo documento
                NSString * revisionActual = [_revisionPorPath objectForKey: file.path];
                NSString * revisionNuevo = file.rev;
                
                if(![_archivoGestionadoPorPath containsObject: file.path] || ![revisionActual isEqualToString: revisionNuevo] ) {
                    [_archivoGestionadoPorPath addObject: file.path];
                    [_revisionPorPath setObject:file.rev forKey: file.path];

                    NSLog(@"Solicitando descarga: %@", file.path);
                    
                    NSURL * urlArchivoDocumentos = [self.urlDocumentos URLByAppendingPathComponent: [file.path substringFromIndex: 1]];
                    
                    
                    if([[NSFileManager defaultManager] createDirectoryAtURL:  [urlArchivoDocumentos URLByDeletingLastPathComponent]
                                                withIntermediateDirectories: YES
                                                                 attributes: nil
                                                                      error: &error]) {
                        [[self restClient] loadFile: file.path intoPath: [urlArchivoDocumentos path]];
                    } else {
                        NSLog( @"No es posible crear el directorio local para almacenar elemento en la nube: %@ con error: %@", [urlArchivoDocumentos URLByDeletingLastPathComponent], error);
                    }
                }
                
                enviarPendientes = TRUE;
            } else {
                [client loadMetadata: [file path]];
            }
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}


- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath {
    // Procesar documento
    NSURL * urlArchivoEnDocumentos = [[[NSURL alloc] initFileURLWithPath: localPath isDirectory: NO] autorelease];
    NSURL * urlDirectorioPadreEnDocumentos = [urlArchivoEnDocumentos URLByDeletingLastPathComponent];
    
    // Registrar Meeting
    if ([[urlArchivoEnDocumentos lastPathComponent] isEqualToString: ARCHIVODEFINICIONMEETING]) {
        Meeting * meeting = [self obtenMeetingDeURL: urlArchivoEnDocumentos];
        [self registraMeeting: meeting conURLDocumentos: urlDirectorioPadreEnDocumentos yURLCloud: nil];
    }
    
    // Registrar Elementos trabajados
    if([[urlDirectorioPadreEnDocumentos lastPathComponent] isEqualToString: DIRECTORIOTRABAJADO]) {
        [self registraElementoTrabajadoPorURL: urlArchivoEnDocumentos];
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    NSURL * urlElementoOrigen = [[[NSURL alloc] initFileURLWithPath:srcPath isDirectory: NO] autorelease];
    
    if(![[urlElementoOrigen lastPathComponent] isEqualToString: ARCHIVODEFINICIONMEETING]) {
        // Borrar elemento en pendiente
        NSError * error;
        if(![[NSFileManager defaultManager] removeItemAtURL: urlElementoOrigen error: &error]) {
            NSLog(@"Borrando %@ elemento trabajado pendiente incorrectamente, con error: %@", srcPath, error);
        }
    }
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
    
    // TODO Revisar que hacer cuando la definición no se publicara a la nube correctamente
}

#pragma Cargado de Meetings a partir de definición dada por iTunes Shared Folder

- (void) cargaMeetingsDeiTunesFileSharing {
    // Lectura de archivos de configuración de Meetings
    NSArray * archivosDefinicionMeetings = [self cargaDefinicionMeetings];
    if( [archivosDefinicionMeetings count] > 0 ) {
        for(NSString * definicionMeetingFileSharing in archivosDefinicionMeetings) {
            NSURL * urlArchivo = [[[NSURL alloc] initFileURLWithPath: definicionMeetingFileSharing isDirectory: FALSE] autorelease];
            Meeting * meetingInteres = [self obtenMeetingDeURL: urlArchivo];
            if(meetingInteres) {
                [self generaEstructuraDeMeeting: meetingInteres];
                
                if (BORRARDEFINICIONMEETING && !REGENERARESTRUCTURA) {
                    // Borrar definicion de iTunes File Sharing
                    NSError * error;
                    if(![[NSFileManager defaultManager] removeItemAtURL: urlArchivo error: &error]) {
                        NSLog(@"Borrando definición de iTunes File Sharing incorrecta, con error: %@", error);
                    }
                }
            }
        }
    }
}

- (void) generaEstructuraDeMeeting: (Meeting *) meeting {
    NSURL * urlDocumentosMeeting = [self cargaDirectorioMeeting: meeting enURL: [self urlDocumentos]];
    [self registraMeeting: meeting conURLDocumentos: urlDocumentosMeeting yURLCloud: nil];
}

- (id) cargaDirectorioMeeting: (Meeting *) meeting enURL: (NSURL *) urlInteres {
	id pathMeeting = nil;
    NSError *error = nil;
    
    if(urlInteres) {
        NSString * pathMeetingBase = [NSString stringWithFormat: @"%@%@", [meeting nombreMeeting], EXTENSIONMEETING];
        NSString * nombrePathMeetingPatron = PATRONARCHIVOS(pathMeetingBase);
        pathMeeting = [urlInteres URLByAppendingPathComponent: nombrePathMeetingPatron isDirectory:YES];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: [pathMeeting path]] || REGENERARESTRUCTURA)
        {
            NSFileManager * fileManager = [NSFileManager defaultManager];
            if ([fileManager createDirectoryAtURL: pathMeeting
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:&error])
            {
                NSLog(@"Creando estructura de Meeting: %@", pathMeeting);
                
                [fileManager createDirectoryAtURL:[pathMeeting URLByAppendingPathComponent: DIRECTORIOTRABAJADO] 
                       withIntermediateDirectories:YES attributes:nil error: &error];
                [fileManager createDirectoryAtURL:[pathMeeting URLByAppendingPathComponent: DIRECTORIOPENDIENTE] 
                       withIntermediateDirectories:YES attributes:nil error: &error];
                
                NSURL * pathDefinicion = [pathMeeting URLByAppendingPathComponent: ARCHIVODEFINICIONMEETING  isDirectory: NO];
                Documento * definicionInteres = [[Documento alloc] initWithFileURL: pathDefinicion];
                [definicionInteres setNoteContent: [meeting definicion]];
                [definicionInteres saveToURL: [definicionInteres fileURL] 
                            forSaveOperation: REGENERARESTRUCTURA ? UIDocumentSaveForOverwriting : UIDocumentSaveForCreating
                           completionHandler:^(BOOL success) {
                               
                               NSLog(@"Definición: %@ salvada: %@", pathMeeting, success ? @"correctamente" : @"incorrectamente");
                               if(success) {
                                   // Se registra el meeting en funcion de su estructura final
                                   [_meetingsPorPathDefinicion setObject: meeting forKey: [self obtenSubPath: pathDefinicion]];
                               }
                }];
                
                [definicionInteres release];
            } else {
                NSLog(@"Error en creación de directorio");
            }
        }
    }
    
    return pathMeeting;
}


- (NSArray *)  cargaDefinicionMeetings {
    
    NSMutableArray *retval = [NSMutableArray array];
    
    // Get public docs dir
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *publicDocumentsDir = [paths objectAtIndex:0];   
    
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return retval;
    }
    
    // Add all sbzs to a list    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"json" options:NSCaseInsensitiveSearch] == NSOrderedSame) {        
            NSString *fullPath = [publicDocumentsDir stringByAppendingPathComponent:file];
            [retval addObject:fullPath];
        }
    }
    
    return retval;
    
}

// TODO Revisar informacion existente para su asignacion
- (Meeting * ) generaMeetingDePOCOs: (NSDictionary *) objetoPlano {
    Meeting * salida = [[Meeting new] autorelease];
    
    id _nombreMeeting = [objetoPlano objectForKey: @"nombreMeeting"];
    if([_nombreMeeting isKindOfClass: [NSString class]]) { 
        [salida setNombreMeeting: _nombreMeeting];
    }
    NSMutableDictionary * conjuntoPersonal = [NSMutableDictionary new];
    [salida setPersonal: [self procesaPersonas: objetoPlano conIdentificadorDeConjunto: @"personas" usandoAcumulador: conjuntoPersonal yPersonaOrigen: nil]];
    [salida setConjuntoEntrevistados: conjuntoPersonal];
    
    return salida;
}

- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia conIdentificadorDeConjunto: (NSString *) identificadorConjunto usandoAcumulador: (NSMutableDictionary *) acumulador yPersonaOrigen:(id) lider {
    NSMutableArray * contenedorPersonal = [NSMutableArray new];
    
    id _personal = [objetoReferencia objectForKey: identificadorConjunto];
    if([_personal isKindOfClass: [NSArray class]]) {
        if([_personal count]) {
            
            for(id persona in _personal) {
                if( [persona isKindOfClass: [NSDictionary class]] ) {
                    Persona * personaInteres = nil;
                    BOOL agregarAcumulador = NO;
                    
                    id _tipoPersona = [persona objectForKey: @"tipo"];
                    if([_tipoPersona isKindOfClass: [NSString class]] && [_tipoPersona length] > 0) {
                        personaInteres = [NSClassFromString(_tipoPersona) new];
                    } else {
                        personaInteres = [Entrevistado new];
                        agregarAcumulador = YES;
                    }
                    
                    if(![self objeto:personaInteres ejecutaSelector: @selector(setNombre:) conArgumento: [persona objectForKey: @"nombre"] deTipo:[NSString class]]) {
                        
                        if(agregarAcumulador) {
                            [personaInteres release];
                            
                            // TODO Agregar Entrevistado basado en Referencia
                            personaInteres = [EntrevistadoRef new];
                        }
                    }
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setIdentificador:) conArgumento: [persona objectForKey: @"identificador"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setZona:) conArgumento: [persona objectForKey: @"zona"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setTelefono:) conArgumento: [persona objectForKey: @"telefono"] deTipo:[NSString class]];
                    
                    if( [personaInteres respondsToSelector: @selector(setPersonas:)] ) {
                        
                        [personaInteres performSelector: @selector(setPersonas:) withObject: [self procesaPersonas: persona conIdentificadorDeConjunto: @"personas" usandoAcumulador: acumulador yPersonaOrigen: personaInteres]];
                    }
                    
                    if ([personaInteres respondsToSelector:@selector(setEntrevistadores:)]) {
                        [personaInteres performSelector: @selector(setEntrevistadores:) withObject: [self procesaPersonas: persona conIdentificadorDeConjunto: @"entrevistadores" usandoAcumulador: acumulador yPersonaOrigen: personaInteres]];
                    }
                    
                    if ([personaInteres respondsToSelector:@selector(setJefesEntrevistadores:)]) {
                        [personaInteres performSelector: @selector(setJefesEntrevistadores:) withObject: [self procesaPersonas: persona conIdentificadorDeConjunto: @"jefesEntrevistadores" usandoAcumulador: acumulador yPersonaOrigen: personaInteres]];
                    }
                    
                    if(personaInteres) {
                        if([personaInteres isKindOfClass: [Persona class]]) {
                            [contenedorPersonal addObject: personaInteres];
                            
                            [personaInteres setLider: lider];
                            
                            // Considerar al entrevistador para los jefes de entrevistadores
                            if(agregarAcumulador) {
                                NSString * identificador = [personaInteres performSelector: @selector(identificador)];
                                if(identificador && [identificador length]) {
                                    [acumulador setObject:personaInteres forKey: identificador];
                                }
                            }
                        }
                        
                        [personaInteres release];
                    }
                }
            }
        }
    }
    
    
    return contenedorPersonal;
}

- (BOOL) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase {
    if([objeto respondsToSelector: selector] && [argumento isKindOfClass: clase]) {
        [objeto performSelector: selector withObject: argumento];
        return YES;
    }
    return NO;
}

@end
