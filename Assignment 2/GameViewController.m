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
#include "BoundingBox.h"
#include "Enemy.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
typedef struct{
    GLKVector3 VertexP;
    GLKVector3 VertexN;
}  TheGOTAChen;

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_FLASHLIGHT_POSITION,
    UNIFORM_FLASHLIGHT_DIRECTION,
    UNIFORM_FOG_COLOR,
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
    
    GLKVector4 flashlightPosition;
    GLKVector3 flashlightDirection;
    GLKVector4 fogColor;
    GLKVector4 diffuseComponent;
    float shininess;
    GLKVector4 specularComponent;
    GLKVector4 ambientComponent;
    
    float _rotation, _moving;
    NSMutableArray *renders, *extraBounds;
    MazeController *maze;
    TextureLoad *textureLoader;
    
    BoundingBox *entrance, *exit;
    GLfloat *floorVertices, *WallVertices, *textureArray, *normalVertices;
    float moving, moving2;
    int height, width;
    GLuint texture[6];
    GLfloat *enemyStuff;
    
    BOOL dayNight, fogEffect, flashLight, collided;
    
    float cameraRotationSpeed;
    
    float cameraVerticalAngle;
    float cameraHorizontalAngle;
    
    GLKVector3 cameraHorizontalMovement;
    
    GLKVector3 cameraPosition, initCameraPos;
    GLKVector3 cameraDirection;
    GLKVector3 cameraUp;
    GLKMatrix4 diffuseDirection;
    GLKVector3 enemyDirection;
    UIImageView *imageView;
    UIView *map;
    
    int numOfVertices;
    
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
- (void)collisionUpdate:(Renderable*)render;
- (void)createFloor;
- (void)CreateWestWalls;
- (void)CreateEastWalls;
- (void)CreateNorthWalls;
- (void)CreateSouthWalls;
- (NSMutableArray*) combineArrays : (NSMutableArray*) vert : (NSMutableArray*) norm : (NSMutableArray*) tex;
- (void)cameraUpdate;
- (void)changeEnemyDirection;
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
    
    map = [self.view viewWithTag:4];
    
    
    renders = [[NSMutableArray alloc] init];
    maze = [[MazeController alloc] init];
    textureLoader = [[TextureLoad alloc] init];
    width = height = 10;
    numOfVertices = 10;
    cameraRotationSpeed = 0.002;
    cameraPosition = initCameraPos = GLKVector3Make((-width / 2.0f) - 0.5f, 0.5f, (-height / 2.0f) + 0.5f);
    cameraUp = GLKVector3Make(0, 1, 0);
    enemyDirection = GLKVector3Make(1.0f, 0.0f, 0.0f);
    cameraVerticalAngle = 0.0f; cameraHorizontalAngle = -M_PI_2;
    
    Enemy *frog = [[Enemy alloc] init];
    [frog customStringFromFile];
    //    NSMutableArray *vertexData = [[NSMutableArray alloc] init];
    //
    //    for (NSArray *face in frog->_faces)
    //    {
    //        for (NSNumber *vertex in face)
    //        {
    //            int vertIndex = [vertex integerValue];
    //
    //            [vertexData addObject:frog->_Vertex[vertIndex - 1]];
    //        }
    //    }
    
