extends CharacterBody3D

@onready var little_adventurer_andie: Node3D = $LittleAdventurerAndie
const SPEED = 10.0
const JUMP_VELOCITY = 8

@onready var animation_tree: AnimationTree = $LittleAdventurerAndie/AnimationTree

func _process(delta):
	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))

func _physics_process(delta: float) -> void:
	if velocity.x != 0:
		var faceRight = velocity.x >0
		if faceRight:
			little_adventurer_andie.rotation = Vector3(0, 5 * PI / 8, 0)
		else:
			little_adventurer_andie.rotation = Vector3(0, -5 * PI / 8, 0)
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontalInput := Input.get_axis("MoveLeft", "MoveRight")
	if horizontalInput:
		velocity.x = horizontalInput * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
