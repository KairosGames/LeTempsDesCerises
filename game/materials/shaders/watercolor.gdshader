shader_type spatial;

// Inspired from shader toy
// Author: Felipe Tovar-Henao
// Title: Watercolors

uniform sampler2D sceen_texture: hint_screen_texture;

uniform float speed = 0.0;
uniform float uv_scale = 0.5;
uniform float time_offset = 0.0;
uniform float triplanar_sharpness = 4.0;

global uniform float dynamic_da;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

mat2 rot2(in float a){
	float c = cos(a);
	float s = sin(a);
	return mat2(vec2(c, s), vec2(-s, c));
}

float fold(in float x){
	return abs(mod(x + 1., 2.) - 1.);
}

vec2 fold(in vec2 p){
	return vec2(fold(p.x), fold(p.y));
}

float cosine(in float x, in float s){
	float y = cos(fract(x) * PI);
	return floor(x) + .5 - (.5 * pow(abs(y), 1. / s) * sign(y));
}

vec2 cosine(in vec2 p, in float s){
	return vec2(cosine(p.x, s), cosine(p.y, s));
}

vec3 cosine(in vec3 p, in float s){
	return vec3(cosine(p.xy, s), cosine(p.z, s));
}

float scale(in float x, in float a, in float b, in float c, in float d){
	return (x - a) / (b - a) * (d - c) + c;
}

vec3 gradient(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d){
	return a + b * cos(TAU * (c * t + d));
}

uniform vec3 c1 = vec3(.1);
uniform vec3 c2 = vec3(.15);
uniform vec3 c3 = vec3(2.6);
uniform vec3 c4 = vec3(.1, .5, .6);

vec3 watercolor(vec2 uv) {
	vec2 p = uv;
	vec2 q = 1. - uv;

	float t = TIME * speed + time_offset;
	t += cosine(t * .25, 2.);

	float a = .5;
	vec3 col = vec3(0.0);

	for(float i = 1.; i < 9.; i++) {
		float s = pow(1.3, i);
		float an = -a - cos(a * .5 + t) * .125;
		mat2 m = rot2(an);

		p *= m;
		q *= m;

		a += dot(cos(q + t + i - a) / s, vec2(.25));

		vec2 k = fold(q - t - a + s);
		float h = scale(sin(a + t * 1.5), -1., 1., .5, .75);

		q = mix(q, k, h);

		vec2 tmp = q;
		q = p;
		p = tmp;

		q *= 2.;

		float w = a;
		col += gradient(a * .5 + t * .3 + i, c1, c2, c3, c4) * w;
	}

	return cosine(col, 1.5);
}

void fragment() {
	vec3 n = normalize(world_normal);

	vec3 blend = pow(abs(n), vec3(triplanar_sharpness));
	blend /= blend.x + blend.y + blend.z;

	vec3 wp = world_pos * uv_scale;

	vec3 col_x = watercolor(wp.zy); // projection X
	vec3 col_y = watercolor(wp.xz); // projection Y
	vec3 col_z = watercolor(wp.xy); // projection Z

	vec3 col = col_x * blend.x
	         + col_y * blend.y
	         + col_z * blend.z;
	
	ALBEDO = mix(col, texture(sceen_texture, SCREEN_UV).rgb, 1.0 - dynamic_da * 0.8);
}