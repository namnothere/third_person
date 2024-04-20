extends Node3D

@export var mob_scene: PackedScene
var scoreLabel: Label
# Called when the node enters the scene tree for the first time.
func _ready():
	$UserInterface/Retry.hide()
	scoreLabel = get_node('UserInterface/ScoreLabel')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()
	print("spawn location: ", mob_spawn_location)

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	#mob.squashed.connect(scoreLabel._on_mob_squashed.bind())
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
