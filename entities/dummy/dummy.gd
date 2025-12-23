class_name Dummy
extends GridEntity

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var danger_indicator: ColorRect = $DangerIndicator
var player: Player

enum State { IDLE, WAIT, CHARGE, ATTACK }
var state: State = State.IDLE

func _ready() -> void:
	super()
	player = GameManager.player
	animated_sprite_2d.play("idle")
	danger_indicator.top_level = true
	Conductor.beat_hit.connect(execute_turn)
	

func execute_turn(_beat: Conductor.BeatInfo, _measure: int) -> void:
	match state:
		State.IDLE:
			pass
		State.WAIT:
			state = State.CHARGE
			
		State.CHARGE:
			state = State.ATTACK
			charge_attack()
			
		State.ATTACK:
			state = State.WAIT
			player.take_damage(base_damage, self)
			#grid.get_first_hittable_entity_at(player.grid_pos)\
				#.take_damage(base_damage)
			danger_indicator.visible = false
			_animate_bump(player.grid_pos)


func take_damage(amount: int, source: GridEntity = null) -> void:
	super(amount, source)
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")


func charge_attack() -> void:
	danger_indicator.position = grid.map_to_local(player.grid_pos) - Vector2(32,32)
	var tween := create_tween()
	danger_indicator.modulate.a = 0.0
	danger_indicator.visible = true
	tween.tween_property(danger_indicator, "modulate:a", 0.75, 0.15)


func _animate_bump(target_pos: Vector2i) -> void:
	var target_world = grid.map_to_local(target_pos)
	var start_world = global_position
	animated_sprite_2d.play("attack")
	var tween = create_tween()
	tween.tween_property(self, "global_position", start_world.lerp(target_world, 0.5), 0.05)
	tween.tween_property(self, "global_position", start_world, 0.05)
	
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
