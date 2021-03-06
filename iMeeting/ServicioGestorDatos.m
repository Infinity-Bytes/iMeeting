//
//  ServicioGestorDatos.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 19/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "SBJson.h"
#import "ZipFile.h"

#import "ServicioGestorDatos.h"
#import "Documento.h"

#import "Persona.h"
#import "Entrevistado.h"
#import "ProxyRefEntrevistado.h"
#import "JefeEntrevistadoresOtro.h"

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
#define STRINGSEPARACIONELEMENTOTRABAJADO @"~"

#pragma Implementación ServicioGestorDatos

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
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
        
        enviarPendientes = NO;
        recolectaInfo = NO;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self setUrlDocumentos: [[[NSURL alloc] initFileURLWithPath: [paths objectAtIndex: 0]  isDirectory: YES] autorelease]];
        
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(procesaElementoTrabajado:) 
                                                     name: @"registraElementoTrabajado" 
                                                   object: nil];

        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(especificadoPermiso:) 
                                                     name: @"especificadoPermiso" 
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
    [_dateFormatter release]; _dateFormatter = nil;
    
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
        NSDate *now = [[NSDate new] autorelease];
        NSString *dateString = [_dateFormatter stringFromDate:now];
        
        // Generacion de fichero correspondiente
        // TODO Evitar elemento deprecated de identificador de dispositivo
        NSError * error;
        NSURL * urlPendientesLocal = [[meeting urlLocal] URLByAppendingPathComponent: DIRECTORIOPENDIENTE isDirectory: YES]; 
        NSString * nombreElementoTrabajado = [NSString stringWithFormat:@"%@%@%@", [entrevistado identificador], STRINGSEPARACIONELEMENTOTRABAJADO, [[UIDevice currentDevice] uniqueIdentifier]];
        NSURL * urlLocal = [ urlPendientesLocal URLByAppendingPathComponent: PATRONARCHIVOS(nombreElementoTrabajado) isDirectory: NO];
        
        if([[NSFileManager defaultManager] createDirectoryAtURL: urlPendientesLocal 
                 withIntermediateDirectories:YES attributes:nil error: &error]) {
            
            Documento * documentoAlmacenar = [[Documento alloc] initWithFileURL: urlLocal];
            [documentoAlmacenar setNoteContent: dateString];
            [documentoAlmacenar saveToURL: [documentoAlmacenar fileURL] 
                         forSaveOperation: REGENERARESTRUCTURA ? UIDocumentSaveForOverwriting : UIDocumentSaveForCreating
                        completionHandler:^(BOOL success) {
                            NSLog(@"Elemento %@ pendiente publicado: %@", [documentoAlmacenar fileURL], success ? @"correctamente" : @"incorrectamente");
                            
                            NSString * subPathElementoTrabajado = [self obtenSubPath: urlLocal];
                            subPathElementoTrabajado = [subPathElementoTrabajado stringByReplacingOccurrencesOfString: DIRECTORIOPENDIENTE withString: DIRECTORIOTRABAJADO];
                            [_elementoTrabajadoPorPath addObject: subPathElementoTrabajado];
                        }];
            
            [documentoAlmacenar release];
        } else {
            NSLog(@"Error en generación de directorio pendiente %@, procesaElementoTrabajado:", error);
        }
    }
}

