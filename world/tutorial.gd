class_name Tutorial
extends BaseLevel

@onready var tile_map_layer_2: TileMapLayer = $GridSystem/TileMapLayer2
@onready var dummy: Dummy = $Enemies/Dummy
@onready var hud: CanvasLayer = $HUD
@onready var obstacles: TileMapLayer = $GridSystem/Obstacles
@onready var bridge: TileMapLayer = $GridSystem/Bridge
@onready var impact: AudioStreamPlayer = $Impact
@onready var dialog_box: Control = $HUD/DialogBox
@onready var box1: MarginContainer = $HUD/DialogBox/Box1
@onready var text1: RichTextLabel = $HUD/DialogBox/Box1/PanelContainer/MarginContainer/Text1
@onready var text2: RichTextLabel = $HUD/DialogBox/Box2/PanelContainer/MarginContainer/Text2
@onready var box2: MarginContainer = $HUD/DialogBox/Box2
@onready var hearts: HBoxContainer = $HUD/Control/Hearts

enum TutorialState { MOVE, ATTACK, SUFFER_DAMAGE, FINISH }
var tutorial_state: TutorialState

const IMPACT = preload("uid://d3q7ssn66sjch")

func _ready() -> void:
	super()
	Conductor.beat_hit.connect(_on_beat_hit)
	
	impact.bus = &"Sfx"
	player.get_node("Impact").bus = &"Sfx"
	dummy.get_node("Impact").bus = &"Sfx"
	
	player.visible = false
	dummy.visible = false
	Conductor.stream_paused = true
	hud.visible = false
	obstacles.visible = false
	bridge.visible = false
	box2.visible = false
	hearts.visible = false
	# TODO: Impedir o pause de funcionar até a transição terminar
	
	tutorial_state = TutorialState.MOVE
	
	text1.text = "Boas vindas ao tutorial de Beats Across Time!\nPara começar, tente se mover com as teclas\nWASD ou ▲ ▼ ◄ ►\ne chegar até mim!\nMas atenção: Você precisa acertar a batida da música para agir!"
	text2.text = "Para atacar, você só precisa se mover na direção de um inimigo ao seu alcance.\nVamos, tente me golpear ao menos três vezes!"
	
	if get_parent().name == "root":
		start_tutorial()


func _play_fall_shader(object):
	object.material.set_shader_parameter("progress", 0.0)
	object.visible = true
	var tween = create_tween()
	tween.tween_property(object.material, "shader_parameter/progress", 1.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	await tween.finished
	impact.play()
	# tocar screen shake com som generico


func start_tutorial() -> void:
	_play_fall_animation(player)
	await get_tree().create_timer(0.25).timeout
	_play_fall_animation(dummy)
	await get_tree().create_timer(0.25).timeout
	_play_fall_shader(obstacles)
	await get_tree().create_timer(1.25).timeout
	Conductor.stream_paused = false
	hud.visible = true


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
	entity.get_node("Impact").play()
	# TODO: Tocar Som & Efeito visual de cair no chão


func _on_beat_hit(_beat, _measure) -> void:
	update_tutorial_state()


func update_tutorial_state() -> void:
	match tutorial_state:
		TutorialState.MOVE:
			if player.grid_pos.x >= 15:
				box2.visible = true
				tutorial_state = TutorialState.ATTACK
		
		TutorialState.ATTACK:
			if dummy and dummy.current_hp == 7:
				box2.visible = false
				hearts.visible = true
				text1.text = "Você possui somente 5 pontos de vida, visíveis no topo da tela.\nVocê poderá recuperar sua vida caso consuma pedaços de carne depois de caçar.\nSe entendeu, então me dê mais 3 golpes para continuar."
			elif dummy and dummy.current_hp == 4:
				box2.visible = true
				tutorial_state = TutorialState.SUFFER_DAMAGE
				text2.text = "Tanto você quanto seus inimigos causam 1 de dano por ataque.\nA sua sorte é que eles são previsíveis!\nFique atento ao chão: sempre que ele brilhar em vermelho, um ataque virá no próximo turno.\nMe dê mais dois golpes que eu te mostro!"
			
		TutorialState.SUFFER_DAMAGE:
			if dummy and dummy.current_hp == 2:
				player.is_immobile = true
				if dummy.state == dummy.State.IDLE:
					dummy.state = dummy.State.CHARGE
			if player.current_hp == 2:
				dummy.state = dummy.State.IDLE
				tutorial_state = TutorialState.FINISH
			
		TutorialState.FINISH:
			player.is_immobile = false
			if bridge.visible == false:
				_play_fall_shader(bridge)
			
			text1.text = "Meus ensinamentos acabaram por hoje. Agora é hora de você explorar sozinho e caçar no ritmo do combate!"
			box2.visible = false
			
			if player.grid_pos.x >= 12 and\
			   player.grid_pos.x <= 14 and\
			   player.grid_pos.y == -1:
				var SM := SceneManager
				SM.change_scene_to(SM.MainScene.LEVEL1)
