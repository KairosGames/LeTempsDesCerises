shader_type canvas_item;

uniform float opening = -0.2;
uniform float corner_opening = 0.3;
uniform float softness = 0.03;

uniform vec2 center = vec2(0.5, 0.5);
uniform float half_width = 0.5;
uniform float darkness = 1.0;

void fragment() {
	vec2 uv = UV;
	vec2 p = uv - center;
	float x = p.x / half_width;
	float curve = sqrt(max(0.0, 1.0 - x * x));
	float eye_height = opening * mix(corner_opening, 1.0, curve);
	float inside = 1.0 - smoothstep(eye_height, eye_height + softness, abs(p.y));
	float inside_width = 1.0 - smoothstep(1.0, 1.0 + softness, abs(x));
	float visible = inside * inside_width;
	COLOR = vec4(0.0, 0.0, 0.0, (1.0 - visible) * darkness);
}
