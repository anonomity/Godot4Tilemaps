extends Node2D


@onready var nothing_rect = $CanvasLayer/Control/HBoxContainer/NothingRect
@onready var farm_rect = $CanvasLayer/Control/HBoxContainer/FarmRect
@onready var seed_rect = $CanvasLayer/Control/HBoxContainer/SeedRect

@onready var tile_map = $TileMap

@onready var farm_sound = $sound_effects/farm
@onready var seed_pop_sound = $sound_effects/seed_pop


@onready var rects = [nothing_rect, farm_rect,seed_rect]

enum MODES {NOTHING, FARMING, SEED}

var current_mode = MODES.NOTHING

var highlight_hex = Color(0.52156865596771, 0.30588236451149, 0.41176471114159, 0.63137257099152)
var invisible_hex = Color(0.52156865596771, 0.30588236451149, 0.41176471114159, 0)

# FARMING TILE INFORMATION
var farming_tile_positions = []
var farming_layer = 1
var farming_terrain_set = 0
var farming_terrain = 0

## SEED TILE INFORMATION
var seed_layer = 2
var source_id = 0
var atlas_coords= Vector2(11,1)
var final_seed_level = 3


#Custom Datas
var is_farmable_custom_data= "farmable"
var is_hoable_custom_data = "hoeable"

func _ready():
	farm_rect.color = invisible_hex
	nothing_rect.color = highlight_hex
	seed_rect.color = invisible_hex


func _input(InputEvent):
	if Input.is_action_just_pressed("farm"):
		highlight_rect(farm_rect, MODES.FARMING)
	if Input.is_action_just_pressed("nothing"):
		highlight_rect(nothing_rect, MODES.NOTHING)
	if Input.is_action_just_pressed("seed"):
		highlight_rect(seed_rect, MODES.SEED)
	if Input.is_action_just_pressed("click"):
		handle_click()
	

func highlight_rect(rect_to_highlight, mode):
	for rect in rects:
		if rect == rect_to_highlight:
			rect.color = highlight_hex
		else:
			rect.color = invisible_hex
	current_mode = mode
	
func handle_click():
	if current_mode == MODES.NOTHING:
		return
	else:
		var mouse_position = get_global_mouse_position()
		var mouse_position_to_tile_position = tile_map.local_to_map(mouse_position)
		if current_mode == MODES.FARMING:
			if check_custom_data(mouse_position_to_tile_position, is_hoable_custom_data, farming_layer):
				farming_tile_positions.append(mouse_position_to_tile_position)
				tile_map.set_cells_terrain_connect(farming_layer,farming_tile_positions,farming_terrain_set, farming_terrain)
				farm_sound.play()
		elif current_mode == MODES.SEED:
			if check_custom_data(mouse_position_to_tile_position, is_farmable_custom_data, farming_layer):
				handle_seed(mouse_position_to_tile_position, 0, atlas_coords)
				seed_pop_sound.play()
			
func check_custom_data(mouse_pos, custom_data_variable,layer):
	var tile_data : TileData = tile_map.get_cell_tile_data(farming_layer,mouse_pos)
	if tile_data:
		return tile_data.get_custom_data(custom_data_variable)
	else:
		return false
		

func handle_seed(pos, level, atlas):
	tile_map.set_cell(seed_layer,pos,source_id,atlas)
	await get_tree().create_timer(5.0).timeout
	if level == final_seed_level:
		return
	else:
		var new_atlas = Vector2(atlas.x+1, atlas.y)
		handle_seed(pos, level+1, new_atlas)
	
	
	
