//
//  Cube.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef Cube_h
#define Cube_h
#include "Renderable.h"

@interface Cube : Renderable

- (id) init : (GLKVector3) pos : (GLKVector3) rot : (GLKVector3) scale : (GLfloat) renderType : (GLfloat) num;

@end


#endif /* Cube_h */
