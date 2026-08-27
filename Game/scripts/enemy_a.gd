extends CharacterBody3D

@onready var enemy_a: CharacterBody3D = $"."
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var ray_cast_3d_forward: RayCast3D = $CollisionShape3D/RayCast3D_Forward
@onready var ray_cast_3d_downward: RayCast3D = $CollisionShape3D/RayCast3D_Downward

@onready var animation_player: AnimationPlayer = $NPC_01/AnimationPlayer


var direction = 1
var facingRight = true
const SPEED = 1.4

func _ready() -> void:
	animation_player.play("NPC_01_WALK")

func _physics_process(delta: float) -> void:
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
