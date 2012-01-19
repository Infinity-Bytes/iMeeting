//
//  ServicioGestorDatos.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 19/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iServicioGestorDatos.h"

@interface ServicioGestorDatos : NSObject <iServicioGestorDatos>

- (void)cargaMeetings;
- (void)queryDidFinishGathering:(NSNotification *)notification;
- (void)loadData:(NSMetadataQuery *)query;

@property (nonatomic, retain) NSMetadataQuery * metaDataQuery;
@property (nonatomic, retain) NSMutableArray * entrevistados;

@end
