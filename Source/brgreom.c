#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "brgeom.h"


//corresponds to N,E,S,W, NE,SE,SW,NW
#define DIRECTIONS 8

typedef int Boolean;

unsigned char *HeightMap;
float *Normals;

float LightSource[3];
float HeightDifference;

float MaxHeight = 40.0;

float ShadeThreshold;
float ShadeAlpha;
float SpecularThreshold;
float SpecularAlpha;

int RenderingNeedsUpdating = 0;

void
RenderIndeterminatePixel( const float * normals, const unsigned char *sourceColors, unsigned char *targetColors);

float
RenderDeterminatePixel( const int index, float shadowHeight, const unsigned char *sourceColors, unsigned char *targetColors);

void
RenderVertical( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[]);

void
RenderHorizontal( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[]);

void
LengthOf3DVector(float * length, const float * vector);


void
SetHeightMap(unsigned char *heightMap){
	RenderingNeedsUpdating = 1;

	HeightMap = heightMap;
}

void
SetNormals(float *normals){
	
	RenderingNeedsUpdating = 1;
	
	Normals = normals;
}

void
SetMaxHeight(float height){
	MaxHeight = height;
}

void
SetLightVector(float x, float y, float z){
		
	float length = sqrtf( x*x + y*y + z*z );
	
	LightSource[0] = x/length;
	LightSource[1] = y/length;
	LightSource[2] = z/length;

	RenderingNeedsUpdating = 1;

}

int
NeedsUpdate(){
	return RenderingNeedsUpdating;
}

/*
void
SetRenderingValues(float shadeThreshold, float shadeAlpha, float specularThreshold, float specularAlpha){
	
	RenderingNeedsUpdating = 1;

	ShadeThreshold = shadeThreshold;
	ShadeAlpha = shadeAlpha;
	SpecularThreshold = specularThreshold;
	SpecularAlpha = specularAlpha;
	
}
*/
void
SetRenderingValues(RenderingValues values){
	
	RenderingNeedsUpdating = 1;
	
	ShadeThreshold = values.shadeThreshold;
	ShadeAlpha = values.shadeAlpha;
	SpecularThreshold = values.specularThreshold;
	SpecularAlpha = values.specularAlpha;
	
}


