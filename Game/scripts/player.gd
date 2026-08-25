extends CharacterBody3D

@onready var animation_player_material: AnimationPlayer = $LittleAdventurerAndie/AnimationPlayer_Material
@onready var little_adventurer_andie: Node3D = $LittleAdventurerAndie

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const SPEED = 10
const JUMP_VELOCITY = 16

const MAX_HEALTH = 3
var currentHealth = MAX_HEALTH

var controllable = true
var isInvinsible = false
var currentJump = 2

@onready var animation_tree: AnimationTree = $LittleAdventurerAndie/AnimationTree
@onready var footstep_vfx: GPUParticles3D = $VFX/Footstep_VFX

signal currentHealthUpdate(newValue)

func _ready():
	currentHealth = MAX_HEALTH
	controllable = true
	isInvinsible = false
	currentJump = 0

func _process(delta):
	handleMovementVFX()

	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))
	animation_tree.set("parameters/StateMachne/Airbone/blend_position", velocity.y)
	if is_on_floor():
		animation_tree.changeStateToNormal()
	else:
		animation_tree.changeStateToAirbone()

func _physics_process(delta: float) -> void:
	if controllable:
	
		if velocity.x != 0:
			var faceRight = velocity.x >0
			if faceRight:
				little_adventurer_andie.rotation = Vector3(0, 5 * PI / 8, 0)
			else:
				little_adventurer_andie.rotation = Vector3(0, -5 * PI / 8, 0)
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta * 4
		else:
			currentJump = 2
	
		# Handle jump.
		if Input.is_action_just_pressed("Jump") and (is_on_floor() or currentJump > 0):
			velocity.y = JUMP_VELOCITY
			currentJump = currentJump - 1
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

func applyDamage():
	if currentHealth <= 0 || isInvinsible:
		return

	currentHealth = currentHealth - 1
	controllable = false
	
	emit_signal("currentHealthUpdate", currentHealth)

	if currentHealth <= 0:
		#print("The player is dead")
		animation_tree.changeStateToDead()
		controllable = false
	else:
		animation_tree.set("parameters/OneShotHurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_player_material.play("Flash_Invincible")

		await get_tree().create_timer(0.9).timeout
		controllable = true
		isInvinsible = true

		await get_tree().create_timer(2.0).timeout
		animation_player_material.play("RESET")
		isInvinsible = false
