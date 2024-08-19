shader_type canvas_item;

uniform sampler2D blur_texture;
uniform vec2 ant_uv;
uniform float gradual_blur_radius = 20;
uniform vec2 picture_size;

void fragment() {
	float real_distance = length((ant_uv - UV) * picture_size);
	vec4 blur_color = texture(blur_texture, UV);
	if (real_distance < gradual_blur_radius) {
		float scaled_distance = real_distance / gradual_blur_radius;
		COLOR = mix(COLOR, blur_color, scaled_distance * scaled_distance);
	} else {
		COLOR = blur_color;
		
	}
}

