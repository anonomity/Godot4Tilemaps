extends Area2D

var tool : Tool = preload("res://Items/instantiations/tools/axe.tres")

func _ready() -> void:
	area_entered.connect(on_tool_interact)

func on_tool_interact(area):
	if area is HarvestableTile:
		area.object_interacted(tool)
