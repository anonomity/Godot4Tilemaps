extends CharacterBody2D


@export var SPEED : float = 300.0

@onready var animation_tree = $AnimationTree
var direction : Vector2 = Vector2.ZERO

func _ready():
	animation_tree.active = true

func _process(delta):
	update_animation_parameters()

func _physics_process(delta):


	direction = Input.get_vector("left", "right","up","down").normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func update_animation_parameters():
#	if(velocity == Vector2.ZERO):
#		animation_tree["parameters/conditions/idle"] = true
#
#	else:
#		animation_tree["parameters/conditions/idle"] = false

	
	
	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
	
