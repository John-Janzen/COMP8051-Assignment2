//
//  Floor.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Renderable.h"
#include "Floor.h"

@implementation Floor

- (id) init: (NSString*) name : (GLKVector3)pos : (GLKVector3)rot : (GLKVector3)scale : (GLKVector3) normalDirect
           : (GLfloat)renderType : (GLfloat)num : (GLfloat *)array : (GLfloat) count
           : (int) textureNum : (BOOL) bound : (BOOL) collidable {
    self = [super init];
    if (self) {
        [super setObjectID:name];
        _positionVector = pos;
        _rotateVector = rot;
        _scaleVector = scale;
        [super transformSetup];
        _arrayVertices = array;
        [super setNumIndices:num];
        [super setRenderType:renderType];
        [super setArraySize: (count * sizeof(GLfloat))];
        _texture = textureNum;
        _normalDirection = normalDirect;
        if (bound) {
            _bounds = [[BoundingBox alloc] init];
            [_bounds updateBounds:array :count :[super getModelMatrix]];
        } else {
            _bounds = NULL;
        }
        [super setCollidable:collidable];
    }
    return self;
}

@end
