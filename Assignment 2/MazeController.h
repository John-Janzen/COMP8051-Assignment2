//
//  MazeController.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef MazeController_h
#define MazeController_h

@interface MazeController : NSObject

- (void) Create : (int) h : (int) y;
- (NSMutableArray*) CreateFloorVertices;
- (NSMutableArray*) CreateFloorNormalVertices;
- (NSMutableArray*) CreateEWWallVertices;
- (NSMutableArray*) CreateEWNormalVertices;
- (NSMutableArray*) CreateNSWallVertices;
- (NSMutableArray*) CreateNSNormalVertices;
- (NSMutableArray*) CreateFloorTextureVertices;
- (NSMutableArray*) CreateEWTextureVertices;
- (NSMutableArray*) CreateNSTextureVertices;
- (void) addVertices : (int) i : (int) j : (GLKVector3) x : (GLKVector3) y : (GLKVector3) z;
- (void) addNormals : (GLKVector3) normal;

@end


#endif /* MazeController_h */
