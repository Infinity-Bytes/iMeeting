//
//  ServicioBusqueda.h
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 13/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iServicioBusqueda.h"

@interface ServicioBusqueda : NSObject <iServicioBusqueda>
{
    NSDictionary * _personalMeeting;
}

@end
