shader_type canvas_item;

uniform float num = 0.0;
uniform bool reverse = false;

void fragment() {
	vec2 uv = UV;
	vec4 col = texture(TEXTURE, UV);
	
	bool grayscale = (uv.y < num);
	if (reverse) { grayscale = uv.y > num; }
	
	if(grayscale) {
		COLOR.rgb = vec3( (col.r + col.g + col.b)/3.0 );
	} else {
		COLOR = col;
	}
}
