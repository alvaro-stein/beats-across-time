extends BaseLevel

@onready var meat: Node2D = $Meat

func _ready() -> void:
	super()
	Conductor.beat_hit.connect(_on_beat_hit)

func _on_beat_hit(_beat, _measure) -> void:
	if player.grid_pos == Vector2i(14, 5):
		SceneManager.change_scene_to(SceneManager.MainScene.LEVEL2)
	if meat and meat.grid_pos == player.grid_pos:
		meat.consume()
