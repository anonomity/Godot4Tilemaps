extends CharacterBody2D


@export var SPEED : float = 150.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
	
	
	if Input.is_action_pressed("click") and (velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_moving"] = false
		animation_tree["parameters/conditions/is_chopping"] = true
		animation_tree["parameters/conditions/is_idle"] = false
		var mouse_dir = get_global_mouse_position() - global_position
		
		animation_tree["parameters/chop/blend_position"] = mouse_dir
	
		
	elif Input.is_action_just_released("click"):
		animation_tree["parameters/conditions/is_chopping"] = false
		animation_tree["parameters/conditions/is_idle"] = true
		
	elif(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_chopping"] = false
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if direction != Vector2.ZERO:
		animation_tree["parameters/idle/blend_position"] = direction
		animation_tree["parameters/walk/blend_position"] = direction

	
	
