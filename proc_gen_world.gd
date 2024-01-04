extends Node2D


@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D
@onready var tile_map = $TileMap

var width : int = 300
var height : int =  300

var noise : Noise
var tree_noise : Noise
var noise_values = []

var water_tile_atlas = Vector2i(0,1)
var sand_tile_atlas = Vector2i(6,0)

var tree_atlas = Vector2i(12,2)
var tree_atlas2 = Vector2i(15,6)

var sand_arr = []
var grass_arr = []
var dirt_arr = []
var cliff_arr = []

var random_grass_atlas_arr = [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0)]
@onready var camera_2d = $Player/Camera2D


func _ready():
	noise = noise_texture.noise
	tree_noise = tree_noise_texture.noise
	generate_world()
	
func generate_world():
	var tree_arr = []
	var noise_val
	var tree_noise_val 
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_val = tree_noise.get_noise_2d(x,y)
			
			#setting cliffs
			if noise_val > 0.6:
				cliff_arr.append(Vector2(x,y))
			
			#setting all grass tiles
			if noise_val > 0.2:
				grass_arr.append(Vector2(x,y))
				if noise_val > 0.3:
					tile_map.set_cell(2, Vector2(x,y), 0,random_grass_atlas_arr.pick_random())
			
			#setting trees where there are no cliffs
			if (tree_noise_val > 0.9) and (noise_val > 0.3) and (noise_val < 0.5):
				tile_map.set_cell(2, Vector2(x,y), 0,tree_atlas2)
		
			# setting sand and palm trees between water and grass
			if noise_val > 0:
				sand_arr.append(Vector2(x,y))
				if noise_val < 0.18:
					if tree_noise_val > 0.92:
						tile_map.set_cell(2, Vector2(x,y), 0,tree_atlas)
						tree_arr.append(tree_noise_val)
				
			
				
			tile_map.set_cell(0,Vector2(x,y), 0,water_tile_atlas)

	tile_map.set_cells_terrain_connect(1, sand_arr, 3,0)
	tile_map.set_cells_terrain_connect(1, grass_arr, 1,0)
	tile_map.set_cells_terrain_connect(3,cliff_arr, 4,0)

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val =camera_2d.zoom.x + 0.1
		
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val =camera_2d.zoom.x - 0.1
		if zoom_val == 0:
			zoom_val =camera_2d.zoom.x - 0.2
			
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
