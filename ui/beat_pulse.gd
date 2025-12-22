extends ColorRect

func _ready() -> void:
	InputJudge.action_judged.connect(_on_action_judged)
	self.color.a = 0.0
	self.visible = true


func _on_action_judged(_action: StringName, judgment: InputJudge.Judgment, _error_ms) -> void:
	if judgment == InputJudge.Judgment.HIT:
		self.color = Color.SPRING_GREEN
		
	elif judgment == InputJudge.Judgment.MISS:
		self.color = Color.FIREBRICK
	
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, 0.25)
