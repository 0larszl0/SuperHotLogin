#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D base;
layout(binding = 2) uniform sampler2D bloom;

layout(std140, binding = 0) uniform Params {
    mat4 qt_Matrix;
    float qt_Opacity;

    float glowIntensity;
} buf;


void main() {
    vec4 original = texture(base, qt_TexCoord0);  // samples the original image colour at this pixel.
    vec4 glow = texture(bloom, qt_TexCoord0);  // samples the bloom texture at the same pixel.
    fragColor = (original + (glow * buf.glowIntensity)) * buf.qt_Opacity;  // adds the glow (boosted by 1.2) to the original colour.
}
