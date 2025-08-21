@tool
extends EditorPlugin

const BitMaskAutomation = preload("res://addons/bitmask_automation/context_menu.gd")
var plugin: BitMaskAutomation

func _enter_tree() -> void:
	plugin = BitMaskAutomation.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, plugin) 
	get_editor_interface().get_selection().selection_changed.connect(on_selection_changed)

func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
	get_editor_interface().get_selection().selection_changed.disconnect(on_selection_changed)
	cleanup_control()

const SolarTerrainTemplateEditorUI = preload("res://addons/bitmask_automation/template_ui.gd")
const TEMPLATE_UI = preload("res://addons/bitmask_automation/template_ui.tscn")

var control: SolarTerrainTemplateEditorUI
func cleanup_control():
	if control:
		remove_control_from_bottom_panel(control)
		control.queue_free()

func on_selection_changed():
	cleanup_control()
	
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	var tile_maps = nodes.filter(func (node): return node is TileMapLayer)
	
	if tile_maps.size() == 1:
		var tile_map := tile_maps.pop_front()
		control = TEMPLATE_UI.instantiate()
		control.tile_map = tile_map
		add_control_to_bottom_panel(control, "Terrain Templates")
