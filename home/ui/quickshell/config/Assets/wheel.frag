
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
    float brightness;
};

vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(2.0, 1.0, 0.0);
    vec3 d = vec3(0.50, 0.20, 0.25);
    return a + b*cos(6.28318*(c*t+d));
}
void main() {
    vec2 uv = qt_TexCoord0 / resolution.xy * 2.0 - 1.0;
    uv.x *= resolution.x / resolution.y;
    uv.x -= resolution.x / resolution.y * 1.1;
        
    float angleOffset = time * 2.0;
    float s = sin(angleOffset);
    float c = cos(angleOffset);
    mat2 rot = mat2(c, -s, s, c);
    uv = rot * uv;
    
    float angle = atan(uv.y, uv.x);
    if (angle < 0.0) angle += 6.28318530718;
    float segment = floor(angle / (6.28318530718 / 60.0));
    float hue = segment / 9.0;
    vec3 color = palette(hue - 0.1 * time);
    fragColor = vec4(color * brightness, 1.0);
}

