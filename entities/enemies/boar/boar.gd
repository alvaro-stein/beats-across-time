class_name Boar
extends GridEntity

enum State { SEEK, PRE_CHARGE, CHARGE, STUNNED }

@export_group("Boar Settings")
@export var charge_range: int = 4
@export var stun_duration_beats: int = 2

var _state: State = State.SEEK
var _charge_direction: Vector2i = Vector2i.ZERO
var _stun_counter: int = 0
var player: Player

# Referências visuais
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var danger_line: Line2D = $DangerLine

func _ready() -> void:
	super()
	sprite.play("idle")
	player = GameManager.player
	
	add_to_group("enemy")
	faction = Faction.ENEMY
	
	if danger_line:
		danger_line.visible = false
		danger_line.top_level = true # Para desenhar no mundo, não relativo ao Javali movendo

func execute_turn(_beat: Conductor.BeatInfo, _measure: int) -> void:
	match _state:
		State.STUNNED:
			_handle_stunned_state()
		State.SEEK:
			_handle_seek_state()
		State.PRE_CHARGE:
			_handle_pre_charge_to_charge()
		State.CHARGE:
			# NOTE: Geralmente o CHARGE acontece logo após o PRE_CHARGE no mesmo fluxo ou no próximo beat. Aqui faremos no próximo beat para dar tempo de reação.
			pass 

func _handle_stunned_state() -> void:
	_stun_counter -= 1
	print("Boar Stunned... turns left: ", _stun_counter)
	
	if _stun_counter <= 0:
		_state = State.SEEK

func _handle_seek_state() -> void:
	sprite.play("idle")
	# Checa alinhamento
	var diff = player.grid_pos - self.grid_pos
	
	# Se alinhado em X ou Y e se ta na distância do charge
	if (diff.x == 0 or diff.y == 0) and (diff.length() <= charge_range):
		# Verifica se tem parede no caminho
		if _has_clear_line_of_sight(player.grid_pos):
			_start_pre_charge(diff)
			return

	var path = grid.pathfinder.get_id_path(grid_pos, player.grid_pos)
	if path.size() > 1:
		var next = path[1]
		if not grid.is_tile_occupied(next):
			_orient_sprite(next - grid_pos)
			move_to(next)
			sprite.play("run")
			await sprite.animation_finished
			sprite.play("idle")
		else:
			sprite.play("idle")
	else:
		sprite.play("idle")

func _start_pre_charge(diff_vector: Vector2i) -> void:
	_state = State.PRE_CHARGE
	# Normaliza o vetor para pegar a direção pura (1,0), (-1,0), etc.
	_charge_direction = Vector2i(sign(diff_vector.x), sign(diff_vector.y))
	_orient_sprite(_charge_direction)
	
	# Visual Feedback: Desenha a linha de perigo
	if danger_line:
		danger_line.visible = true
		danger_line.clear_points()
		
		var half_tile_size = 32.0
		var center_pos = grid.map_to_local(grid_pos)
		
		var start_offset = Vector2(_charge_direction) * half_tile_size
		var start_point = center_pos + start_offset
		var end_offset = Vector2(_charge_direction) * half_tile_size
		
		var target_dest_grid = grid_pos + (_charge_direction * charge_range)
		var end_point = grid.map_to_local(target_dest_grid) + end_offset
		
		# Ponto inicial
		danger_line.add_point(start_point)
		# Ponto final
		danger_line.add_point(end_point)
		
		# Animação de piscada na linha
		var tween = create_tween()
		danger_line.modulate.a = 0.5
		tween.set_loops(2).tween_property(danger_line, "modulate:a", 1.0, 0.2)

func _handle_pre_charge_to_charge() -> void:
	_state = State.CHARGE
	if danger_line: danger_line.visible = false
	sprite.play("charge")
	
	# Loop para andar X tiles num único turno
	for i in range(charge_range):
		var next_tile = grid_pos + _charge_direction
		
		# Verifica paredes e obstaculos
		if not grid.is_tile_walkable(next_tile):
			apply_stun()
			return # Interrompe a investida imediatamente
		
		# Verifica Entidades
		var target = grid.get_first_hittable_entity_at(next_tile)
		if target:
			if target.faction == Faction.PLAYER:
				target.take_damage(base_damage, self)
				_state = State.SEEK
				sprite.play("idle")
				return
			elif target is Boar:
				target.apply_stun()
				self.apply_stun()
				return
			else:
				target.take_damage(base_damage, self)
				if target.current_hp > 0:
					_state = State.SEEK
					return
		
		move_to(next_tile)
	
	_state = State.SEEK
	sprite.play("idle")

func apply_stun() -> void:
	print("Boar hit a wall! Stunned!")
	_state = State.STUNNED
	_stun_counter = stun_duration_beats
	sprite.play("stun")
	# Animação de impacto (Shake)
	var tween = create_tween()
	var original_pos = global_position
	tween.tween_property(self, "position", original_pos + Vector2(_charge_direction * 10), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

func _has_clear_line_of_sight(target: Vector2i) -> bool:
	# Raycast simples no Grid
	var current = grid_pos
	var dir = Vector2i(sign(target.x - current.x), sign(target.y - current.y))
	
	current += dir
	while current != target:
		if not grid.is_tile_walkable(current):
			return false # Tem parede no caminho
		current += dir
	return true

func _orient_sprite(dir: Vector2i) -> void:
	if dir.x != 0:
		sprite.flip_h = (dir.x > 0)
