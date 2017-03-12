//
//  Shader.vsh
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//
precision mediump float;

attribute vec4 position;
attribute vec3 normal;
attribute vec2 TexCoordIn;

varying vec3 eyeNormal;
varying vec4 eyePos;
varying vec2 TexCoordOut;
varying vec3 spotDirection;
varying vec3 lightPosition;

uniform vec4 flashlightPosition;
uniform vec3 flashlightDirection;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

void main()
{
    eyeNormal = (normalMatrix * normal);
    
    eyePos = modelViewMatrix * position;
    
    TexCoordOut = TexCoordIn;
    
    lightPosition = (modelViewMatrix * flashlightPosition).xyz;
    
    spotDirection = normalize(normalMatrix * flashlightDirection);
    
    gl_Position = modelViewProjectionMatrix * position;
}
