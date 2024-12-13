shader_type canvas_item;

// Effect parameters
uniform vec3 effect_color: source_color = vec3(0.2, 0.3, 0.8);
uniform int octave_count: hint_range(1, 20) = 10;
uniform float amp_start = 0.5;
uniform float amp_coeff = 0.5;
uniform float freq_coeff = 0;
uniform float speed = 1;
uniform float thickness: hint_range(0.0, 10.0) = 1.25; // Thickness of the effect

// Pixelation parameters
uniform float pixel_size: hint_range(1.0, 150.0) = 10.0; // Size of pixelation effect

// Hash and noise functions
float hash12(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1, 311.7)),
              dot(uv, vec2(269.5, 183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0, 0.0)), fuv - vec2(0.0, 0.0)),
                   dot(hash22(iuv + vec2(1.0, 0.0)), fuv - vec2(1.0, 0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0, 1.0)), fuv - vec2(0.0, 1.0)),
                   dot(hash22(iuv + vec2(1.0, 1.0)), fuv - vec2(1.0, 1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves) {
    float value = 0.0;
    float amplitude = amp_start;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(uv);
        uv *= freq_coeff;
        amplitude *= amp_coeff;
    }
    return value;
}

// Fragment shader logic
void fragment() {
    vec2 uv = 2.0 * UV - 1.0;

    // Apply pixelation
    vec2 pixel_uv = floor(uv * pixel_size) / pixel_size;

    // Rotate 90 degrees by swapping x and y
    pixel_uv = vec2(pixel_uv.y, -pixel_uv.x); // Clockwise rotation
    // For counterclockwise, use: uv = vec2(-pixel_uv.y, pixel_uv.x);

    pixel_uv += 2.0 * fbm(pixel_uv + TIME * speed, octave_count) - 1.0;
    float dist = abs(pixel_uv.x);

    // Modify alpha based on distance and thickness
    float edge_factor = smoothstep(thickness, 0.0, dist);

    // Retain color variation
    vec3 color = effect_color * edge_factor;

    // Clamp alpha to binary values while keeping color gradients
    float alpha = step(0.5, edge_factor); // Clamp alpha to 0 or 1

    COLOR = vec4(color, alpha);
}
