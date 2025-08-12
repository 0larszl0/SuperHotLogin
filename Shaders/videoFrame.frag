#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColour;  // the output colour of this fragment/pixel

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform Params {
    mat4 qt_Matrix;
    float qt_Opacity;  // takes the opacity value from ShaderEffect

    float radius;  // range between [0, 1]
} buf;


void main() {
    vec2 center = vec2(0.5, 0.5);

    float maxDist = length(center);  // gets the largest distance from the center (from point (0, 0))
    float dist = distance(qt_TexCoord0, center);  // gets the distance between the current pixel to the center   

    if ((dist / maxDist) > buf.radius) {  // dist/maxDist normalises to a value between [0, 1] for radius
	fragColour = vec4(0.0, 0.0, 0.0, 0.0);
	return;
    }

    fragColour = texture(source, qt_TexCoord0) * buf.qt_Opacity;
}
