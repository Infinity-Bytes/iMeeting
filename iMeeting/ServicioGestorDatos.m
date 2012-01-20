//
//  ServicioGestorDatos.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 19/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ServicioGestorDatos.h"
#import "Documento.h"

@implementation ServicioGestorDatos

@synthesize metaDataQuery;
@synthesize delegado;


- (id)init {
    self = [super init];
    if (self) {
        [self setMetaDataQuery: nil];
        [self setDelegado: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(cargaMeetings) 
                                                     name: UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
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

- (void)cargaMeetings {
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq) {
        self.metaDataQuery = [[NSMetadataQuery alloc] init];
        [self.metaDataQuery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K like 'text.txt'", NSMetadataItemFSNameKey];
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
        NSLog(@"AppDelegate: ocument not found in iCloud.");
        
        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"text.txt"];
        
        Documento *doc = [[[Documento alloc] initWithFileURL:ubiquitousPackage] autorelease];
        
        [doc saveToURL:[doc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            NSLog(@"AppDelegate: new document save to iCloud");
            [doc openWithCompletionHandler:^(BOOL success) {
                NSLog(@"AppDelegate: new document opened from iCloud");
            }];
        }];
    }
}

@end
