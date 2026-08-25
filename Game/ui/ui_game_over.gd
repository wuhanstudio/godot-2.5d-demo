extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_tree().get_root().get_node("Root").get_node("Player")
	player.currentHealthUpdate.connect(checkGameOver)
	visible = false

func showGameOverUI():
	await get_tree().create_timer(1.0).timeout
	visible = true

func checkGameOver(newValue):
		if newValue <= 0:
			showGameOverUI()


func _on_texture_button_restart_pressed() -> void:
	get_tree().reload_current_scene()
