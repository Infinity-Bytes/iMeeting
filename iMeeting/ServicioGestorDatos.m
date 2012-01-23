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

#define REGENERARESTRUCTURA YES
#define PATRONARCHIVOS(x) [NSString stringWithFormat:@"__%@", x]

@implementation ServicioGestorDatos

@synthesize metaDataQuery;
@synthesize delegado;
@synthesize urlDocumentos;


- (id)init {
    self = [super init];
    if (self) {
        [self setMetaDataQuery: nil];
        [self setDelegado: nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self setUrlDocumentos: [[NSURL alloc] initFileURLWithPath: [paths objectAtIndex: 0]  isDirectory: YES]];
    }
    return self;
}

- (void)dealloc {
    [self setMetaDataQuery: nil];
    [self setDelegado: nil];
    [self setUrlDocumentos: nil];
    
    [super dealloc];
}

- (void) estableceDelegado: (id<iServicioGestorDatosDelegate>) delegadoInteres {
    [self setDelegado: delegadoInteres];
}

- (void) registraMeeting: (Meeting *) meeting conURLDocumentos: (NSURL *) urlMeetingDocumentos yURLCloud: (NSURL *) urlMeetingiCloud {
    // TODO Revisar si el Meeting ya fue previamente registrado (por sus PATH) sino, registrarlo al delegado
    NSLog(@"RegistraMeeting: %@ conURLDocumentos: %@ yURLCloud: %@", [meeting nombreMeeting], urlMeetingDocumentos, urlMeetingiCloud);
}

- (void) registraElementoTrabajado: (NSURL *) urlElementoTrabajado {
    // TODO Registrar elemento al delegado
    // TODO Crear archivo si se requiere ya sea en pendientes o en trabajado si se tiene o no acceso a iCloud
    NSLog(@"RegistraElementoTrabajado: %@", urlElementoTrabajado);
}

- (Meeting *) obtenMeetingDeURL: (NSURL*) urlArchivo {
    Meeting * meetingInteres = nil;
    NSStringEncoding encoding;
    NSError * error;
    NSString * definicionMeeting = [NSString stringWithContentsOfURL: urlArchivo usedEncoding:&encoding error:&error];
    id definicion = [definicionMeeting JSONValue];
    if([definicion isKindOfClass: [NSDictionary class]]) {
        meetingInteres = [self generaMeetingDePOCOs: definicion];
        [meetingInteres setEncodingDefinicion: encoding];
        [meetingInteres setDefinicion: definicionMeeting];
    }
    return meetingInteres;
}

