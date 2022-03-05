shader_type canvas_item;

uniform sampler2D tex;
uniform float uv_scale = 1.0;
uniform float scroll_speed = 0.07;
uniform vec2 real_size;

void fragment() {
	vec2 uv = UV + scroll_speed * TIME;
	uv = uv * uv_scale * vec2(1.0, real_size.y/real_size.x);
	vec2 clamped_uv = uv - floor(uv);
	COLOR = texture(tex, clamped_uv);
}
