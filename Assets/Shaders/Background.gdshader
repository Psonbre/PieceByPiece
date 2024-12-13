shader_type canvas_item;

uniform vec4 old_color : source_color; // Old color to mix with the gradient
uniform vec4 bottom_color : source_color;
uniform float wave_amp : hint_range(0.0, 0.5);
uniform float wave_size : hint_range(1.0, 10.0);
uniform float wave_time_mul : hint_range(0.1, 2.0);
uniform int total_phases : hint_range(2, 600, 1);
uniform float gradient_speed : hint_range(0.01, 1.0) = 0.01;
uniform sampler2D gradient : source_color; // Single gradient texture
uniform float transition_progress : hint_range(0.0, 1.0); // Progress between old_color and gradient

float rand(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noise(float p) {
    float fl = floor(p);
    float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

float fmod(float x, float y) {
    return x - floor(x / y) * y;
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

    // Calculate the gradient position for scrolling
    float gradient_position = mod(TIME * gradient_speed, 1.0);

    // Sample the gradient
    vec4 gradient_color = texture(gradient, vec2(gradient_position, 0.5));

    // Blend the old color with the gradient based on transition progress
    vec4 blended_color = mix(old_color, gradient_color, transition_progress);

    // Blend the resulting color with the bottom color based on wave phase
    COLOR = mix(blended_color, bottom_color, i / (t - 1.0));
}
