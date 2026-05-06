shader_type spatial;

render_mode unshaded, cull_disabled;

uniform sampler2D fog_texture;
uniform float alpha_mul : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	//add squach and stretch
}

void fragment() {
	vec4 fog_tex = texture(fog_texture, UV);
	ALBEDO = COLOR.xyz * fog_tex.rgb;
	ALPHA = COLOR.a * fog_tex.a * alpha_mul;
}
