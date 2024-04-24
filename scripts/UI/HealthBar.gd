extends ProgressBar

@onready var healthLabel = $HealthLabel
@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("hit", _on_player_hit.bind())
	healthLabel.text = "Health: %s" % player.health
	value = player.health
	max_value = player.health
	get("theme_override_styles/fill").border_width_right = 5
	
func _on_player_hit(_damage, new_health):
	get("theme_override_styles/fill").border_width_right = 0
	healthLabel.text = "Health: %s" % new_health
	value = player.health
