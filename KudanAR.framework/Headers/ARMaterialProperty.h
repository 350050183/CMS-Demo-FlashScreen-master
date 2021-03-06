#import <Foundation/Foundation.h>

@class ARTexture;
@class ARVector3;

/**
 A class representing a property held by a material. e.g. Colour or Ambient lighting.
 **/
@interface ARMaterialProperty : NSObject

/**
 Vector used to set material property to uniform value.
 **/
@property (nonatomic) ARVector3 *value;

/**
 Texture used to set material property. Used to apply normal, specular, ambient, diffuse maps and set the colour of a material.
 If both value and texture are set, the texture will take precedence.
 **/
@property (nonatomic) ARTexture *texture;

/**
Used to multiply the vector value for the colour material property when no texture is set.
 **/
@property (nonatomic) float factor;

@end
