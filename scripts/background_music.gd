extends Node

@onready var _anim_player := $AnimationPlayer
@onready var _neutralTrack := $neutralTrack
@onready var _battleTrack := $battleTrack

# crossfades to a new audio stream
func crossfade_to(audio_stream: AudioStream) -> void:
	# If both tracks are playing, we're calling the function in the middle of a fade.
	# We return early to avoid jumps in the sound.
	if _neutralTrack.playing and _battleTrack.playing:
		return

	# The `playing` property of the stream players tells us which track is active. 
	# If it's track two, we fade to track one, and vice-versa.
	if _battleTrack.playing:
		_neutralTrack.stream = audio_stream
		_neutralTrack.play()
		_anim_player.play("FadeToTrack1")
	else:
		_battleTrack.stream = audio_stream
		_battleTrack.play()
		_anim_player.play("FadeToTrack2")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