void
CalculateNormals( const unsigned char heightMap[], float normals[], const int width, const int height ){

	//comment

	RenderingNeedsUpdating = 1;

	int z, z2, x, y, n;
	int index, index2;
	float * v1;
	float * v2;
	float vn[3] = {0,0,0};
	float an[3] = {0,0,0};

	//float vnx, vny, vnz;
	float length;//, an_x, an_y, an_z;

	float * vectors;

	float i_vectors[24] = { -1,0,0, -1,-1,0, 0,-1,0, 1,-1,0, 1,0,0, 1,1,0, 0,1,0, -1,1,0 };

	Boolean * booleans;

	booleans = (Boolean *)malloc(sizeof(Boolean)*DIRECTIONS);
	vectors = (float *)malloc(sizeof(float)*DIRECTIONS*3);


	for(y = height; y --; ){

		for(x=width; x--; ){

			index = y*width+x;

			z = (int) heightMap[index];

			memcpy(vectors,i_vectors,DIRECTIONS*3*sizeof(float));

			if(x != 0){
				index2 = (y + vectors[1] )*width + x + vectors[0];
				z2 = (int) heightMap[index2];
				vectors[2] = z2-z;
			}
			if(y != 0 && x != 0){
				index2 = (y + vectors[4] )*width + x + vectors[3];
				z2 = (int) heightMap[index2];
				vectors[5] = z2-z;
			}
			if(y != 0){
				index2 = (y + vectors[7] )*width + x + vectors[6];
				z2 = (int) heightMap[index2];
				vectors[8] = z2-z;

			}
			if(y != 0 && x != width - 1){
				index2 = (y + vectors[10] )*width + x + vectors[9];
				z2 = (int) heightMap[index2];
				vectors[11] = z2-z;

			}
			if(x != width - 1){
				index2 = (y + vectors[13] )*width + x + vectors[12];
				z2 = (int) heightMap[index2];
				vectors[14] = z2-z;
			}
			if(y != height - 1 && x != width - 1){
				index2 = (y + vectors[16] )*width + x + vectors[15];
				z2 = (int) heightMap[index2];
				vectors[17] = z2-z;

			}
			if(y != height - 1){
				index2 = (y + vectors[19] )*width + x + vectors[18];
				z2 = (int) heightMap[index2];
				vectors[20] = z2-z;

			}
			if(y != height - 1 && x != 0){
				index2 = (y + vectors[22] )*width + x + vectors[21];
				z2 = (int) heightMap[index2];
				vectors[23] = z2-z;

			}


			an[0] = 0.0;
			an[1] = 0.0;
			an[2] = 0.0;

			for(n = DIRECTIONS; n--;){

				v1 = &vectors[n*3];
				v2 = &vectors[((n+1)%DIRECTIONS)*3];

				vn[0] = v1[1]*v2[2] - v1[2]*v2[1];

				vn[1] = v1[2]*v2[0] - v1[0]*v2[2];

				vn[2] = v1[0]*v2[1] - v1[1]*v2[0];

				LengthOf3DVector( &length, vn);

				an[0] += vn[0]/length;
				an[1] += vn[1]/length;
				an[2] += vn[2]/length;

			}
			LengthOf3DVector( &length, an);
			//length = sqrt(an_x*an_x + an_y*an_y + an_z*an_z);

			normals[index*3 + 0] = an[0] / length;
			normals[index*3 + 1] = an[1] / length;
			normals[index*3 + 2] = an[2] / length;

			//printf("%f, %f, %f\n",normals[index*3 + 0],normals[index*3 + 1],normals[index*3 + 2]);

		}

	}

}

void
LengthOf3DVector(float * length, const float * vector){

	* length = sqrt(vector[0]*vector[0] + vector[1]*vector[1] + vector[2]*vector[2]);

}


/*
 * 
 * 
 * 
 * int colors
 * Array of unsigned char 4 component colors, the length of height*width*4 which will be modified
 * */
void
RenderIndeterminate( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[]){
	
	RenderingNeedsUpdating = 0;
	
	int index = width*height;

	for(index = width*height; index--; ){
		RenderIndeterminatePixel( &Normals[index*3], &sourceColors[index*4], &targetColors[index*4]);
	}
			
}

void
RenderBase( const int width, const int height, unsigned char sourceColors[]){

	RenderingNeedsUpdating = 0;

	int index = width*height;

	unsigned char * sc;

	for(index = width*height; index--; ){
		float colorShift = 0;
		float dotProduct;

		sc = &sourceColors[index*4];

		dotProduct = Normals[index*3 + 2];

		if(dotProduct < ShadeThreshold){

			colorShift = 1.0- (ShadeAlpha*(ShadeThreshold - dotProduct)/ShadeThreshold)/255;

			sc[0] = sc[0]*colorShift;
			sc[1] = sc[1]*colorShift;
			sc[2] = sc[2]*colorShift;

		}else if(dotProduct > SpecularThreshold){

			colorShift = (SpecularAlpha*(dotProduct - SpecularThreshold)/(1 - SpecularThreshold))/255;

			sc[0] = sc[0]*(1- colorShift) + colorShift*255;
			sc[1] = sc[1]*(1- colorShift) + colorShift*255;
			sc[2] = sc[2]*(1- colorShift) + colorShift*255;

		}

	}

}


