extends AnimationTree

enum {
	Normal,
	Airbone,
	Dead
}

var state

func changeStateToAirbone():
	if state != Dead: 
		state = Airbone

func changeStateToNormal():
	if state != Dead: 
		state = Normal

func changeStateToDead():
	state = Dead

func checkIsAirbone():
	return state == Airbone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