//        TheGOTAChen vertData[frog->_faces.count];
//        int faceCounter = 0;
//        for (NSMutableArray *face in frog->_faces)
//        {
//            int vertIndex = [face[0] integerValue] - 1;
//            float vertX = [frog->_Vertex[vertIndex] floatValue];
//            float vertY = [frog->_Vertex[vertIndex + 1] floatValue];
//            float vertZ = [frog->_Vertex[vertIndex + 2] floatValue];
//            
//            vertData[faceCounter].VertexP = GLKVector3Make(vertX, vertY, vertZ);
//    
//            faceCounter += 3;
//            for (NSNumber *vertex in face)
//            {
//                int vertIndex = [vertex integerValue];
//    
//                [vertexData addObject:frog->_Vertex[vertIndex - 1]];
//            }
//        }
    
    
    enemyStuff = (GLfloat*) malloc(sizeof(GLfloat) * (frog->_faces.count * 10));
    for (int i = 0, j = 0; j < frog->_faces.count; i+=numOfVertices, j++) {
        enemyStuff[i] = [frog->_Vertex[(([frog->_faces[j][0] intValue] - 1) * 3)] floatValue];
        enemyStuff[i + 1] = [frog->_Vertex[(([frog->_faces[j][0] intValue] - 1) * 3) + 1] floatValue];
        enemyStuff[i + 2] = [frog->_Vertex[(([frog->_faces[j][0] intValue] - 1) * 3) + 2] floatValue];
        enemyStuff[i + 3] = 1.0f;
        
        enemyStuff[i + 4] = [frog->_VertexNormal[(([frog->_faces[j][2] intValue] - 1) * 3)] floatValue];
        enemyStuff[i + 5] = [frog->_VertexNormal[(([frog->_faces[j][2] intValue] - 1) * 3) + 1] floatValue];
        enemyStuff[i + 6] = [frog->_VertexNormal[(([frog->_faces[j][2] intValue] - 1) * 3) + 2] floatValue];
        enemyStuff[i + 7] = 1.0f;
        
        enemyStuff[i + 8] = 1.0f;
        enemyStuff[i + 9] = 0.0f;
    }
    
    [renders addObject:[[Wall alloc] init: @"Enemy" : GLKVector3Make(0.0f, 5.0f, 0.0f)
                                         : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                         : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                         : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                         : GL_TRIANGLES : frog->_faces.count : enemyStuff
                                         : (frog->_faces.count * 10) : 5 : false : false]];
    
    [maze Create:width :height];

    
    [self createFloor];
    
    [self CreateWestWalls];
    [self CreateEastWalls];
    [self CreateNorthWalls];
    [self CreateSouthWalls];
    
    exit = [[BoundingBox alloc] init];
    entrance = [[BoundingBox alloc] init];
    extraBounds = [[NSMutableArray alloc] init];
    
    [extraBounds addObject:[exit createEmptyBounds : width : 1]];
    [extraBounds addObject:[entrance createEmptyBounds : -width : 0]];
    
    [renders addObject:[[Cube alloc] init: @"Cube"
                                         : GLKVector3Make( (-width / 2) + 0.5f, 0.5f, (-height / 2) + 0.5f)
                                         : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                         : GLKVector3Make(0.25f, 0.25f, 0.25f)
                                         : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                         : GL_TRIANGLES : 36 : NULL : 0 : 5 : true : true]];
    
    [maze createMiniMap: map];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 10, 10, 10)];
    imageView.image = [UIImage imageNamed:@"playerPointer.png"];
    imageView.transform = CGAffineTransformMakeRotation(-cameraHorizontalAngle - M_PI_2);
    [map addSubview:imageView];
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
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_FLASHLIGHT_POSITION] = glGetUniformLocation(_program, "flashlightPosition");
    uniforms[UNIFORM_FLASHLIGHT_DIRECTION] = glGetUniformLocation(_program, "flashlightDirection");
    uniforms[UNIFORM_FOG_COLOR] = glGetUniformLocation(_program, "fogColor");
    uniforms[UNIFORM_SHININESS] = glGetUniformLocation(_program, "shininess");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_program, "ambientComponent");
    uniforms[UNIFORM_DIFFUSE_COMPONENT] = glGetUniformLocation(_program, "diffuseComponent");
    uniforms[UNIFORM_SPECULAR_COMPONENT] = glGetUniformLocation(_program, "specularComponent");
    
    ambientComponent = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    diffuseComponent = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    shininess = 100.0;
    specularComponent = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    fogColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0);
    
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    
    for (Renderable *render in renders) {
        
        glGenVertexArraysOES(1, &render->_vertexArray);
        glBindVertexArrayOES(render->_vertexArray);
        
        glGenBuffers(1, render->_vertexBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, render->_vertexBuffer[0]);
        glBufferData(GL_ARRAY_BUFFER, [render getArraySize], render->_arrayVertices, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, numOfVertices * sizeof(GLfloat), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE,  numOfVertices * sizeof(GLfloat), BUFFER_OFFSET(16));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE,  numOfVertices * sizeof(GLfloat), BUFFER_OFFSET(32));
        
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
    flashlightPosition = GLKVector4Make(cameraPosition.x, cameraPosition.y, cameraPosition.z, 1.0f);
    flashlightDirection = GLKVector3Make(cameraDirection.x, cameraDirection.y, cameraDirection.z);
    GLKMatrix4 cameraViewMatrix = GLKMatrix4MakeLookAt(cameraPosition.x, cameraPosition.y, cameraPosition.z,
                                                       GLKVector3Subtract(cameraPosition, cameraDirection).x,
                                                       GLKVector3Subtract(cameraPosition, cameraDirection).y,
                                                       GLKVector3Subtract(cameraPosition, cameraDirection).z,
                                                       cameraUp.x, cameraUp.y, cameraUp.z);
    
    for (Renderable *render in renders) {
        [render transformSetup];
        
        [self specialUpdates:render];
        [self collisionUpdate:render];
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
    glUniform4fv(uniforms[UNIFORM_FLASHLIGHT_POSITION], 1, flashlightPosition.v);
    glUniform3fv(uniforms[UNIFORM_FLASHLIGHT_DIRECTION], 1, flashlightDirection.v);
    glUniform4fv(uniforms[UNIFORM_DIFFUSE_COMPONENT], 1, diffuseComponent.v);
    glUniform1f(uniforms[UNIFORM_SHININESS], shininess);
    glUniform4fv(uniforms[UNIFORM_SPECULAR_COMPONENT], 1, specularComponent.v);
    glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
    glUniform4fv(uniforms[UNIFORM_FOG_COLOR], 1, fogColor.v);
    
    
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

- (void) collisionUpdate : (Renderable*) render{
    if ([render getCollidable]) {
        [render->_bounds updateBounds: render->_arrayVertices : [render getArraySize] :[render getModelMatrix]];
        for (Renderable *coll in renders) {
            if (coll->_bounds != NULL && coll != render) {
                if ((render->_bounds->minX <= coll->_bounds->maxX && render->_bounds->maxX >= coll->_bounds->minX) &&
                    (render->_bounds->minY <= coll->_bounds->maxY && render->_bounds->maxY >= coll->_bounds->minY) &&
                    (render->_bounds->minZ <= coll->_bounds->maxZ && render->_bounds->maxZ >= coll->_bounds->minZ)) {
                    if (GLKVector3DotProduct(enemyDirection, coll->_normalDirection) <= -0.5) {
                        NSLog(@"%@, %@", [render getObjectID], [coll getObjectID]);
                        [self changeEnemyDirection];
                        break;
                    }
                }
            }
        }
        for (BoundingBox *bounds in extraBounds) {
            if ((render->_bounds->minX <= bounds->maxX && render->_bounds->maxX >= bounds->minX) &&
                (render->_bounds->minY <= bounds->maxY && render->_bounds->maxY >= bounds->minY) &&
                (render->_bounds->minZ <= bounds->maxZ && render->_bounds->maxZ >= bounds->minZ)) {
                [self changeEnemyDirection];
                break;
            }
        }
    }
}

- (void) changeEnemyDirection {
    //enemyDirection = GLKVector3Negate(enemyDirection);
    enemyDirection = GLKMatrix4MultiplyVector3(GLKMatrix4MakeYRotation(M_PI * 1.5f), enemyDirection);
}

- (void) specialUpdates : (Renderable*) render{
    if ([[render getObjectID] isEqual:@"Cube"]) {
        [render movingVectorMove:GLKVector3MultiplyScalar(enemyDirection, self.timeSinceLastUpdate * 0.5f)];
        [render translateMatrix:render->_movementVector];
        //[render rotateMatrix:GLKVector3Make(1.0f, 1.0f, 1.0f) :_rotation];
    }
}

- (void) cameraUpdate {
    cameraDirection = GLKVector3Make(cosf(cameraVerticalAngle) * sinf(cameraHorizontalAngle)
                                     , sinf(cameraVerticalAngle), cosf(cameraVerticalAngle) * cosf(cameraHorizontalAngle));
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
    [imageView setFrame:CGRectMake(GLKVector3Subtract(cameraPosition, initCameraPos).x * 20 - 10,GLKVector3Subtract(cameraPosition, initCameraPos).z * 20 + 10, 10, 10)];
}

- (IBAction)doubleTap:(UITapGestureRecognizer *)sender {
    cameraPosition = GLKVector3Make((-width / 2.0f) - 0.5f, 0.5f, (-height / 2.0f) + 0.5f);
    cameraVerticalAngle = 0.0f; cameraHorizontalAngle = -3.14159f / 2.0;
    [imageView setFrame:CGRectMake(- 10, 10, 10, 10)];
    imageView.transform = CGAffineTransformMakeRotation(-cameraHorizontalAngle - M_PI_2);
    
}

- (IBAction)doubleTouches:(id)sender {
    map.hidden = !map.hidden;
    
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender translationInView:self.view];
    
    cameraHorizontalAngle -= (point.x * cameraRotationSpeed);
    
    cameraVerticalAngle += (point.y * cameraRotationSpeed);
    imageView.transform = CGAffineTransformMakeRotation(-cameraHorizontalAngle - M_PI_2);
    
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)day2Night:(UIButton *)sender {
    if (dayNight) {
        ambientComponent = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
    } else {
        ambientComponent = GLKVector4Make(0.05, 0.05, 0.05, 1.0);
    }
    dayNight = !dayNight;
}

