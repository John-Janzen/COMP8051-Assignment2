//
//  MazeController.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "MazeController.h"
#include "maze.h"

GLKVector3 cubeVertex[8] =
{
    GLKVector3Make(0, 1, 0),
    GLKVector3Make(0, 1, 1),
    GLKVector3Make(0, 0, 0),
    GLKVector3Make(0, 0, 1),
    GLKVector3Make(1, 1, 0),
    GLKVector3Make(1, 1, 1),
    GLKVector3Make(1, 0, 0),
    GLKVector3Make(1, 0, 1),
};

@interface MazeController () {
    
    Maze *maze;
    int height, width;
    NSMutableArray *verticesArray, *texturesArray, *normalArray;
}

@end

@implementation MazeController

- (void) Create : (int) w : (int) h {
    maze = new Maze(w, h);
    maze->Create();
    height = h;
    width = w;
}

- (NSMutableArray*) CreateFloorVertices {
    verticesArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            [self addVertices:i :j : cubeVertex[6]: cubeVertex[2]: cubeVertex[3]];
            [self addVertices:i :j : cubeVertex[3]: cubeVertex[7]: cubeVertex[6]];
            
        }
    }
    return verticesArray;
}

- (NSMutableArray*) CreateFloorTextureVertices {
    texturesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
            [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(1.0f)];
            [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
            
            [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
            [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(0.0f)];
            [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
        }
    }
    return texturesArray;
}

- (NSMutableArray*) CreateEWTextureVertices {
    texturesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (maze->GetCell(i, j).westWallPresent) {
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
            }
            if (maze->GetCell(i, j).eastWallPresent) {
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
                
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
            }
        }
    }
    return texturesArray;
}

- (NSMutableArray*) CreateNSTextureVertices {
    texturesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (maze->GetCell(i, j).northWallPresent) {
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
            }
            if (maze->GetCell(i, j).southWallPresent) {
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(1.0f)];
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                
                [texturesArray addObject:@(0.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(0.0f)];
                [texturesArray addObject:@(1.0f)]; [texturesArray addObject:@(1.0f)];
            }
        }
    }
    return texturesArray;
}

- (NSMutableArray*) CreateFloorNormalVertices {
    normalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            [self addNormals :GLKVector3Make(0.0f, 1.0f, 0.0)];
            [self addNormals :GLKVector3Make(0.0f, 1.0f, 0.0)];
        }
    }
    return normalArray;
}

- (NSMutableArray*) CreateEWNormalVertices {
    normalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (maze->GetCell(i, j).westWallPresent) {
                [self addNormals :GLKVector3Make(0.0f, 0.0f, 1.0)];
                [self addNormals :GLKVector3Make(0.0f, 0.0f, 1.0)];
            }
            if (maze->GetCell(i, j).eastWallPresent) {
                [self addNormals :GLKVector3Make(0.0f, 0.0f, -1.0)];
                [self addNormals :GLKVector3Make(0.0f, 0.0f, -1.0)];
            }
            
        }
    }
    return normalArray;
}

- (NSMutableArray*) CreateEWWallVertices {
    verticesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (maze->GetCell(i, j).westWallPresent) {
                [self addVertices:i :j : cubeVertex[4]: cubeVertex[0]: cubeVertex[2]];
                [self addVertices:i :j : cubeVertex[2]: cubeVertex[6]: cubeVertex[4]];
            }
            if (maze->GetCell(i, j).eastWallPresent) {
                [self addVertices:i :j : cubeVertex[3]: cubeVertex[1]: cubeVertex[5]];
                [self addVertices:i :j : cubeVertex[5]: cubeVertex[7]: cubeVertex[3]];
            }
        }
    }
    
    return verticesArray;
}

- (NSMutableArray*) CreateNSNormalVertices {
    normalArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (maze->GetCell(i, j).northWallPresent) {
                [self addNormals :GLKVector3Make(1.0f, 0.0f, 0.0)];
                [self addNormals :GLKVector3Make(1.0f, 0.0f, 0.0)];
            }
            if (maze->GetCell(i, j).southWallPresent) {
                [self addNormals :GLKVector3Make(-1.0f, 0.0f, 0.0)];
                [self addNormals :GLKVector3Make(-1.0f, 0.0f, 0.0)];
            }
            
        }
    }
    return normalArray;
}

- (NSMutableArray*) CreateNSWallVertices {
    verticesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            if (maze->GetCell(i, j).northWallPresent) {
                [self addVertices:i :j : cubeVertex[0]: cubeVertex[1]: cubeVertex[3]];
                [self addVertices:i :j : cubeVertex[3]: cubeVertex[2]: cubeVertex[0]];
            }
            if (maze->GetCell(i, j).southWallPresent) {
                [self addVertices:i :j : cubeVertex[5]: cubeVertex[4]: cubeVertex[6]];
                [self addVertices:i :j : cubeVertex[6]: cubeVertex[7]: cubeVertex[5]];
            }
        }
    }
    
    return verticesArray;
}

- (void) addVertices:(int)i :(int)j :(GLKVector3)x :(GLKVector3)y :(GLKVector3)z{
    [verticesArray addObject:@(x.x + i - (width /2))]; [verticesArray addObject:@(x.y)]; [verticesArray addObject:@(x.z + j - (height /2))];
    [verticesArray addObject:@(y.x + i - (width /2))]; [verticesArray addObject:@(y.y)]; [verticesArray addObject:@(y.z + j - (height /2))];
    [verticesArray addObject:@(z.x + i - (width /2))]; [verticesArray addObject:@(z.y)]; [verticesArray addObject:@(z.z + j - (height /2))];
    
}

- (void) addNormals :(GLKVector3) normal {
    [normalArray addObject:@(normal.x)]; [normalArray addObject:@(normal.y)]; [normalArray addObject:@(normal.z)];
    [normalArray addObject:@(normal.x)]; [normalArray addObject:@(normal.y)]; [normalArray addObject:@(normal.z)];
    [normalArray addObject:@(normal.x)]; [normalArray addObject:@(normal.y)]; [normalArray addObject:@(normal.z)];
}

@end
