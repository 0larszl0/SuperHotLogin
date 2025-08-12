#version 440

// A 'fragment' is a would-be pixel on the screen, thus fragment shaders are programs that run once per pixel in whatever item we're drawing in.
// 'varying' : One value per pixel, interpolated from the vertices
// 'uniform' : One value shared by ALL pixels for this draw call

/*

(0, 1)          (1, 1)
  +--------------+
  |              |      ^
  |              |      |
  |     Item     |      | v
  |              |      |
  |              |
  +--------------+
(0, 0)          (1, 0)

        ---> u

*/

layout(std140, binding = 0) uniform Params {
    mat4 qt_Matrix;
    float qt_Opacity;

    float lineOpacity;  // global opacity from QML
    float time;	   // running time in seconds
    float lineSpacing; // Repeat every n units, where n in [0, 1]
    float thickness;   // How much of the lineSpacing to fill up, use range [0, 1]
    float speed;	   // How fast the scanlines move
} buf;

layout(location = 0) in vec2 qt_TexCoord0; // Per-pixel UV coordinate (x, y)
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;


void main() {

    // --- Summary --- //
    // Effectively, 'offset' represents where we are within the repeating stripe pattern, and will be used to check if the pixel is inside the visible part of a stripe
    // 'stripe' determines whether to draw a given pixel or not- 1 to draw, 0 to leave transparent, this is based on the offset falling inside the stripe's thickness.
    // Example: image drawing stripes on a vertical wall
    // let lineSpacing = 10cm
    // let thickness = 3cm
    // offset tells how many cm into the current 10cm cycle is this point
    // stripe determines whether it's between 0-3cm or not, if so paint, otherwise leave blank.

    // Scroll the UV downward, then wrap it every 'lineSpacing'
    // i.e. let lineSpacing=0.1, pixels from 0.0 to 0.1 is one loop, so is from 0.1 to 0.2, resultantly a difference of 0.1 will loop between these values
    // 'time * speed' makes the pixel move down, higher speed => faster scroll
    float offset = mod(qt_TexCoord0.y + (buf.time * buf.speed), buf.lineSpacing);

    // 'step(x, y)' returns the 1.0 if x <= y, 0.0 otherwise 
    // So, 'step(0.0, offset)' stops negative values being used, while 'step(offset, 0.5)' caps the value at 0.5 
    // overall determines how much of the offset range is allowed to be visible
    float stripe = step(0.0, offset) * step(offset, buf.thickness);

    vec4 tex = texture(source, qt_TexCoord0);  // get the texture of the source

    if (stripe != 1) {
	fragColor = tex * clamp(buf.lineOpacity - 0.3, 0.01, 1.0);
	return;
    }

    // Output colour when 'stripe'==1, transparent elsewhere
    fragColor = tex * stripe * buf.lineOpacity;
}
