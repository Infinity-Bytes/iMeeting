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


- (id)init {
    self = [super init];
    if (self) {
        [self setMetaDataQuery: nil];
        [self setDelegado: nil];
    }
    return self;
}

- (void)dealloc {
    [self setMetaDataQuery: nil];
    [self setDelegado: nil];
    
    [super dealloc];
}

- (void) estableceDelegado: (id<iServicioGestorDatosDelegate>) delegadoInteres {
    [self setDelegado: delegadoInteres];
}

- (void) registraMeeting: (Meeting *) meeting conURLDocumentos: (NSURL *) urlDocumentos yURLCloud: (NSURL *) urliCloud {
    // TODO Revisar si el Meeting ya fue previamente registrado (por sus PATH) sino, registrarlo al delegado
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
    [delegado numeroDeElementosAProcesar: [query resultCount]];
    
    if([query resultCount]) {
        for (NSMetadataItem *item in [query results]) {
            
            NSURL *url = [item valueForAttribute: NSMetadataItemURLKey];
            Documento * doc = [[[Documento alloc] initWithFileURL: url] autorelease];
            
            [doc openWithCompletionHandler: ^(BOOL success) {
                if (success) {
                    [delegado procesaDocumento: doc];
                    NSLog(@"openend file from iCloud %@", doc);
                } else {
                    [delegado fallidoAccesoADocumento: doc];
                    NSLog(@"failed to open from iCloud %@", doc);
                }
            }];
        }
    } else {
        /*NSLog(@"AppDelegate: ocument not found in iCloud.");
        
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"text.txt"];
        
        Documento *doc = [[[Documento alloc] initWithFileURL:ubiquitousPackage] autorelease];
        
        [doc saveToURL:[doc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"AppDelegate: new document save to iCloud");
            [doc openWithCompletionHandler:^(BOOL success) {
                NSLog(@"AppDelegate: new document opened from iCloud");
            }];
        }];*/
    }
}

#pragma Cargado de Meetings a partir de definición dada por iTunes Shared Folder

- (void) cargaMeetingsDeiTunesFileSharing {
    // Lectura de archivos de configuración de Meetings
    NSArray * archivosDefinicionMeetings = [self cargaDefinicionMeetings];
    if( [archivosDefinicionMeetings count] > 0 ) {
        for(NSString * archivoDefinicionMeeting in archivosDefinicionMeetings) {
            NSStringEncoding encoding;
            NSError * error;
            NSString * definicionMeeting = [NSString stringWithContentsOfFile: archivoDefinicionMeeting usedEncoding:&encoding error:&error];
            id definicion = [definicionMeeting JSONValue];
            if([definicion isKindOfClass: [NSDictionary class]]) {
                Meeting * meetingInteres = [self generaMeetingDePOCOs: definicion];
                [meetingInteres setEncodingDefinicion: encoding];
                [meetingInteres setDefinicion: definicionMeeting];
                
                [self generaEstructuraDeMeeting: meetingInteres];
                
                if (!REGENERARESTRUCTURA) {
                    // TODO Borrar definicion de iTunes File Sharing
                }
            }
        }
    }
}

- (void) generaEstructuraDeMeeting: (Meeting *) meeting {
    // Buscar directorio del Meeting en Documentos
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    // Buscar directorio del Meeting en iCloud
    NSURL * urlDocumentos = [[NSURL alloc] initFileURLWithPath: [paths objectAtIndex: 0]  isDirectory: YES];
    NSURL * ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    NSURL * urlDocumentosMeeting = [self cargaDirectorioMeeting: meeting enURL: urlDocumentos];
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
                NSString * nombreDirectorioTrabajado = PATRONARCHIVOS(@"trabajado");
                NSString * nombreDirectorioPendiente = PATRONARCHIVOS(@"pendiente");
                
                [fileManager createDirectoryAtURL:[pathMeeting URLByAppendingPathComponent: nombreDirectorioTrabajado] 
                       withIntermediateDirectories:YES attributes:nil error: &error];
                [fileManager createDirectoryAtURL:[pathMeeting URLByAppendingPathComponent: nombreDirectorioPendiente] 
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
