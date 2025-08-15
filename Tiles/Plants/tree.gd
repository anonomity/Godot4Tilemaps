extends Area2D
class_name HarvestableTile

var health = 5
enum Types {Oak, Palm}
@onready var tree_type : Types
@onready var sprite_2d: Sprite2D = $Sprite2D

const OAK_TEXTURE = preload("res://assets/oak_texture.tres")
const PALM_TEXTURE = preload("res://assets/palm_texture.tres")

signal chop_sound
signal death_sound

var sprite_texture = PALM_TEXTURE

func _ready() -> void:
	sprite_2d.texture = sprite_texture

func object_interacted(tool : Tool):
	chop(tool)

func set_type(type : Types):
	match(type):
		Types.Oak:
			sprite_texture = OAK_TEXTURE
		Types.Palm:
			sprite_texture = PALM_TEXTURE

func chop(tool : Tool):
	chop_sound.emit()
	health -= tool.dmg
	if health <= 0:
		death_sound.emit()
		queue_free()
