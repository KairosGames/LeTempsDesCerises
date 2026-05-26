float random_from_seed(inout uint seed) {
	seed = seed * 747796405u + 2891336453u;
	uint result = ((seed >> ((seed >> 28u) + 4u)) ^ seed) * 277803737u;
	result = (result >> 22u) ^ result;
	return float(result) / 4294967295.0;
}

vec3 random_unit_vector(inout uint seed) {
	float z = random_from_seed(seed) * 2.0 - 1.0;
	float a = random_from_seed(seed) * TAU;
	float r = sqrt(max(0.0, 1.0 - z * z));

	return vec3(
		r * cos(a),
		z,
		r * sin(a)
	);
}

mat3 rotation_matrix(vec3 axis, float angle) {
	axis = normalize(axis);

	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;

	return mat3(
		vec3(oc * axis.x * axis.x + c,          oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s),
		vec3(oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c,          oc * axis.y * axis.z - axis.x * s),
		vec3(oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c)
	);
}