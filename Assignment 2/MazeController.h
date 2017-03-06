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
- (NSMutableArray*) CreateEWWallVertices;
- (NSMutableArray*) CreateNSWallVertices;
- (NSMutableArray*) CreateTextureVertices;
- (void) addVertices : (int) i : (int) j : (GLKVector3) normal : (GLKVector3) x : (GLKVector3) y : (GLKVector3) z;

@end


#endif /* MazeController_h */
