shader_type spatial;
render_mode blend_mix;

uniform vec3 color: source_color = vec3(.2,.2,.2);

void vertex() {
	COLOR.a = INSTANCE_CUSTOM.x;
}

void fragment() {
	ALBEDO = color;
	ALPHA = max(.0, 1.0 - pow(COLOR.a, 15.0));
}