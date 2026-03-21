extends Control


@onready var rank: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/Rank
@onready var accuracy: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/Accuracy

@onready var score: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/ScoreHBox/Count

@onready var perfect_count: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/PerfectHBox/Count
@onready var good_count: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/GoodHBox/Count
@onready var bad_count: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/BadHBox/Count
@onready var miss_count: Label = $ColorRect/ResultPanel/ResultMargin/ResultVBox/MissHBox/Count

func _ready() -> void:
	# RANK & ACCURACY
	display_rank()
	accuracy.text = str("%.2f" % ResultManager.accuracy) + "%"

	# SCORE
	score.text = str(ResultManager.score)

	# NOTE COUNTS
	perfect_count.text = str(ResultManager.perfect_count)
	good_count.text = str(ResultManager.good_count)
	bad_count.text = str(ResultManager.bad_count)
	miss_count.text = str(ResultManager.miss_count)

func _on_back_button_pressed() -> void:
	ResultManager.clear()
	get_tree().change_scene_to_file("res://scenes/selection_menu.tscn")

func display_rank() -> void:
	rank.text = ResultManager.rank

	match rank.text:
		"S":
			rank.modulate = Color.YELLOW
		"A":
			rank.modulate = Color.GREEN
		"B":
			rank.modulate = Color.ORANGE
		"C":
			rank.modulate = Color.SADDLE_BROWN
		"F":
			rank.modulate = Color.RED
