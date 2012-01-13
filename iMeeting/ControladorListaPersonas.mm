//
//  ControladorListaPersonas.m
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ControladorListaPersonas.h"
#import "Entrevistado.h"

@implementation ControladorListaPersonas

@synthesize datos;
@synthesize tablaDatos;


-(void)dealloc
{
    self.tablaDatos =nil;
    self.datos = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
  
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
   }

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    }

- (void)viewDidUnload
{
    [super viewDidUnload];
    }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view datasource methods


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [[self datos] count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CeldaPersonas = @"Personas";
   
    UITableViewCell *celda;
         
            celda = [tableView dequeueReusableCellWithIdentifier:CeldaPersonas];
            if (celda == nil) { 
                celda = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CeldaPersonas] autorelease];
                celda.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            Entrevistado * entrevistado = [ self.datos objectAtIndex: [indexPath row]  ];
            if(entrevistado)
            {
                celda.textLabel.text =  [NSString stringWithFormat:@"%@", [entrevistado nombre]];
                celda.detailTextLabel.text = [entrevistado telefono];
            }
    
	return celda;
}


#pragma mark -
#pragma mark Table view delegate methods

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60 ;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
