shader_type canvas_item;

uniform vec4 bottom_color: source_color;
uniform float wave_amp: hint_range(0.0, 0.5);
uniform float wave_size: hint_range(1.0, 10.0);
uniform float wave_time_mul: hint_range(0.1, 2.0);
uniform int total_phases: hint_range(2, 600, 1);
uniform float color_speed: hint_range(0.01, 1.0) = 0.1;
uniform float color_value: hint_range(0.0, 1.0) = 0.5; // Lower brightness

float rand(float n){return fract(sin(n) * 43758.5453123);}

float noise(float p){
    float fl = floor(p);
    float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

float fmod(float x, float y) {
    return x - floor(x / y) * y;
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 lerp(vec4 a, vec4 b, float w) {
    return a + w * (b - a);
}

void fragment() {
    float t = float(total_phases);
    float effective_wave_amp = min(wave_amp, 0.5 / t);
    float d = fmod(UV.y, 1.0 / t);
    float i = floor(UV.y * t);
    float vi = floor(UV.y * t + t * effective_wave_amp);
    float s = effective_wave_amp * sin((UV.x + TIME * max(1.0 / t, noise(vi)) * wave_time_mul * vi / t) * 2.0 * PI * wave_size);

    if (d < s) i--;
    if (d > s + 1.0 / t) i++;
    i = clamp(i, 0.0, t - 1.0);

    // Cycle top color through hues with lower value (brightness)
    float hue = mod(TIME * color_speed, 1.0);  // Cycle hue over time
    vec3 top_color_rgb = hsv2rgb(vec3(hue, 1.0, color_value)); // Use color_value to lower brightness

    COLOR = lerp(vec4(top_color_rgb, 1.0), bottom_color, i / (t - 1.0));
}
