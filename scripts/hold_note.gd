extends Node2D

const APPROACH_TIME = 1.0
const HIT_MS = 0.2
const NOTE_RADIUS = 40.0
const APPROACH_RADIUS = 100.0
const EARLY_RELEASE_TOLERANCE = 0.12

@export var key: String
@export var hold_duration: float
@onready var label: Label = $CenterContainer/Label

var time: float = 0.0
var done: bool = false
var approaching_radius: float = APPROACH_RADIUS

var holding := false
var hold_timer := 0.0

func _ready() -> void:
	label.text = key
	label.add_theme_font_size_override("font_size", 32)
	label.modulate = Color.RED

func _draw() -> void:
	draw_arc(Vector2.ZERO, NOTE_RADIUS, 0, TAU, 64, Color(1.0, 1.0, 0.0, 0.9), 3)
	if not holding:
		draw_arc(Vector2.ZERO, approaching_radius, 0, TAU, 64, Color(1.0, 1.0, 1.0, 0.5), 3)
	if holding:
		var progress: float = clampf(hold_timer / hold_duration, 0.0, 1.0)
		draw_arc(Vector2.ZERO, NOTE_RADIUS + 8, -PI/2, -PI/2 + TAU * progress, 64, Color(1.0, 1.0, 1.0, 0.9), 3)

func _process(delta: float) -> void:
	if done: return
	if holding:
		hold_timer += delta
		if hold_timer > hold_duration:
			hit("PERFECT")

	time += delta
	if not holding and time > APPROACH_TIME + HIT_MS:
		hit("MISS")

	var relative_time: float = time / APPROACH_TIME
	var clamped_time: float = clampf(relative_time, 0.0, 1.0)
	approaching_radius = lerpf(APPROACH_RADIUS, NOTE_RADIUS, clamped_time)
	queue_redraw()

func _exit_tree() -> void:
	if get_parent().has_method("remove_note"):
		get_parent().remove_note(self)

func setup(note_data: Dictionary) -> void:
	key = note_data.key.to_upper()
	hold_duration = note_data.hold
	position = Vector2(note_data.x*100, note_data.y*100)

func hit(result: String) -> void:
	done = true
	label.text = result
	label.add_theme_font_size_override("font_size", 16)

	match result:
		"PERFECT":
			label.modulate = Color.YELLOW
		"GOOD":
			label.modulate = Color.GREEN
		"BAD":
			label.modulate = Color.ORANGE
		"MISS":
			label.modulate = Color.SADDLE_BROWN

	get_parent().add_score(result)
	await get_tree().create_timer(0.2).timeout
	queue_free()

func register_hit() -> void:
	if holding or done: return

	get_parent().play_hit_sound()
	var err: float = abs(time - APPROACH_TIME)

	if err <= HIT_MS:
		holding = true

func register_release() -> void:
	if not holding or done: return

	holding = false
	if hold_timer >= hold_duration - EARLY_RELEASE_TOLERANCE:
		hit("PERFECT")
	else:
		hit("BAD")
