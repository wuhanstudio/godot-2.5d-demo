extends CharacterBody3D

@onready var little_adventurer_andie: Node3D = $LittleAdventurerAndie
const SPEED = 10.0
const JUMP_VELOCITY = 8

@onready var animation_tree: AnimationTree = $LittleAdventurerAndie/AnimationTree
@onready var footstep_vfx: GPUParticles3D = $VFX/Footstep_VFX

func _process(delta):
	handleMovementVFX()

	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))
	animation_tree.set("parameters/StateMachne/Airbone/blend_position", velocity.y)
	if is_on_floor():
		animation_tree.changeStatetoNormal()
	else:
		animation_tree.changeStatetoAirbone()

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
		playerGroundSmokeVFX()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontalInput := Input.get_axis("MoveLeft", "MoveRight")
	if horizontalInput:
		velocity.x = horizontalInput * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func handleMovementVFX():
	if is_on_floor():
		if velocity.x != 0:
			footstep_vfx.emitting = true
		else:
			footstep_vfx.emitting = false
	else:
		footstep_vfx.emitting = false
	
	if is_on_floor():
		if animation_tree.checkIsAirbone():
			playerGroundSmokeVFX()

func playerGroundSmokeVFX():
	var vfxToSpawn = preload("res://Asset/VFX/Scene/land_vfx.tscn")
	var vfxInstance = vfxToSpawn.instantiate()
	get_tree().get_root().get_node("Root").add_child(vfxInstance)
	vfxInstance.global_position = global_position + Vector3(0, 0.3, 0.2)
	vfxInstance.restart()
	
	await get_tree().create_timer(0.6).timeout
	
	vfxInstance.queue_free()
