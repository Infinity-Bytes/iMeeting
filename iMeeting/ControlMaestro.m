
#import "ControlMaestro.h"
#import "ControladorDetalleEntrevistador.h"
#import "ControladorListaPersonas.h"
#import "DetalleGrafica.h"
#import "ServicioGestorDatos.h"
#import "ControladorListaRegiones.h"
#import "JefeEntrevistadores.h"
#import "JefeEntrevistadoresOtro.h"

@implementation ControlMaestro

@synthesize servicioBusqueda;
@synthesize controlNavegacionPrincipal;

- (id)init {
    self = [super init];
    if (self) {
        [self setServicioBusqueda: nil];
        [self setControlNavegacionPrincipal: nil];
        
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
    [usuario release]; usuario = nil;
    
    [self setServicioBusqueda: nil];
    [self setControlNavegacionPrincipal: nil];
    
    [super dealloc];
}

-(NSDictionary *) establecerOriginDatos:(NSArray*)arregloDatos bajoNombre:(NSString*)nombre
{
    NSMutableDictionary * salida = [[NSMutableDictionary new] autorelease];
    [salida setObject:arregloDatos forKey:nombre];
    
    return salida;
}

#pragma Delegado Control Navegacion
//un selector para desglosar informacion en detalle grafica asi mismo elegir a que ventana lo llevara la seleccion
-(void) mostrarPanelSiguienteSegunEntrevistador:(Entrevistador*)entrevistador bajoIdentificador:(NSString*) identificador  usandoControlNavegacion: (UINavigationController*) controlNavegacion
{
    if([entrevistador isKindOfClass: [JefeEntrevistadores class]]) {
        NSArray * personaAsuCargo = nil;
        NSString * nombreLista = nil;
        
        JefeEntrevistadores* jefeEntrevistadores = (JefeEntrevistadores *)entrevistador;
        if([[jefeEntrevistadores jefesEntrevistadores] count]) {
            personaAsuCargo = [jefeEntrevistadores jefesEntrevistadores];
            nombreLista = @"Subjefe";
        } else {
            if([[jefeEntrevistadores entrevistadores] count]) {
                personaAsuCargo = [jefeEntrevistadores entrevistadores];
                nombreLista = @"Entrevistadores";
            }
        }
        
        if ( nombreLista != nil && personaAsuCargo != nil) {
            ControladorListaRegiones* controladorListaRegiones = [[ControladorListaRegiones alloc] initWithNibName:@"ControladorListaRegiones" bundle:nil];
            [controladorListaRegiones setDelegadoControladorNavegacion:self];
            [controladorListaRegiones setEncargadosPorRegion:[self establecerOriginDatos:personaAsuCargo bajoNombre:nombreLista]];
            [controladorListaRegiones setIdentificador:@"ListaRegiones"];
            [controlNavegacion pushViewController:controladorListaRegiones animated:YES];
            [controladorListaRegiones release];
        }
    } else {
        if ([identificador isEqualToString:@"ListaRegiones"]) {
            
            ControladorDetalleEntrevistador * controladorDetalle = [[ControladorDetalleEntrevistador alloc] initWithNibName:@"ControladorDetalleEntrevistador" bundle:[NSBundle mainBundle]];
            
            [controladorDetalle setDelegadoControladorNavegacion:self];
            [controladorDetalle establecerEntrevistador:entrevistador];
            
            [controlNavegacion pushViewController:controladorDetalle animated:YES];
            
            [controladorDetalle release];
            
        } else {
            ControladorListaPersonas * controladorListaPersonas = [[ControladorListaPersonas alloc] initWithNibName:@"ControladorListaPersonas" bundle:[NSBundle mainBundle]];
            
            NSSet * origenDatos = [NSSet set];
            if ([identificador isEqualToString:@"personasEntrevistadas"])
                origenDatos = [entrevistador personasEntrevistadas];
            if ([identificador isEqualToString:@"personasSinEntrevistar"])
                origenDatos = [entrevistador personasSinEntrevistar];
            
            [controladorListaPersonas setEntrevistador: entrevistador];
            [controladorListaPersonas setOrigenDatos: origenDatos];
            
            [controlNavegacion pushViewController:controladorListaPersonas animated: YES];
            [controladorListaPersonas release];
        }
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
    if(respuesta && _ultimoEntrevistado && ![_ultimoEntrevistado asistio]) {
        
        [self procesaElementoTrabajado: _ultimoEntrevistado enMeeting: _meeting];
        
        // Notificar para generacion de archivo y envio posterior a iCloud
        NSNotification * myNotification = [NSNotification notificationWithName:@"registraElementoTrabajado" 
                                                                        object:self 
                                                                      userInfo: [NSDictionary dictionaryWithObjectsAndKeys:_meeting, @"meeting", _ultimoEntrevistado , @"elementoTrabajado", nil]];
        
        [[NSNotificationQueue defaultQueue] enqueueNotification: myNotification
                                                   postingStyle: NSPostWhenIdle
                                                   coalesceMask: NSNotificationNoCoalescing
                                                       forModes: nil];
    }
}

- (void) procesaElementoTrabajado: (Entrevistado *) entrevistado enMeeting: (Meeting *) meeting {
    if(![entrevistado asistio]) {
        [entrevistado setAsistio: YES];
        
        Entrevistador * entrevistadorLider = [entrevistado lider];
        if(![[entrevistadorLider personasEntrevistadas] containsObject: entrevistado]) {
            [[entrevistadorLider personasSinEntrevistar] removeObject: entrevistado];
            [[entrevistadorLider personasEntrevistadas] addObject: entrevistado];
            
            NSMutableSet * conjuntoEntrevistadoresInteres = [NSMutableSet new];
            [self obtenEntrevistadoresAcumulador: conjuntoEntrevistadoresInteres aPartir: entrevistadorLider];
            [self procesaAcumulado: conjuntoEntrevistadoresInteres];
            [conjuntoEntrevistadoresInteres release];
        }
        
        [[NSNotificationQueue defaultQueue] enqueueNotification: [NSNotification notificationWithName:@"refrescarPantallasConEntrevistador" object:self userInfo: [NSDictionary dictionaryWithObjectsAndKeys:entrevistado, @"entrevistado", meeting, @"meeting", nil]]
                                                   postingStyle: NSPostWhenIdle
                                                   coalesceMask: NSNotificationNoCoalescing
                                                       forModes: nil];
    }
}

- (void) obtenEntrevistadoresAcumulador:(NSMutableSet *) acumulador aPartir: (Entrevistador *) entrevistador {
    if(entrevistador && ![acumulador containsObject: entrevistador]) {
        [acumulador addObject: entrevistador];
        
        Entrevistador * lider = [entrevistador lider];
        [self obtenEntrevistadoresAcumulador:acumulador aPartir: lider];
    }
}

- (void) procesaAcumulado: (NSSet *) acumulador {
    for(Entrevistador * entrevistador in acumulador) {
        
        // Agregar en el acumulador
        entrevistador.numeroPersonasEntrevistadas++;
    }
}


#pragma Delegado Gestor Datos

- (void) registraMeeting: (NSNotification *) notificacion {
    NSLog(@"registraMeeting: %@", notificacion);
    Meeting * meeting = [[notificacion userInfo] objectForKey: @"meeting"];
    
    if(meeting != _meeting) {
        [_meeting release];
        _meeting = [meeting retain];
        
        
        // Reiniciar ventanas de trabajo
        [[self controlNavegacionPrincipal] popToRootViewControllerAnimated: NO];
        
        [servicioBusqueda setPersonalMeeting: [_meeting conjuntoEntrevistados]];
        
        [[NSNotificationQueue defaultQueue] enqueueNotification: [NSNotification notificationWithName:@"refrescarPantallas" object:self 
                                                                                             userInfo: [NSDictionary dictionaryWithObjectsAndKeys: meeting, @"meeting", nil]]
                                                   postingStyle: NSPostWhenIdle
                                                   coalesceMask: NSNotificationNoCoalescing
                                                       forModes: nil];
    }
}


-(void) registraElementoTrabajadoPorURL: (NSNotification *) notificacion {
    NSLog(@"registraElementoTrabajadoPorURL: %@", notificacion);
    
    Meeting * meeting = [[notificacion userInfo] objectForKey: @"meeting"];
    NSString * elementoTrabajado = [[notificacion userInfo] objectForKey: @"elementoTrabajado"];
    
    // Asignar trabajado
    Entrevistado * entrevistado = [[meeting conjuntoEntrevistados] objectForKey: elementoTrabajado];
    if(entrevistado) {
        [self procesaElementoTrabajado: entrevistado enMeeting:meeting];
    }
}

-(int)comprobarIdentidad:(NSString*)idenfificador
{
    int resultado = 3;
    if(_meeting){
        usuario = [[_meeting conjuntoEntrevistadores] objectForKey: idenfificador];
        if(usuario)
            if(![usuario isKindOfClass:[JefeEntrevistadoresOtro class]])
                return ([usuario isKindOfClass:[JefeEntrevistadores class]])?1:0;
    }
    return resultado; 
}

@end
