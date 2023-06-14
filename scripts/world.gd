extends Node2D

@onready var tile_map : TileMap = $TileMap

var ground_layer = 1
var environment_layer = 2

var can_place_seed_custom_data = "can_place_seeds"

func _ready():
	pass



func _input(event):
	if Input.is_action_just_pressed("click"):
		
		var mouse_pos : Vector2 = get_global_mouse_position()
		
#		print("global mouse position: ", mouse_pos)
		
		var tile_mouse_pos : Vector2i = tile_map.local_to_map(mouse_pos)
		
#		print("tile mouse position ", tile_mouse_pos)
		
		var source_id : int = 0
		
		var atlas_coord : Vector2i= Vector2i(11,1)
		
		var tile_data : TileData = tile_map.get_cell_tile_data(ground_layer, tile_mouse_pos)
		
		if tile_data:
			var can_place_seeds = tile_data.get_custom_data(can_place_seed_custom_data)
			if can_place_seeds:
				tile_map.set_cell(environment_layer, tile_mouse_pos, source_id,  atlas_coord)
			else:
				print("can't place here!")
		else:
			print("no tile data")

