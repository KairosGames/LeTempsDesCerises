shader_type spatial;

uniform vec3 color1 : source_color = vec3(1.0);
uniform vec3 color2 : source_color = vec3(0.0);

uniform float size = 1;

void fragment() {
	vec2 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
	vec2 pos = floor((world_pos - (size/2.0)) * size);
	
	float pattern = mod(pos.x + mod(pos.y,2.0),2.0);
	ALBEDO = mix(color1, color2, pattern);
}