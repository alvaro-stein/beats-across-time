extends BaseLevel

const BLACK_BOAR = preload("uid://crvexsoicooa8")
@onready var grid := GameManager.active_grid
@onready var enemies: Node2D = $Enemies

func _ready() -> void:
	super()
	for enemy in enemies.get_children():
		enemy.queue_free()
	Conductor.beat_hit.connect(_on_beat_hit)

func _on_beat_hit(_beat, _measure) -> void:
	if get_tree().get_nodes_in_group(&"enemy").is_empty():
		# spawna boss
		var black_boar = BLACK_BOAR.instantiate()
		Conductor.stream_paused = true
		
		black_boar.position = grid.map_to_local(Vector2i(23, 16))
		self.add_child(black_boar)
		
		Conductor.stream_paused = false
