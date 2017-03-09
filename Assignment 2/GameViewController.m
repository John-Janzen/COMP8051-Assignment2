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
#include "Wall.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_FLASHLIGHT_POSITION,
    UNIFORM_DIFFUSE_LIGHT_POSITION,
    UNIFORM_SHININESS,
    UNIFORM_AMBIENT_COMPONENT,
    UNIFORM_DIFFUSE_COMPONENT,
    UNIFORM_SPECULAR_COMPONENT,
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
    
    GLKVector3 flashlightPosition;
    GLKVector3 diffuseLightPosition;
    GLKVector4 diffuseComponent;
    float shininess;
    GLKVector4 specularComponent;
    GLKVector4 ambientComponent;
    
    float _rotation;
    NSMutableArray *renders;
    MazeController *maze;
    TextureLoad *textureLoader;
    GLfloat *floorVertices, *WallVertices, *textureArray, *normalVertices;
    float moving, moving2;
    int height, width;
    GLuint texture[6];
    
    float cameraRotationSpeed;
    
    float cameraVerticalAngle;
    float cameraHorizontalAngle;
    
    GLKVector3 cameraHorizontalMovement;
    
    GLKVector3 cameraPosition;
    GLKVector3 cameraDirection;
    GLKVector3 cameraUp;
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (void)specialUpdates:(Renderable*)render;
- (void)createFloor;
- (void)CreateWestWalls;
- (void)CreateEastWalls;
- (void)CreateNorthWalls;
- (void)CreateSouthWalls;
- (NSMutableArray*) combineArrays : (NSMutableArray*) vert : (NSMutableArray*) norm : (NSMutableArray*) tex;
- (void) cameraUpdate;
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
    maze = [[MazeController alloc] init];
    textureLoader = [[TextureLoad alloc] init];
    width = height = 10;
    cameraRotationSpeed = 0.002;
    cameraPosition = GLKVector3Make((-width / 2.0f) - 0.5f, 0.5f, (-height / 2.0f) + 0.5f);
    cameraUp = GLKVector3Make(0, 1, 0);
    cameraVerticalAngle = 0.0f; cameraHorizontalAngle = -3.14159f / 2.0;
    [maze Create:width :height];
    [self createFloor];
    
    [self CreateWestWalls];
    [self CreateEastWalls];
    [self CreateNorthWalls];
    [self CreateSouthWalls];
    
    [renders addObject:[[Cube alloc] init:@"Cube" :GLKVector3Make( (-width / 2) + 0.5f, 0.5f, (-height / 2) + 0.5f) :GLKVector3Make(0.0f, 0.0f, 0.0f) :GLKVector3Make(0.25f, 0.25f, 0.25f) : GL_TRIANGLES : 36 : NULL : 0 : 5]];
    
    moving = 0.0f;
    
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
    [self loadShaders];
    
    //self.effect = [[GLKBaseEffect alloc] init];
    //self.effect.light0.enabled = GL_TRUE;
    //self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    /* more needed here... */
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_program, "flashlightPosition");
    uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION] = glGetUniformLocation(_program, "diffuseLightPosition");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_program, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_program, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_program, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_program, "specularComponent");
    
    flashlightPosition = cameraPosition;
    diffuseLightPosition = GLKVector3Make(0.0f, 1.0f, 1.0f);
    diffuseComponent = GLKVector4Make(0.8, 0.8, 0.8, 1.0);
    shininess = 200.0;
    specularComponent = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    ambientComponent = GLKVector4Make(0.2, 0.2, 0.2, 1.0);
    
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    
    for (Renderable *render in renders) {
        
        //uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "Texture");
        glGenVertexArraysOES(1, &render->_vertexArray);
        glBindVertexArrayOES(render->_vertexArray);
        
        glGenBuffers(1, render->_vertexBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, render->_vertexBuffer[0]);
        glBufferData(GL_ARRAY_BUFFER, [render getArraySize], render->_arrayVertices, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
        
        glBindVertexArrayOES(0);
        
    }
    texture[0] = [textureLoader loadTexture:@"floorTexture.jpg"];
    texture[1] = [textureLoader loadTexture:@"leftArrowTexture.jpg"];
    texture[2] = [textureLoader loadTexture:@"rightArrowTexture.jpg"];
    texture[3] = [textureLoader loadTexture:@"NoPassTexture.jpg"];
    texture[4] = [textureLoader loadTexture:@"leftAndRightArrowsTexture.jpg"];
    texture[5] = [textureLoader loadTexture:@"crate.jpg"];
    glActiveTexture(GL_TEXTURE0);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for (Renderable *render in renders) {
        glDeleteBuffers(1, render->_vertexBuffer);
        glDeleteVertexArraysOES(1, &render->_vertexArray);
    }
    free(texture);
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
    [self cameraUpdate];
    GLKMatrix4 cameraViewMatrix = GLKMatrix4MakeLookAt(cameraPosition.x, cameraPosition.y, cameraPosition.z,
                                                       GLKVector3Subtract(cameraPosition, cameraDirection).x,
                                                       GLKVector3Subtract(cameraPosition, cameraDirection).y,
                                                       GLKVector3Subtract(cameraPosition, cameraDirection).z,
                                                       cameraUp.x, cameraUp.y, cameraUp.z);
    
    
    for (Renderable *render in renders) {
        [render transformSetup];
        
        [self specialUpdates:render];
        [render setModelMatrix:GLKMatrix4Multiply(cameraViewMatrix, [render getModelMatrix])];
        
        [render setNormalMatrix:GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3([render getModelMatrix]), NULL)];
        [render setModelProjection:GLKMatrix4Multiply(projectionMatrix, [render getModelMatrix])];
        
    }
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    /* set lighting parameters... */
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
    glUniform3fv(uniforms[UNIFORM_DIFFUSE_LIGHT_POSITION], 1, diffuseLightPosition.v);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
    glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
    glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
    glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
    
    
    for (Renderable *render in renders) {
        glBindVertexArrayOES(render->_vertexArray);
        glBindTexture(GL_TEXTURE_2D, texture[render->_texture]);
        
        // Render the object again with ES2
        glUseProgram(_program);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, [render getModelProjection].m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, [render getNormalMatrix].m);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, [render getModelMatrix].m);
        
        glDrawArrays([render getRenderType], 0, [render getNumIndices]);
    }
}

