@tool
extends Control

const Utils = preload("res://addons/bitmask_automation/utils.gd")

@onready var source_select: ItemList = %SourceSelect
@onready var source_texture_rect: TextureRect = %SourceTextureRect
@onready var template_texture_rect: TextureRect = %TemplateTextureRect
@onready var apply_button: Button = %ApplyButton

@export var tile_map: TileMapLayer:
	get():
		return tile_map
	set(value):
		if(tile_map):
			tile_map.changed.disconnect(setup_source_list)
		tile_map = value
		if(tile_map):
			tile_map.changed.connect(setup_source_list)
		setup_source_list()
		check_apply_btn_disabled()

var template_texture: Texture2D:
	get():
		return template_texture
	set(value):
		template_texture = value
		if template_texture_rect:
			template_texture_rect.texture = template_texture
		check_apply_btn_disabled()

var item_to_source_map: Dictionary[int, TileSetAtlasSource] = {}
var source_to_item_map: Dictionary[TileSetAtlasSource, int] = {}

var selected_source_idx: int = 0:
	get():
		return selected_source_idx
	set(value):
		selected_source_idx = value
		var source := item_to_source_map.get(selected_source_idx, null)
		if source:
			selected_source = source
		if source_select and source_select.item_count > 0:
			source_select.select(selected_source_idx)

var selected_source: TileSetAtlasSource:
	get():
		return selected_source
	set(value):
		selected_source = value
		if source_texture_rect and selected_source:
			source_texture_rect.texture = selected_source.texture
		check_apply_btn_disabled()

func setup_source_list():
	clear_item_list()
	populate_item_list()
	selected_source_idx = selected_source_idx

func clear_item_list():
	if source_select:
		for item_id in range(source_select.item_count - 1, -1, -1):
			source_select.remove_item(item_id)
		item_to_source_map = {}
		source_to_item_map = {}

func populate_item_list():
	if source_select and tile_map and tile_map.tile_set:
		for source in Utils.get_atlas_sources(tile_map.tile_set):
			var name := source.texture.resource_path.split("/")[-1]
			var id = source_select.add_item(name, source.texture, true)
			item_to_source_map.set(id, source)
			source_to_item_map.set(source, id)

func check_apply_btn_disabled():
	if apply_button:
		if tile_map and template_texture and selected_source:
			apply_button.disabled = false
		else:
			apply_button.disabled = true

func _ready() -> void:
	tile_map = tile_map
	selected_source_idx = 0

func _on_item_list_item_selected(index: int) -> void:
	selected_source_idx = index
	
@onready var done_label: Label = %DoneLabel

func _on_apply_button_pressed() -> void:
	if tile_map and template_texture and selected_source:
		Utils.update_tile_map(tile_map, template_texture, selected_source)
		done_label.show()
		await get_tree().create_timer(1).timeout
		done_label.hide()

@onready var file_dialog: FileDialog = $FileDialog

func _on_pick_template_button_pressed() -> void:
	file_dialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
	var res = load(path)
	if res is Texture2D:
		template_texture = res
