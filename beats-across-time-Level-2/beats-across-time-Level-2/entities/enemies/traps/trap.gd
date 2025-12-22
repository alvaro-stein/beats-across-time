class_name Trap
extends GridEntity

# Ciclo de vida da armadilha
enum State { IDLE, WARNING, ACTIVE }

@export_group("Trap Settings")
# De quantos em quantos beats ela completa um ciclo?
@export var cycle_length_beats: int = 3
# Em qual beat do ciclo ela ativa? (Ex: no beat 2 ela avisa, no 3 ela ataca)
@export var activation_beat: int = 2

var current_step: int = 0
var _state: State = State.IDLE

# Referência visual para indicar perigo 
@export var danger_indicator: ColorRect
# TODO: change to AnimatedSprite2D
@export var sprite: Sprite2D

func _ready() -> void:
	super() 
	add_to_group("trap")

	faction = Faction.TRAP
	is_immobile = true
	is_hittable = false # Armadilhas geralmente não podem ser atacadas
	occupies_tile = false # Permite que Player/Inimigos andem por cima
	
	_update_visuals()

# Chamado pelo GameManager na fase "Traps"
func execute_turn(_beat: Conductor.BeatInfo, _measure: int) -> void:
	# Avança o ciclo (0 -> 1 -> 2 -> 0 ...)
	current_step = (current_step + 1) % cycle_length_beats
	
	_calculate_state()
	_perform_state_action()
	_update_visuals()

func _calculate_state() -> void:
	# Exemplo: Se cycle=3 e activation=2 (0=Idle, 1=Warn, 2=Active)
	if current_step == activation_beat:
		_state = State.ACTIVE
	elif current_step == activation_beat - 1:
		_state = State.WARNING
	else:
		_state = State.IDLE

func _perform_state_action() -> void:
	if _state == State.ACTIVE:
		# Verifica quem está no mesmo tile AGORA
		var targets = grid.get_entities_at(grid_pos)
		for target in targets:
			if target != self and target.is_hittable:
				# Causa dano no Player e Inimigos
				target.take_damage(base_damage, self)
				print("Trap at %s hit %s!" % [grid_pos, target.name])

func _update_visuals() -> void:
	# Lógica simples para alternar visibilidade.
	# Usaria AnimationPlayer aqui
	if danger_indicator:
		danger_indicator.visible = (_state == State.WARNING)
		
	if sprite: # TODO: HARDCODED
		if _state == State.ACTIVE:
			sprite.scale = Vector2(3.5, 3.5)
		else:
			sprite.scale = Vector2(2.0, 2.0)
