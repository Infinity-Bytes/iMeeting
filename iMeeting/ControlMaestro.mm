//
//  ControlMaestro.m
//  iMeeting
//
//  Created by Jesus Cagide on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "ControlMaestro.h"
#import "ControladorDetalleEntrevistador.h"
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
    
    }
    if ([identificador isEqualToString:@"DetalleEntrevistador"]) {
        
    }

}


@end
