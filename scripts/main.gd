extends Node3D

@export var mob_scene: PackedScene
@export var player: CharacterBody3D
@export var building: Node3D
@export var UI: Control
@export var mobTimer: Timer
@export var events: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().call_group("mob", "_on_safe_area_changed", false)
	UI.get_node("Retry").hide()
	UI.get_node("Info").show()
	events.connect("die", _on_player_die)
	events.connect("isPlayerInSafeArea", _on_safe_area_changed)
	#building.connect("isPlayerInSafeArea", _on_safe_area_changed.bind())

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()
	mob.initialize(mob_spawn_location.position, player, UI, building, events)
	add_child(mob)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and UI.get_node("Retry").visible:
		get_tree().reload_current_scene()

func _on_player_die():
	mobTimer.stop()
	get_tree().call_group("mob", "_on_safe_area_changed", true)
	UI.get_node("Info").hide()
	UI.get_node("Retry").show()

func _on_safe_area_changed(new_value):
	if new_value == true:
		mobTimer.stop()
		print("stopped mob spawner")
	elif new_value == false:
		mobTimer.start()
		print("resumed mob spawner")
	else:
		print("invalid value")
