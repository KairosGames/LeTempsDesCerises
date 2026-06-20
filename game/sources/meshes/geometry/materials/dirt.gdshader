shader_type spatial;
render_mode blend_mix;

uniform sampler2D albedo_texture: source_color;
uniform float scale = 1.0;

varying vec3 world_pos;
varying vec3 world_normal;

vec4 triplanar(sampler2D tex, float blend_sharpness, float texture_scale, vec3 world_position, vec3 normal) {
	vec3 world_pos = world_position * texture_scale;

    vec3 blend = abs(normal);
    blend = pow(blend, vec3(blend_sharpness));
    blend /= blend.x + blend.y + blend.z;

    vec4 x_proj = texture(tex, world_pos.zy);
    vec4 y_proj = texture(tex, world_pos.xz);
    vec4 z_proj = texture(tex, world_pos.xy);

    return x_proj * blend.x + y_proj * blend.y + z_proj * blend.z;
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec4 color = triplanar(albedo_texture, 4.0, scale, world_pos, world_normal);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
