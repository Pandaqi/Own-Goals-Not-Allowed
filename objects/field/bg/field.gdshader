shader_type canvas_item;

uniform sampler2D tex;
uniform float uv_scale  = 5.0;
uniform float blend = 0.5;

void fragment() {
	vec2 uv = UV * uv_scale;
	vec2 clipped_uv = uv - floor(uv);
	COLOR = mix(COLOR, texture(tex, clipped_uv), blend);
}
