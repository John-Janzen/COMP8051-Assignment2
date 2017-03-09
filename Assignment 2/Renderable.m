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
    _modelMatrix = GLKMatrix4Identity;
    [self rotateMatrixSetup];
    [self makeTranslationSetUp];
    [self scaleMatrixSetup];
}

- (void) makeTranslationSetUp {
    _modelMatrix = GLKMatrix4TranslateWithVector3(_modelMatrix, _positionVector);
}

- (void) rotateMatrixSetup {
    _modelMatrix = GLKMatrix4RotateX(_modelMatrix, _rotateVector.x);
    _modelMatrix = GLKMatrix4RotateY(_modelMatrix, _rotateVector.y);
    _modelMatrix = GLKMatrix4RotateZ(_modelMatrix, _rotateVector.z);
    //_modelMatrix = GLKMatrix4TranslateWithVector3(_modelMatrix, GLKVector3Negate(_positionVector));
    //NSLog(@"_positionVector Z: %.1f", _positionVector.z);
    //NSLog(@"_positionVector Negate Z: %.1f", GLKVector3Negate(_positionVector).z);
    //_modelMatrix = GLKMatrix4TranslateWithVector3(_modelMatrix, _positionVector);
    
}

- (void) scaleMatrixSetup {
    _modelMatrix = GLKMatrix4ScaleWithVector3(_modelMatrix, _scaleVector);
}

- (void) rotateMatrix:(GLKVector3)rotateMat : (float) degree {
    [self removeScaleFactor];
    //_modelMatrix = GLKMatrix4TranslateWithVector3(_modelMatrix, GLKVector3Negate(_positionVector));
    _modelMatrix = GLKMatrix4RotateWithVector3(_modelMatrix, degree, rotateMat);
    //_modelMatrix = GLKMatrix4TranslateWithVector3(_modelMatrix, _positionVector);
    [self scaleMatrixSetup];
}

- (void) removeScaleFactor {
    _modelMatrix = GLKMatrix4Scale(_modelMatrix, 1.0f / _scaleVector.x, 1.0f / _scaleVector.y, 1.0f / _scaleVector.z);
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


- (void) translateMatrix:(GLKVector3)moveVector{
    [self removeScaleFactor];
    _modelMatrix = GLKMatrix4TranslateWithVector3(_modelMatrix, moveVector);
    [self scaleMatrixSetup];
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
