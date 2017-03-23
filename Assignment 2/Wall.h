//
//  Wall.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-08.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef Wall_h
#define Wall_h
#include "Renderable.h"

@interface Wall : Renderable

- (id) init : (NSString*) name :(GLKVector3) pos : (GLKVector3) rot : (GLKVector3) scale : (GLKVector3) normalDirect
            : (GLfloat) renderType : (GLfloat) num : (GLfloat*) array
            : (GLfloat) count  : (int) textureNum : (BOOL) bound : (BOOL) collidable;

@end


#endif /* Wall_h */
