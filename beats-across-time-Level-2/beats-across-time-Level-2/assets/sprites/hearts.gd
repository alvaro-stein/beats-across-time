extends Node2D

@export var player: Player
@onready var heart1: Sprite2D = $Heart
@onready var heart2: Sprite2D = $Heart2
@onready var heart3: Sprite2D = $Heart3
@onready var heart4: Sprite2D = $Heart4
@onready var heart5: Sprite2D = $Heart5
var heart_sprite = preload("res://assets/sprites/heart.png")
var empty_heart_sprite = preload("res://assets/sprites/heart_empty.png")

func _ready() -> void:
	player.health_changed.connect(_on_health_changed)

func _on_health_changed(amount: int, player: Player):
	match amount:
		5:
			heart1.texture = heart_sprite
			heart2.texture = heart_sprite
			heart3.texture = heart_sprite
			heart4.texture = heart_sprite
			heart5.texture = heart_sprite
		4:
			heart1.texture = heart_sprite
			heart2.texture = heart_sprite
			heart3.texture = heart_sprite
			heart4.texture = heart_sprite
			heart5.texture = empty_heart_sprite
		3:
			heart1.texture = heart_sprite
			heart2.texture = heart_sprite
			heart3.texture = heart_sprite
			heart4.texture = empty_heart_sprite
			heart5.texture = empty_heart_sprite
		2:
			heart1.texture = heart_sprite
			heart2.texture = heart_sprite
			heart3.texture = empty_heart_sprite
			heart4.texture = empty_heart_sprite
			heart5.texture = empty_heart_sprite
		1:
			heart1.texture = heart_sprite
			heart2.texture = empty_heart_sprite
			heart3.texture = empty_heart_sprite
			heart4.texture = empty_heart_sprite
			heart5.texture = empty_heart_sprite
		0:
			heart1.texture = empty_heart_sprite
			heart2.texture = empty_heart_sprite
			heart3.texture = empty_heart_sprite
			heart4.texture = empty_heart_sprite
			heart5.texture = empty_heart_sprite
