#version 440

layout(location = 0) in vec2 qt_TexCoord0;  // input from vertex shader that's auto-injected by QtQuick
layout(location = 0) out vec4 fragColor;  // the final colour the fragment will write to the framebuffer

layout(binding = 1) uniform sampler2D source;  // source texture we're sampling (output of ShaderEffectSource)

layout(std140, binding = 0) uniform Params {
    mat4 qt_Matrix;
    float qt_Opacity;

    float blurSize;  // how far apart each blur sample os
} buf;


void main() {
    vec4 sum = vec4(0.0);  // accumulator for our final blurred colour
    float weights[5] = float[](0.227, 0.316, 0.07, 0.045, 0.009);  // precomputed Gaussian weights

    for (int i = -2; i <= 2; i++) {
	vec2 h_offset = vec2(float(i) * buf.blurSize, 0.0);  // produce a horizontal offset for the blur
	vec4 tex = texture(source, qt_TexCoord0 + h_offset);  // samples the texture at the offset position
	float brightness = max(tex.r, max(tex.g, tex.b));  // gets the brightness of the sampled pixel using MAX

	if (brightness > 0.6) {  // a bright-pass filter -- only bright pixels correspond to the blur
	    sum += tex * weights[abs(i)];
	}
    }

    fragColor = sum * buf.qt_Opacity;
}
