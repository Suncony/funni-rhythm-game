extends Control


@onready var song_vbox: VBoxContainer = $ColorRect/SongMargin/SongVBox


var songs: Array[Dictionary] = [{
	"name" = "Rise of the Jade Dragon",
	"path" = "res://songs/RiseOfTheJadeDragon/"
}]

func _ready() -> void:
	create_song_buttons()

func _on_song_button_pressed(song_data):
	SongManager.selected_song = song_data
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func create_song_buttons() -> void:
	for song in songs:
		var button := Button.new()
		button.text = song["name"]

		button.pressed.connect(func():_on_song_button_pressed(song))
		song_vbox.add_child(button)
