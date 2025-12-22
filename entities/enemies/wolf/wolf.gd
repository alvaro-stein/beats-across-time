class_name SimpleEnemy
extends GridEntity

enum State { SEEK, CHARGE_ATTACK }

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var state: State = State.SEEK
var _attack_target_pos: Vector2i
var player: Player

@export var danger_indicator: ColorRect

func _ready() -> void:
	super()
	player = GameManager.player
	add_to_group("enemy")
	faction = Faction.ENEMY
	
	# Configuração inicial do visual
	if danger_indicator:
		danger_indicator.visible = false
		danger_indicator.top_level = true # Para podermos mover ele livremente pelo grid sem herdar transform do node pai


func execute_turn(_beat: Conductor.BeatInfo, _measure: int) -> void:
	if not player:
		return

	match state:
		State.SEEK:
			_handle_chase_state()
			
		State.CHARGE_ATTACK:
			_handle_attack_execution()


func _handle_chase_state() -> void:
	var dist = grid_pos.distance_to(player.grid_pos) # Distância Manhattan aproximada no grid
	
	# Se estivermos ao lado (distância de 1 tile, não diagonal), preparamos o ataque
	if dist == 1.0:
		_start_attack_charge(player.grid_pos)
	else:
		_move_towards_target(player.grid_pos)


func _start_attack_charge(target_pos: Vector2i) -> void:
	state = State.CHARGE_ATTACK
	_attack_target_pos = target_pos
	
	# Visual Feedback
	if danger_indicator:
		danger_indicator.global_position = grid.map_to_local(target_pos) - Vector2(32, 32)
		danger_indicator.visible = true
		var tween = create_tween()
		danger_indicator.modulate.a = 0.0
		tween.tween_property(danger_indicator, "modulate:a", 0.75, 0.15)


func _handle_attack_execution() -> void:
	if player.grid_pos == _attack_target_pos:
		player.take_damage(base_damage, self)
		_animate_bump(_attack_target_pos)
	
	# Reseta estado
	state = State.SEEK
	if danger_indicator:
		danger_indicator.visible = false


func _move_towards_target(target_pos: Vector2i) -> void:
	var path := grid.pathfinder.get_id_path(grid_pos, target_pos)
	
	# path[0] é a posição atual, path[1] é o próximo passo
	if path.size() > 1:
		var next_step: Vector2i = path[1]
		
		var direction_x = next_step.x - grid_pos.x
		
		if direction_x != 0:
			# Se direction_x < 0 (indo pra esquerda), flip_h vira TRUE.
			# Se direction_x > 0 (indo pra direita), flip_h vira FALSE.
			sprite.flip_h = (direction_x > 0)
		
		# The tile is empty?
		if not grid.is_tile_occupied(next_step):
			sprite.play("left")
			move_to(next_step)


func _animate_bump(target_pos: Vector2i) -> void:
	var target_world = grid.map_to_local(target_pos)
	var start_world = global_position
	sprite.play("attack")
	var tween = create_tween()
	tween.tween_property(self, "global_position", start_world.lerp(target_world, 0.5), 0.05)
	tween.tween_property(self, "global_position", start_world, 0.05)
