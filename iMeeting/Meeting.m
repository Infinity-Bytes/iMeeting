//
//  Meeting.m
//  iMeeting
//
//  Created by Luis Alejandro Rangel Sánchez on 12/01/12.
//  Copyright (c) 2012 INEGI. All rights reserved.
//

#import "Meeting.h"

@implementation Meeting

@synthesize nombreMeeting;
@synthesize personal;


- (void)dealloc {
    [self setNombreMeeting: nil];
    [self setPersonal: nil];
    
    [super dealloc];
}
@end
