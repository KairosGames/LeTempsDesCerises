shader_type spatial;

render_mode cull_disabled, blend_mix;

uniform sampler2D noise_tex;

// Bruit principal
uniform float noise_scale = 2.0;
uniform float noise_speed = 0.4;
uniform float noise_strength = 0.08;

// Glitch
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

    //----------------------------------
    // Bruit continu
    //----------------------------------

    //vec2 uv = VERTEX.xz * noise_scale;
    //float n = texture(noise_tex, uv + vec2(t * noise_speed)).r;
	
	vec2 warp = texture(noise_tex, VERTEX.xz * 0.5 + TIME * 0.05).rg;
	warp = (warp - 0.5) * 0.8;
	float n = texture(noise_tex,VERTEX.xz * 2.0 + warp).r;

    // déplacement dans la normale
    //vec3 base_dir = normalize(vec3(
    //hash(floor(VERTEX * 8.0)),
    //hash(floor(VERTEX * 8.0) + 17.0),
    //hash(floor(VERTEX * 8.0) + 42.0)) * 2.0 - 1.0);
	//OU sans changement brutaux de directions
	vec3 dir = normalize(vec3(sin(n * 6.28 + TIME * 0.4),cos(n * 7.1 + TIME * 0.3),sin(n * 5.3 - TIME * 0.2)));

	//use base_dir or dir
	vec3 smooth_offset = dir * ((n - 0.5) * 2.0) * noise_strength;

    //----------------------------------
    // Glitch
    //----------------------------------

    vec3 cell = floor(VERTEX * glitch_frequency);

    vec3 random_dir = normalize(vec3(hash(cell),hash(cell + 13.0),hash(cell + 31.0)) * 2.0 - 1.0);

    float phase = hash(cell + 53.0) * TAU;

    float pulse = sin(t * glitch_speed + phase);

    // transforme le sinus en impulsions plus franches
    pulse = sign(pulse) * pow(abs(pulse), 8.0);

    vec3 glitch_offset = random_dir * pulse * glitch_strength;

    //----------------------------------

    VERTEX += smooth_offset + glitch_offset;
}

void fragment()
{
	float n = texture(noise_tex, UV * 2.0 + TIME * 0.1).r;

	ALBEDO = vec3(0.02 * n);
    ALPHA = 0.6;
}