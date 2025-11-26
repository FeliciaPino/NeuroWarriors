shader_type canvas_item;
mat4 contrastMatrix(float c){
	float t = (1.0-c)/2.0;
	return mat4(
		vec4(c,0,0,0),
		vec4(0,c,0,0),
		vec4(0,0,c,0),
		vec4(t,t,t,1)
	);
}

void fragment() {
	mat4 contrastMat = contrastMatrix(2);
	vec4 pixelColor = texture(TEXTURE, UV);
	float brightness = (0.299*pixelColor.r + 0.587*pixelColor.g + 0.114*pixelColor.b);
	brightness *= 0.3;
	vec4 grey = vec4(brightness, brightness, brightness, pixelColor.a);
	COLOR = contrastMat * grey;
	//outline
	float outline_thickness = 1.0; // yeah, I got no clue why this doesn't change anything
	vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE,0));
	float max_alpha = 0.0;
	float least_alpha = 1.0;
	for(int x = -1*int(outline_thickness); x<=1*int(outline_thickness); x++){
		for(int y = -1*int(outline_thickness);y<=1*int(outline_thickness);y++){
			vec2 offset = vec2(float(x),float(y)) * pixel_size;
			max_alpha = max(max_alpha, texture(TEXTURE,UV+offset).a);
			least_alpha = min(least_alpha, texture(TEXTURE, UV+offset).a);
		}
	}
	float outline_strength = smoothstep(0.0, 0.5, (max_alpha - least_alpha)*(1.0-pixelColor.a));
	vec3 final_color = mix(grey.rgb, vec3(0.1,0.1,0.1), outline_strength);
	COLOR = vec4(final_color, max(pixelColor.a,outline_strength));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
