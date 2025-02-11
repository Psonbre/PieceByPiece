shader_type canvas_item;

uniform float speed = 0.0;
uniform vec4 color = vec4(0,0,0,1);
void fragment() {
    vec4 in_tex = texture(TEXTURE, vec2(UV.x + TIME * speed, UV.y));
    COLOR = in_tex * color;
}
