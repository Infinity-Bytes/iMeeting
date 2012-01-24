//
//  Meeting.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meeting : NSObject

@property(nonatomic, retain) NSString * nombreMeeting;
@property(nonatomic, retain) NSArray * personal;
@property(nonatomic, retain) NSDictionary * conjuntoPersonas;

@property(nonatomic, retain) NSString * directorioDocumentosMeeting;
@property(nonatomic, retain) NSString * definicion;
@property(nonatomic, assign) NSStringEncoding encodingDefinicion;

@end
