shader_type spatial;

#include "sg_vfx_utils.gdshaderinc"

render_mode unshaded, cull_disabled;

uniform sampler2D fog_texture : repeat_disable;
uniform float alpha_mul : hint_range(0.0, 1.0) = 1.0;

uniform int particles_anim_h_frames : hint_range(1, 128);
uniform int particles_anim_v_frames : hint_range(1, 128);

void vertex() {

	// Billboard Mode: Particles
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]),
			normalize(INV_VIEW_MATRIX[2]),
			MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

	float h_frames = float(particles_anim_h_frames);
	float v_frames = float(particles_anim_v_frames);
	float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
	float particle_frame = floor(INSTANCE_CUSTOM.z * float(particle_total_frames));
	
	//particle_frame = clamp(particle_frame, 0.0, particle_total_frames - 1.0);
	//particle_frame = mod(particle_frame, particle_total_frames);
	particle_frame = 5.0; //pour lock le billboard sur une frame specifique

	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);
}

void fragment() {
	vec2 uv = UV;
	vec4 fog_tex = texture(fog_texture, uv);
	ALBEDO = COLOR.xyz * fog_tex.rgb;
	ALPHA = COLOR.a * fog_tex.a * alpha_mul;
}
