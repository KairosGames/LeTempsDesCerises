shader_type spatial;

uniform sampler2D normal_texture;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D ao_texture;

uniform vec3 color : source_color = vec3(1.0, 0.0, 0.0); 

void vertex() {
}

void fragment() {
	vec3 ao_tex = texture(ao_texture, UV).xyz;
	ALBEDO = color * ao_tex;
	NORMAL_MAP = texture(normal_texture, UV).xyz;
	NORMAL_MAP_DEPTH = normal_scale;
}