- (void) especificadoPermiso: (NSNotification *) theNotification {
    recolectaInfo = NO;
    NSNumber * number = [[theNotification userInfo] objectForKey: @"tipo"];
    if([number intValue] == 1)
        recolectaInfo = YES;
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


// TODO Revisar no descargar archivos que esten de manera local

- (void) registraElementoTrabajadoPorURL: (NSURL *) urlElementoTrabajado {

    // Obtener elementos publicados por URL de manera singleton (evitar trabajo por cada llamada de iCloud)
    NSString * subPathElementoTrabajado = [self obtenSubPath: urlElementoTrabajado];
    subPathElementoTrabajado = [subPathElementoTrabajado stringByReplacingOccurrencesOfString: DIRECTORIOPENDIENTE withString: DIRECTORIOTRABAJADO];
    
    if(![_elementoTrabajadoPorPath containsObject: subPathElementoTrabajado]) {
        [_elementoTrabajadoPorPath addObject: subPathElementoTrabajado];
        
        // Registrar elemento trabajado para Meeting específico
        NSString * elementoTrabajado = SINPATRONARCHIVOS([urlElementoTrabajado lastPathComponent]);
        
        // Obtener el nombre base del archivo
        elementoTrabajado = [[elementoTrabajado componentsSeparatedByString: STRINGSEPARACIONELEMENTOTRABAJADO] objectAtIndex: 0];
        
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
        NSError * error = nil;
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
                NSString * subPathDefinicion = [@"/" stringByAppendingString:[self obtenSubPath: urlElementoTrabajado]];
                [_archivoGestionadoPorPath addObject: subPathDefinicion];
                
                if(![[urlElementoTrabajado lastPathComponent] hasPrefix: @".zip"]) {
                    [self registraElementoTrabajadoPorURL: urlElementoTrabajado];
                }
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
                    NSString * subPathDefinicion = [@"/" stringByAppendingString:[self obtenSubPath: urlDefinicion]];
                    [_archivoGestionadoPorPath addObject: subPathDefinicion];
                        
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
            NSURL * urlTrabajado = [url URLByAppendingPathComponent: DIRECTORIOTRABAJADO isDirectory: YES];
            
            BOOL directorio;
            if([defaultManager fileExistsAtPath: [urlPendientes path] isDirectory: &directorio]) {
                if(directorio) {
                    NSArray * elementosEnPendientes = [defaultManager contentsOfDirectoryAtURL: urlPendientes 
                                                                    includingPropertiesForKeys:[NSArray array] 
                                                                                       options:0 
                                                                                         error:&error];
                    if ([elementosEnPendientes count]) {
                        
                        // Comprimir elementos trabajados y enviar empaquetado a la nube
                        NSStringEncoding encoding;
                        NSError * error;
                        
                        NSDate *now = [[NSDate new] autorelease];
                        NSString *dateString = [_dateFormatter stringFromDate:now];
                        
                        NSString * nombreArchivo = [NSString stringWithFormat: @"%@.zip", dateString];
                        NSURL * urlArchivoZip = [urlTrabajado URLByAppendingPathComponent: nombreArchivo isDirectory: NO];
                        
                        NSError * errorInteres;
                        if([defaultManager createDirectoryAtURL:urlTrabajado withIntermediateDirectories: YES attributes: nil  error: &errorInteres]) {
                        
                            ZipFile * zipFile = [[ZipFile alloc] initWithFileName: [urlArchivoZip path] mode: ZipFileModeCreate];
                            
                            
                            
                            for(NSURL * urlElementoEnDocumentosPendientes in elementosEnPendientes) {
                                
                                ZipWriteStream * stream = [zipFile writeFileInZipWithName: [urlElementoEnDocumentosPendientes lastPathComponent] 
                                                                                 fileDate: [NSDate dateWithTimeIntervalSinceNow:-86400.0] 
                                                                         compressionLevel: ZipCompressionLevelBest];
                                
                                
                                NSString * text = [NSString stringWithContentsOfURL:urlElementoEnDocumentosPendientes usedEncoding:&encoding error:&error];
                                [stream writeData: [text dataUsingEncoding: encoding]];
                                [stream finishedWriting];
                            }
                            
                            [zipFile close];
                            [zipFile release];
                            
                            // Generar Path de Pendientes a Trabajados y para iCloud
                            NSString * subPath = [[self obtenSubPath: [urlArchivoZip URLByDeletingLastPathComponent]] 
                                                  stringByReplacingOccurrencesOfString: DIRECTORIOPENDIENTE withString: DIRECTORIOTRABAJADO];
                            NSString * localPath = [urlArchivoZip path];
                            NSString * filename = [urlArchivoZip lastPathComponent];
                            NSString * destDir = [@"/" stringByAppendingString: subPath];
                            
                            [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
                        } else {
                            NSLog(@"Error en creacion de directorio trabajado para depositar Zip con error: %@", errorInteres);
                        }
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
                NSLog( @"Metadata archivo: %@", [file path]);
                
                if(![_archivoGestionadoPorPath containsObject: file.path]) {
                    NSURL * urlArchivoDocumentos = [self.urlDocumentos URLByAppendingPathComponent: [file.path substringFromIndex: 1]];
                    
                    
                    if([[NSFileManager defaultManager] createDirectoryAtURL:  [urlArchivoDocumentos URLByDeletingLastPathComponent]
                                                withIntermediateDirectories: YES
                                                                 attributes: nil
                                                                      error: &error]) {
                        
                        if(recolectaInfo 
                           || [[[file path] lastPathComponent] isEqualToString: ARCHIVODEFINICIONMEETING]) {

                            NSLog(@"Solicitando descarga: %@", file.path);
                            
                            [_archivoGestionadoPorPath addObject: file.path];
                            [_revisionPorPath setObject:file.rev forKey: file.path];                            
                            
                            [[self restClient] loadFile: file.path intoPath: [urlArchivoDocumentos path]];
                        }
                    } else {
                        NSLog( @"No es posible crear el directorio local para almacenar elemento en la nube: %@ con error: %@", [urlArchivoDocumentos URLByDeletingLastPathComponent], error);
                    }
                }
            } else {
                [client loadMetadata: [file path]];
            }
        }
    }
    
    enviarPendientes = TRUE;
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
        
        if([[urlArchivoEnDocumentos lastPathComponent] hasSuffix:@".zip"]) {
            ZipFile * zipFile = [[ZipFile alloc] initWithFileName: [urlArchivoEnDocumentos path] mode: ZipFileModeUnzip];
            
            for(FileInZipInfo * zipInfo in [zipFile listFileInZipInfos]) {
                // Registrar cada elemento obtenido en el archivo compreso
                NSURL * urlElementoTrabajado = [urlDirectorioPadreEnDocumentos URLByAppendingPathComponent:[zipInfo name] isDirectory: NO];
                
                if([zipFile locateFileInZip: [zipInfo name]]) {
                    ZipReadStream * readStream = [zipFile readCurrentFileInZip];
                    NSData * data = [readStream readDataOfLength: [zipInfo length]];
                    [readStream finishedReading];
                    
                    [data writeToURL: urlElementoTrabajado atomically: YES];
                    [self registraElementoTrabajadoPorURL: urlElementoTrabajado];
                }
            }
            
            [zipFile close];
            [zipFile release];
        }
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
        // Borrar elementos pendientes para evitar envio multiple
        if([[urlElementoOrigen lastPathComponent] hasSuffix: @".zip"]) {
            NSURL * urlPendientes = [[[urlElementoOrigen URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByAppendingPathComponent:DIRECTORIOPENDIENTE isDirectory: NO];
            NSURL * urlTrabajados = [[[urlElementoOrigen URLByDeletingLastPathComponent] URLByDeletingLastPathComponent] URLByAppendingPathComponent:DIRECTORIOTRABAJADO isDirectory: NO];
            
            ZipFile * zipFile= [[ZipFile alloc] initWithFileName: [urlElementoOrigen path] mode:ZipFileModeUnzip];
            for (FileInZipInfo * zipInfo in [zipFile listFileInZipInfos]) {

                NSURL * urlElementoEliminar = [urlPendientes URLByAppendingPathComponent: [zipInfo name] isDirectory: NO];
                NSURL * urlElementoTrabajado = [urlTrabajados URLByAppendingPathComponent: [zipInfo name] isDirectory: NO];
                
                NSError * error;
                
                if(![[NSFileManager defaultManager] moveItemAtURL:urlElementoEliminar toURL:urlElementoTrabajado error: &error]) {
                    NSLog(@"Error en mover de archivo: %@ pendiente a trabajado con error: %@", urlElementoEliminar, error);
                }
            }
            
            [zipFile close];
            [zipFile release];
        } else {
            // Borrar elemento en pendiente
            NSError * error;
            if(![[NSFileManager defaultManager] removeItemAtURL: urlElementoOrigen error: &error]) {
                NSLog(@"Borrando %@ elemento trabajado pendiente incorrectamente, con error: %@", srcPath, error);
            }
        }
    }
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)errorUpload {
    NSLog(@"File upload failed with error - %@", errorUpload);
    NSString * sourcePath = [[errorUpload userInfo] objectForKey:@"sourcePath"];
    if(sourcePath) {
        NSURL * urlElementoOrigen = [[[NSURL alloc] initFileURLWithPath:sourcePath isDirectory: NO] autorelease];
        
        if(![[urlElementoOrigen lastPathComponent] isEqualToString: ARCHIVODEFINICIONMEETING]) {
            NSError * error;
            if(![[NSFileManager defaultManager] removeItemAtURL: urlElementoOrigen error: &error]) {
                NSLog(@"Error en eliminacion de archivo %@ fallido de envio: %@", urlElementoOrigen, error);
            }
        }
    }
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
                [self generaEstructuraDeMeeting: meetingInteres conURLOrigen: urlArchivo];
                
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

- (void) generaEstructuraDeMeeting: (Meeting *) meeting conURLOrigen: (NSURL *) urlOrigen {
    NSURL * urlDocumentosMeeting = [self cargaDirectorioMeeting: meeting enURL: [self urlDocumentos] yURLOrigen: urlOrigen];
    [self registraMeeting: meeting conURLDocumentos: urlDocumentosMeeting yURLCloud: nil];
}

- (id) cargaDirectorioMeeting: (Meeting *) meeting enURL: (NSURL *) urlInteres yURLOrigen: (NSURL *) urlOrigen {
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
                
                NSError * error = nil;
                NSURL * pathDefinicion = [pathMeeting URLByAppendingPathComponent: ARCHIVODEFINICIONMEETING  isDirectory: NO];
                
                if([[NSFileManager defaultManager] copyItemAtURL: urlOrigen toURL: pathDefinicion error:&error ]) {
                    [_meetingsPorPathDefinicion setObject: meeting forKey: [self obtenSubPath: pathDefinicion]];
                }
                
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
    
    [self objeto:salida ejecutaSelector: @selector(setNombreMeeting:) 
                           conArgumento: [objetoPlano objectForKey: @"nombreMeeting"] 
                                 deTipo:[NSString class]];
    
    NSMutableDictionary * conjuntoEntrevistados = [NSMutableDictionary new];
    NSMutableDictionary * conjuntoEntrevistadores = [NSMutableDictionary new];
    
    [salida setPersonal: [self procesaPersonas: objetoPlano 
                    conIdentificadorDeConjunto: @"personas" 
                 usandoAcumuladorEntrevistados: conjuntoEntrevistados 
                     acumuladorEntrevistadores: conjuntoEntrevistadores
                                yPersonaOrigen: nil]];
    
    [salida setConjuntoEntrevistados: conjuntoEntrevistados];
    [salida setConjuntoEntrevistadores: conjuntoEntrevistadores];
    
    [conjuntoEntrevistados release];
    [conjuntoEntrevistadores release];
    
    return salida;
}

- (NSArray *) procesaPersonas: (NSDictionary *) objetoReferencia 
   conIdentificadorDeConjunto: (NSString *) identificadorConjunto 
             usandoAcumuladorEntrevistados: (NSMutableDictionary *) acumulador 
    acumuladorEntrevistadores: (NSMutableDictionary *) acumuladorEntrevistadores
               yPersonaOrigen:(id) lider {
    
    NSMutableArray * contenedorPersonal = [NSMutableArray new];
    
    id _personal = [objetoReferencia objectForKey: identificadorConjunto];
    if([_personal isKindOfClass: [NSArray class]]) {
        if([_personal count]) {
            
            for(id persona in _personal) {
                if( [persona isKindOfClass: [NSDictionary class]] ) {
                    Persona * personaInteres = nil;
                    
                    id _tipoPersona = [persona objectForKey: @"tipo"];
                    if([_tipoPersona isKindOfClass: [NSString class]] && [_tipoPersona length] > 0) {
                        personaInteres = [NSClassFromString(_tipoPersona) new];
                    } else {
                        Entrevistado * entrevistado = [Entrevistado new];
                        [entrevistado setEntrevistable: YES];
                        personaInteres = entrevistado;
                    }
                    
                    if(![self objeto:personaInteres ejecutaSelector: @selector(setNombre:) conArgumento: [persona objectForKey: @"nombre"] deTipo:[NSString class]]) {
                        
                        if([personaInteres isMemberOfClass:[Entrevistado class]]) {
                            [personaInteres release];
                            
                            // Agregar Entrevistado basado en Referencia
                            ProxyRefEntrevistado * entrevistadorRef = [ProxyRefEntrevistado new];
                            [entrevistadorRef setConjuntoEntrevistadores: acumuladorEntrevistadores];
                            personaInteres = entrevistadorRef;
                        }
                    }
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setIdentificador:) conArgumento: [persona objectForKey: @"identificador"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setZona:) conArgumento: [persona objectForKey: @"zona"] deTipo:[NSString class]];
                    
                    [self objeto:personaInteres ejecutaSelector: @selector(setTelefono:) conArgumento: [persona objectForKey: @"telefono"] deTipo:[NSString class]];
                    
                    if( [personaInteres respondsToSelector: @selector(setPersonas:)] ) {
                        
                        [personaInteres performSelector: @selector(setPersonas:) withObject: [self procesaPersonas: persona conIdentificadorDeConjunto: @"personas" usandoAcumuladorEntrevistados: acumulador
                                                                                         acumuladorEntrevistadores: acumuladorEntrevistadores yPersonaOrigen: personaInteres]];
                    }
                    
                    if ([personaInteres respondsToSelector:@selector(setEntrevistadores:)]) {
                        [personaInteres performSelector: @selector(setEntrevistadores:) withObject: [self procesaPersonas: persona conIdentificadorDeConjunto: @"entrevistadores" usandoAcumuladorEntrevistados: acumulador
                                                                                                acumuladorEntrevistadores: acumuladorEntrevistadores yPersonaOrigen: personaInteres]];
                    }
                    
                    if ([personaInteres respondsToSelector:@selector(setJefesEntrevistadores:)]) {
                        [personaInteres performSelector: @selector(setJefesEntrevistadores:) withObject: [self procesaPersonas: persona conIdentificadorDeConjunto: @"jefesEntrevistadores" usandoAcumuladorEntrevistados: acumulador
                                                                                                     acumuladorEntrevistadores: acumuladorEntrevistadores  yPersonaOrigen: personaInteres]];
                    }
                    
                    
                    if(personaInteres) {
                        if([personaInteres isKindOfClass: [Persona class]]) {
                            [contenedorPersonal addObject: personaInteres];
                            
                            [personaInteres setLider: lider];
                            
                            // Considerar al entrevistador para los jefes de entrevistadores
                            NSString * identificador = [personaInteres performSelector: @selector(identificador)];
                            if(identificador && [identificador length]) {
                                
                                if([personaInteres respondsToSelector: @selector(entrevistable)] 
                                   && [personaInteres performSelector: @selector(entrevistable)]) {
                                    [acumulador setObject:personaInteres forKey: identificador];
                                }
                                
                                if ([personaInteres isKindOfClass: [Entrevistador class]]) {
                                    [acumuladorEntrevistadores setObject: personaInteres forKey: identificador];
                                }
                            }
                        }
                        
                        
                        // Calculo de numero de personas a cargo de cada líder
                        if(lider) {
                            Entrevistador * liderEntrevistador = lider;
                            
                            int numeroPersonas = 1;
                            if([personaInteres isKindOfClass:[Entrevistador class]]) {
                                Entrevistador * entrevistadorInteres = (Entrevistador *)personaInteres;
                                numeroPersonas = [entrevistadorInteres numeroPersonasASuCargo];
                            } else {
                                if([personaInteres isKindOfClass: [Entrevistado class]]) {
                                    [[liderEntrevistador personasSinEntrevistar] addObject: personaInteres];
                                }
                            }
                            
                            [liderEntrevistador setNumeroPersonasASuCargo: [liderEntrevistador numeroPersonasASuCargo] +  numeroPersonas];
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
