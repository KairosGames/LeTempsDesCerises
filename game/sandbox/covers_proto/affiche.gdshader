shader_type spatial;

uniform sampler2D affiche_texture : source_color;

uniform float width = 1.0;
uniform float radius = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
	float local_x = (UV.x - 0.5) * width;
	
	float angle = local_x / radius;
	
	VERTEX.x = sin(angle) * radius;
	VERTEX.z = radius - cos(angle) * radius;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = texture(affiche_texture, UV).rgb;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
