class_name Player
extends GridEntity

@export var sprite: AnimatedSprite2D

#const ACTIONS: Dictionary[StringName, Dictionary] = {
	#&"up": { "vector": Vector2i.UP, "collider": up },
#}
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

# Executes turn on beat hit based on the GM logic order
func execute_turn(beat: Conductor.BeatInfo, measure: int) -> void:
	if buffered_action in ACTIONS_VECTOR:
		var direction: Vector2i = ACTIONS_VECTOR[buffered_action]
		var target_grid_pos: Vector2i = self.grid_pos + direction
		var target_entity: GridEntity = grid.get_first_hittable_entity_at(target_grid_pos)
		
		if target_entity:
			_attack(target_entity)
		
		elif grid.is_tile_walkable(target_grid_pos) and not grid.is_tile_occupied(target_grid_pos):
			self.move_to(target_grid_pos)
		else:
			_animate_bump(target_grid_pos)
	buffered_action = &""


func _on_action_judged(action: StringName, judgment: InputJudge.Judgment, error_ms: int) -> void:
	if judgment == InputJudge.Judgment.HIT:
		buffered_action = action
		_update_facing_direction(action)
	elif judgment == InputJudge.Judgment.MISS:
		pass

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
	died.emit(self)
	grid.unregister_entity(self, grid_pos)
	
