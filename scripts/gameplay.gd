extends Node2D


const APPROACH_TIME = 1.0

var tap_note_scene := preload("res://scenes/tap_note.tscn")
var hold_note_scene := preload("res://scenes/hold_note.tscn")

var keys := "abcdefghijklmnopqrstuvwxyz".split("")
var used_keys := []

var all_notes := []			# ARRAY OF NOTE DATA
var current_notes := []		# ARRAY OF SPAWNED NOTE NODES
var note_index: int = 0
var total_notes: int

var song_time: float = 0.0
var score: int = 0

var perfect_count:int = 0
var good_count:int = 0
var bad_count:int = 0
var miss_count:int = 0

@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var hit_sound: AudioStreamPlayer = $HitSound

func _ready() -> void:
	var song = SongManager.selected_song

	var base_path = song["path"]
	var audio_path = base_path + "audio.mp3"
	var chart_path = base_path + "level.json"

	# LOAD AUDIO
	audio_player.stream = load(audio_path)
	audio_player.play()

	# LOAD CHART
	var chart = load_level(chart_path)
	all_notes = chart["notes"]
	total_notes = all_notes.size()

	SongManager.selected_song = {}

func _process(delta: float) -> void:
	song_time = get_song_time()

	if note_index < all_notes.size() and song_time >= all_notes[note_index]["time"] - APPROACH_TIME:
		if all_notes[note_index]["hold"] == 0.0:
			spawn_tap_note(all_notes[note_index])
		else:
			spawn_hold_note(all_notes[note_index])
		note_index += 1

	if song_ended():
		show_result()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		var key = OS.get_keycode_string(event.keycode).to_upper()

		for note in current_notes:
			if note.key == key:
				if event.pressed:
					handle_note_hit(key)
				else:
					if note.has_method("register_release"):
						note.register_release()

func handle_note_hit(key: String) -> void:		# HANDLES DUPLICATE KEYS
	var candidates := []
	
	for note in current_notes:
		if note.key == key:
			candidates.append(note)

	if candidates.is_empty():
		return

	candidates.sort_custom(func(a, b): return a.time > b.time)
	candidates[0].register_hit()

func song_ended() -> bool:
	if not audio_player.playing:
		return true
	else:
		return false

func get_song_time() -> float:
	var playback := audio_player.get_playback_position()
	var mix := AudioServer.get_time_since_last_mix()
	var latency := AudioServer.get_output_latency()
	return playback + mix - latency

func load_level(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No level file found")
		return {}

	var text: String = file.get_as_text()
	var result: Dictionary = JSON.parse_string(text)
	if result == null:
		push_error("Invalid JSON")
		return {}

	return result

func spawn_tap_note(note_data: Dictionary) -> void:
	var tap_note_node = tap_note_scene.instantiate()
	tap_note_node.setup(note_data)

	add_child(tap_note_node)
	current_notes.append(tap_note_node)

func spawn_hold_note(note_data: Dictionary) -> void:
	var hold_note_node = hold_note_scene.instantiate()
	hold_note_node.setup(note_data)
	
	add_child(hold_note_node)
	current_notes.append(hold_note_node)

func remove_note(note: Node2D) -> void:
	current_notes.erase(note)

func play_hit_sound() -> void:
	hit_sound.play()

func add_score(result: String) -> void:
	match result:
		"PERFECT":
			score += 100
			perfect_count += 1
		"GOOD":
			score += 80
			good_count += 1
		"BAD":
			score += 50
			bad_count += 1
		"MISS":
			score += 0
			miss_count += 1

func compute_accuracy() -> float:
	var max_score: float = total_notes * 100.0
	return float(score) / max_score * 100.0

func get_rank(accuracy: float) -> String:
	if accuracy >= 95.0:
		return "S"
	elif accuracy >= 90.0:
		return "A"
	elif accuracy >= 80:
		return "B"
	elif accuracy >= 50:
		return "C"
	else:
		return "F"

func show_result() -> void:
	var accuracy: float = compute_accuracy()
	var rank: String = get_rank(accuracy)

	ResultManager.accuracy = accuracy
	ResultManager.rank = rank
	
	ResultManager.score = score
	
	ResultManager.perfect_count = perfect_count
	ResultManager.good_count = good_count
	ResultManager.bad_count = bad_count
	ResultManager.miss_count = miss_count

	get_tree().change_scene_to_file("res://scenes/result_screen.tscn")
