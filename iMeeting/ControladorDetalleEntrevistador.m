//
//  ControladorDetalleEntrevistador.m
//  iMeeting
//
//  Created by Jesus Cagide on 11/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ControladorDetalleEntrevistador.h"
#import "Meeting.h"

@implementation ControladorDetalleEntrevistador

@synthesize nombreEntrevistador;
@synthesize zona;
@synthesize tablaDatos;
@synthesize celdaDetalleGrafica;
@synthesize cellNib = _cellNib;
@synthesize colores;
@synthesize detallesDeGrafica;

@synthesize delegadoControladorNavegacion;

-(void)dealloc
{
     self.nombreEntrevistador = nil;
     self.zona = nil;
     self.tablaDatos = nil;
    
     self.celdaDetalleGrafica = nil;
     self.colores = nil;
     self.detallesDeGrafica = nil;
     self.cellNib = nil;

    [_datosEntrevistador release];
    self.delegadoControladorNavegacion = nil;
    
    [super dealloc];
}

-(void)establecerEntrevistador:(Entrevistador*)entrevistador
{
    _entrevistador = entrevistador;
    [self cargaInfo: entrevistador];
}

- (void) cargaInfo: (Entrevistador *) entrevistador {
    
    DetalleGrafica *personasEntrevistadas = [DetalleGrafica new];
    
    [personasEntrevistadas setCantidad: [NSString  stringWithFormat:@"%d", entrevistador.personasEntrevistadas.count]];
    [personasEntrevistadas setPorcentaje: (entrevistador.personasEntrevistadas.count *100 ) / entrevistador.personas.count]; 
    [personasEntrevistadas setNombreLeyenda:@"Si"];
    
    DetalleGrafica *personasNoEntrevistadas = [DetalleGrafica new];
    
    [personasNoEntrevistadas setCantidad: [NSString  stringWithFormat:@"%d", entrevistador.personasSinEntrevistar.count]];
    [personasNoEntrevistadas setPorcentaje: (entrevistador.personasSinEntrevistar.count *100 ) / entrevistador.personas.count]; 
    [personasNoEntrevistadas setNombreLeyenda:@"No"];
    
    [self setDetallesDeGrafica:[[NSArray alloc] initWithObjects:personasEntrevistadas, personasNoEntrevistadas, nil]];
    
    [personasEntrevistadas release];
    [personasNoEntrevistadas release];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.cellNib = [UINib nibWithNibName:@"CeldaDetalleGrafica" bundle:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(refrescarPantallasConEntrevistador:) name:@"refrescarPantallasConEntrevistador" object: nil];
    
    [self cargaInfo: _entrevistador];
    [super viewWillAppear:animated];
}


-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [[self tablaDatos] reloadData];
}

- (void)viewDidLoad
{    
    
    self.colores = [[NSArray alloc] initWithObjects:
                    [UIColor colorWithPatternImage: [UIImage imageNamed:@"azul.png"] ],
                [UIColor colorWithPatternImage: [UIImage imageNamed:@"naranja.png"] ],nil];
    
   
    
    _datosEntrevistador = [[NSMutableDictionary alloc] init];
    
    if([[_entrevistador telefono ] length] >0)
        [_datosEntrevistador setObject:[_entrevistador telefono ] forKey:@"Telefono"];
    
    self.nombreEntrevistador.text = [_entrevistador nombre];
    self.zona.text = [_entrevistador zona];
    
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
	return 2;
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [_datosEntrevistador count];
            break;
        case 1:
            return [[self detallesDeGrafica] count];
            break;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identificador = @"DetalleGrafica";
    static NSString * identificadorInformacion = @"Informacion";
    CeldaDetalleGrafica *celda;
    UITableViewCell *celdaInformacion;
    id key;
    switch (indexPath.section)
    {
        case 0:
            celdaInformacion = [tableView dequeueReusableCellWithIdentifier:identificadorInformacion];
            
            if (celdaInformacion == nil) 
            { 
                celdaInformacion = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identificadorInformacion] autorelease];
                celdaInformacion.selectionStyle = UITableViewCellSelectionStyleGray;
                
            }
            
            if( (key = [[_datosEntrevistador allKeys] objectAtIndex:[indexPath row] ]) )
            {
                celdaInformacion.textLabel.text = key;
                celdaInformacion.detailTextLabel.text = [_datosEntrevistador objectForKey:key];
            }
            return celdaInformacion;
        case 1:
            celda = (CeldaDetalleGrafica *)[tableView dequeueReusableCellWithIdentifier:identificador];
            
            if (celda == nil) {
                [self.cellNib instantiateWithOwner:self options:nil];
                celda = [self celdaDetalleGrafica];
                self.celdaDetalleGrafica = nil;
                celda.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            CustomCellBackgroundViewPosition pos;
            int numeroElementos = 0;
            numeroElementos = [[self detallesDeGrafica] count];
            
            pos = CustomCellBackgroundViewPositionBottom;
            
            if (indexPath.row == 0) {
                pos = CustomCellBackgroundViewPositionTop;
            } else {
                if (indexPath.row <numeroElementos-1) {
                    pos = CustomCellBackgroundViewPositionMiddle;
                }
            }
            if (numeroElementos == 1) {
                pos = CustomCellBackgroundViewPositionSingle;
            }
            [celda establecerPosicion:pos yColor: [self.colores objectAtIndex:indexPath.row]];
            [celda establecerDetalleGrafica: [[self detallesDeGrafica] objectAtIndex:[indexPath row]]];
            return celda;
    }
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 55 ;
}

#pragma mark -
#pragma mark Table view delegate methods

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"";
			break;
		case 1:
			return @"Personas a su Cargo";
			break;
	}
	return nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identificador=@"";
    if (indexPath.section ==1 )
    {
        switch (indexPath.row) 
        {
            case 0:
                identificador = @"personasEntrevistadas";
                break;
            case 1:
                identificador = @"personasSinEntrevistar";
                break;
        }
        [[self delegadoControladorNavegacion] mostrarPanelSiguienteSegunEntrevistador:_entrevistador bajoIdentificador:identificador usandoControlNavegacion:self.navigationController];
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) refrescarPantallasConEntrevistador: (NSNotification *) notification {
    Entrevistado * entrevistadoInteres = [[notification userInfo] objectForKey: @"entrevistado"];
    if([[_entrevistador personas] containsObject: entrevistadoInteres]) {
        [self cargaInfo: _entrevistador];
        [[self tablaDatos] reloadData];
    }
}

@end
