shader_type spatial;

render_mode unshaded, cull_disabled;

void vertex() {
}

void fragment() {
	ALBEDO = COLOR.xyz;
	ALPHA = COLOR.a;
}
