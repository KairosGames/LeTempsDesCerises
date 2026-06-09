shader_type spatial;

#include "sg_vfx_utils.gdshaderinc"

render_mode unshaded, cull_disabled;

uniform sampler2D fog_texture : repeat_disable;
uniform float alpha_mul : hint_range(0.0, 1.0) = 1.0;
uniform float rotation_speed = 0.05;

void fragment() {
	vec2 uv = rotate(UV, vec2(0.5), 1.0 *(TIME * rotation_speed));
	vec4 fog_tex = texture(fog_texture, uv);
	ALBEDO = COLOR.xyz * fog_tex.rgb;
	ALPHA = COLOR.a * fog_tex.a * alpha_mul;
}
