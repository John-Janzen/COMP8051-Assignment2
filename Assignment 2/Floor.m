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

- (id) init:(GLKVector3)pos :(GLKVector3)rot :(GLKVector3)scale
           :(GLfloat)renderType :(GLfloat)num :(GLfloat *)array :(GLfloat) count
           : (GLfloat*) txtArray : (NSString*) texture : (GLfloat) size : (GLfloat*) normArray : (GLfloat) size3{
    self = [super init];
    if (self) {
        _positionVector = pos;
        _rotateVector = rot;
        _scaleVector = scale;
        _arrayVertices = array;
        [super setNumIndices:num];
        [super setRenderType:renderType];
        [super setArraySize: (count * sizeof(GLfloat))];
        [super setTxtArraySize:(size * sizeof(GLfloat))];
        [super setNormArraySize:(size3 * sizeof(GLfloat))];
        _texture = texture;
        _textureArray = txtArray;
        _normalArray = normArray;
    }
    return self;
}

@end
