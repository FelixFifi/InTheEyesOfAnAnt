extends Node2D

signal target_reached()

@export var levels: Array[PackedScene]
var level_index: int = 0

var current_picture: Picture
var ant: Ant

const GUESS_UI = preload("res://guess_ui.tscn")
var guess_ui: GuessUI

func load_picture(picture_scene: PackedScene):
	if guess_ui != null:
		guess_ui.queue_free()
	guess_ui = GUESS_UI.instantiate()
	add_child(guess_ui)
	guess_ui.guess_button_pressed.connect(_on_guess_ui_guess_button_pressed)
	guess_ui.guess_text_focus_changed.connect(_on_guess_ui_guess_text_focus_changed)

	var picture: Picture = picture_scene.instantiate()
	if current_picture != null:
		current_picture.queue_free()
	current_picture = picture
	add_child(picture)

	ant = current_picture.get_ant()
	ant.target_entered.connect(_on_ant_enter_target)

	%PheromoneTrail.clear_points()
	%PheromoneTrail.add_point(ant.global_position)

func _ready():
	load_picture(levels[level_index])

func _unhandled_key_input(event):
	if OS.is_debug_build():
		if event.is_action_pressed("level_1"):
			load_picture(levels[0])
			level_index = 0
		if event.is_action_pressed("level_2"):
			load_picture(levels[1])
			level_index = 1

func _on_guess_ui_guess_text_focus_changed(focused):
	current_picture.get_ant().movement_allowed = not focused

func _on_guess_ui_guess_button_pressed(guess: String):
	if guess.to_lower() in current_picture.get_valid_guesses():
		guess_ui.guess_correct(guess.to_lower(), current_picture.get_target_description())
		ant.enable_target_search()

func end_level():
	current_picture.finished = true
	ant.disable_camera()
	target_reached.emit()
	current_picture.show_full_image(ant.get_camera_position(), ant.zoom_default)
	%PheromoneTrail.width = 2

	await get_tree().create_timer(10).timeout
	var next_level_index: int = (level_index + 1) % levels.size()
	load_picture(levels[next_level_index])
	level_index = next_level_index

func _on_ant_enter_target():
	if current_picture.finished == false:
		end_level()

func _on_pheromone_timer_timeout():
	%PheromoneTrail.add_point(ant.global_position)
