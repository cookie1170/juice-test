shader_type canvas_item;

uniform vec4 vignette_color : source_color;
uniform float dist;
uniform vec2 position;
uniform vec2 size;

void fragment() {
	float is_in_circle = step(distance(UV * size, (position + size / 2.0)), dist);
	COLOR = mix(vignette_color, vec4(0.0), is_in_circle + step(dist, -1));
}




