shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 0.7;
uniform float softness : hint_range(0.0, 5.0) = 0.5;

void fragment() {
	float dist = distance(UV, vec2(0.5));
	float alpha_value = smoothstep(0.0, softness, dist * (1.0 / radius));
	COLOR.a *= alpha_value;
}