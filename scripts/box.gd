extends CharacterBody3D
signal squashed

@export var min_speed = 2.0
@export var max_speed = 4.0
var random_speed = randi_range(min_speed, max_speed)
var SPEED = random_speed
#
@onready var player_path: NodePath = "../Player"
@onready var scoreLabel: Label = $"../UserInterface/ScoreLabel"

@onready var nav_agent = $NavigationAgent3D
@onready var player: Node3D = null
@onready var building: Node3D = $"../map_desert/NavigationRegion3D/building"

var next_location = null
var isPlayerInside = false
var isSetup = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("actor_setup")
	player = get_node(player_path)
	self.squashed.connect(scoreLabel._on_mob_squashed.bind())
	building.connect("isPlayerInSafeArea", _on_safe_area_changed.bind())
	#.connect(scoreLabel._on_mob_squashed.bind())
	
	add_to_group("mob")
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	isSetup = true
	
# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))
	
func _physics_process(_delta):
	if player == null: _ready()
	if isSetup == false: await actor_setup()
	if isPlayerInside == false && player != null:
		chasingPlayer(_delta)

func chasingPlayer(_delta):
	look_at(Vector3(player.global_position.x, self.global_position.y, player.global_position.z), Vector3.UP)
	
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_position)
	next_location = nav_agent.get_next_path_position()
	
	var current_location = global_transform.origin
	velocity = (next_location - current_location).normalized() * SPEED
	#if not is_on_floor():
	velocity.y = 0

	move_and_slide()

func squash():
	squashed.emit()
	queue_free()

func _on_safe_area_changed(new_value):
	if new_value == true:
		print("Quit chasing player")
		isPlayerInside = true
	elif new_value == false:
		print("Continue chasing player")
		isPlayerInside = false
	else:
		print("invalid value")
		
