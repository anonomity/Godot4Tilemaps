extends Node2D

@onready var environment_layer: TileMapLayer = $tilemap/environment


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("plant"):
		var mouse_coords =  environment_layer.local_to_map(get_global_mouse_position())
		environment_layer.set_cell(mouse_coords,1,Vector2.ZERO, 1)
