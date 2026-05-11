
//flipbook : size correspond au tilling, progress à time * speed
vec2 flipbook(vec2 uv, vec2 size, float progress){
	progress = floor( mod(progress, (size.x * size.y)) );
	vec2 frame_size = vec2(1.0, 1.0) / vec2(size.x, size.y);
	vec2 frame = fract(uv / size) + frame_size;
	
	frame.x += ( (progress / size.x) - frame_size.x * floor(progress/size.x) * size.x ) - frame_size.x;
	frame.y += (frame_size.y * floor(progress/size.x) ) - frame_size.y ;
	
	return frame;
}

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}