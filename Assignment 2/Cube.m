//
//  Cube.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Cube.h"

GLfloat gCubeVertexData[] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f, 1.0f,       1.0f, 0.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    0.5f, 0.5f, -0.5f, 1.0f,        1.0f, 0.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    0.5f, -0.5f, 0.5f, 1.0f,        1.0f, 0.0f, 0.0f, 1.0f,   0.0f, 1.0f,
    0.5f, -0.5f, 0.5f, 1.0f,        1.0f, 0.0f, 0.0f, 1.0f,   0.0f, 1.0f,
    0.5f, 0.5f, -0.5f, 1.0f,        1.0f, 0.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    0.5f, 0.5f, 0.5f, 1.0f,         1.0f, 0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    
    0.5f, 0.5f, -0.5f, 1.0f,        0.0f, 1.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f, 1.0f,       0.0f, 1.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    0.5f, 0.5f, 0.5f, 1.0f,         0.0f, 1.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    0.5f, 0.5f, 0.5f, 1.0f,         0.0f, 1.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f, 1.0f,       0.0f, 1.0f, 0.0f, 1.0f,   0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f, 1.0f,        0.0f, 1.0f, 0.0f, 1.0f,   0.0f, 1.0f,
    
    -0.5f, 0.5f, -0.5f, 1.0f,       -1.0f, 0.0f, 0.0f, 1.0f,  1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f, 1.0f,      -1.0f, 0.0f, 0.0f, 1.0f,  0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f, 1.0f,        -1.0f, 0.0f, 0.0f, 1.0f,  1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f, 1.0f,        -1.0f, 0.0f, 0.0f, 1.0f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, 1.0f,      -1.0f, 0.0f, 0.0f, 1.0f,  0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f, 1.0f,       -1.0f, 0.0f, 0.0f, 1.0f,  0.0f, 1.0f,
    
    -0.5f, -0.5f, -0.5f, 1.0f,      0.0f, -1.0f, 0.0f, 1.0f,  0.0f, 0.0f,
    0.5f, -0.5f, -0.5f, 1.0f,       0.0f, -1.0f, 0.0f, 1.0f,  1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f, 1.0f,       0.0f, -1.0f, 0.0f, 1.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f, 1.0f,       0.0f, -1.0f, 0.0f, 1.0f,  0.0f, 1.0f,
    0.5f, -0.5f, -0.5f, 1.0f,       0.0f, -1.0f, 0.0f, 1.0f,  1.0f, 0.0f,
    0.5f, -0.5f, 0.5f, 1.0f,        0.0f, -1.0f, 0.0f, 1.0f,  1.0f, 1.0f,
    
    0.5f, 0.5f, 0.5f, 1.0f,         0.0f, 0.0f, 1.0f, 1.0f,   1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f, 1.0f,        0.0f, 0.0f, 1.0f, 1.0f,   0.0f, 1.0f,
    0.5f, -0.5f, 0.5f, 1.0f,        0.0f, 0.0f, 1.0f, 1.0f,   1.0f, 0.0f,
    0.5f, -0.5f, 0.5f, 1.0f,        0.0f, 0.0f, 1.0f, 1.0f,   1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,  1.0f,       0.0f, 0.0f, 1.0f, 1.0f,   0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f, 1.0f,       0.0f, 0.0f, 1.0f, 1.0f,   0.0f, 0.0f,
    
    0.5f, -0.5f, -0.5f, 1.0f,       0.0f, 0.0f, -1.0f, 1.0f,  1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,1.0f,       0.0f, 0.0f, -1.0f, 1.0f,  0.0f, 0.0f,
    0.5f, 0.5f, -0.5f, 1.0f,        0.0f, 0.0f, -1.0f, 1.0f,  1.0f, 1.0f,
    0.5f, 0.5f, -0.5f, 1.0f,        0.0f, 0.0f, -1.0f, 1.0f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f, 1.0f,      0.0f, 0.0f, -1.0f, 1.0f,  0.0f, 0.0f,
    -0.5f, 0.5f, -0.5f, 1.0f,       0.0f, 0.0f, -1.0f, 1.0f,  0.0f, 1.0f
};

@implementation Cube

- (id) init: (NSString*) name :(GLKVector3)pos :(GLKVector3)rot :(GLKVector3)scale : (GLKVector3) normalDirect
           :(GLfloat)renderType :(GLfloat)num :(GLfloat *)array :(GLfloat) count : (int) textureNum : (BOOL) bound : (BOOL) collidable {
    self = [super init];
    if (self) {
        [super setObjectID:name];
        _positionVector = pos;
        _rotateVector = rot;
        _scaleVector = scale;
        [super transformSetup];
        _arrayVertices = gCubeVertexData;
        [super setNumIndices: num];
        [super setRenderType: renderType];
        [super setArraySize: sizeof(gCubeVertexData)];
        _texture = textureNum;
        _normalDirection = normalDirect;
        if (bound) {
            _bounds = [[BoundingBox alloc] init];
            [_bounds updateBounds: gCubeVertexData :sizeof(gCubeVertexData) :[super getModelMatrix]];
        } else {
            _bounds = NULL;
        }
        [super setCollidable:collidable];
    }
    return self;
}

@end
