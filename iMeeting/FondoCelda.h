//
//  FondoCelda.h
//  Grafo
//
//  Created by Jesus Cagide on 05/11/11.
//  Copyright (c) 2011 INEGI. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Posicion de la celda para que éste sea considera por las celdas agrupadas
 */
typedef enum  {
	CustomCellBackgroundViewPositionTop, 
	CustomCellBackgroundViewPositionMiddle, 
	CustomCellBackgroundViewPositionBottom,
	CustomCellBackgroundViewPositionSingle
} CustomCellBackgroundViewPosition;

/**
 Vista de fondo para celdas customizadas.
 Vista utilizada en las celdas que se colorean un cierto porcentaje segun modelo enviado
 */
@interface FondoCelda : UIView {
	/**
		Color del borde de la vista
	*/
	UIColor *borderColor;
	
	/**
		Color de relleno de la vista
	*/
	UIColor *fillColor;
	
	/**
		Posición de la celda, para redondear las esquinas según corresponda
	*/
	CustomCellBackgroundViewPosition position;
}

/**
 @brief Colores de la vista de la celda
 */
@property(nonatomic, retain) UIColor *borderColor, *fillColor;

/**
 @property position
 @brief Propiedad que representa posición de la celda, para redondear las esquinas según corresponda
 */
@property(nonatomic) CustomCellBackgroundViewPosition position;

@end
