extends HBoxContainer

@export var fullHeartTexture: Texture2D
@export var emptyHeartTexture: Texture2D

var heartTexureRectArray: Array[TextureRect]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_root().get_node("Root").get_node("Player")
	player.currentHealthUpdate.connect(updateHearts)

	for item in get_children():
		heartTexureRectArray.append(item)

func updateHearts(newValue):
	var fullHeartNumber = newValue
	
	for item in heartTexureRectArray:
		if fullHeartNumber > 0:
			fullHeartNumber = fullHeartNumber - 1
			item.texture = fullHeartTexture
		else:
			item.texture = emptyHeartTexture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
