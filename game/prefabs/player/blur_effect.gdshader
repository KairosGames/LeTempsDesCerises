shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform int strength: hint_range(0, 3) = 3;
uniform float blur_size: hint_range(0.0, 20.0) = 0.0;
uniform float effect = 8.0;

float gauss(int x, int y) {
	return exp(-float(x * x + y * y) / (2.0 * effect * effect)) / (2.0 * PI * effect * effect);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_size = SCREEN_PIXEL_SIZE;

	vec4 color_total = vec4(0.0);
	float weight_total = 0.0;

	for (int i = -strength; i <= strength; i++) {
		for (int j = -strength; j <= strength; j++) {
			float weight = gauss(i, j);
			vec2 offset = vec2(float(i), float(j)) * pixel_size * blur_size;
			color_total += texture(screen_texture, uv + offset) * weight;
			weight_total += weight;
		}
	}
	
	COLOR = color_total / weight_total;
}
