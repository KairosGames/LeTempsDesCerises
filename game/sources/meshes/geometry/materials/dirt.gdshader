shader_type spatial;
render_mode blend_mix;

uniform vec3 color: source_color;

uniform sampler2D texture_a : source_color;
uniform float texture_a_scale = 1.0;
uniform vec3 texture_a_offset;
uniform float texture_a_intensity = 1.0;

uniform sampler2D texture_b : source_color;
uniform float texture_b_scale = 1.0;
uniform vec3 texture_b_offset;
uniform float texture_b_intensity = 1.0;

uniform float blend_sharpness = 4.0;

varying vec3 world_pos;
varying vec3 world_normal;

vec4 triplanar(
	sampler2D tex,
	float texture_scale,
	vec3 world_position,
	vec3 normal
) {
	vec3 p = world_position * texture_scale;

	vec3 blend = abs(normal);
	blend = pow(blend, vec3(blend_sharpness));
	blend /= blend.x + blend.y + blend.z;

	vec4 x_proj = texture(tex, p.zy);
	vec4 y_proj = texture(tex, p.xz);
	vec4 z_proj = texture(tex, p.xy);

	return x_proj * blend.x + y_proj * blend.y + z_proj * blend.z;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec4 mask_a = triplanar(
		texture_a,
		texture_a_scale,
		world_pos + texture_a_offset,
		world_normal
	);
	
	vec4 mask_b = triplanar(
		texture_b,
		texture_b_scale,
		world_pos + texture_b_offset,
		world_normal
	);

	ALBEDO = color;
	ALPHA = (mask_a.r * texture_a_intensity + mask_b.r * texture_b_intensity) / 2.0;
}