void RenderDeterminate( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[] ){
	
	if(RenderingNeedsUpdating){
		
		RenderingNeedsUpdating = 0;
		
		if(LightSource[0] == 0 && LightSource[1] == 0){
			RenderIndeterminate( width ,  height ,  sourceColors ,  targetColors );
		}else{
		
			
			
			//float angle = fabs(180.0*atan2f(LightSource[1], LightSource[0])/M_PI);
		
			//float l1, l0;
			
			//l1 = LightSource[1];
			//l0 = LightSource[0];
			
			float ratio = fabs(LightSource[0]/LightSource[1]);
			
			if(ratio > 1){
				
				RenderHorizontal(  width ,  height ,  sourceColors ,  targetColors );
			}else{
				//RenderIndeterminate( width ,  height ,  sourceColors ,  targetColors );
				RenderVertical(  width ,  height ,  sourceColors ,  targetColors );
			}
		}
		
	}
	
}

//, const int rows
void
GenerateIndices(const int columns, unsigned short *indices){
	
	int i;
	
	for(i = columns; i-- ; ){

		indices[2*i] = (unsigned short) i;
		indices[2*i + 1] = (unsigned short) (i + columns);
	}
	
}

void
GenerateVertices(const int columns, const int rows, int *vertices){
	
	int j, i, index;	
	index = 2*rows*columns;
	for(j = rows; j-- ; ){
		
		for(i = columns; i-- ; ){
			
			index -= 2;
			
			vertices[index] = i;
			vertices[index + 1] = j;
			
		}
		
	}
	
}


void
RenderVertical( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[]){
	
	Boolean isTop = LightSourceIsTop();
	Boolean isLeft = LightSourceIsLeft();
	float preFraction = 0.0;
	float postFraction = 1.0;
	float numerator = isTop ? 1.0 : -1.0;
	
	float shadowHeight;
	
	int workingCurrentIndex = 0;
	int workingPreviousIndex = 0;
	int currentZeroPadIndex = 0;
	
	float *swapHeights;
	float *currentHeights;
	float *workingCurrentHeights;
	float *previousHeights;
	float *workingPreviousHeights;
	int index;
	int j, i;
	float l1, l0;
	
	currentHeights = (float *)malloc( sizeof(float)*(width + 1));
	previousHeights = (float *)malloc( sizeof(float)*(width + 1));
	
	
	l1 = LightSource[1];
	l0 = LightSource[0];


	if(isLeft){
		
		//workingPreviousIndex = 0;
		//currentZeroPadIndex = width;
		workingCurrentIndex = 1;
				
		preFraction = numerator * ( l0 / l1 ) ;
	}else{
		
		preFraction = 1 + numerator * ( l0 / l1 ) ;
	}

	postFraction = 1 - preFraction ;
	
	//stepSize ??? how to handle this (externally most likely)
	//heightDiffernce is the only thing really requisite on step size
	HeightDifference = numerator*LightSource[2] / LightSource[1]  ;
		

	memset(currentHeights,0,sizeof(float)*width);

	if(isTop){
		
			
		for(j=0; j < height; j++){
			
			swapHeights = previousHeights;
			
			previousHeights = currentHeights;
			
			currentHeights = swapHeights;
			
			workingPreviousHeights = &previousHeights[workingPreviousIndex];
			workingCurrentHeights = &currentHeights[workingCurrentIndex];
			currentHeights[currentZeroPadIndex] = 0.0;
			
			for(i = 0; i < width; i++){
				
				shadowHeight = workingPreviousHeights[i]*preFraction + workingPreviousHeights[i+1]*postFraction + HeightDifference;
				
				if(shadowHeight > MaxHeight){
					shadowHeight = 0;
				}

				index = j*width + i;
				
				workingCurrentHeights[i] = RenderDeterminatePixel(index, shadowHeight, &sourceColors[index*4], &targetColors[index*4] );
				

			}
			
		}
	}else{
		
			
		for(j = height - 1; j > -1; j--){
			
			swapHeights = previousHeights;
			
			previousHeights = currentHeights;
			
			currentHeights = swapHeights;
			
			workingPreviousHeights = &previousHeights[workingPreviousIndex];
			workingCurrentHeights = &currentHeights[workingCurrentIndex];
			currentHeights[currentZeroPadIndex] = 0.0;
			
			for(i = 0; i < width; i++){
				
				shadowHeight = workingPreviousHeights[i]*preFraction + workingPreviousHeights[i+1]*postFraction + HeightDifference;
				
				if(shadowHeight > MaxHeight){
					shadowHeight = 0;
				}
				
				index = j*width + i;
				
				workingCurrentHeights[i] = RenderDeterminatePixel(index, shadowHeight, &sourceColors[index*4], &targetColors[index*4] );
				
			}
			
		}
		
	}
	
}




