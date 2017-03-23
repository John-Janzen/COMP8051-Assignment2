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

- (id) init {
    [super self];
    if (self) {
        minX = minY = minZ = 15;
        maxX = maxY = maxZ = -15;
    }
    return self;
}

- (void) updateBounds: (GLfloat*) vertices : (GLfloat) count : (GLKMatrix4)modelView {
    GLKVector4 verticesModeled = GLKVector4Make(vertices[0], vertices[1], vertices[2], 1);
    verticesModeled = GLKMatrix4MultiplyVector4(modelView, verticesModeled);
    minX = maxX = verticesModeled.x;
    minY = maxY = verticesModeled.y;
    minZ = maxZ = verticesModeled.z;
    for (int i = 10; i < count; i+= 10) {
        verticesModeled = GLKVector4Make(vertices[i], vertices[i + 1], vertices[i + 2], 1);
        verticesModeled = GLKMatrix4MultiplyVector4(modelView, verticesModeled);
        if (verticesModeled.x > maxX) maxX = verticesModeled.x;
        if (verticesModeled.y > maxY) maxY = verticesModeled.y;
        if (verticesModeled.z > maxZ) maxZ = verticesModeled.z;
        if (verticesModeled.x < minX) minX = verticesModeled.x;
        if (verticesModeled.y < minY) minY = verticesModeled.y;
        if (verticesModeled.z < minZ) minZ = verticesModeled.z;
    }
}

- (id) createEmptyBounds : (int) wh : (int) x {
    
    maxX = minX = wh / 2;
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            if (i > maxY) maxY = i;
            if (j + wh/2 > maxZ) maxZ = j + wh/2;
            if (i < minY) minY = i;
            if (j + wh/2 < minZ) minZ = j + wh/2;
        }
    }
    return self;
}



@end
