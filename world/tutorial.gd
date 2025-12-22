class_name Tutorial
extends BaseLevel

@onready var tile_map_layer_2: TileMapLayer = $GridSystem/TileMapLayer2
@onready var dummy: Dummy = $Enemies/Dummy
@onready var hud: CanvasLayer = $HUD
@onready var obstacles: TileMapLayer = $GridSystem/Obstacles

func _ready() -> void:
	super()
	Conductor.stream_paused = true
	hud.visible = false
	# Impedir o pause de funcionar até a transição terminar

func _play_fall_shader(object):
	object.material.set_shader_parameter("progress", 0.0)
	object.visible = true
	var tween = create_tween()
	tween.tween_property(object.material, "shader_parameter/progress", 1.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	# tocar screen shake com som generico


func start_tutorial() -> void:
	_play_fall_animation(player)
	await get_tree().create_timer(0.25).timeout
	_play_fall_animation(dummy)
	await get_tree().create_timer(0.25).timeout
	_play_fall_shader(obstacles)
	# Tocar Som & Efeito visual de cair no chão


func _play_fall_animation(entity: Node2D) -> void:
	var tween1 = create_tween()
	var tween2 = create_tween()
	entity.visible = true
	var entity_pos: Vector2 = entity.global_position
	entity.global_position -= Vector2(0, 64)
	entity.modulate.a = 0.0
	tween1.tween_property(entity, "global_position", entity_pos, 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween2.tween_property(entity, "modulate:a", 1.0, 0.3)
	
	await tween1.finished
	entity.get_node("ImpactAnimation").play("impact")
	# TODO: Tocar Som & Efeito visual de cair no chão
