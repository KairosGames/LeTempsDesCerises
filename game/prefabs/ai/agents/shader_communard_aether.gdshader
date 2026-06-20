shader_type spatial;

render_mode cull_disabled, blend_mix, depth_prepass_alpha;

uniform vec3 color: source_color;
global uniform float dynamic_da = 0.5;

group_uniforms Noise;
uniform sampler2D noise_tex;
uniform float noise_scale = 2.0;
uniform float noise_speed = 0.4;
uniform float noise_strength = 0.08;

group_uniforms Glitch;
uniform float glitch_strength = 0.02;
uniform float glitch_speed = 12.0;
uniform float glitch_frequency = 25.0;


float hash(vec3 p)
{
    return fract(sin(dot(p, vec3(127.1,311.7,74.7))) * 43758.5453123);
}

void vertex()
{
    float t = TIME;
	vec2 warp = texture(noise_tex, VERTEX.xz * 0.5 + TIME * 0.05).rg;
	warp = (warp - 0.5) * 0.8;
	float n = texture(noise_tex,VERTEX.xz * 2.0 + warp).r;
	vec3 dir = normalize(vec3(sin(n * 6.28 + TIME * 0.4),cos(n * 7.1 + TIME * 0.3),sin(n * 5.3 - TIME * 0.2)));
	vec3 smooth_offset = dir * ((n - 0.5) * 2.0) * noise_strength;
    vec3 cell = floor(VERTEX * glitch_frequency);
    vec3 random_dir = normalize(vec3(hash(cell),hash(cell + 13.0),hash(cell + 31.0)) * 2.0 - 1.0);
    float phase = hash(cell + 53.0) * TAU;
    float pulse = sin(t * glitch_speed + phase);
    pulse = sign(pulse) * pow(abs(pulse), 8.0);
    vec3 glitch_offset = random_dir * pulse * glitch_strength;
    VERTEX += (smooth_offset + glitch_offset) * dynamic_da;
}

void fragment()
{
	float n = texture(noise_tex, UV * 2.0 + TIME * 0.1).r;

	ALBEDO = mix(color, vec3(0.02 * n), dynamic_da);
	ALPHA = mix(1.0, 0.6, dynamic_da);
}