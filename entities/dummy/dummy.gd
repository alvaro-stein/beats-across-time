class_name Dummy
extends GridEntity

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super()
	animated_sprite_2d.play("idle")

func execute_turn(beat: Conductor.BeatInfo, measure: int) -> void:
	pass

func take_damage(amount: int, source: GridEntity = null) -> void:
	super(amount, source)
	animated_sprite_2d.play("hurt")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
