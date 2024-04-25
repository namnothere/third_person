extends Control

@export var player: CharacterBody3D

@onready var scoreLabel = $Info/ScoreLabel
@onready var healthBar = $Info/HealthBar

var score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	#player.connect("health", _on_player_hit.bind())
	player.connect("health_update", _on_health_update.bind())
	healthBar.get_node("HealthLabel").text = "Health: %s" % player.health
	healthBar.value = player.health
	healthBar.max_value = player.health
	healthBar.get("theme_override_styles/fill").border_width_right = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_mob_killed():
	score += 1
	scoreLabel.text = "Score: %s" % score

func _on_health_update(new_health):
	healthBar.get("theme_override_styles/fill").border_width_right = 0
	healthBar.get_node("HealthLabel").text = "Health: %s" % new_health
	healthBar.value = player.health
