class_name GridSystem
extends TileMapLayer

# Dict to track entities in the tile map (player, enemies, traps...)
var _grid_entities: Dictionary[Vector2i, Array] = {} # key: coords, value: Array[GridEntity]

func _enter_tree() -> void:
	GameManager.active_grid = self

func _exit_tree() -> void:
	if GameManager.active_grid == self:
		GameManager.active_grid = null


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
	var tile_data = get_cell_tile_data(coords)
	if not tile_data:
		return false # Tile is empty
	# Checks a custom data layer from the TileSet
	return tile_data.get_custom_data("is_walkable")


## Returns the first hittable entity found at the given tile coordinates
func get_first_hittable_entity_at(coords: Vector2i) -> GridEntity:
	var entities: Array[GridEntity] = get_entities_at(coords)
	for entity in entities:
		if entity.is_hittable: return entity
	return null
