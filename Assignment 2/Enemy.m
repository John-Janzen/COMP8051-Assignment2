//
//  Enemy.m
//  Assignment 2
//
//  Created by 李晨 on 20/03/2017.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Enemy.h"


@implementation Enemy : NSObject

- (void) customStringFromFile
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"enemyModel5" ofType:@"obj"];
    NSString * StringContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray * lines = [StringContent componentsSeparatedByString:@"\n"];
    
    _Vertex = [[NSMutableArray alloc] init];
    _VertexNormal = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];
    
    for (NSString * line in lines)
    {
        if ([line hasPrefix:@"v "])
        {
            NSString *Deletespace = [line substringFromIndex:2];
            NSString * RowtoColum = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowtoColum)
            {
                float vertexVVV = [number floatValue];
                [_Vertex addObject:[NSNumber numberWithFloat:vertexVVV]];
            }
        }
        else if([line hasPrefix:@"vn "])
        {
            NSString * Deletespace = [line substringFromIndex:3];
            NSString * RowtoColum2 = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowtoColum2)
            {
                float vertexNNN = [number floatValue];
                [_VertexNormal addObject:[NSNumber numberWithFloat:vertexNNN]];
                
            }
            
        }else if([line hasPrefix:@"f "])
            
        {
            NSString * Deletespace = [line substringFromIndex:2];
            NSString * RowtoColum3 = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowtoColum3)
            {
                
                NSString * individualNumbers = [number componentsSeparatedByString:@"/"];
                NSMutableArray *facePointNumbers = [[NSMutableArray alloc] init];
                for (NSString * individualNumber in individualNumbers)
                {
                    int vertexPoint = [individualNumber intValue];
                    [facePointNumbers addObject:[NSNumber numberWithInteger:vertexPoint]];
                }
                [_faces addObject:facePointNumbers];
            }
            
        }
        
    }
}
@end

