shader_type spatial;
render_mode blend_mix, cull_back;

uniform vec2 Scale = vec2(1.0, 1.0);
uniform vec2 Speed_XY;
uniform sampler2D Disolver_Texture : source_color, repeat_enable;
uniform sampler2D Color_1D_Gradient : source_color, repeat_disable;


uniform sampler2D ColorTime_1D_Gradient : source_color, repeat_disable;

// SubUV parameters
uniform ivec2 subuv_grid = ivec2(1, 1); // Columns x Rows
uniform bool use_subuv = false;


vec2 get_subuv_coordinates(vec2 original_uv, ivec2 grid, float random_seed) {
    if (!use_subuv || (grid.x <= 1 && grid.y <= 1)) {
        return original_uv;
    }

    int total_frames = grid.x * grid.y;
    int frame_index = int(random_seed * float(total_frames));
    frame_index = clamp(frame_index, 0, total_frames - 1);

    ivec2 cell = ivec2(frame_index % grid.x, frame_index / grid.x);

    vec2 cell_size = vec2(1.0 / float(grid.x), 1.0 / float(grid.y));
    vec2 cell_offset = vec2(cell) * cell_size;

    // Scale UV to fit within the cell
    vec2 sub_uv = original_uv * cell_size + cell_offset;

    return sub_uv;
}

void fragment() {
    // Calculate base UV coordinates
    vec2 base_uv = UV * Scale;
    vec2 animated_uv = base_uv + Speed_XY * TIME;

    // Get random seed from particle properties
    float random_seed = COLOR.r;

    // Apply subUV transformation if enabled
    vec2 final_uv = use_subuv ? get_subuv_coordinates(animated_uv, subuv_grid, random_seed) : animated_uv;

    // Sample dissolution texture and gradient
    float dissolution_value = texture(Disolver_Texture, final_uv).r;
    vec3 gradient_color = texture(Color_1D_Gradient, vec2(dissolution_value)).rgb;

	float gradient_time_color = texture(ColorTime_1D_Gradient, vec2(COLOR.a,UV.y) ).r;

    // Apply vertex color tint
    vec3 albedo_color = gradient_color * gradient_time_color;

    // Set output parameters
    ALBEDO = albedo_color;
    ALPHA = dissolution_value;
    ALPHA_SCISSOR_THRESHOLD = COLOR.a;
}

void light() {

	vec3 n_out8p0 = clamp(LIGHT_COLOR * vec3(0.30000, 0.30000, 0.30000),vec3(0.0),vec3(1.0));

// Output:0
	DIFFUSE_LIGHT = n_out8p0;

}