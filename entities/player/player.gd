class_name Player
extends GridEntity

@export var sprite: AnimatedSprite2D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
const ERROR = preload("uid://bttec44mk0pj8")
const HIT = preload("uid://c6c63snjq6v2r")
@onready var bow: AnimatedSprite2D = $Bow
@onready var arrow: Sprite2D = $Arrow
const ARROW = preload("uid://br52vn5s76t0k")

# Variaveis do arco
var bow_cooldown_counter: int = 0
var is_charging_bow: bool = false
var is_bow_ready: bool = false
const BOW_MAX_COOLDOWN: int = 5


const ACTIONS_VECTOR: Dictionary[StringName, Vector2i] = {
	&"up":    Vector2i.UP,
	&"down":  Vector2i.DOWN,
	&"left":  Vector2i.LEFT,
	&"right": Vector2i.RIGHT,
}

var buffered_action: StringName


func _enter_tree() -> void:
	GameManager.player = self

func _exit_tree() -> void:
	if GameManager.player == self:
		GameManager.player = null

func _ready() -> void:
	super()
	InputJudge.action_judged.connect(_on_action_judged)
	Conductor.beat_hit.connect(_on_beat_hit)

func _on_beat_hit(_beat, _measure) -> void:
	if bow_cooldown_counter > 0:
		bow_cooldown_counter -= 1

	if is_bow_ready:
		fail_bow_charge()
		
		print("Timeout: Perdeu a flecha por demora!")
		return # Encerra aqui para não processar mais nada desse estado

	if is_charging_bow:
		is_charging_bow = false
		is_bow_ready = true

# Executes turn on beat hit based on the GM logic order
func execute_turn(beat: Conductor.BeatInfo, measure: int) -> void:

	if buffered_action == &"space":
		if is_charging_bow or is_bow_ready:
			fail_bow_charge()
		elif bow_cooldown_counter > 0:
			print("Arco em Cooldown! Faltam %d turnos" % bow_cooldown_counter)
			audio.stream = ERROR
			audio.play()
		else:
			_update_facing_direction(&"down")
			start_charging_bow()
		
		buffered_action = &""
		return


	if buffered_action in ACTIONS_VECTOR:
		var direction: Vector2i = ACTIONS_VECTOR[buffered_action]
		

		if is_bow_ready:
			fire_arrow(direction)
			buffered_action = &""
			return
			

		if is_charging_bow:
			fail_bow_charge() 
			buffered_action = &""
			return 
		
		if is_immobile:
			buffered_action = &""
			return
		
		var target_grid_pos: Vector2i = self.grid_pos + direction
		var target_entity: GridEntity = grid.get_first_hittable_entity_at(target_grid_pos)
		
		if target_entity:
			_attack(target_entity)
		elif grid.is_tile_walkable(target_grid_pos) and not grid.is_tile_occupied(target_grid_pos):
			self.move_to(target_grid_pos)
		else:
			_animate_bump(target_grid_pos)
	
	# Limpa a ação no final
	buffered_action = &""


func _on_action_judged(action: StringName, judgment: InputJudge.Judgment, error_ms: int) -> void:
	if judgment == InputJudge.Judgment.HIT:
		buffered_action = action
		_update_facing_direction(action)
	elif judgment == InputJudge.Judgment.MISS:
		if is_charging_bow:
			fail_bow_charge()
		audio.stream = ERROR
		audio.play()

func _update_facing_direction(action: StringName) -> void:
	if action in ACTIONS_VECTOR:
		sprite.play(action)



func _attack(target_entity: GridEntity) -> void:
	print("Player attacking %s" % target_entity.name)
	target_entity.take_damage(base_damage, self)
	# TODO: Tocar animação feedback visual
	_animate_bump(target_entity.grid_pos)


func _animate_bump(target_grid_pos: Vector2i) -> void:
	var target_world = grid.map_to_local(target_grid_pos)
	var start_world = self.global_position
	# Vai até 40% do caminho e volta
	var mid_point = start_world.lerp(target_world, 0.4)
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", mid_point, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", start_world, 0.05).set_trans(Tween.TRANS_SINE)

func _die() -> void:
	health_changed.emit(current_hp, self)
	died.emit(self)
	grid.unregister_entity(self, grid_pos)
	




func start_charging_bow():
	if is_charging_bow or is_bow_ready:
		return
	
	bow.visible = true
	bow.play("charge")
	is_charging_bow = true

func fail_bow_charge():
	bow.visible = false
	print("Falha no Arco: ")
	is_charging_bow = false
	is_bow_ready = false
	start_cooldown()

func start_cooldown():
	bow_cooldown_counter = BOW_MAX_COOLDOWN


func fire_arrow(direction: Vector2i):
	print("Atirando flecha na direção: ", direction)
	
	is_bow_ready = false
	
	var target_grid_pos = grid_pos + direction
	var max_range = 20
	var hit_something = false
	var final_pos = grid_pos + (direction * max_range)
	
	for i in range(max_range):
		# Verifica colisão com Entidades
		var entity = grid.get_first_hittable_entity_at(target_grid_pos)
		
		if entity:
			if entity != self:
				entity.take_damage(base_damage, self) 
				final_pos = target_grid_pos
				hit_something = true
				break
			
		# Verifica colisão com Paredes (Tiles não andáveis)
		if not grid.is_tile_walkable(target_grid_pos):
			final_pos = target_grid_pos
			hit_something = true
			break
		
		# Avança o raio
		target_grid_pos += direction
	

	spawn_arrow_visual(grid_pos, final_pos)
	start_cooldown()


func spawn_arrow_visual(start_grid_coords: Vector2i, end_grid_coords: Vector2i):
	var arrow_instance = Sprite2D.new()
	arrow_instance.texture = ARROW
	
	get_parent().add_child(arrow_instance)
	

	var start_pixel = grid.map_to_local(start_grid_coords)
	var target_pixel = grid.map_to_local(end_grid_coords)
	
	arrow_instance.global_position = start_pixel
	arrow_instance.look_at(target_pixel)
	
	var tween = create_tween()
	var travel_time = 0.25
	
	tween.tween_property(arrow_instance, "global_position", target_pixel, travel_time)
	tween.tween_callback(arrow_instance.queue_free)
	
	bow.play("shoot")
	await bow.animation_finished
	bow.visible = false
