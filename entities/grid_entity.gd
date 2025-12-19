@abstract
class_name GridEntity
extends Node2D

signal died(entity: GridEntity)

enum Faction { PLAYER, TRAP, ENEMY, BOSS, NEUTRAL }

@export_group("Stats")
@export var faction: Faction = Faction.NEUTRAL
@export var max_hp: int = 1
@export var base_damage: int = 1
@export var is_hittable: bool = false
@export var occupies_tile: bool = false
@export var is_immobile: bool = false

var current_hp: int
var grid_pos: Vector2i
var grid: GridSystem

### Referência opcional para animar algo específico (ex: o Sprite dentro do Player)
### Se não for atribuído, moveremos o próprio root do objeto.
#@export var visual_node: Node2D


func _ready() -> void:
	current_hp = max_hp
	grid = GameManager.active_grid
	assert(grid != null, "Error: GameManager.active_grid == null")
	
	grid_pos = grid.local_to_map(self.global_position)
	self.global_position = grid.map_to_local(grid_pos)
	grid.register_entity(self, grid_pos)
	assert(grid.get_cell_source_id(grid_pos) != -1, "Error: Entity '%s' started on an empty or invalid tile at %s. Please check the TileMap placement." % [name, grid_pos])


@abstract
func execute_turn(beat: Conductor.BeatInfo, measure: int) -> void


## Moves the entity logically and visually.
## Does not check for entities occupying the target position.
func move_to(target_grid_pos: Vector2i) -> void:
	if is_immobile: return
	# 1. Atualiza o registro no GridSystem (libera o tile antigo, ocupa o novo)
	if not grid.move_entity(self, grid_pos, target_grid_pos):
		return # Não foi possível mover a entidade
	
	# 2. Atualiza a variável lógica
	grid_pos = target_grid_pos
	
	# 3. Calcula a posição no mundo real para onde vamos
	var target_world_pos: Vector2 = grid.map_to_local(target_grid_pos)

	# 4. Inicia o movimento visual (Tween)
	var tween = create_tween()
	# Usar ease_out deixa o movimento mais "snappy" (rápido no começo, suave no fim)
	tween.tween_property(self, "global_position", target_world_pos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#tween.tween_callback(func(): movement_finished.emit())


func take_damage(amount: int, source: GridEntity = null) -> void:
	if not is_hittable:
		return
			
	current_hp -= abs(amount)
	print("%s took %d damage! HP: %d/%d" % [name, amount, current_hp, max_hp])
	
	if current_hp <= 0:
		_die()
		# TODO: Animação de morte (shader pra desintegrar e tals)
	else:
		pass
		# TODO: Adicionar feedback visual aqui (flash branco, shake, etc)

# TODO: remove queue_free from here, maybe make this an abstract and let the entity itself chose how to die (player would be very specific, while the enemies would die about the same way)
func _die() -> void:
	died.emit(self)
	grid.unregister_entity(self, grid_pos)
	# await animation end
	queue_free()
