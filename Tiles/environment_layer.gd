extends TileMapLayer

@onready var chop_sound: AudioStreamPlayer = $ChopSound
@onready var tree_death_sound: AudioStreamPlayer = $TreeDeathSound

func _ready() -> void:
	child_entered_tree.connect(on_child_entered)

func on_child_entered(node):
	if node is HarvestableTile:
		node.chop_sound.connect(play_sound.bind(chop_sound))
		node.death_sound.connect(play_sound.bind(tree_death_sound))
		node.set_type(HarvestableTile.Types.Palm)
		
		
func play_sound(audio_player):
	audio_player.play()

func _process(delta: float) -> void:
	pass
