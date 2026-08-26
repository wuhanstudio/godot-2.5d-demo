extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var heal_mesh: Node3D = $HEAL_MESH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	heal_mesh.rotate_y(delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.addHealth():
		queue_free()
