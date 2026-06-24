shader_type canvas_item;

uniform float factor: hint_range(0.0, 1.0);
uniform sampler2D dissolve_map: filter_nearest;

void fragment() {
	vec4 src = COLOR;
	vec4 map = texture(dissolve_map, UV);

	float mask = step(map.r + 0.1 * (1.0 - factor), factor);

	COLOR = vec4(src.rgb, src.a * mask);
}

