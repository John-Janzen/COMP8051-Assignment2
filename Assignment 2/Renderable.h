//
//  Renderable.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef Renderable_h
#define Renderable_h
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "BoundingBox.h"

@interface Renderable : NSObject {
    
    @public
    GLfloat *_arrayVertices;
    GLuint _vertexArray, _vertexBuffer[1];
    GLKVector3 _positionVector, _rotateVector, _scaleVector;
    int _texture;
    BoundingBox *_bounds;
    @private
    GLKMatrix4 _modelMatrix, _modelViewProjection;
    GLKMatrix3 _normalMatrix;
    GLfloat _arraySize, _renderType, _numOfIndices, _txtArraySize, _normArraySize;
    NSString *_ID;
}

- (void) transformSetup;
- (void) makeTranslationSetUp; // sets up the translation matrix at the beginning
- (void) rotateMatrixSetup; // sets up rotation vector
- (void) scaleMatrixSetup;
- (void) removeScaleFactor;

- (void) setNormalMatrix:(GLKMatrix3) matrix;
- (void) setModelMatrix:(GLKMatrix4) matrix; // set the model matrix whenever needed
- (void) setModelProjection:(GLKMatrix4)matrix;

- (GLKMatrix4) getModelMatrix; // returns model matrix for item
- (GLKMatrix3) getNormalMatrix;
- (GLKMatrix4) getModelProjection;

- (void) translateMatrix:(GLKVector3) translate; // translates the model
- (void) rotateMatrix:(GLKVector3)rotateMat : (float)degree; // rotates model by radians on axis
- (void) scaleMatrix : (GLKVector3) scale;

- (void) newRotate:(GLKVector3)rot; // creates new rotation matrix
- (void) resetPosRot; // resets position + rotation to 0,0,0

- (GLfloat) getArraySize;
- (GLfloat) getRenderType;
- (GLfloat) getNumIndices;
- (GLfloat) getTxtArraySize;
- (GLfloat) getNormArraySize;
- (NSString*) getObjectID;

- (void) setArraySize : (GLfloat) size;
- (void) setRenderType : (GLfloat) render;
- (void) setNumIndices : (GLfloat) ind;
- (void) setTxtArraySize : (GLfloat) size;
- (void) setNormArraySize : (GLfloat) size;
- (void) setObjectID : (NSString*) name;


@end


#endif /* Renderable_h */
