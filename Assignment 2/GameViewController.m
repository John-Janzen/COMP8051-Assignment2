//
//  GameViewController.m
//  Assignment 2
//
//  Created by John Janzen on 2017-03-04.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#include "Cube.h"
#include "MazeController.h"
#include "Floor.h"
#include "TextureLoad.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
    
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface GameViewController () {
    GLuint _program;
    
    
    float _rotation;
    NSMutableArray *renders;
    MazeController *maze;
    TextureLoad *textureLoader;
    GLfloat *floorVertices, *EWWallVertices, *NSWallVertices, *textureArray, *normalVertices;
    float moving, moving2;
    int height, width;
    GLuint texture[3];
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (float)createFloor;
- (float)createEWWalls;
- (float)createNSWalls;
- (float)createEWTexture;
- (float)createNSTexture;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    renders = [[NSMutableArray alloc] init];
    renders = [NSMutableArray arrayWithCapacity:1];
    maze = [[MazeController alloc] init];
    textureLoader = [[TextureLoad alloc] init];
    width = height = 4;
    [maze Create:width :height];
    float size = [self createFloor];
    float size2 = [self createFloorTexture];
    float size3 = [self createFloorNormals];
    
    [renders addObject:[[Floor alloc] init : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : GL_TRIANGLES: (size / 3) : floorVertices : size : textureArray : @"floorTexture.jpg" : size2 : normalVertices : size3]];
    size = [self createEWWalls];
    size2 = [self createEWTexture];
    size3 = [self createEWNormals];
    [renders addObject:[[Floor alloc] init : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : GL_TRIANGLES: (size / 3) : EWWallVertices : size : textureArray : @"wallEWTexture.jpg" : size2 : normalVertices : size3]];
    size = [self createNSWalls];
    size2 = [self createNSTexture];
    size3 = [self createNSNormals];
    [renders addObject:[[Floor alloc] init : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : GL_TRIANGLES: (size / 3) : NSWallVertices : size : textureArray : @"wallNSTexture.jpg" : size2 : normalVertices : size3]];
    moving = -5.0f;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    int i = 0;
    [self loadShaders];
    
    //self.effect = [[GLKBaseEffect alloc] init];
    //self.effect.light0.enabled = GL_TRUE;
    //self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    
    for (Renderable *render in renders) {
        
        //uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "Texture");
        glGenVertexArraysOES(1, &render->_vertexArray);
        glBindVertexArrayOES(render->_vertexArray);
        
        glGenBuffers(3, render->_vertexBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, render->_vertexBuffer[0]);
        glBufferData(GL_ARRAY_BUFFER, [render getArraySize], render->_arrayVertices, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), BUFFER_OFFSET(0));
        
        glBindBuffer(GL_ARRAY_BUFFER, render->_vertexBuffer[1]);
        glBufferData(GL_ARRAY_BUFFER, [render getNormArraySize], render->_normalArray, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), BUFFER_OFFSET(0));
        
        glBindBuffer(GL_ARRAY_BUFFER, render->_vertexBuffer[2]);
        glBufferData(GL_ARRAY_BUFFER, [render getTxtArraySize], render->_textureArray, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), BUFFER_OFFSET(0));
        
        glBindVertexArrayOES(0);
        
        texture[i++] =  [textureLoader loadTexture:(render->_texture)];
        glActiveTexture(GL_TEXTURE0);
        glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for (Renderable *render in renders) {
        glDeleteBuffers(3, render->_vertexBuffer);
        glDeleteVertexArraysOES(1, &render->_vertexArray);
    }
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, -2.0f, moving);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, moving2, 0.0f, 1.0f, 0.0f);
    
    for (Renderable *render in renders) {
        // Compute the model view matrix for the object rendered with ES2
        [render transformSetup];
        //[render rotateMatrix:GLKVector3Make(0.0f, 1.0f, 0.0f) :_rotation];
        [render setModelMatrix: GLKMatrix4Multiply(baseModelViewMatrix, [render getModelMatrix])];
        
        [render setNormalMatrix:GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3([render getModelMatrix]), NULL)];
        [render setModelProjection:GLKMatrix4Multiply(projectionMatrix, [render getModelMatrix])];
        
    }
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    int i = 0;
    for (Renderable *render in renders) {
        glBindVertexArrayOES(render->_vertexArray);
        glBindTexture(GL_TEXTURE_2D, texture[i++]);
        
        // Render the object again with ES2
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, [render getModelProjection].m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, [render getNormalMatrix].m);
        
        glDrawArrays([render getRenderType], 0, [render getNumIndices]);
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "TexCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "Texture");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (IBAction)pinch:(UIPinchGestureRecognizer *)sender {
    float velocity = [sender velocity];
    if (velocity > 0) {
        moving += 1.0 * self.timeSinceLastUpdate;
    } else if (velocity < 0){
        moving -= 1.0 * self.timeSinceLastUpdate;
    }
    NSLog(@"%.1f", moving);
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    CGPoint velocity = [sender velocityInView:self.view];
    if (velocity.x > 0) {
        moving2 += 1.0 * self.timeSinceLastUpdate;
    } else if (velocity.x < 0) {
        moving2 -= 1.0 * self.timeSinceLastUpdate;
    }
}

