shader_type spatial;

render_mode cull_disabled;

uniform sampler2D noise_tex;

uniform float amplitude = 0.1;
uniform float speed = 1.0;
uniform float scale = 2.0;

void vertex()
{
    vec2 uv = VERTEX.xy * scale;

    float t = TIME * speed;

    float n = texture(noise_tex, uv + vec2(t)).r;

    vec3 dir = NORMAL;

    VERTEX += dir * (n - 0.5) * amplitude;