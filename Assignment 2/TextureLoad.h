//
//  TextureLoad.h
//  Assignment 2
//
//  Created by John Janzen on 2017-03-05.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef TextureLoad_h
#define TextureLoad_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface TextureLoad : NSObject

- (GLuint) loadTexture : (NSString*) name;

@end


#endif /* TextureLoad_h */
