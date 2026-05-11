shader_type spatial;

#include "sg_vfx_utils.gdshaderinc"

render_mode unshaded, cull_disabled, blend_add;

uniform sampler2D flash_texture : repeat_disable;
uniform float alpha_mul : hint_range(0.0, 1.0) = 1.0;

void vertex() {
}

void fragment() {
	vec4 flash_tex = texture(flash_texture, UV);
	ALBEDO = COLOR.xyz * flash_tex.rgb;
	ALPHA = COLOR.a * flash_tex.a * alpha_mul;
}