- (IBAction)fogButton:(UIButton *)sender {
    if (fogEffect) {
        fogColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
        
    } else {
        fogColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 0.0f);
    }
    fogEffect = !fogEffect;
}

- (IBAction)flashlightButton:(UIButton *)sender {
    if (flashLight) {
        diffuseComponent = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
        specularComponent = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    } else {
        diffuseComponent = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
        specularComponent = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    }
    flashLight = !flashLight;
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
    [renders addObject:[[Floor alloc] init : @"Floor" : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                           : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                           : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : GLKVector3Make(0.0f, -1.0f, 0.0f)
                                           : GL_TRIANGLES: combine.count / numOfVertices : WallVertices
                                           : combine.count : 0 : false : false]];
}

- (void) CreateWestWalls {
    int nameNum = 0;
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
            [renders addObject:[[Wall alloc] init: [NSString stringWithFormat:@"WestWall%d", nameNum++] : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GLKVector3Make(0.0f, 0.0f, -1.0f)
                                                 : GL_TRIANGLES : (combine.count / numOfVertices) : WallVertices
                                                 : combine.count : [maze getDirectionText : i : j : WALLWEST] : true : false]];
            
        }
    }
}

- (void) CreateEastWalls {
    int nameNum = 0;
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
            [renders addObject:[[Wall alloc] init: [NSString stringWithFormat:@"EastWall%d", nameNum++] : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GLKVector3Make(0.0f, 0.0f, 1.0f)
                                                 : GL_TRIANGLES : (combine.count / numOfVertices) : WallVertices
                                                 : combine.count : [maze getDirectionText : i : j : WALLEAST] : true : false]];
        }
    }
}

