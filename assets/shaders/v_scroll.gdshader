shader_type canvas_item;
uniform float scroll_speed = 0.5; 
void vertex() {
	UV.y += TIME*scroll_speed;
}

