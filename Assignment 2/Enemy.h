//
//  Enemy.h
//  Assignment 2
//
//  Created by 李晨 on 20/03/2017.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef Enemy_h
#define Enemy_h
#import <GLKit/GLKit.h>

@interface Enemy : NSObject {
    GLKVector3 Vec3;
@public
    NSMutableArray *_Vertex;
    NSMutableArray *_VertexNormal;
    NSMutableArray *_faces;
}


- (void) customStringFromFile;


@end
#endif /* Enemy_h */
