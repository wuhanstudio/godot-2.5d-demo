extends CharacterBody3D

@onready var animation_player_material: AnimationPlayer = $LittleAdventurerAndie/AnimationPlayer_Material
@onready var little_adventurer_andie_mesh: MeshInstance3D = $LittleAdventurerAndie/LittleAdventurerAndie_GameRig/Skeleton3D/LittleAdventurerAndieMesh
@onready var heal_player_vfx: GPUParticles3D = $LittleAdventurerAndie/LittleAdventurerAndie_GameRig/VFX/HEAL_Player_VFX

@onready var animation_player_heal: AnimationPlayer = $LittleAdventurerAndie/AnimationPlayer_Heal
@onready var animation_player_melee: AnimationPlayer = $LittleAdventurerAndie/LittleAdventurerAndie_GameRig/VFX/AnimationPlayer_BladeVFX

@onready var little_adventurer_andie: Node3D = $LittleAdventurerAndie
@onready var melee_vfx: Node3D = $LittleAdventurerAndie/LittleAdventurerAndie_GameRig/VFX/MELEE_VFX

@onready var blade_vfx: MeshInstance3D = $"LittleAdventurerAndie/LittleAdventurerAndie_GameRig/VFX/Blade VFX"
@onready var area_3d_hitbox: Area3D = $LittleAdventurerAndie/Area3D_Hitbox

var drag_strength := 5.0
var max_drag := 150.0

var dragging := false
var drag_start := Vector2.ZERO
var drag_current := Vector2.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const SPEED = 10
const JUMP_VELOCITY = 16

const MAX_HEALTH = 3
var currentHealth = MAX_HEALTH

var controllable = true
var isInvinsible = false
var currentJump = 2
var uncontrollableRemain = 0
var getHurtCooldown = 1
var meleeAttackCooldown = 0.6
var meleeAttackDamage = 10

@onready var animation_tree: AnimationTree = $LittleAdventurerAndie/AnimationTree
@onready var footstep_vfx: GPUParticles3D = $LittleAdventurerAndie/LittleAdventurerAndie_GameRig/VFX/Footstep_VFX

signal currentHealthUpdate(newValue)

func _ready():
	area_3d_hitbox.monitoring = false

	currentHealth = MAX_HEALTH
	controllable = true
	isInvinsible = false
	currentJump = 0
	
var last_tap_time := 0.0
var last_tap_position := Vector2.ZERO

const DOUBLE_TAP_DELAY := 0.3
const DOUBLE_TAP_DISTANCE := 50.0

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0

		if (
 			now - last_tap_time <= DOUBLE_TAP_DELAY
			and event.position.distance_to(last_tap_position) <= DOUBLE_TAP_DISTANCE
		):
			print("Double tap!")
			meleeAttack()
			last_tap_time = 0.0
		else:
			last_tap_time = now
			last_tap_position = event.position

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				meleeAttack()

			# Mouse pressed
			if event.pressed:
				dragging = true
				drag_start = event.position
				drag_current = event.position

			# Mouse released
			else:
				dragging = false
				velocity.x = 0

	elif event is InputEventMouseMotion and dragging:
		drag_current = event.position


func _process(delta):
	handleMovementVFX()
	
	if currentHealth <= 0:
		return
	
	animation_tree.set("parameters/StateMachine/GroundMovement/blend_position", abs(velocity.x))
	animation_tree.set("parameters/StateMachne/Airbone/blend_position", velocity.y)
	if is_on_floor():
		animation_tree.changeStateToNormal()
	else:
		animation_tree.changeStateToAirbone()
	
	if controllable == false && currentHealth > 0:
		uncontrollableRemain -= delta
		if uncontrollableRemain <= 0:
			controllable = true
		
func _physics_process(delta: float) -> void:
	if controllable:
		if velocity.x != 0:
			var faceRight = velocity.x > 0
			if faceRight:
				little_adventurer_andie.rotation = Vector3(0, 4 * PI / 8, 0)
			else:
				little_adventurer_andie.rotation = Vector3(0, -4 * PI / 8, 0)
		
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
		
		if Input.is_action_just_pressed("MelleeAttack"):
			meleeAttack()

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var horizontalInput := Input.get_axis("MoveLeft", "MoveRight")
		if horizontalInput:
			velocity.x = horizontalInput * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if dragging:
			var drag = drag_start - drag_current
			#drag = drag.limit_length(max_drag)
			if (sign(drag[0]) != 0):
				velocity.x = -sign(drag[0]) * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)

			# Handle jump.
			if sign(drag[1]) > 0:
				velocity.y = JUMP_VELOCITY
				currentJump = currentJump - 1
				playerGroundSmokeVFX()

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
	uncontrollableRemain += getHurtCooldown

	emit_signal("currentHealthUpdate", currentHealth)

	if currentHealth <= 0:
		#print("The player is dead")
		animation_tree.changeStateToDead()
		controllable = false
	else:
		animation_tree.set("parameters/OneShotMelee/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		animation_tree.set("parameters/OneShotHurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_player_material.play("Flash_Invincible")

		await get_tree().create_timer(2.0).timeout
		animation_player_material.play("RESET")
		isInvinsible = false

func meleeAttack():
	if controllable and is_on_floor():
		animation_tree.set("parameters/OneShotHit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		animation_player_melee.play("play_blade")

		area_3d_hitbox.monitoring = true
		controllable = false
		uncontrollableRemain += meleeAttackCooldown
		await get_tree().create_timer(0.6).timeout
		area_3d_hitbox.monitoring = false


func addHealth():
	if currentHealth >= MAX_HEALTH:
		return false

	currentHealth = currentHealth + 1
	emit_signal("currentHealthUpdate", currentHealth)
	
	animation_player_heal.play("Flash_Heal")
	heal_player_vfx.restart()

	return true


func _on_area_3d_hitbox_body_entered(body: Node3D) -> void:
	body.applyDamage(10)
	
	var vfx_position = body.global_position
	vfx_position.y += 1.5
	vfx_position.z += 1
	
	melee_vfx.global_position = vfx_position
	for item in melee_vfx.get_children():
		item.restart()
