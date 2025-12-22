class_name EnemyBoar
extends GridEntity

enum State { SEEK, PRE_CHARGE, CHARGE, STUNNED }

@export_group("Boar Settings")
@export var charge_range: int = 3
@export var stun_duration_beats: int = 2

var _state: State = State.SEEK
var _charge_direction: Vector2i = Vector2i.ZERO
var _stun_counter: int = 0
var _player_ref: Player

# Referências visuais
@onready var sprite: Sprite2D = $Sprite2D # Assumindo que existe
@onready var danger_line: Line2D = $DangerLine # Vamos criar isso na cena

func _ready() -> void:
	super()
	# Busca o player via grupo para evitar dependência direta se possível
	# Mas como temos GameManager, podemos usar:
	_player_ref = GameManager.player
	
	add_to_group("enemy")
	faction = Faction.ENEMY
	
	if danger_line:
		danger_line.visible = false
		danger_line.top_level = true # Para desenhar no mundo, não relativo ao Javali movendo

func execute_turn(_beat: Conductor.BeatInfo, _measure: int) -> void:
	if not _player_ref:
		_player_ref = GameManager.player
		if not _player_ref: return # Se não tiver player, não faz nada

	match _state:
		State.STUNNED:
			_handle_stunned_state()
		State.SEEK:
			_handle_seek_state()
		State.PRE_CHARGE:
			_handle_pre_charge_to_charge()
		State.CHARGE:
			# Nota: Geralmente o CHARGE acontece logo após o PRE_CHARGE no mesmo fluxo
			# ou no próximo beat. Aqui faremos no próximo beat para dar tempo de reação.
			pass 

func _handle_stunned_state() -> void:
	_stun_counter -= 1
	print("Boar Stunned... turns left: ", _stun_counter)
	# Feedback visual (ex: mudar cor, tremer)
	sprite.modulate = Color.GRAY
	
	if _stun_counter <= 0:
		_state = State.SEEK
		sprite.modulate = Color.WHITE

func _handle_seek_state() -> void:
	# 1. Checa alinhamento
	var diff = _player_ref.grid_pos - grid_pos
	
	# Se alinhado em X (diff.x == 0) ou Y (diff.y == 0)
	# E está numa distância razoável (não está em cima)
	if (diff.x == 0 or diff.y == 0) and diff.length() > 1.0:
		# Verifica se tem parede no caminho (Raycast lógico)
		if _has_clear_line_of_sight(_player_ref.grid_pos):
			_start_pre_charge(diff)
			return

	# 2. Se não alinhou, persegue normal (A*)
	# Usamos a lógica padrão de movimento (copiada ou herdada, mas simplificada aqui)
	var path = grid.astar.get_id_path(grid_pos, _player_ref.grid_pos)
	if path.size() > 1:
		var next = path[1]
		if not grid.is_tile_occupied(next):
			_orient_sprite(next - grid_pos)
			move_to(next)

func _start_pre_charge(diff_vector: Vector2i) -> void:
	_state = State.PRE_CHARGE
	# Normaliza o vetor para pegar a direção pura (1,0), (-1,0), etc.
	_charge_direction = Vector2i(sign(diff_vector.x), sign(diff_vector.y))
	_orient_sprite(_charge_direction)
	
	# Visual Feedback: Desenha a linha de perigo
	if danger_line:
		danger_line.visible = true
		danger_line.clear_points()
		# Ponto inicial (centro do javali)
		danger_line.add_point(grid.map_to_local(grid_pos))
		# Ponto final (até onde ele vai correr: 3 tiles)
		var target_dest = grid_pos + (_charge_direction * charge_range)
		danger_line.add_point(grid.map_to_local(target_dest))
		
		# Animação de piscada na linha
		var tween = create_tween()
		danger_line.modulate.a = 0.5
		tween.tween_property(danger_line, "modulate:a", 1.0, 0.2).set_loops(2)

func _handle_pre_charge_to_charge() -> void:
	# Esse turno é a execução da investida!
	_state = State.CHARGE # Apenas semântico, pois vamos executar agora
	if danger_line: danger_line.visible = false
	
	# Loop para andar X tiles num único turno
	for i in range(charge_range):
		var next_tile = grid_pos + _charge_direction
		
		# 1. Verifica PAREDE
		if not grid.is_tile_walkable(next_tile):
			_apply_stun()
			return # Interrompe a investida imediatamente
		
		# 2. Verifica Entidades (Player)
		var target = grid.get_first_hittable_entity_at(next_tile)
		if target:
			if target.faction == Faction.PLAYER:
				target.take_damage(base_damage, self)
				# Bateu no player: para, mas não stuna (ou stuna se quiser facilitar)
				_state = State.SEEK 
				return
			else:
				# Bateu em outro inimigo? Bloqueia e para.
				_state = State.SEEK
				return
		
		# 3. Caminho livre: Move
		# Nota: move_to usa tween. Se chamarmos 3x rápido, o tween pode sobrescrever.
		# Para o MVP, o GridEntity atualiza a posição lógica instantaneamente, 
		# então visualmente ele vai "teletransportar" ou deslizar rápido até o final.
		move_to(next_tile)
		
		# Pequeno delay visual se quiser ver ele "andando" tile a tile (opcional)
		# await get_tree().create_timer(0.05).timeout 
	
	# Se completou a carga sem bater em nada:
	_state = State.SEEK

func _apply_stun() -> void:
	print("Boar hit a wall! Stunned!")
	_state = State.STUNNED
	_stun_counter = stun_duration_beats
	
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
		sprite.flip_h = (dir.x > 0) # Ajuste conforme sua arte