- (float) createFloor {
    NSMutableArray *floor = [maze CreateFloorVertices];
    floorVertices = (GLfloat*)malloc([floor count] * sizeof(GLfloat));
    for (int i = 0; i < [floor count]; i++) {
        floorVertices[i] = [floor[i] floatValue];
    }
    return floor.count;
}

- (float) createEWWalls {
    NSMutableArray *walls = [maze CreateEWWallVertices];
    EWWallVertices = (GLfloat*)malloc([walls count] * sizeof(GLfloat));
    for (int i = 0; i < [walls count]; i++) {
        EWWallVertices[i] = [walls[i] floatValue];
    }
    return walls.count;
}

- (float) createEWNormals {
    NSMutableArray *norm = [maze CreateEWNormalVertices];
    normalVertices = (GLfloat*)malloc([norm count] * sizeof(GLfloat));
    for (int i = 0; i < [norm count]; i++) {
        normalVertices[i] = [norm[i] floatValue];
    }
    return norm.count;
}

- (float) createNSWalls {
    NSMutableArray *walls = [maze CreateNSWallVertices];
    NSWallVertices = (GLfloat*)malloc([walls count] * sizeof(GLfloat));
    for (int i = 0; i < [walls count]; i++) {
        NSWallVertices[i] = [walls[i] floatValue];
    }
    return walls.count;
}

- (float) createNSNormals {
    NSMutableArray *norm = [maze CreateNSNormalVertices];
    normalVertices = (GLfloat*)malloc([norm count] * sizeof(GLfloat));
    for (int i = 0; i < [norm count]; i++) {
        normalVertices[i] = [norm[i] floatValue];
    }
    return norm.count;
}

- (float) createFloorTexture {
    NSMutableArray *text = [maze CreateFloorTextureVertices];
    textureArray = (GLfloat*)malloc([text count] * sizeof(GLfloat));
    for (int i = 0; i < [text count]; i++) {
        textureArray[i] = [text[i] floatValue];
    }
    return text.count;
}

- (float) createEWTexture {
    NSMutableArray *text = [maze CreateEWTextureVertices];
    textureArray = (GLfloat*)malloc([text count] * sizeof(GLfloat));
    for (int i = 0; i < [text count]; i++) {
        textureArray[i] = [text[i] floatValue];
    }
    return text.count;
}

- (float) createNSTexture {
    NSMutableArray *text = [maze CreateNSTextureVertices];
    textureArray = (GLfloat*)malloc([text count] * sizeof(GLfloat));
    for (int i = 0; i < [text count]; i++) {
        textureArray[i] = [text[i] floatValue];
    }
    return text.count;
}

- (float) createFloorNormals {
    NSMutableArray *norm = [maze CreateFloorNormalVertices];
    normalVertices = (GLfloat*)malloc([norm count] * sizeof(GLfloat));
    for (int i = 0; i < [norm count]; i++) {
        normalVertices[i] = [norm[i] floatValue];
    }
    return norm.count;
}

@end
