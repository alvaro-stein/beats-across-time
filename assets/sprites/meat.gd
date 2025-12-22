extends Node2D

var player: Player
@export var grid_pos: Vector2i

func _ready() -> void:
	player = GameManager.player

func consume():
	player.current_hp = player.max_hp
	player.health_changed.emit(player.max_hp, player)
	queue_free()