- (void) specialUpdates :(Renderable*) render{
    if ([[render getObjectID] isEqual:@"Cube"]) {
        [render rotateMatrix:GLKVector3Make(1.0f, 1.0f, 1.0f) :_rotation];
    }
    
}

- (void) cameraUpdate {
    cameraDirection = GLKVector3Make(cosf(cameraVerticalAngle) * sinf(cameraHorizontalAngle), sinf(cameraVerticalAngle), cosf(cameraVerticalAngle) * cosf(cameraHorizontalAngle));
    cameraHorizontalMovement = GLKVector3Make(sinf(cameraHorizontalAngle - M_PI_2), 0, cosf(cameraHorizontalAngle - M_PI_2));
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
        cameraPosition = GLKVector3Subtract(cameraPosition, GLKVector3MultiplyScalar(cameraDirection, 2.0f * self.timeSinceLastUpdate));
        cameraPosition.y = 0.5f;
    } else if (velocity < 0){
        cameraPosition = GLKVector3Subtract(cameraPosition, GLKVector3MultiplyScalar(cameraDirection, 2.0f * -self.timeSinceLastUpdate));
        cameraPosition.y = 0.5f;
    }
}

- (IBAction)doubleTap:(UITapGestureRecognizer *)sender {
    cameraPosition = GLKVector3Make((-width / 2.0f) - 0.5f, 0.5f, (-height / 2.0f) + 0.5f);
    cameraVerticalAngle = 0.0f; cameraHorizontalAngle = -3.14159f / 2.0;
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender translationInView:self.view];
    
    cameraHorizontalAngle -= (point.x * cameraRotationSpeed);
    
    cameraVerticalAngle += (point.y * cameraRotationSpeed);
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void) createFloor {
    NSMutableArray *floor = [maze CreateFloorVertices];
    NSMutableArray *norm = [maze CreateFloorNormalVertices];
    NSMutableArray *text = [maze CreateFloorTextureVertices];
    NSMutableArray *combine = [self combineArrays:floor :norm :text];
    [floor removeAllObjects];
    [norm removeAllObjects];
    [text removeAllObjects];
    WallVertices = (GLfloat*)malloc([combine count] * sizeof(GLfloat));
    for (int i = 0; i < [combine count]; i++) {
        WallVertices[i] = [combine[i] floatValue];
    }
    floorVertices = (GLfloat*)malloc([floor count] * sizeof(GLfloat));
    [renders addObject:[[Floor alloc] init : @"Floor" :GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : GL_TRIANGLES: combine.count / 8 : WallVertices : combine.count : 0]];
}

