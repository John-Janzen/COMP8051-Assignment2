//
//  MazeController.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef MazeController_h
#define MazeController_h

typedef enum : NSUInteger {
    WALLWEST,
    WALLEAST,
    WALLSOUTH,
    WALLNORTH
} WallDirection;

@interface MazeController : NSObject

- (void) Create : (int) h : (int) y;
- (NSMutableArray*) CreateFloorVertices;
- (NSMutableArray*) CreateFloorNormalVertices;
- (NSMutableArray*) CreateFloorTextureVertices;

- (NSMutableArray*) CreateWestWallVertices :(int) i :(int) j;
- (NSMutableArray*) CreateWestNormalVertices :(int) i :(int) j;
- (NSMutableArray*) CreateWestTextureVertices :(int) i :(int) j;

- (NSMutableArray*) CreateEastWallVertices :(int) i :(int) j;
- (NSMutableArray*) CreateEastNormalVertices :(int) i :(int) j;
- (NSMutableArray*) CreateEastTextureVertices :(int) i :(int) j;

- (NSMutableArray*) CreateNorthWallVertices :(int) i :(int) j;
- (NSMutableArray*) CreateNorthNormalVertices :(int) i :(int) j;
- (NSMutableArray*) CreateNorthTextureVertices :(int) i :(int) j;

- (NSMutableArray*) CreateSouthWallVertices :(int) i :(int) j;
- (NSMutableArray*) CreateSouthNormalVertices :(int) i :(int) j;
- (NSMutableArray*) CreateSouthTextureVertices :(int) i :(int) j;

- (void) addVertices : (int) i : (int) j : (GLKVector3) x : (GLKVector3) y : (GLKVector3) z;
- (void) addNormals : (GLKVector3) normal;

- (GLfloat) getDirectionText : (int) i : (int) j : (WallDirection) direct;
- (void) createMiniMap : (UIView*) view;

@end


#endif /* MazeController_h */
