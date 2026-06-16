shader_type spatial;

uniform float bend_strength = 0.1;
uniform sampler2D affiche_texture : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
	float uv = UV.x - 0.5;
	float edge = abs(uv) * 2.0;
	VERTEX.z += pow(edge,2.0) * bend_strength;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(affiche_texture, UV).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
