shader_type canvas_item;
uniform vec2 scroll = vec2(0,0);
uniform float parallax_factor = 0.1;

void fragment() {
	vec2 uv = UV + scroll*parallax_factor;
	uv = fract(uv);

}
