#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0) uniform sampler2D source_color;
layout(rgba16f, set = 0, binding = 1) uniform writeonly image2D destination_color;

layout(push_constant, std430) uniform Parameters {
    vec2 size;
    vec2 direction;
    float blur_size;
    float padding_0;
    float padding_1;
    float padding_2;
} parameters;

void main() {
    ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
    if (any(greaterThanEqual(pixel, ivec2(parameters.size)))) {
        return;
    }

    vec2 uv = (vec2(pixel) + vec2(0.5)) / parameters.size;
    vec2 step_uv = parameters.direction * parameters.blur_size / parameters.size;
    // Normalized separable weights of the original sigma-8, radius-3 kernel.
    const float weights[4] = float[](0.147338174, 0.146191579, 0.142805055, 0.137334279);
    vec4 color = textureLod(source_color, uv, 0.0) * weights[0];
    for (int i = 1; i <= 3; ++i) {
        vec2 offset = float(i) * step_uv;
        color += (textureLod(source_color, uv + offset, 0.0)
                + textureLod(source_color, uv - offset, 0.0)) * weights[i];
    }
    imageStore(destination_color, pixel, color);
}
