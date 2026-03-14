shader_type canvas_item;
uniform float starting_zoom = 0.9f;
uniform float max_zoom=1.1f;
uniform float zoom_speed=0.01f;
uniform vec2 pivot_offset = vec2(0,0);
void vertex() {
	float curr_zoom = max(1.0f/(starting_zoom+TIME*zoom_speed),1.0f/max_zoom);
	UV.x = (UV.x-pivot_offset.x)*curr_zoom + pivot_offset.x;
	UV.y = (UV.y-pivot_offset.y)*curr_zoom + pivot_offset.y;
}
void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
