//
//  Shader.fsh
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main()
{
    gl_FragColor = colorVarying * texture2D(Texture, TexCoordOut);
}
