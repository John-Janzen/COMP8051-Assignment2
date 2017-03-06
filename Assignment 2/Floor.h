//
//  Floor.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef Floor_h
#define Floor_h

@interface Floor : Renderable

- (id) init : (GLKVector3) pos : (GLKVector3) rot : (GLKVector3) scale
            : (GLfloat) renderType : (GLfloat) num : (GLfloat*) array
            : (GLfloat) count : (GLfloat*) txtArray : (GLuint) texture : (GLfloat) size;

@end


#endif /* Floor_h */
