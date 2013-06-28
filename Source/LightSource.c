/*
 *  LightSource.c
 *  BasRelief
 *
 *  Created by Daniel Mueller on 8/6/09.
 *  Copyright Gabicoware LLC 2013. All rights reserved.
 *
 */
#include <math.h>
#include "LightSource.h"


int LightSourceDidUpdate = 0;

float LightSource[3];

float LightSourceDifferenceSensitivity = 0.02;

void
SetLightSource(float x, float y, float z){
	
	float ProposedLightSource[3];
	float LightSourceDifference;
	float length;
	
	length = sqrtf( x*x + y*y + z*z );
	
	ProposedLightSource[0] = x/length;
	ProposedLightSource[1] = y/length;
	ProposedLightSource[2] = z/length;
	
	if(LightSource[0] != LightSource[0] || LightSource[1] != LightSource[1] || LightSource[2] != LightSource[2]){
		LightSourceDifference = 1;
	}else{
		LightSourceDifference= fabs( LightSource[0] - ProposedLightSource[0]) + fabs( LightSource[1] - ProposedLightSource[1]) + fabs( LightSource[2] - ProposedLightSource[2]);
	}
    
	if(LightSourceDifference > LightSourceDifferenceSensitivity){
		
		LightSource[0] = ProposedLightSource[0] ;
		
		LightSource[1] = ProposedLightSource[1];
		
		LightSource[2] = ProposedLightSource[2];
		
		LightSourceDidUpdate = 1;
		
	}
	
}

void
SetLightSourceDidUpdate(){
	LightSourceDidUpdate = 1;
}


int
GetLightSourceDidUpdate(){
	if(LightSourceDidUpdate){
		LightSourceDidUpdate = 0;
		return 1;
	}
	return 0;
}


float
GetLightSourceX(){
	return LightSource[0];
}

float
GetLightSourceY(){
	return LightSource[1];
}

float
GetLightSourceZ(){
	return LightSource[2];
}

