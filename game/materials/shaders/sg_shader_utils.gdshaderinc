//for vertex pass

//for fragment pass

//saturation : basic saturation value is 1.0
vec3 c_saturation(vec3 input_color, float saturation_value){
		return mix(vec3(dot(vec3(1.0), input_color) *0.33333), input_color, saturation_value);
}