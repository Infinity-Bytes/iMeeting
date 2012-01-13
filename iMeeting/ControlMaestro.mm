
#import "ControlMaestro.h"
#import "ControladorDetalleEntrevistador.h"
#import "ControladorListaPersonas.m"
#import "DetalleGrafica.h"

@implementation ControlMaestro



#pragma Delegado Control Lista
-(NSDictionary *)obtenerDatosSeparadosPorRegiones
{
    return [NSDictionary new];
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
        
        [personasEntrevistadas setCantidad: [NSString  stringWithFormat:@"%d", entrevistador.entrevistados.count]];
        [personasEntrevistadas setPorcentaje: (entrevistador.personasEntrevistadas.count *100 ) / entrevistador.entrevistados.count]; 
        [personasEntrevistadas setNombreLeyenda:@"Si"];
        
        DetalleGrafica *personasNoEntrevistadas = [DetalleGrafica new];
        
        [personasNoEntrevistadas setCantidad: [NSString  stringWithFormat:@"%d", entrevistador.entrevistados.count]];
        [personasNoEntrevistadas setPorcentaje: (entrevistador.personasSinEntrevistar.count *100 ) / entrevistador.entrevistados.count]; 
        [personasNoEntrevistadas setNombreLeyenda:@"No"];
        
        
        [controladorDetalle setDetallesDeGrafica:[[NSArray alloc] initWithObjects:personasEntrevistadas,personasNoEntrevistadas, nil]];
        
        [controlNavegacion pushViewController:controlNavegacion animated:YES];
        
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
        
        [controlNavegacion pushViewController:controlNavegacion animated:YES];
        [controladorListaPersonas release];
    }
}


@end