- (void) CreateWestWalls{
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            NSMutableArray *vertices = [maze CreateWestWallVertices: i: j];
            if (vertices.count == 0) {
                continue;
            }
            NSMutableArray *norm = [maze CreateWestNormalVertices: i : j];
            NSMutableArray *text = [maze CreateWestTextureVertices : i : j];
            NSMutableArray *combine = [self combineArrays :vertices :norm :text];
            [vertices removeAllObjects];
            [text removeAllObjects];
            [norm removeAllObjects];
            WallVertices = (GLfloat*)malloc([combine count] * sizeof(GLfloat));
            for (int i = 0; i < [combine count]; i++) {
                WallVertices[i] = [combine[i] floatValue];
            }
            [renders addObject:[[Wall alloc] init: @"WestWalls" :GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GL_TRIANGLES : (combine.count / 8) : WallVertices : combine.count : [maze getDirectionText : i : j : WALLEAST]]];
        }
    }
}

- (void) CreateEastWalls{
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            NSMutableArray *vertices = [maze CreateEastWallVertices: i: j];
            if (vertices.count == 0) {
                continue;
            }
            NSMutableArray *norm = [maze CreateEastNormalVertices: i : j];
            NSMutableArray *text = [maze CreateEastTextureVertices : i : j];
            NSMutableArray *combine = [self combineArrays :vertices :norm :text];
            [vertices removeAllObjects];
            [text removeAllObjects];
            [norm removeAllObjects];
            WallVertices = (GLfloat*)malloc([combine count] * sizeof(GLfloat));
            for (int i = 0; i < [combine count]; i++) {
                WallVertices[i] = [combine[i] floatValue];
            }
            [renders addObject:[[Wall alloc] init: @"EastWalls" :GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GL_TRIANGLES : (combine.count / 3) : WallVertices : combine.count : [maze getDirectionText : i : j : WALLEAST]]];
        }
    }
}

- (void) CreateNorthWalls{
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            NSMutableArray *vertices = [maze CreateNorthWallVertices: i: j];
            if (vertices.count == 0) {
                continue;
            }
            NSMutableArray *norm = [maze CreateNorthNormalVertices: i : j];
            NSMutableArray *text = [maze CreateNorthTextureVertices : i : j];
            NSMutableArray *combine = [self combineArrays :vertices :norm :text];
            [vertices removeAllObjects];
            [text removeAllObjects];
            [norm removeAllObjects];
            WallVertices = (GLfloat*)malloc([combine count] * sizeof(GLfloat));
            for (int i = 0; i < [combine count]; i++) {
                WallVertices[i] = [combine[i] floatValue];
            }
            [renders addObject:[[Wall alloc] init: @"NorthWalls" :GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GL_TRIANGLES : (combine.count / 3) : WallVertices : combine.count : [maze getDirectionText : i : j : WALLNORTH]]];
        }
    }
}

- (void) CreateSouthWalls{
    for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
            NSMutableArray *vertices = [maze CreateSouthWallVertices: i: j];
            if (vertices.count == 0) {
                continue;
            }
            NSMutableArray *norm = [maze CreateSouthNormalVertices: i : j];
            NSMutableArray *text = [maze CreateSouthTextureVertices : i : j];
            NSMutableArray *combine = [self combineArrays :vertices :norm :text];
            [vertices removeAllObjects];
            [text removeAllObjects];
            [norm removeAllObjects];
            WallVertices = (GLfloat*)malloc([combine count] * sizeof(GLfloat));
            for (int i = 0; i < [combine count]; i++) {
                WallVertices[i] = [combine[i] floatValue];
            }
            [renders addObject:[[Wall alloc] init: @"SouthWalls" :GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(0.0f, 0.0f, 0.0f) : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GL_TRIANGLES : (combine.count / 3) : WallVertices : combine.count : [maze getDirectionText : i : j : WALLSOUTH]]];
        }
    }
}

- (NSMutableArray*) combineArrays : (NSMutableArray*) vert : (NSMutableArray*) norm : (NSMutableArray*) tex {
    NSMutableArray *combined = [[NSMutableArray alloc] init];
    int j = 0;
    for (int i = 0; i < vert.count; i += 3) {
        [combined addObject:vert[i]]; [combined addObject:vert[i +1]]; [combined addObject:vert[i +2]];
        [combined addObject:norm[i]]; [combined addObject:norm[i +1]]; [combined addObject:norm[i +2]];
        [combined addObject:tex[j]]; [combined addObject:tex[j +1]];
        j += 2;
    }
    return combined;
}

@end
