@tool
extends EditorContextMenuPlugin

const TILEMAP_SOURCE_ID := 1

func _popup_menu(paths: PackedStringArray) -> void:
	#for path in paths:
		#var node := EditorInterface.get_edited_scene_root().get_node(path)
		#if node is TileMapLayer:
			#if node.tile_set.tile_shape == TileSet.TileShape.TILE_SHAPE_SQUARE:
				#add_context_menu_item('Apply Terrain Bitmap', on_apply)
				##add_context_menu_item('Save Terrain Bitmap', on_save)
				#return
	pass

#const template := preload("res://addons/bitmask_automation/terrain-tilemap-template.png")
const Utils = preload("res://addons/bitmask_automation/utils.gd")

func on_apply(args: Array) -> void:
	#for arg in args:
		#if arg is TileMapLayer:
			#Utils.update_tile_map(arg, template, TILEMAP_SOURCE_ID)
	pass

func on_save(args: Array) -> void:
	for arg in args:
		if arg is TileMapLayer:
			print('here')
			var terrain_set_index := Utils.prepare_terrain_set(arg.tile_set)
			print('here')
			var terrainColorToId := Utils.build_terrain_color_map(arg.tile_set, terrain_set_index, [])
			print('here')
			var abc := Utils.BitMaskImageParseResult.from_tile_set(arg.tile_set, TILEMAP_SOURCE_ID, terrainColorToId).to_image()
			print(abc)
			abc.save_png('./test.png')
