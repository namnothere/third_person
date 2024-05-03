extends CharacterBody3D

signal health_update(health)
signal die

@export var health = 10.0
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var bounce_impulse = 3.5

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/stinky/AnimationPlayer
@onready var visual = $visuals
@onready var audioPlayer = $GameMusic/AudioGetDamagePlayer
@onready var audioJump = $GameMusic/Jump

var SPEED = 5.0
const JUMP_VELOCITY = 4.5

var walking_speed = 3.0
var running_speed = 5.0
var base_damage = 5.0
var regen_health = 1.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") - 1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visual.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))

func _physics_process(delta):
	if Input.is_action_pressed("speed_up"):
		SPEED = running_speed
	else:
		SPEED = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		audioJump.play()
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if animation_player.current_animation != "ParadeWalk":
			animation_player.play("ParadeWalk")
			
		visual.look_at(position + direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)

		# If the collision is with ground
		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# we check that we are hitting it from above.
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce.
				mob.squash()
				velocity.y = bounce_impulse
				# Prevent further duplicate calls.
				break
	move_and_slide()

func _on_hitbox_body_entered(_body):
	_damage(base_damage)

func _damage(damage: float):
	health -= damage
	health_update.emit(health)
	if health <= 0:
		_die()
	audioPlayer.play()

func _die():
	die.emit()

func _regen():
	pass
