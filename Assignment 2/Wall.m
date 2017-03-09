//
//  Wall.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-08.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Wall.h"

@implementation Wall

- (id) init:(NSString*) name : (GLKVector3)pos :(GLKVector3)rot :(GLKVector3)scale
           :(GLfloat)renderType :(GLfloat)num :(GLfloat *)array :(GLfloat) count
           :(int) textureNum{
    self = [super init];
    if (self) {
        [super setObjectID:name];
        _positionVector = pos;
        _rotateVector = rot;
        _scaleVector = scale;
        _arrayVertices = array;
        [super setNumIndices:num];
        [super setRenderType:renderType];
        [super setArraySize: (count * sizeof(GLfloat))];
        _texture = textureNum;
    }
    return self;
}

@end
