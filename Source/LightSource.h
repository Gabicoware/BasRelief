/*
 *  LightSource.h
 *  BasRelief
 *
 *  Created by Daniel Mueller on 8/6/09.
 *  Copyright Gabicoware LLC 2013. All rights reserved.
 *
 */



void
SetLightSource(float x, float y, float z);

//BY CALLING THIS FUNCTION YOU RESET LIGHTSOURCEDIDUPDATE TO 0
int
GetLightSourceDidUpdate();

void
SetLightSourceDidUpdate();

float
GetLightSourceX();

float
GetLightSourceY();

float
GetLightSourceZ();
