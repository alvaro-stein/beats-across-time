extends HBoxContainer

var player: Player
const HEART_FULL = preload("uid://b77rvy2fjucdu")
const HEART_EMPTY = preload("uid://1ppv0o32xuh1")

func _ready() -> void:
	player = GameManager.player
	player.health_changed.connect(_on_player_health_changed)
	
	for i in range(player.max_hp):
		var texture_rect = TextureRect.new()
		texture_rect.texture = HEART_FULL
		#texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
		add_child(texture_rect)

func _on_player_health_changed(current_hp: int, _player: Player):
	var hearts = get_children()
	for i in range(hearts.size()):
		if i < current_hp:
			hearts[i].texture = HEART_FULL
		else:
			hearts[i].texture = HEART_EMPTY
