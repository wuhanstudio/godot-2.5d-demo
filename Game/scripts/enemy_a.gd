extends CharacterBody3D

@onready var enemy_a: CharacterBody3D = $"."
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var ray_cast_3d_forward: RayCast3D = $CollisionShape3D/RayCast3D_Forward
@onready var ray_cast_3d_downward: RayCast3D = $CollisionShape3D/RayCast3D_Downward

@onready var animation_player: AnimationPlayer = $NPC_01/AnimationPlayer
@onready var animation_player_material: AnimationPlayer = $NPC_01/AnimationPlayer_Material
@onready var area_3d: Area3D = $Area3D

var direction = 1
var facingRight = true
const SPEED = 1.4

var currentHealth = 20

func _ready() -> void:
	animation_player.play("NPC_01_WALK")

func _physics_process(delta: float) -> void:
	if currentHealth < 0:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 5
	
	if ray_cast_3d_forward.is_colliding() || ray_cast_3d_downward.is_colliding() == false:	
		facingRight = !facingRight
	
	if facingRight:
		direction = 1
		enemy_a.rotation.y = 0
	else:
		direction = -1
		enemy_a.rotation.y = PI

	velocity.x = direction * SPEED

	move_and_slide()



func _on_area_3d_body_entered(body: Node3D) -> void:
	body.applyDamage()


func applyDamage(damage: int):
	if currentHealth <= 0:
		return
	
	currentHealth -= damage
	animation_player_material.play("Flash")
	
	if currentHealth <= 0:
		animation_player.play("NPC_01_DEAD")
		collision_shape_3d.set_deferred("disabled", true)
		set_physics_process(false)
		area_3d.monitoring = false
