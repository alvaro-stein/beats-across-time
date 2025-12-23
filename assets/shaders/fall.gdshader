shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float fall_distance = 20.0;

void vertex() {
	// Aqui o UV.y vai de 0.0 (topo do tile) a 1.0 (base do tile)
	// Multiplicamos o progresso para que cada tile caia individualmente
	float offset = (1.0 - progress) * fall_distance;
	VERTEX.y += offset;
}

void fragment() {
	// Pega a cor do tile
	vec4 tex_color = texture(TEXTURE, UV);

	// Faz o fade individual de cada tile baseado no progress
	// Se progress for 0, alpha é 0. Se progress for 1, alpha é 1.
	COLOR = vec4(tex_color.rgb, tex_color.a * progress);
}