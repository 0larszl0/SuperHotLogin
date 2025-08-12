#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColour;  // the output colour of this fragment/pixel

layout(binding = 1) uniform sampler2D source;


// REQUIRED to start with mat4 qt_Matrix followed by float qt_Opacity as qt6 dedicates these two values to begin
// with, in their layout 
layout(std140, binding = 0) uniform Params {
    mat4 qt_Matrix;
    float qt_Opacity;  // takes the opacity value from ShaderEffect

    float edgeFadeSize;
    float itemWidth;
    float itemHeight;

    bool fadeInX;
    bool fadeInY;
} buf;


void main() {
    // -- Find distance to closest edge -- //
    float distX = min(qt_TexCoord0.x, 1.0 - qt_TexCoord0.x);  // say ... .x = 0.6 it'd be closer right than left
    float distY = min(qt_TexCoord0.y, 1.0 - qt_TexCoord0.y);

    // -- Calculate fade based on distance away from edge -- //
    // 'distX * itemWidth' gets the equivalent position in terms of the original item size
    // |___ / edgeFadeSize gets the factor difference between the above multiplication and the edgeFadeSize
    //     |____ square the result to make a more gradual/parabolic appearance
    // in summary, anything less than edgeFadeSize will be <1 and anything above becomes 1

    float fadeX = 1;
    float fadeY = 1;

    if (buf.fadeInX) {
        fadeX = clamp(pow((distX * buf.itemWidth) / buf.edgeFadeSize, 2.0), 0.0, 1.0);
    }

    if (buf.fadeInY) {
        fadeY = clamp(pow((distY * buf.itemHeight) / buf.edgeFadeSize, 2.0), 0.0, 1.0);
    }

    // Combines any fade values
    float fade = fadeX * fadeY;

    fragColour = texture(source, qt_TexCoord0) * (fade * buf.qt_Opacity);
}