void
RenderHorizontal( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[]){
	
	Boolean isTop = LightSourceIsTop();
	Boolean isLeft = LightSourceIsLeft();
	float preFraction = 0.0;
	float postFraction = 1.0;
	float numerator = isLeft ? 1.0 : -1.0;
	
	float shadowHeight;
	
	int workingCurrentIndex = 0;
	int workingPreviousIndex = 0;
	int currentZeroPadIndex = 0;
	
	float *swapHeights;
	float *currentHeights;
	float *workingCurrentHeights;
	float *previousHeights;
	float *workingPreviousHeights;
	int index;
	float l1, l0;
	int j, i;
	
	currentHeights = (float *)malloc( sizeof(float)*(height + 1));
	previousHeights = (float *)malloc( sizeof(float)*(height + 1));
	
	
	l1 = LightSource[1];
	l0 = LightSource[0];
	
	
	if(isTop){
		workingCurrentIndex = 1;
		preFraction = numerator * ( l1 / l0 )  ;
	}else{
		//workingPreviousIndex = 1;
		//currentZeroPadIndex = height;
		
		preFraction = 1 + numerator * ( l1 / l0 ) ;
		
	}
	
	postFraction = 1 - preFraction ;
	
	//stepSize ??? how to handle this (externally most likely)
	//heightDiffernce is the only thing really requisite on step size
	HeightDifference = numerator*LightSource[2] / LightSource[0]  ;
	
	memset(currentHeights,0,sizeof(float)*width);
	
	if(isLeft){
		
		for(i=0; i < width; i++){	
			
			swapHeights = previousHeights;
			
			previousHeights = currentHeights;
			
			currentHeights = swapHeights;
			
			workingPreviousHeights = &previousHeights[workingPreviousIndex];
			workingCurrentHeights = &currentHeights[workingCurrentIndex];
			currentHeights[currentZeroPadIndex] = 0.0;
			
			
			
			for(j = 0; j < height; j++){
				
				shadowHeight = workingPreviousHeights[j]*preFraction + workingPreviousHeights[j+1]*postFraction + HeightDifference;
				
				if(shadowHeight > MaxHeight){
					shadowHeight = 0;
				}
				
				index = j*width + i;
				
				workingCurrentHeights[j] = RenderDeterminatePixel(index, shadowHeight, &sourceColors[index*4], &targetColors[index*4] );

			}
			
		}
	}else{
		
		for(i = width - 1; i > -1; i--){
		
			swapHeights = previousHeights;
			
			previousHeights = currentHeights;
			
			currentHeights = swapHeights;
			
			workingPreviousHeights = &previousHeights[workingPreviousIndex];
			workingCurrentHeights = &currentHeights[workingCurrentIndex];
			currentHeights[currentZeroPadIndex] = 0.0;
			
			
			for(j = 0; j < height; j++){
				
				shadowHeight = workingPreviousHeights[j]*preFraction + workingPreviousHeights[j+1]*postFraction + HeightDifference;
				
				if(shadowHeight > MaxHeight){
					shadowHeight = 0;
				}
				
				index = j*width + i;
				
				workingCurrentHeights[j] = RenderDeterminatePixel(index, shadowHeight, &sourceColors[index*4], &targetColors[index*4] );
				
			}
			
		}
		
	}
		
}

