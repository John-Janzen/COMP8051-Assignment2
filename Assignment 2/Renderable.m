//
//  Renderable.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Renderable.h"

@implementation Renderable

- (void) transformSetup {
    [self makeTranslationSetUp];
    [self rotateMatrixSetup];
}

- (void) makeTranslationSetUp {
    _modelMatrix = GLKMatrix4MakeTranslation(_positionVector.x, _positionVector.y, _positionVector.z);
}

- (void) rotateMatrixSetup {
    GLKMatrix4 newMatrix = GLKMatrix4Identity;
    newMatrix = GLKMatrix4RotateX(newMatrix, _rotateVector.x);
    newMatrix = GLKMatrix4RotateY(newMatrix, _rotateVector.y);
    _modelMatrix = GLKMatrix4Multiply(_modelMatrix, GLKMatrix4RotateZ(newMatrix, _rotateVector.z));
    
}

- (void) setModelMatrix:(GLKMatrix4)matrix {
    _modelMatrix = matrix;
}

- (void) setNormalMatrix:(GLKMatrix3)matrix {
    _normalMatrix = matrix;
}

- (void) setModelProjection:(GLKMatrix4)matrix {
    _modelViewProjection = matrix;
}


- (GLKMatrix4) getModelMatrix {
    return _modelMatrix;
}

- (GLKMatrix3) getNormalMatrix {
    return _normalMatrix;
}

- (GLKMatrix4) getModelProjection {
    return _modelViewProjection;
}


- (void) rotateMatrix:(GLKVector3)rotateMat : (float) degree {
    _modelMatrix = GLKMatrix4RotateWithVector3(_modelMatrix, degree, rotateMat);
}

- (void) translateMatrix:(GLKVector3)moveVector{
    _positionVector = GLKVector3Add(_positionVector, moveVector);
}

- (void) newRotate:(GLKVector3)rot {
    _rotateVector = GLKVector3Add(_rotateVector, rot);
}


- (void) resetPosRot {
    _positionVector = GLKVector3Make(0.0f, 0.0f, 0.0f);
    _rotateVector = GLKVector3Make(0.0f, 0.0f, 0.0f);
}

- (GLfloat) getArraySize {
    return _arraySize;
}

- (GLfloat) getRenderType {
    return _renderType;
}

- (GLfloat) getNumIndices {
    return _numOfIndices;
}

- (GLfloat) getTxtArraySize {
    return _txtArraySize;
}

- (GLfloat) getNormArraySize {
    return _normArraySize;
}

- (NSString*) getObjectID {
    return _ID;
}

- (void) setArraySize : (GLfloat) size{
    _arraySize = size;
}

- (void) setRenderType : (GLfloat) render{
    _renderType = render;
}

- (void) setNumIndices : (GLfloat) ind{
    _numOfIndices = ind;
}

- (void) setTxtArraySize:(GLfloat)size {
    _txtArraySize = size;
}

- (void) setNormArraySize:(GLfloat)size {
    _normArraySize = size;
}

- (void) setObjectID:(NSString *)name {
    _ID = name;
}

@end
