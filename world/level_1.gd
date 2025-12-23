extends BaseLevel

@onready var arrow: AnimatedSprite2D = $Arrow

func _ready() -> void:
	super()
	Conductor.beat_hit.connect(_on_beat_hit)

func _on_beat_hit(_beat, _measure) -> void:
	if not arrow.visible and get_tree().get_nodes_in_group(&"enemy").is_empty():
		arrow.visible = true
		arrow.play("default")
	
	if player.grid_pos == Vector2i(4, 2) and\
	   get_tree().get_nodes_in_group(&"enemy").is_empty():
		SceneManager.change_scene_to(SceneManager.MainScene.CAVE)
