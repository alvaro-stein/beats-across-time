class_name Boar
extends GridEntity

enum State { SEEK, PRE_CHARGE, CHARGE, STUNNED }

# Constantes de configuração visual e feedback
const TILE_HALF_SIZE := 32.0
const TWEEN_FADE_DURATION := 0.2
const SHAKE_DURATION := 0.05
const SHAKE_OFFSET := 10.0

@export_group("Boar Settings")
@export var charge_range: int = 4
@export var stun_duration_beats: int = 2

# Referências
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var danger_line: Line2D = $DangerLine

var _state: State = State.SEEK
var _charge_direction: Vector2i = Vector2i.ZERO
var _stun_counter: int = 0
var player: Player

func _ready() -> void:
	super()
	add_to_group("enemy")
	faction = Faction.ENEMY
	
	player = GameManager.player
	sprite.play("idle")
	
	if danger_line:
		danger_line.visible = false
		danger_line.top_level = true # Desenhar no mundo, independente do transform do pai

func execute_turn(_beat: Conductor.BeatInfo, _measure: int) -> void:
	match _state:
		State.STUNNED:
			_handle_stunned_state()
		State.SEEK:
			_handle_seek_state()
		State.PRE_CHARGE:
			_execute_charge()
		State.CHARGE:
			pass # Estado transitório, ação ocorre no PRE_CHARGE

# --- Lógica de Estados ---

func _handle_stunned_state() -> void:
	_stun_counter -= 1
	print("Boar Stunned... turns left: ", _stun_counter)
	
	if _stun_counter <= 0:
		_transition_to(State.SEEK)

func _handle_seek_state() -> void:
	if not player:
		return

	var diff = player.grid_pos - self.grid_pos
	
	# Verifica alinhamento nos eixos (X ou Y) e distância
	var is_aligned = (diff.x == 0 or diff.y == 0)
	var in_range = diff.length() <= charge_range
	
	if is_aligned and in_range and _has_clear_line_of_sight(player.grid_pos):
		_start_pre_charge(diff)
	else:
		_move_towards_player()

func _start_pre_charge(diff_vector: Vector2i) -> void:
	_transition_to(State.PRE_CHARGE)
	
	_charge_direction = Vector2i(sign(diff_vector.x), sign(diff_vector.y))
	_orient_sprite(_charge_direction)
	
	_draw_danger_line()

func _execute_charge() -> void:
	_transition_to(State.CHARGE)
	if danger_line: danger_line.visible = false
	sprite.play("charge")
	
	for i in range(charge_range):
		var next_tile = grid_pos + _charge_direction
		
		# 1. Verifica Parede
		if not grid.is_tile_walkable(next_tile):
			apply_stun()
			return # Interrompe carga
		
		# 2. Verifica Entidades
		var target = grid.get_first_hittable_entity_at(next_tile)
		if target:
			if _handle_collision(target):
				return # Interrompe carga se a colisão foi bloqueante
		
		# 3. Caminho livre (ou alvo morreu): Move
		move_to(next_tile)
	
	# Se completou o trajeto sem interrupções
	_transition_to(State.SEEK)

# --- Auxiliares de Lógica ---

## Retorna true se a colisão deve parar a carga
func _handle_collision(target: GridEntity) -> bool:
	if target.faction == Faction.PLAYER:
		target.take_damage(base_damage, self)
		_transition_to(State.SEEK)
		return true # Player bloqueia e encerra carga
		
	elif target is Boar:
		target.apply_stun()
		self.apply_stun()
		return true # Colisão dupla causa stun em ambos
		
	else:
		# Outros inimigos (Atropelamento)
		target.take_damage(base_damage, self)
		if target.current_hp > 0:
			_transition_to(State.SEEK)
			return true # Inimigo sobreviveu e bloqueou
		
		return false # Inimigo morreu, continua carga

func _move_towards_player() -> void:
	var path = grid.pathfinder.get_id_path(grid_pos, player.grid_pos)
	if path.size() > 1:
		var next = path[1]
		if not grid.is_tile_occupied(next):
			_orient_sprite(next - grid_pos)
			move_to(next)
			_play_run_animation()
		else:
			sprite.play("idle")
	else:
		sprite.play("idle")

func apply_stun() -> void:
	print("Boar hit a wall! Stunned!")
	_state = State.STUNNED
	_stun_counter = stun_duration_beats
	sprite.play("stun")
	_animate_shake()

func _transition_to(new_state: State) -> void:
	_state = new_state
	if new_state == State.SEEK:
		sprite.play("idle")

# --- Visuais e Utilitários ---

func _draw_danger_line() -> void:
	if not danger_line: return
	
	danger_line.visible = true
	danger_line.clear_points()
	
	var center_pos = grid.map_to_local(grid_pos)
	var offset = Vector2(_charge_direction) * TILE_HALF_SIZE
	
	# Calcula pontos inicial e final visualmente ajustados
	var start_point = center_pos + offset
	var target_grid = grid_pos + (_charge_direction * charge_range)
	var end_point = grid.map_to_local(target_grid) + offset # Nota: Ajuste se quiser alinhar diferente
	
	danger_line.add_point(start_point)
	danger_line.add_point(end_point)
	
	# Feedback de "Warning" piscando
	var tween = create_tween()
	danger_line.modulate.a = 0.5
	tween.set_loops(2).tween_property(danger_line, "modulate:a", 1.0, TWEEN_FADE_DURATION)

func _animate_shake() -> void:
	var tween = create_tween()
	var original_pos = global_position
	var shake_vec = Vector2(_charge_direction) * SHAKE_OFFSET
	tween.tween_property(self, "position", original_pos + shake_vec, SHAKE_DURATION)
	tween.tween_property(self, "position", original_pos, SHAKE_DURATION)

func _play_run_animation() -> void:
	sprite.play("run")
	await sprite.animation_finished
	if _state == State.SEEK: # Só volta pra idle se ainda estivermos buscando
		sprite.play("idle")

func _has_clear_line_of_sight(target: Vector2i) -> bool:
	var current = grid_pos
	var dir = Vector2i(sign(target.x - current.x), sign(target.y - current.y))
	
	current += dir
	while current != target:
		if not grid.is_tile_walkable(current):
			return false
		current += dir
	return true

func _orient_sprite(dir: Vector2i) -> void:
	if dir.x != 0:
		sprite.flip_h = (dir.x > 0)
