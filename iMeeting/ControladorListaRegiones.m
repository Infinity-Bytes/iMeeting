//
//  ControladorPlantasTratadoras.m
//  INAGUAPP
//
//  Created by Jesus Cagide on 07/12/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>
#import "ControladorListaRegiones.h"
#import "Entrevistador.h"


@implementation ControladorListaRegiones

@synthesize tablaDatos = _tablaDatos;
@synthesize celda = _celda;
@synthesize cellNib = _cellNib;
@synthesize encargadosPorRegion = _encargadosPorRegion;

@synthesize identificador;

@synthesize delegadoControladorNavegacion;

-(void)dealloc
{
    [_tablaDatos release];
    [_celda release];
    [_cellNib release];
    [_encargadosPorRegion release];
    
    self.identificador=nil;

    self.delegadoControladorNavegacion = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.encargadosPorRegion = nil;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(refrescarPantallas:) name:@"refrescarPantallas" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(refrescarPantallasConEntrevistador:) name:@"refrescarPantallasConEntrevistador" object: nil];
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
    }
    
    [[self tablaDatos] reloadData];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[[self view ] setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"fondo_txtu2.png"] ]];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Atrás" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
    self.cellNib = [UINib nibWithNibName:@"CeldaEncargadoPorRegion" bundle:nil];
    
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
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
	return [_encargadosPorRegion count];
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id key =  [[_encargadosPorRegion allKeys] objectAtIndex:section ];
    NSArray * arregloObjetos =  [_encargadosPorRegion objectForKey:key];
    return  [arregloObjetos count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CeldaEncargadoPorRegion * celda;
    celda = (CeldaEncargadoPorRegion *)[tableView dequeueReusableCellWithIdentifier:self.identificador];
    
    if (celda == nil) {
        [self.cellNib instantiateWithOwner:self options:nil];
        celda = [self celda];
        self.celda = nil;
        celda.selectionStyle = UITableViewCellSelectionStyleGray;
        
        celda.etiquetaNombre.textColor = [UIColor colorWithRed: 0.0/255.0 green: 40.0/255.0 blue: 62.0/255.0 alpha: 1];
        celda.capacidad.textColor = [UIColor colorWithRed: 0.0/255.0 green: 40.0/255.0 blue: 62.0/255.0 alpha: 1];
    }
    
    id key =  [[_encargadosPorRegion allKeys] objectAtIndex:indexPath.section ];
    NSArray * arregloObjetos =  [_encargadosPorRegion objectForKey:key];
    Entrevistador * entrevistador = [arregloObjetos objectAtIndex: indexPath.row];
    [celda establecerEntrevistador:entrevistador];
    
    return celda;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 49;
}

#pragma mark -
#pragma mark Table view delegate methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 25.0)];
    
    // create the button object
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor =[UIColor colorWithRed: 8.0/255.0 green: 49.0/255.0 blue: 87.0/255.0 alpha: 0.8];
    headerLabel.opaque = NO;

    headerLabel.textColor = [UIColor colorWithRed: 227.0/255.0 green: 240.0/255.0 blue: 250.0/255.0 alpha: 1];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.frame = CGRectMake(0.0, 0.0, 320.0, 22.0);
    
    headerLabel.text = [[_encargadosPorRegion allKeys] objectAtIndex:section ];
    [customView addSubview:headerLabel];
    
    return customView;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id key =  [[_encargadosPorRegion allKeys] objectAtIndex:indexPath.section ];
    NSArray * arregloObjetos =  [_encargadosPorRegion objectForKey:key];
    
    Entrevistador * entrevistador = [arregloObjetos objectAtIndex: indexPath.row];
    
    [[self delegadoControladorNavegacion] mostrarPanelSiguienteSegunEntrevistador:entrevistador bajoIdentificador:self.identificador  usandoControlNavegacion:self.navigationController];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void) refrescarPantallas: (NSNotification *) notification {
    //TODO refactoring cambiar a todo modificar la infor por le meeting
    Meeting* meeting = [[notification userInfo] objectForKey:@"meeting"];
    [self refrescarDatos:meeting];
}

-(void)refrescarDatos:(Meeting*) meeting
{
    if(meeting)
    {
        self.encargadosPorRegion = [self establecerOriginDatos:[meeting personal]  bajoNombre:@"Jefes"];
        [[self tablaDatos] reloadData];
    }
}

-(void) refrescarPantallasConEntrevistador: (NSNotification *) notification {
    [[self tablaDatos] reloadData];
}

-(NSDictionary *) establecerOriginDatos:(NSArray*)arregloDatos bajoNombre:(NSString*)nombre
{
    NSMutableDictionary * salida = [[NSMutableDictionary new] autorelease];
    [salida setObject:arregloDatos forKey:nombre];
    
    return salida;
}

@end