void 
RenderIndeterminatePixel( const float *normals, const unsigned char *sourceColors, unsigned char *targetColors){
	
	float colorShift = 0;
	float dotProduct;
	
	dotProduct = normals[0]*LightSource[0] + normals[1]*LightSource[1] + normals[2]*LightSource[2];
	
	if(dotProduct < 0.0) dotProduct = 0.0;
	
	if(dotProduct < ShadeThreshold){
		
		colorShift = 1.0- (ShadeAlpha*(ShadeThreshold - dotProduct)/ShadeThreshold)/255;
		
		targetColors[0] = sourceColors[0]*colorShift;
		targetColors[1] = sourceColors[1]*colorShift;
		targetColors[2] = sourceColors[2]*colorShift;

	}else if(dotProduct > SpecularThreshold){
		
		colorShift = (SpecularAlpha*(dotProduct - SpecularThreshold)/(1 - SpecularThreshold))/255;
		
		targetColors[0] = sourceColors[0]*(1- colorShift) + colorShift*255;
		targetColors[1] = sourceColors[1]*(1- colorShift) + colorShift*255;
		targetColors[2] = sourceColors[2]*(1- colorShift) + colorShift*255;

	}else{

		targetColors[0] = sourceColors[0];
		targetColors[1] = sourceColors[1];
		targetColors[2] = sourceColors[2];

	}
	
}

float
RenderDeterminatePixel( const int index, float shadowHeight, const unsigned char *sourceColors, unsigned char *targetColors){
	
	int addOn = 0;
	float colorShift = 0;
	float dotProduct;
	float *normals;
	float currentHeight;
	float ratio;
	float colorShift2;
	
	currentHeight = (float) HeightMap[index];
	
	normals = &Normals[index*3];
	
	if(shadowHeight > currentHeight){
		
		ratio = (shadowHeight - currentHeight) / fabs(HeightDifference);

		if(ratio < 1){
			colorShift = ratio*ShadeAlpha/255;
			
			dotProduct = normals[0]*LightSource[0] + normals[1]*LightSource[1] + normals[2]*LightSource[2];
			
			if(dotProduct < 0.0) dotProduct = 0.0;
			
			
			if(dotProduct < ShadeThreshold){
				
				colorShift2 = (ShadeAlpha*(ShadeThreshold - dotProduct)/ShadeThreshold)/255;
				
				colorShift = 1 - (1-colorShift)*(1-colorShift2);
				
			}else if(dotProduct > SpecularThreshold){
				
				colorShift = (SpecularAlpha*(dotProduct - SpecularThreshold)/(1 - SpecularThreshold))/255 - colorShift;
				
				if(colorShift > 0){
					addOn = 255;
				}else{
					colorShift = fabs(colorShift);
				}
				
			}
			
			targetColors[0] = sourceColors[0]*(1- colorShift) + colorShift*addOn;
			targetColors[1] = sourceColors[1]*(1- colorShift) + colorShift*addOn;
			targetColors[2] = sourceColors[2]*(1- colorShift) + colorShift*addOn;

		}else{

			colorShift = 1.0 - ShadeAlpha/255.0;

			targetColors[0] = sourceColors[0]*colorShift;
			targetColors[1] = sourceColors[1]*colorShift;
			targetColors[2] = sourceColors[2]*colorShift;

		}
		
		
		currentHeight = shadowHeight;
		
		
	}else{
		
		RenderIndeterminatePixel(normals, sourceColors, targetColors);
	}
	
	
	return currentHeight;
		
}

Boolean
LightSourceIsLeft(){
	if(LightSource[0] > 0){
		return 0;
	}
	
	return 1;
}

Boolean
LightSourceIsTop(){
	if(LightSource[1] > 0){
		return 0;
	}
	
	return 1;
}
