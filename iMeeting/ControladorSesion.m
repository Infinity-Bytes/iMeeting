//
//  ControladorSesion.m
//  iMeetingMX
//
//  Created by Luis Rangel on 10/02/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ControladorSesion.h"


@implementation ControladorSesion

@synthesize controladorLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)cmdCerrarSesion:(id)sender
{
    [[self controladorLogin] setEsCapturador:false];
    [[[self controladorLogin] navigationController] popToRootViewControllerAnimated:YES];
}

@end
