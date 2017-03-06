//
//  TextureLoad.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-05.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "TextureLoad.h"

@implementation TextureLoad

- (GLuint) loadTexture : (NSString*) name{
    CGImageRef image = [UIImage imageNamed:name].CGImage;
    
    if (!image) {
        NSLog(@"Failed to load image %@", name);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    GLubyte * imageData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, width, height), image);
    CGContextRelease(imageContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    free(imageData);
    return texName;
}

@end
