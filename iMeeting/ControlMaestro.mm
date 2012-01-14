
#import "ControlMaestro.h"
#import "ControladorDetalleEntrevistador.h"
#import "ControladorListaPersonas.h"
#import "DetalleGrafica.h"

@implementation ControlMaestro

@synthesize servicioBusqueda;

- (id)init {
    self = [super init];
    if (self) {
        _ultimoEntrevistado = nil;
    }
    return self;
}

- (void)dealloc {
    [_meeting release]; _meeting = nil;
    [self setServicioBusqueda: nil];
    [super dealloc];
}


-(void) asignarMeeting: (Meeting *) meeting {
    _meeting = [meeting retain];
    
    [servicioBusqueda setPersonalMeeting: [_meeting conjuntoPersonas]];
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
        [_ultimoEntrevistado setAsistio: !respuesta];
        
        // TODO Notificar para generacion de archivo y envio posterior a iCloud
    }
}

@end
