extends CharacterBody3D

const SPEED = 4.0

@export var player_path: NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var player: Node3D = null
var next_location = null

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("actor_setup")
	player = get_node(player_path)
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	
func _physics_process(delta):
	look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
	
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_position)	
	next_location = nav_agent.get_next_path_position()

	var new_velocity = position.direction_to(next_location).normalized() * SPEED * delta
	velocity = new_velocity
	move_and_collide(velocity)
