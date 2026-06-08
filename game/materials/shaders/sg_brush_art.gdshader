// base shader for painted look and da adaptation

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

#include "sg_shader_utils.gdshaderinc"

global uniform float da_state : hint_range(0.0, 1.0);

group_uniforms brush;
uniform sampler2D texture_brush_oil : filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_brush_wc : filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal_supp : hint_roughness_normal, filter_linear_mipmap, repeat_enable;

uniform float brush_strength = 1.0;
uniform float brush_tilling = 1.0;
uniform float brush_hue_shift : hint_range(-1.0, 1.0) = 0.1;


group_uniforms albedo;
/**
* to add emissive look, get I to go higher than 0 
*/
uniform vec4 albedo : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float color_saturation : hint_range(0.0, 5.0) = 1.0;
uniform float color_luminosity : hint_range(0.0, 5.0) = 1.0;
uniform float color_contrast : hint_range(0.0, 5.0) = 1.0;

group_uniforms ORM;
/**
* ORM packing : correspond à ambiant occlusion, roughness, metallic 
*/
uniform sampler2D texture_orm : hint_roughness_g,filter_linear_mipmap,repeat_enable;
uniform float roughness : hint_range(0.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0);

group_uniforms Normal;
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;

group_uniforms Others;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

varying vec3 uv1_triplanar_pos;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001) = 1.0;
varying vec3 uv1_power_normal;

uniform float uv1_scale = 1.0;
uniform float uv1_offset = 0.0;
//uniform vec3 uv2_scale;
//uniform vec3 uv2_offset;


void vertex() {
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

	TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
	TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);

	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
	BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);

	// UV1 Triplanar: Enabled (with World Triplanar)
	uv1_power_normal = pow(abs(normal), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	// SAMPLING **************************************
	
	vec3 uv_brushes = uv1_triplanar_pos * brush_tilling;
	
	vec3 brush_tex_oil = triplanar_texture(texture_brush_oil, uv1_power_normal, uv_brushes).rgb;
	vec3 brush_tex_wc = triplanar_texture(texture_brush_wc, uv1_power_normal, uv_brushes).rgb;
	
	vec3 normal_tex_supp = triplanar_texture(texture_normal_supp, uv1_power_normal, uv_brushes).rgb;

	// CLASSIC UV MAPPING
	vec4 albedo_tex = texture(texture_albedo, UV);
	vec3 normal_tex = texture(texture_normal, UV).rgb;
	vec4 orm_tex = texture(texture_orm, UV);
	
	// USE TRIPLANAR
	//vec4 albedo_tex = triplanar_texture(texture_albedo, uv1_power_normal, uv1_triplanar_pos);
	//vec3 normal_tex = triplanar_texture(texture_normal, uv1_power_normal, uv1_triplanar_pos).rgb;
	//vec4 orm_tex = triplanar_texture(texture_orm, uv1_power_normal, uv1_triplanar_pos);
	
	// MATERIAL PHYSICS *******************************
	
	vec3 c_albedo = albedo.rgb * albedo_tex.rgb;
	
	float r = orm_tex.g * roughness;
	float m = orm_tex.b * metallic;
	
	// BRUSH ******************************************
	vec3 brush_tex = mix(brush_tex_oil, brush_tex_wc, da_state);
	
	vec3 c_hsv = rgb2hsv(c_albedo);
	
	vec3 b_hsv = c_hsv;
	b_hsv.x = mod(c_hsv.x + brush_hue_shift, 1.0);
	b_hsv.y *= 0.95;
	c_hsv = mix(c_hsv, b_hsv, brush_tex.r * brush_strength);

	//corriger pour que la normal de base reste
	//vec3 c_normal = mix(normal_tex, normal_tex_supp, 1.0 - da_state);
	normal_tex_supp.xy *= 2.0;
	vec3 c_normal = normalize(normal_tex + normal_tex_supp * (1.0 - da_state));
	
	r *= mix(1.0, brush_tex.r, brush_strength);

	// STYLISATION *************************************
	
	c_hsv.z = 0.5 + (c_hsv.z - 0.5) * color_contrast;
	float da_saturation = mix(1.05, 0.94, da_state);
	c_hsv.y *= color_saturation * da_saturation;
	c_hsv.z *= color_luminosity;
	c_albedo = hsv2rgb(c_hsv);
	
	float da_r = mix(1.0, 0.5, da_state);
	r *= da_r;
	
	// OUTPUT ******************************************
	ALBEDO = c_albedo;
	NORMAL_MAP = c_normal;
	NORMAL_MAP_DEPTH = normal_scale;
	AO = orm_tex.a;
	AO_LIGHT_AFFECT = ao_light_affect;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}