- (void)cargaMeetingsDeDocumentos {
    NSString * nombreArchivoDefinicion = PATRONARCHIVOS(@"Definicion.json");
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray * elementosEnDocumentos = [defaultManager contentsOfDirectoryAtURL: [self urlDocumentos] 
                  includingPropertiesForKeys:[NSArray array] 
                                     options:0 
                                       error:&error];
    for (NSURL *url in elementosEnDocumentos) {
        NSString * extension = [url pathExtension];
        if([extension isEqualToString: @"meeting"]) {
            NSURL * urlDefinicion = [url URLByAppendingPathComponent: nombreArchivoDefinicion isDirectory: NO];
            BOOL directorio;
            if([defaultManager fileExistsAtPath: [urlDefinicion path] isDirectory: &directorio]) {
                if(!directorio) {
                    Meeting * meeting = [self obtenMeetingDeURL: urlDefinicion];
                    if(meeting) {
                        [self registraMeeting: meeting conURLDocumentos: url yURLCloud: nil];
                        
                        // Registrar elementos ya trabajados
                        NSURL * urlTrabajado = [url URLByAppendingPathComponent: @"trabajado"];
                        if([defaultManager fileExistsAtPath: [urlTrabajado path] isDirectory: &directorio]) {
                            if(directorio) {
                                NSArray * elementosTrabajados = [defaultManager contentsOfDirectoryAtURL: urlTrabajado
                                                                                includingPropertiesForKeys:[NSArray array] 
                                                                                                   options:0 
                                                                                                     error:&error];
                                for(NSURL * urlElementoTrabajado in elementosTrabajados) {
                                    [self registraElementoTrabajado: urlElementoTrabajado];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#pragma Cargado de archivos de iCloud

- (void)cargaMeetingsDeiCloud {
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSString * documentoDefinicion = PATRONARCHIVOS(@"");
    if (ubiq) {
        self.metaDataQuery = [[NSMetadataQuery alloc] init];
        [self.metaDataQuery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        NSString * sentenciaPredicate = [@"%K " stringByAppendingString: [NSString stringWithFormat:@" like '%@*'", documentoDefinicion]];
        NSPredicate *pred = [NSPredicate predicateWithFormat: sentenciaPredicate, NSMetadataItemFSNameKey];
        [self.metaDataQuery setPredicate:pred];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(queryDidFinishGathering:) 
                                                     name:NSMetadataQueryDidFinishGatheringNotification 
                                                   object:self.metaDataQuery];
        
        [self.metaDataQuery startQuery];
        
        // TODO Enviar pendientes como trabajados a iCloud
        
    } else {
        // TODO Revisar comportamiento al no haber acceso a iCloud
        NSLog(@"No iCloud access");
    }
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [self loadData:query];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    
    self.metaDataQuery = nil;
}

- (void)loadData:(NSMetadataQuery *)query {
    
    if([query resultCount]) {
        NSURL * ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL * urlDocUbiq = [ubiq URLByAppendingPathComponent: @"Documents"];
        
        for (NSMetadataItem *item in [query results]) {
            
            NSURL *url = [item valueForAttribute: NSMetadataItemURLKey];
            Documento * doc = [[[Documento alloc] initWithFileURL: url] autorelease];
            
            if([[url path] hasPrefix: [urlDocUbiq path]]) {
                NSString * subPath = [[url path] substringFromIndex: [[urlDocUbiq path] length] + 1];
                
                [doc openWithCompletionHandler: ^(BOOL success) {
                    [self procesaDocumento: doc conPathRelativo: subPath legible: success];
                }];
            }
        }
    }
}


- (void) procesaDocumento: (Documento *) doc conPathRelativo: (NSString *) subPath legible: (BOOL) legible {
    // Almacenar en Documentos usando el path relativo
    NSURL * urlArchivoEnDocumentos = [[self urlDocumentos] URLByAppendingPathComponent: subPath];
    
    if (legible) {
        NSLog(@"openend file from iCloud %@", doc);
        
        NSURL * urlDirectorioPadreEnDocumentos = [urlArchivoEnDocumentos URLByDeletingLastPathComponent];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError * error;
        if ([fileManager createDirectoryAtURL: urlDirectorioPadreEnDocumentos
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            Documento * docEnDocumentos = [[Documento alloc] initWithFileURL: urlArchivoEnDocumentos];
            [docEnDocumentos setNoteContent: [doc noteContent]];
            [docEnDocumentos saveToURL:[docEnDocumentos fileURL] 
                      forSaveOperation:REGENERARESTRUCTURA ? UIDocumentSaveForOverwriting : UIDocumentSaveForCreating 
                     completionHandler:^(BOOL success) {
                         NSLog(@"Archivo de iCloud almacenado en Documentos: %@", docEnDocumentos);
                         
                         // Registrar Meeting
                         NSString * nombreArchivoDefinicion = PATRONARCHIVOS(@"Definicion.json");
                         if ([[urlArchivoEnDocumentos lastPathComponent] isEqualToString: nombreArchivoDefinicion]) {
                             NSURL * urlDefinicionMeetingEnICloud = [[doc fileURL] URLByDeletingLastPathComponent];
                             
                             Meeting * meeting = [self obtenMeetingDeURL: [doc fileURL]];
                             [self registraMeeting: meeting conURLDocumentos: urlDirectorioPadreEnDocumentos yURLCloud: urlDefinicionMeetingEnICloud];
                         }
                         
                         // Registrar Elementos trabajados
                         if([[urlDirectorioPadreEnDocumentos lastPathComponent] isEqualToString: @"trabajado"]) {
                             [self registraElementoTrabajado: [docEnDocumentos fileURL]];
                         }
                     }];
            [docEnDocumentos release];
        }
    } else {
        NSLog(@"failed to open from iCloud %@", doc);
    }
}

#pragma Cargado de Meetings a partir de definición dada por iTunes Shared Folder

- (void) cargaMeetingsDeiTunesFileSharing {
    // Lectura de archivos de configuración de Meetings
    NSArray * archivosDefinicionMeetings = [self cargaDefinicionMeetings];
    if( [archivosDefinicionMeetings count] > 0 ) {
        for(NSString * archivoDefinicionMeeting in archivosDefinicionMeetings) {
            NSURL * urlArchivo = [[NSURL alloc] initFileURLWithPath: archivoDefinicionMeeting isDirectory: FALSE];
            Meeting * meetingInteres = [self obtenMeetingDeURL: urlArchivo];
            if(meetingInteres) {
                [self generaEstructuraDeMeeting: meetingInteres];
                
                if (!REGENERARESTRUCTURA) {
                    // TODO Borrar definicion de iTunes File Sharing
                }
            }
        }
    }
}

- (void) generaEstructuraDeMeeting: (Meeting *) meeting {
    
    NSURL * ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    NSURL * urlDocumentosMeeting = [self cargaDirectorioMeeting: meeting enURL: [self urlDocumentos]];
    NSURL * urlCloudMeeting = [self cargaDirectorioMeeting: meeting enURL: [ubiq URLByAppendingPathComponent: @"Documents"]];
    
    [self registraMeeting: meeting conURLDocumentos: urlDocumentosMeeting yURLCloud: urlCloudMeeting];
}

- (id) cargaDirectorioMeeting: (Meeting *) meeting enURL: (NSURL *) urlInteres {
	id pathMeeting = nil;
    NSError *error = nil;
    
    if(urlInteres) {
        NSString * pathMeetingBase = [NSString stringWithFormat: @"%@.meeting", [meeting nombreMeeting]];
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
                
                NSString * nombreDefinicion = PATRONARCHIVOS(@"Definicion.json");
                
                [fileManager createDirectoryAtURL:[pathMeeting URLByAppendingPathComponent: @"trabajado"] 
                       withIntermediateDirectories:YES attributes:nil error: &error];
                [fileManager createDirectoryAtURL:[pathMeeting URLByAppendingPathComponent: @"pendiente"] 
                       withIntermediateDirectories:YES attributes:nil error: &error];
                
                NSURL * pathDefinicion = [pathMeeting URLByAppendingPathComponent: nombreDefinicion  isDirectory: NO];
                Documento * definicionInteres = [[Documento alloc] initWithFileURL: pathDefinicion];
                [definicionInteres setNoteContent: [meeting definicion]];
                [definicionInteres saveToURL: [definicionInteres fileURL] 
                            forSaveOperation: REGENERARESTRUCTURA ? UIDocumentSaveForOverwriting : UIDocumentSaveForCreating
                           completionHandler:^(BOOL success) {
                               
                               NSLog(@"Definicion: %@ salvada: %@", pathMeeting, success ? @"correctamente" : @"incorrectamente");
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

- (Meeting * ) generaMeetingDePOCOs: (NSDictionary *) objetoPlano {
    Meeting * salida = [[Meeting new] autorelease];
    
    id _nombreMeeting = [objetoPlano objectForKey: @"nombreMeeting"];
    if([_nombreMeeting isKindOfClass: [NSString class]]) { 
        [salida setNombreMeeting: _nombreMeeting];
    }
    NSMutableDictionary * conjuntoPersonal = [NSMutableDictionary new];
    [salida setPersonal: [self procesaPersonas: objetoPlano usandoAcumulador: conjuntoPersonal]];
    [salida setConjuntoPersonas: conjuntoPersonal];
    
    return salida;
}

- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia usandoAcumulador: (NSMutableDictionary *) acumulador {
    NSMutableArray * contenedorPersonal = [NSMutableArray new];
    
    id _personal = [objetoReferencia objectForKey:@"personas"];
    if([_personal isKindOfClass: [NSArray class]]) {
        if([_personal count]) {
            
            for(id persona in _personal) {
                if( [persona isKindOfClass: [NSDictionary class]] ) {
                    Persona * personaInteres = nil;
                    
                    id _tipoPersona = [persona objectForKey: @"tipo"];
                    if([_tipoPersona isKindOfClass: [NSString class]] && [_tipoPersona length] > 0) {
                        personaInteres = [NSClassFromString(_tipoPersona) new];
                    } else {
                        personaInteres = [Entrevistado new];
                    }
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setIdentificador:) conArgumento: [persona objectForKey: @"identificador"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setNombre:) conArgumento: [persona objectForKey: @"nombre"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setZona:) conArgumento: [persona objectForKey: @"zona"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setTelefono:) conArgumento: [persona objectForKey: @"telefono"] deTipo:[NSString class]];
                    
                    if( [personaInteres respondsToSelector: @selector(setPersonas:)] ) {
                        
                        [personaInteres performSelector: @selector(setPersonas:) withObject: [self procesaPersonas: persona usandoAcumulador: acumulador]];
                    }
                    
                    if(personaInteres) {
                        if([personaInteres isKindOfClass: [Persona class]]) {
                            [contenedorPersonal addObject: personaInteres];
                            
                            NSString * identificador = [personaInteres performSelector: @selector(identificador)];
                            if(identificador && [identificador length]) {
                                [acumulador setObject:personaInteres forKey: identificador];
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

- (void) objeto: (id) objeto ejecutaSelector: (SEL) selector conArgumento: (id) argumento deTipo: (Class) clase {
    if([objeto respondsToSelector: selector] && [argumento isKindOfClass: clase]) {
        [objeto performSelector: selector withObject: argumento];
    }
}

@end
