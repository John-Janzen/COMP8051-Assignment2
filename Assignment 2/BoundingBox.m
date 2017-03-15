//
//  BoundingBox.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "BoundingBox.h"

@implementation BoundingBox

- (id) init : (GLfloat*) vertices : (GLfloat) count {
    self = [super init];
    if (self) {
        minX = maxX = vertices[0];
        minY = maxY = vertices[1];
        minZ = maxZ = vertices[2];
        for (int i = 10; i < count; i+= 10) {
            if (vertices[i] > maxX) maxX = vertices[i];
            if (vertices[i + 1] > maxY) maxY = vertices[i + 1];
            if (vertices[i + 2] > maxZ) maxZ = vertices[i + 2];
            if (vertices[i] < minX) minX = vertices[i];
            if (vertices[i + 1] < minY) minY = vertices[i + 1];
            if (vertices[i + 2] < minZ) minZ = vertices[i + 2];
        }
    }
    return self;
}

@end
