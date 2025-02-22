shader_type canvas_item;

uniform vec4 vignette_color : source_color;
uniform float dist;
uniform vec2 position;
uniform vec2 size;

void fragment() {
	COLOR = mix(vignette_color, vec4(0.0), step(distance(UV * size, (position + size / 2.0)), dist) + step(dist, -1));
}




