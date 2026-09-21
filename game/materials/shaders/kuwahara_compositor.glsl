#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform readonly image2D input_image;
layout(rgba16f, set = 0, binding = 1) uniform writeonly image2D output_image;
layout(set = 0, binding = 2) uniform sampler2D depth_texture;

layout(push_constant, std430) uniform Params {
    vec2 raster_size;
    float dynamic_da;
    float copy_pass;
    vec4 depth_fade;
    mat4 inverse_projection;
} params;

vec3 read_color(ivec2 pixel, ivec2 size) {
    return imageLoad(input_image, clamp(pixel, ivec2(0), size - ivec2(1))).rgb;
}

float get_view_distance(ivec2 pixel) {
    float depth = texelFetch(depth_texture, pixel, 0).r;
    vec2 uv = (vec2(pixel) + vec2(0.5)) / params.raster_size;
    vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
    vec4 view_position = params.inverse_projection * vec4(ndc, 1.0);
    return abs(view_position.z / view_position.w);
}

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    ivec2 size = ivec2(params.raster_size);
    if (pixel.x >= size.x || pixel.y >= size.y) {
        return;
    }

    vec4 source = imageLoad(input_image, pixel);
    if (params.copy_pass > 0.5) {
        imageStore(output_image, pixel, source);
        return;
    }

    int radius = int(clamp(params.dynamic_da, 0.0, 1.0) * 5.0);
    if (radius == 0) {
        imageStore(output_image, pixel, source);
        return;
    }

    vec3 means[4] = vec3[4](vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));
    vec3 squares[4] = vec3[4](vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));

    for (int y = -radius; y <= 0; y++) {
        for (int x = -radius; x <= 0; x++) {
            vec3 color = read_color(pixel + ivec2(x, y), size);
            means[0] += color;
            squares[0] += color * color;
        }
    }

    for (int y = -radius; y <= 0; y++) {
        for (int x = 0; x <= radius; x++) {
            vec3 color = read_color(pixel + ivec2(x, y), size);
            means[1] += color;
            squares[1] += color * color;
        }
    }

    for (int y = 0; y <= radius; y++) {
        for (int x = 0; x <= radius; x++) {
            vec3 color = read_color(pixel + ivec2(x, y), size);
            means[2] += color;
            squares[2] += color * color;
        }
    }

    for (int y = 0; y <= radius; y++) {
        for (int x = -radius; x <= 0; x++) {
            vec3 color = read_color(pixel + ivec2(x, y), size);
            means[3] += color;
            squares[3] += color * color;
        }
    }

    float sample_count = float((radius + 1) * (radius + 1));
    float minimum_variance = 1e20;
    vec3 filtered_color = source.rgb;

    for (int index = 0; index < 4; index++) {
        vec3 mean = means[index] / sample_count;
        vec3 variance = abs(squares[index] / sample_count - mean * mean);
        float total_variance = variance.r + variance.g + variance.b;
        if (total_variance < minimum_variance) {
            minimum_variance = total_variance;
            filtered_color = mean;
        }
    }

    float view_distance = get_view_distance(pixel);
    float distance_blend = smoothstep(params.depth_fade.x, params.depth_fade.y, view_distance);
    float effect_strength = mix(1.0, params.depth_fade.z, distance_blend);
    vec3 final_color = mix(source.rgb, filtered_color, effect_strength);
    imageStore(output_image, pixel, vec4(final_color, source.a));
}
