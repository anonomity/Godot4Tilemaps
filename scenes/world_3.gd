extends Node2D

@onready var environment_layer: TileMapLayer = $tilemap/environment

var plant_source_id = 1
var tree_alternative_tile = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("plant"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = environment_layer.local_to_map(mouse_pos)
		
		environment_layer.set_cell(tile_pos, plant_source_id, Vector2i.ZERO, tree_alternative_tile)
