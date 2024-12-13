shader_type canvas_item;

uniform float speed = 5.0;
uniform vec4 color = vec4(1,1,1,1);
void fragment() {
	vec4 in_tex = texture(TEXTURE, UV + TIME * speed);
	COLOR = in_tex * color;
}
