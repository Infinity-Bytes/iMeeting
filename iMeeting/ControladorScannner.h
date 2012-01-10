//
//  ControladorScannner.h
//  iMeeting
//
//  Created by Jesus Cagide on 10/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXingWidgetController.h"

@interface ControladorScannner : UIViewController <ZXingDelegate> 

@property (nonatomic, assign) IBOutlet UITextField *Tbtexto;

- (IBAction)cmdScanner:(id)sender;


#pragma mark -
#pragma mark ZXingDelegateMethods

- (void)zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result;

- (void)zxingControllerDidCancel:(ZXingWidgetController*)controller;

@end
