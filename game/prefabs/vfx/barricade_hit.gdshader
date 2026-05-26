shader_type particles;
render_mode collision_use_scale;

#include "tools.gdshaderinc"

uniform vec3 box_size = vec3(4.0, 2.0, 0.6);
uniform vec3 grid_count = vec3(12.0, 6.0, 2.0);

uniform vec3 explosion_direction = vec3(0.0, 0.4, 1.0);
uniform float explosion_force = 8.0;
uniform float random_force = 4.0;
uniform float upward_force = 2.0;

uniform float angular_velocity = 8.0;
uniform float particle_scale = 0.2;

uniform vec3 gravity = vec3(0.0, -9.8, 0.0);
uniform float damping = 0.08;

uniform float collision_bounce = 0.35;
uniform float collision_friction = 0.65;
uniform float collision_spin_damping = 0.5;

void start() {
	uint seed = RANDOM_SEED + uint(INDEX) * 97u + 13u;

	vec3 safe_grid = max(grid_count, vec3(1.0));
	float particle_index = float(INDEX);

	float x = mod(particle_index, safe_grid.x);
	float y = mod(floor(particle_index / safe_grid.x), safe_grid.y);
	float z = mod(floor(particle_index / (safe_grid.x * safe_grid.y)), safe_grid.z);

	vec3 grid_position = vec3(x, y, z);
	vec3 normalized_position = grid_position / max(safe_grid - vec3(1.0), vec3(1.0));

	vec3 local_position = (normalized_position - vec3(0.5)) * box_size;

	TRANSFORM = mat4(
		vec4(particle_scale, 0.0, 0.0, 0.0),
		vec4(0.0, particle_scale, 0.0, 0.0),
		vec4(0.0, 0.0, particle_scale, 0.0),
		vec4(local_position, 1.0)
	);

	vec3 direction = normalize(explosion_direction);
	vec3 random_direction = random_unit_vector(seed);

	float force_variation = mix(1.0 - 0.35, 1.0 + 0.35, random_from_seed(seed));

	VELOCITY =
		direction * explosion_force * force_variation +
		random_direction * random_force +
		vec3(0.0, upward_force * random_from_seed(seed), 0.0);

	CUSTOM.xyz = random_unit_vector(seed);
	CUSTOM.w = mix(-angular_velocity, angular_velocity, random_from_seed(seed));
}

void process() {
	VELOCITY += gravity * DELTA;
	VELOCITY *= max(0.0, 1.0 - damping * DELTA);

	if (COLLIDED && COLLISION_DEPTH > 0.0) {
		vec3 collision_normal = normalize(COLLISION_NORMAL);

		TRANSFORM[3].xyz += collision_normal * COLLISION_DEPTH;

		float normal_speed = dot(VELOCITY, collision_normal);

		if (normal_speed < 0.0) {
			vec3 normal_velocity = collision_normal * normal_speed;
			vec3 tangent_velocity = VELOCITY - normal_velocity;

			VELOCITY =
				tangent_velocity * collision_friction -
				normal_velocity * collision_bounce;

			CUSTOM.w *= collision_spin_damping;
		}
	}

	vec3 axis = normalize(CUSTOM.xyz);
	float angle = CUSTOM.w * DELTA;

	mat3 rotation = rotation_matrix(axis, angle);

	TRANSFORM[0].xyz = rotation * TRANSFORM[0].xyz;
	TRANSFORM[1].xyz = rotation * TRANSFORM[1].xyz;
	TRANSFORM[2].xyz = rotation * TRANSFORM[2].xyz;
}