- (void) CreateNorthWalls {
    int nameNum = 0;
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
            [renders addObject:[[Wall alloc] init: [NSString stringWithFormat:@"NorthWall%d", nameNum++] : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GLKVector3Make(1.0f, 0.0f, 0.0f)
                                                 : GL_TRIANGLES : (combine.count / numOfVertices) : WallVertices
                                                 : combine.count : [maze getDirectionText : i : j : WALLNORTH] : true : false]];
        }
    }
}

- (void) CreateSouthWalls {
    int nameNum = 0;
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
            [renders addObject:[[Wall alloc] init: [NSString stringWithFormat:@"SouthWall%d", nameNum++] : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                 : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                 : GLKVector3Make(-1.0f, 0.0f, 0.0f)
                                                 : GL_TRIANGLES : (combine.count / numOfVertices) : WallVertices
                                                 : combine.count : [maze getDirectionText : i : j : WALLSOUTH] : true : false]];
        }
    }
}

- (NSMutableArray*) combineArrays : (NSMutableArray*) vert : (NSMutableArray*) norm : (NSMutableArray*) tex {
    NSMutableArray *combined = [[NSMutableArray alloc] init];
    int j = 0;
    for (int i = 0; i < vert.count; i += 3) {
        [combined addObject:vert[i]]; [combined addObject:vert[i +1]]; [combined addObject:vert[i +2]]; [combined addObject: [NSNumber numberWithFloat:1.0f]];
        [combined addObject:norm[i]]; [combined addObject:norm[i +1]]; [combined addObject:norm[i +2]]; [combined addObject: [NSNumber numberWithFloat:1.0f]];
        [combined addObject:tex[j]]; [combined addObject:tex[j +1]];
        j += 2;
    }
    return combined;
}

@end
