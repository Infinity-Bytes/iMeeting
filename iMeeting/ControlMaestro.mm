
#import "ControlMaestro.h"
#import "ControladorDetalleEntrevistador.h"
#import "ControladorListaPersonas.h"
#import "DetalleGrafica.h"
#import "ServicioGestorDatos.h"

@implementation ControlMaestro

@synthesize servicioBusqueda;

- (id)init {
    self = [super init];
    if (self) {
        [self setServicioBusqueda: nil];
        
        _ultimoEntrevistado = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector: @selector(registraMeeting:) 
                                                     name: @"RegistraMeeting" object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector: @selector(registraElementoTrabajadoPorURL:) 
                                                     name: @"registraElementoTrabajadoPorURL" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [_meeting release]; _meeting = nil;
    
    [self setServicioBusqueda: nil];
    
    [super dealloc];
}


#pragma Delegado Control Lista
-(NSDictionary *)obtenerDatosSeparadosPorRegionesUsandoDefinicionOrden: (NSMutableArray * ) definicionOrden;
{
    NSMutableDictionary * salida = [[NSMutableDictionary new] autorelease];
    NSMutableSet * zonas = [NSMutableSet new];
    
    if(_meeting) {
        for(id idPersona in [_meeting conjuntoPersonas]) {
            id persona = [[_meeting conjuntoPersonas] objectForKey: idPersona];
            if([persona respondsToSelector: @selector(zona)]) {
                NSString * zona = [persona performSelector:@selector(zona)];
                if (zona) {
                    NSMutableArray * personasPorZona = [salida objectForKey: zona];
                    if(!personasPorZona) {
                        personasPorZona = [NSMutableArray new];
                        [salida setObject:personasPorZona forKey: zona];
                    } else {
                        [personasPorZona retain];
                    }
                    
                    NSArray * personasInteres = [persona personas];
                    [persona setPersonasEntrevistadas: [[NSMutableArray new] autorelease]];
                    [persona setPersonasSinEntrevistar: [[NSMutableArray new] autorelease]];
                    
                    for(id personaInterna in personasInteres) {
                        BOOL personaInternaAsistio = [personaInterna asistio];
                        
                        if(personaInternaAsistio)
                            [[persona personasEntrevistadas] addObject: personaInterna];
                        else
                            [[persona personasSinEntrevistar] addObject: personaInterna];
                    }
                    
                    [personasPorZona addObject: persona];
                    [personasPorZona release];
                    
                    [zonas addObject:zona];
                }
            }
        }
        
        // TODO Orden alfabético
        NSEnumerator * it_zonas = [zonas objectEnumerator];
        id zonaInteres = nil;
        while(zonaInteres = [it_zonas nextObject]) {
            [definicionOrden addObject: zonaInteres];
        }
    }
    return salida;
}

#pragma Delegado Control Navegacion
//un selector para desglosar informacion en detalle grafica asi mismo elegir a que ventana lo llevara la seleccion
-(void) mostrarPanelSiguienteSegunEntrevistador:(Entrevistador*)entrevistador bajoIdentificador:(NSString*) identificador  usandoControlNavegacion: (UINavigationController*) controlNavegacion
{
    if ([identificador isEqualToString:@"ListaRegiones"]) {
        
        ControladorDetalleEntrevistador * controladorDetalle = [[ControladorDetalleEntrevistador alloc] initWithNibName:@"ControladorDetalleEntrevistador" bundle:[NSBundle mainBundle]];
        
        [controladorDetalle establecerEntrevistador:entrevistador];
        [controladorDetalle setDelegadoControladorNavegacion:self];
        
        DetalleGrafica *personasEntrevistadas = [DetalleGrafica new];
        
        [personasEntrevistadas setCantidad: [NSString  stringWithFormat:@"%d", entrevistador.personasEntrevistadas.count]];
        [personasEntrevistadas setPorcentaje: (entrevistador.personasEntrevistadas.count *100 ) / entrevistador.personas.count]; 
        [personasEntrevistadas setNombreLeyenda:@"Si"];
        
        DetalleGrafica *personasNoEntrevistadas = [DetalleGrafica new];
        
        [personasNoEntrevistadas setCantidad: [NSString  stringWithFormat:@"%d", entrevistador.personasSinEntrevistar.count]];
        [personasNoEntrevistadas setPorcentaje: (entrevistador.personasSinEntrevistar.count *100 ) / entrevistador.personas.count]; 
        [personasNoEntrevistadas setNombreLeyenda:@"No"];
        
        
        [controladorDetalle setDetallesDeGrafica:[[NSArray alloc] initWithObjects:personasEntrevistadas,personasNoEntrevistadas, nil]];
        
        [controlNavegacion pushViewController:controladorDetalle animated:YES];
        
        [controladorDetalle release];
        [personasEntrevistadas release];
        [personasNoEntrevistadas release];
        
    }else
    {
        ControladorListaPersonas * controladorListaPersonas = [[ControladorListaPersonas alloc] initWithNibName:@"ControladorListaPersonas" bundle:[NSBundle mainBundle]];
        
        if ([identificador isEqualToString:@"personasEntrevistadas"])
            [controladorListaPersonas setDatos:[entrevistador personasEntrevistadas]];
        
        if ([identificador isEqualToString:@"personasSinEntrevistar"])
            [controladorListaPersonas setDatos:[entrevistador personasSinEntrevistar]];
        
        [controlNavegacion pushViewController:controladorListaPersonas animated:YES];
        [controladorListaPersonas release];
    }
}


-(NSString *) obtenerEntrevistado:(NSString *)identificador
{
    _ultimoEntrevistado = (Entrevistado *)([servicioBusqueda buscarPersonaPorIdentificador: identificador]);
    if(_ultimoEntrevistado) {
        BOOL asistio = [_ultimoEntrevistado asistio];
        return asistio ? [NSString stringWithFormat:@"Persona ya asistió: %@", [_ultimoEntrevistado nombre]] : [NSString stringWithFormat:@"Registrar asistencia de: %@", [_ultimoEntrevistado nombre]];
    } else {
        return @"Código no identificado";
    }
}

-(void) notificarRespuesta:(BOOL)respuesta
{
    if(_ultimoEntrevistado && ![_ultimoEntrevistado asistio]) {
        [_ultimoEntrevistado setAsistio: YES];
        
        // Notificar para generacion de archivo y envio posterior a iCloud
        NSNotification * myNotification =
        [NSNotification notificationWithName:@"registraElementoTrabajado" object:self userInfo: [NSDictionary dictionaryWithObjectsAndKeys:_meeting, @"meeting", _ultimoEntrevistado , @"elementoTrabajado", nil]];
        
        [[NSNotificationQueue defaultQueue] enqueueNotification: myNotification
                                                   postingStyle: NSPostWhenIdle
                                                   coalesceMask: NSNotificationNoCoalescing
                                                       forModes: nil];
    }
}

#pragma Delegado Gestor Datos

- (void) registraMeeting: (NSNotification *) notificacion {
    NSLog(@"registraMeeting: %@", notificacion);
    Meeting * meeting = [[notificacion userInfo] objectForKey: @"meeting"];

    if(meeting != _meeting) {
        [_meeting release];
        _meeting = [meeting retain];
    }
    
    [servicioBusqueda setPersonalMeeting: [_meeting conjuntoPersonas]];
}


-(void) registraElementoTrabajadoPorURL: (NSNotification *) notificacion {
    NSLog(@"registraElementoTrabajadoPorURL: %@", notificacion);
    
    Meeting * meeting = [[notificacion userInfo] objectForKey: @"meeting"];
    NSString * elementoTrabajado = [[notificacion userInfo] objectForKey: @"elementoTrabajado"];
    
    // Asignar trabajado
    Entrevistado * entrevistado = [[meeting conjuntoPersonas] objectForKey: elementoTrabajado];
    if(entrevistado) {
        [entrevistado setAsistio: YES];
    }
}

@end
