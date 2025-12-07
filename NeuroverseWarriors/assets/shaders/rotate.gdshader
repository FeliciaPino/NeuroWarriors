shader_type canvas_item;
uniform float rotation_speed  = 0.3;
uniform vec2 pivot_offset = vec2(0,0);
void vertex() {
	// Called for every vertex the material is visible on.
	float t = TIME*rotation_speed;
	float sine = sin(t);
	float cosine = cos(t);
	vec2 p = VERTEX-pivot_offset;
	VERTEX = vec2(
		p.x*cosine - p.y*sine +pivot_offset.x,
		p.x*sine + p.y*cosine +pivot_offset.y
	);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
