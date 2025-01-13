extends Node2D

@export var noise_height_text : NoiseTexture2D
@export var noise_tree_text : NoiseTexture2D
var noise : Noise
var tree_noise : Noise

var width : int = 100
var height : int = 100

@onready var water_tilemaplayer: TileMapLayer = $TileMap/water
@onready var ground_1_tilemaplayer: TileMapLayer = $TileMap/ground_1
@onready var ground_2_tilemaplayer: TileMapLayer = $"TileMap/ground 2"
@onready var cliff_tilemaplayer: TileMapLayer = $TileMap/cliff
@onready var environment_tilemaplayer: TileMapLayer = $TileMap/environment

var noise_val_arr = []

var source_id = 0

var water_atlas = Vector2i(0,1)
var land_atlas  = Vector2i(0,0)

var sand_tiles_arr = []
var terrain_sand_int = 3

var grass_tiles_arr = []
var terrain_grass_int = 1

var cliff_tiles_arr = []
var terrain_cliff_int = 4

var grass_atlas_arr = [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0)]
var palm_tree_atlas_arr = [Vector2i(12,2),Vector2i(15,2)]
var oak_tree_atlas = Vector2i(15,6)
@onready var camera_2d = $Player/Camera2D

func _ready():
	noise = noise_height_text.noise
	tree_noise = noise_tree_text.noise
	generate_world()
	
func generate_world():
	for x in range(-width/2, width /2):
		for y in range(-height/2, height/2):
			var noise_val :float = noise.get_noise_2d(x,y)
			var tree_noise_val :float = tree_noise.get_noise_2d(x,y)
			noise_val_arr.append(tree_noise_val)
			
			# placing ground
			if noise_val >= 0.0:
				if noise_val > 0.05 and noise_val < 0.17 and tree_noise_val > 0.7:
					environment_tilemaplayer.set_cell(Vector2i(x,y), source_id, palm_tree_atlas_arr.pick_random())
				
				if noise_val > 0.2:
					grass_tiles_arr.append(Vector2i(x,y))
					
					if noise_val > 0.25:
						if noise_val < 0.35 and tree_noise_val > 0.8:
							environment_tilemaplayer.set_cell(Vector2i(x,y), source_id, oak_tree_atlas)
						ground_2_tilemaplayer.set_cell( Vector2i(x,y), source_id, grass_atlas_arr.pick_random())
					if noise_val > 0.4:
						cliff_tiles_arr.append(Vector2i(x,y))
				sand_tiles_arr.append(Vector2i(x,y))
			
			water_tilemaplayer.set_cell(Vector2(x,y), source_id, water_atlas)
	ground_1_tilemaplayer.set_cells_terrain_connect(sand_tiles_arr,terrain_sand_int, 0)
	ground_2_tilemaplayer.set_cells_terrain_connect(grass_tiles_arr,terrain_grass_int, 0)
	cliff_tilemaplayer.set_cells_terrain_connect(cliff_tiles_arr,terrain_cliff_int, 0)

	print("min: ", noise_val_arr.min())
	print("max: ", noise_val_arr.max())


func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
  
	if Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
