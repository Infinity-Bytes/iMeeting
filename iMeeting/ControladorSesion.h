//
//  ControladorSesion.h
//  iMeetingMX
//
//  Created by Luis Rangel on 10/02/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControladorScannner.h"

@interface ControladorSesion : UIViewController

@property(nonatomic, assign) ControladorScannner * controladorLogin;

-(IBAction)cmdCerrarSesion:(id)sender;
@end
