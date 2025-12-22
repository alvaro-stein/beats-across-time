class_name BlackBoar
extends Boar


func _execute_charge() -> void:
	_transition_to(State.CHARGE)
	if danger_line: danger_line.visible = false
	sprite.play("charge")
	
	for i in range(charge_range):
		var next_tile = grid_pos + _charge_direction
		
		if not grid.is_tile_walkable(next_tile):
			apply_stun()
			return 
		
		var target = grid.get_first_hittable_entity_at(next_tile)
		if target:
			if _handle_collision(target):
				return
		
		move_to(next_tile)
	
	# Lógica de chain charge pra avançar continuamente
	if _can_chain_charge():
		print("Black Boar found target! Chaining charge!")
		# Volta para PRE_CHARGE imediatamente. 
		_transition_to(State.PRE_CHARGE)
		_draw_danger_line()
	else:
		_transition_to(State.SEEK)


## Verifica se o player ainda está alinhado e visível na mesma direção
func _can_chain_charge() -> bool:
	if not player: return false
	
	var diff = player.grid_pos - grid_pos
	
	var direction_to_player = Vector2i(sign(diff.x), sign(diff.y))
	
	if direction_to_player != _charge_direction:
		return false
		
	if not _has_clear_line_of_sight(player.grid_pos):
		return false
		
	return true
