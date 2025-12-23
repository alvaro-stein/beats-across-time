class_name GridSystem
extends Node2D

var _layers: Array[TileMapLayer] = []
var _grid_entities: Dictionary[Vector2i, Array] = {} # key: coords, value: Array[GridEntity]
# Initialize the pathfinder's A* algorithm object
var pathfinder := AStarGrid2D.new()
var _tile_map_layer_reference: TileMapLayer

func _enter_tree() -> void:
	GameManager.active_grid = self


func _exit_tree() -> void:
	if GameManager.active_grid == self:
		GameManager.active_grid = null


func _ready() -> void:
	#_layers.assign(get_children().filter(func(c): c is TileMapLayer))
	for child in get_children():
		if child is TileMapLayer:
			_layers.append(child)
	
	_tile_map_layer_reference = _layers[0]
	
	_setup_pathfinder()


## Registers an entity at a specific coordinate
func register_entity(entity: GridEntity, coords: Vector2i) -> void:
	if not _grid_entities.has(coords):
		_grid_entities[coords] = []
	_grid_entities[coords].append(entity)


## Removes an entity register from a specific coordinate (e.g: if it moves or dies)
func unregister_entity(entity: GridEntity, coords: Vector2i) -> void:
	if _grid_entities.has(coords) and _grid_entities[coords].has(entity):
		_grid_entities[coords].erase(entity)
		if _grid_entities[coords].is_empty():
			_grid_entities.erase(coords)


## Returns an Array with all GridEntities on the tile (can be empty)
func get_entities_at(coords: Vector2i) -> Array[GridEntity]:
	var entities: Array[GridEntity] = []
	entities.assign(_grid_entities.get(coords, entities))
	return entities


## Returns true if success, false otherwise
func move_entity(entity: GridEntity, current_grid_pos: Vector2i, target_grid_pos: Vector2i) -> bool:
	if _grid_entities.has(current_grid_pos) and _grid_entities[current_grid_pos].has(entity):
		unregister_entity(entity, current_grid_pos)
		register_entity(entity, target_grid_pos)
		return true
	return false


func is_tile_occupied(coords: Vector2i) -> bool:
	var entities: Array[GridEntity] = get_entities_at(coords)
	return entities.any(func(entity): return entity.occupies_tile)


## Returns true if the tile exists and is walkable (e.g: not a wall).
## (NOTE: Does not check for entities, use is_tile_occupied() for that.)
func is_tile_walkable(coords: Vector2i) -> bool:
	var tile_found: bool = false
	
	for layer in _layers:
		var tile_data = layer.get_cell_tile_data(coords)
		if tile_data:
			if not tile_data.get_custom_data("is_walkable"):
				return false
			tile_found = true
	
	return tile_found


## Returns the first hittable entity found at the given tile coordinates
func get_first_hittable_entity_at(coords: Vector2i) -> GridEntity:
	var entities: Array[GridEntity] = get_entities_at(coords)
	for entity in entities:
		if entity.is_hittable: return entity
	return null

func _setup_pathfinder():
	# Pega a região usada no TileMap para definir os limites do A*
	# var rect := get_used_rect()
	var rect := Rect2i(0, 0, 30, 17)
	pathfinder.region = rect
	
	# Configurações padrão
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	pathfinder.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	pathfinder.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	pathfinder.update()
	
	# Preenche os obstáculos ESTÁTICOS (Paredes)
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var coords = Vector2i(x, y)
			# Se NÃO for andável, marcamos como sólido no A*
			if not is_tile_walkable(coords):
				pathfinder.set_point_solid(coords, true)

func local_to_map(local_position: Vector2) -> Vector2i:
	return _tile_map_layer_reference.local_to_map(local_position)

func map_to_local(map_position: Vector2i) -> Vector2:
	return _tile_map_layer_reference.map_to_local(map_position)

func get_cell_source_id(coords: Vector2i) -> int:
	return _tile_map_layer_reference.get_cell_source_id(coords)
