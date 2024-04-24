extends Node3D
signal isPlayerInSafeArea(new_value)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_body_entered(_body: Node3D) -> void:
	isPlayerInSafeArea.emit(true)
	#get_tree().call_group("mob", "_on_safe_area_changed", true)
func _on_body_exited(_body):
	isPlayerInSafeArea.emit(false)
	#get_tree().call_group("mob", "_on_safe_area_changed", false)
