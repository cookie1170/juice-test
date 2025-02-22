shader_type canvas_item;

uniform float amount : hint_range(0.0, 1.0, 0.01);
uniform float burn_edge_size : hint_range(0.0, 1.0, 0.01);
uniform float tint_amount : hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_edge_color : source_color;
uniform vec3 tint_color : source_color;
uniform sampler2D noise_texture;


void fragment() {
	float amount_at_uv = texture(noise_texture, UV).r;
	float inversed_amount = 1.0 - amount;
	float burn_edge_step = amount_at_uv * (1.0 - step(amount, 0.001)) * (step(amount, 0.999));
	float dissolve_threshold = step(amount_at_uv, inversed_amount); // 0 or 1
	float burn_edge = step(burn_edge_step, inversed_amount - burn_edge_size);
	COLOR.a *= dissolve_threshold;
	COLOR.rgb = mix(mix(COLOR.rgb, tint_color, tint_amount).rgb, burn_edge_color.rgb, 1.0 - burn_edge);
}
