//
//  BoundingBox.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef BoundingBox_h
#define BoundingBox_h
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface BoundingBox : NSObject {
    
    GLfloat minX, minY, minZ;
    GLfloat maxX, maxY, maxZ;
    
}

- (id) init : (GLfloat*) vertices : (GLfloat) count ;

@end


#endif /* BoundingBox_h */
