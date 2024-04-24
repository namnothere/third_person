extends Node3D

@export var mob_scene: PackedScene
@export var player: CharacterBody3D
@onready var building: Node3D = $map_desert/NavigationRegion3D/building

# Called when the node enters the scene tree for the first time.
func _ready():
	$UserInterface/Retry.hide()
	$UserInterface/Info.show()
	building.connect("isPlayerInSafeArea", _on_safe_area_changed.bind())

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	add_child(mob)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()

func _on_player_die():
	$MobTimer.stop()
	$UserInterface/Info.hide()
	$UserInterface/Retry.show()

func _on_safe_area_changed(new_value):
	if new_value == true:
		$MobTimer.stop()
		print("stopped mob spawner")
	elif new_value == false:
		$MobTimer.start()
		print("resumed mob spawner")
	else:
		print("invalid value")
