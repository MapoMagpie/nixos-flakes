#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
};

vec3 palette(float t) {
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.263, 0.416, 0.557);
  
  return a + b*cos(6.28318*(c*t+d));

}
void main() {
    vec2 uv = (qt_TexCoord0 * 2.0 - resolution.xy) / resolution.x;
    
    float d = length(uv);
    vec3 col = palette(d + time);
    
    d = sin(d*9. + time)/8.0;
    d = abs(d);
    
    d = 0.02 / d;
    
    col *= d;

    fragColor = vec4(col,1.0);
}

