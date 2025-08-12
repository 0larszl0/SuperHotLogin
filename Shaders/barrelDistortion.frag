#version 440

// 'in' refers to the variable using an input register
layout(location = 0) in vec2 qt_TexCoord0;  // an input to the fragment shader, and it should be read from location 0, the area where Qt provides texture coordinates.

// 'out' refers to the variable using an output register
// 'vec4' denotes the RGBA colour scheme
layout(location = 0) out vec4 fragColour;  // the output colour of this fragment/pixel

// 'uniform' means that this variable is coming from outside the shader, more specifically one set by Qt/QML
// 'sampler2D' refers to a 2D texture or input image that the shader can read pixel-by-pixel
// 'layout(binding = 1)' binds the variable to texture binding unit 1 in the GPU pipeline
layout(binding = 1) uniform sampler2D source;  // in this case, the source will likely be the screen

layout(std140, binding = 0) uniform Params {
    mat4 qt_Matrix;
    float qt_Opacity;

    float distortionStrength;  //  k > 0: barrel distortion, k < 0: pincushion distortion effect
} buf;


void main() {
    // -- Normalize texture coordinates -- //
    vec2 uv = (qt_TexCoord0 * 2.0) - 1.0;  // convert from range [0, 1] to [-1, 1]

    float r = length(uv);  // distance from centre, like a radius

    vec2 distorted = uv * (1.0 + (buf.distortionStrength * r * r));  // apply the distortion formula
    distorted = (distorted + 1.0) / 2.0;  // converts from normalised space to standard texture space

    // Check if the new coordinates are off the screen
    if (distorted.x < 0.0 || distorted.x > 1.0 || distorted.y < 0.0 || distorted.y > 1.0) {
	fragColour = vec4(0.0, 0.0, 0.0, 0.0);  // if off the screen, output transparent black
	return;
    }

    // Sample the input image at the new distorted position and write that colour to the screen.
    fragColour = texture(source, distorted);

    // NOTES:
    // No need to return anything as the changes are made through the output register at variable fragColour
    // All math logic involving scalars and vectors, require the scalars to be a float object.
}
