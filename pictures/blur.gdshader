shader_type canvas_item;

uniform sampler2D blur_texture;
uniform vec2 ant_uv;
uniform float gradual_blur_radius = 20;
uniform float texture_aspect_ratio;

void fragment() {
	vec2 aspect = normalize(vec2(texture_aspect_ratio, 1));
	float uv_distance = distance(ant_uv * aspect, UV * aspect);
	vec4 blur_color = texture(blur_texture, UV);
	if (uv_distance < gradual_blur_radius) {
		COLOR = mix(COLOR, blur_color, (uv_distance / gradual_blur_radius) * (uv_distance / gradual_blur_radius));
	} else {
		COLOR = blur_color;
		
	}
}

