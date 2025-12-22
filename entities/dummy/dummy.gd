class_name Dummy
extends GridEntity

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var danger_indicator: ColorRect = $DangerIndicator
var attack_charged: bool = false
var target_pos: Vector2i

func _ready() -> void:
	super()
	animated_sprite_2d.play("idle")
	danger_indicator.top_level = true

func execute_turn(beat: Conductor.BeatInfo, measure: int) -> void:
	if attack_charged:
		grid.get_first_hittable_entity_at(target_pos)\
		.take_damage(base_damage)
		animated_sprite_2d.play("attack")

func take_damage(amount: int, source: GridEntity = null) -> void:
	super(amount, source)
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")

func charge_attack_at(coords: Vector2i) -> void:
	attack_charged = true
	target_pos = coords
	danger_indicator.global_position = to_global(grid.map_to_local(coords))
	danger_indicator.visible = true
