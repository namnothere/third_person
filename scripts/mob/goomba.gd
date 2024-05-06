extends CharacterBody3D

@export var min_speed = 3.5
@export var max_speed = 6.0
@export var player: Node3D
@export var UI: Control
@export var building: Node3D
@export var isExample: bool = false
@export var events: Node2D

var random_speed = randi_range(min_speed, max_speed)
var SPEED = random_speed

@onready var nav_agent = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $visuals/AnimationPlayer
var next_location = null
var isChasingPlayer = true
var isSetup = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	if (isExample == true): animation_player.pause()
	call_deferred("actor_setup")
	
	#self.mob_killed.connect(UI._on_mob_killed.bind())
	#building.connect("isPlayerInSafeArea", _on_safe_area_changed.bind())
	if events:
		events.connect("isPlayerInSafeArea", _on_safe_area_changed)
	add_to_group("mob")
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	isSetup = true
	
# This function will be called from the Main scene.
func initialize(start_position, Player: CharacterBody3D, ui: Control, Building: Area3D, Events: Node2D):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	player = Player
	UI = ui
	building = Building
	events = Events
	events.connect("isPlayerInSafeArea", _on_safe_area_changed)
	
	look_at_from_position(start_position, Player.position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))
	
func _physics_process(_delta):
	if player == null: return
	if isSetup == false: await actor_setup()
	if isChasingPlayer == true && player != null:
		chasingPlayer(_delta)

func chasingPlayer(_delta):
	look_at(Vector3(player.global_position.x, self.global_position.y, player.global_position.z), Vector3.UP)
	
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_position)
	next_location = nav_agent.get_next_path_position()
	
	var current_location = global_transform.origin
	velocity = (next_location - current_location).normalized() * SPEED
	velocity.y = 0

	move_and_slide()

func squash():
	if (events != null):
		events.emit_signal("mob_killed")
	queue_free()

func _on_safe_area_changed(new_value):
	if isExample == true: return
	if new_value == true:
		isChasingPlayer = false
		animation_player.pause()
	elif new_value == false:
		isChasingPlayer = true
		animation_player.play("Take 001")
	else:
		print("invalid value")
		
