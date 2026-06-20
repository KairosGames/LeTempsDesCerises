shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_size = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    vec2 pixel = TEXTURE_PIXEL_SIZE * outline_size;

    float outline = 0.0;

    outline += texture(TEXTURE, UV + vec2(pixel.x, 0.0)).a;
    outline += texture(TEXTURE, UV - vec2(pixel.x, 0.0)).a;
    outline += texture(TEXTURE, UV + vec2(0.0, pixel.y)).a;
    outline += texture(TEXTURE, UV - vec2(0.0, pixel.y)).a;
    outline += texture(TEXTURE, UV + vec2(pixel.x, pixel.y) * 1.414).a;

    if (tex.a < 0.1 && outline > 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = tex * COLOR ;
    }
}
