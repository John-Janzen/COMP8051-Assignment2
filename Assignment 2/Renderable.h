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

@interface Renderable : NSObject {
    
    @public
    GLfloat *_arrayVertices, *_textureArray;
    GLuint _vertexArray, _vertexBuffer[2];
    GLKVector3 _positionVector, _rotateVector, _scaleVector;
    GLuint _texture;
    @private
    GLKMatrix4 _modelMatrix, _modelViewProjection;
    GLKMatrix3 _normalMatrix;
    GLfloat _arraySize, _renderType, _numOfIndices, _txtArraySize;
    
}

- (void) transformSetup;
- (void) makeTranslationSetUp; // sets up the translation matrix at the beginning
- (void) rotateMatrixSetup; // sets up rotation vector

- (void) setNormalMatrix:(GLKMatrix3) matrix;
- (void) setModelMatrix:(GLKMatrix4) matrix; // set the model matrix whenever needed
- (void) setModelProjection:(GLKMatrix4)matrix;

- (GLKMatrix4) getModelMatrix; // returns model matrix for item
- (GLKMatrix3) getNormalMatrix;
- (GLKMatrix4) getModelProjection;

- (void) translateMatrix:(GLKVector3) translate; // translates the model
- (void) rotateMatrix:(GLKVector3)rotateMat : (float)degree; // rotates model by radians on axis

- (void) newRotate:(GLKVector3)rot; // creates new rotation matrix
- (void) resetPosRot; // resets position + rotation to 0,0,0

- (GLfloat) getArraySize;
- (GLfloat) getRenderType;
- (GLfloat) getNumIndices;
- (GLfloat) getTxtArraySize;

- (void) setArraySize : (GLfloat) size;
- (void) setRenderType : (GLfloat) render;
- (void) setNumIndices : (GLfloat) ind;
- (void) setTxtArraySize : (GLfloat) size;

@end


#endif /* Renderable_h */
