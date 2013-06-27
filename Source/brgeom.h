#ifndef BRGEOM_H_
#define BRGEOM_H_

typedef struct {
	float shadeThreshold;
	float shadeAlpha;
	float specularThreshold;
	float specularAlpha;
} RenderingValues;

void
SetLightVector(float x, float y, float z);

void
SetHeightMap(unsigned char *heightMap);

void
SetNormals(float *normals);

void
SetMaxHeight(float height);

//void
//SetRenderingValues(float shadeThreshold, float shadeAlpha, float specularThreshold, float specularAlpha);
void
SetRenderingValues(RenderingValues values);

void
CalculateNormals( const unsigned char heightMap[], float normals[], const int width, const int height );

void
RenderBase( const int width, const int height, unsigned char sourceColors[]);

void
RenderIndeterminate( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[]);

void
RenderDeterminate( const int width, const int height, const unsigned char sourceColors[], unsigned char targetColors[] );
//, const int height
void
GenerateIndices(const int width, unsigned short *indices);

void
GenerateVertices(const int columns, const int rows, int *vertices);

int
NeedsUpdate();

//Internal functions
int
LightVectorIsLeft();

int
LightVectorIsTop();


#endif /*BRGEOM_H_*/

