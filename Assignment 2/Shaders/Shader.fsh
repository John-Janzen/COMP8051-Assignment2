//
//  Shader.fsh
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//
precision mediump float;

float fogDensity = 0.5;
const float LOG2 = 1.442695;
float spotCutoff = 10.0;

varying vec3 eyeNormal;
varying vec4 eyePos;
varying vec2 TexCoordOut;
varying vec3 spotDirection;
varying vec3 lightPosition;
uniform sampler2D Texture;

uniform vec4 fogColor;
uniform vec4 diffuseComponent;
uniform float shininess;
uniform vec4 specularComponent;
uniform vec4 ambientComponent;

void main()
{
    vec4 specular;
    float z = gl_FragCoord.z / gl_FragCoord.w;
    float fogFactor = exp2(-fogDensity * fogDensity * z * z * LOG2);
    fogFactor = clamp(fogFactor, 0.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(spotDirection)));
    vec4 diffuse = diffuseComponent * nDotVP;

    vec3 E = normalize(-eyePos.xyz);
    vec3 L = normalize(lightPosition - eyePos.xyz);
    float Ks = pow(max(dot(eyeNormal, normalize(L+E)), 0.0), shininess);
    
    float lightDist = length(L);
    float attenuation = 1.0 / (1.0 + 0.007 * lightDist +  0.000008 * lightDist * lightDist);
    
    float angle = max(dot(spotDirection, -normalize(eyePos.xyz - lightPosition)), 0.0);
    
    if (acos(angle) > radians(spotCutoff)) {
        specular = vec4(0,0,0,1);
        diffuse = vec4(0,0,0,1);
    } else {
        specular = Ks*specularComponent;
    }
    
    gl_FragColor = mix(fogColor, (ambientComponent + specular + (diffuse * attenuation)) * texture2D(Texture, TexCoordOut), fogFactor);
    gl_FragColor.a = 1.0;
}
