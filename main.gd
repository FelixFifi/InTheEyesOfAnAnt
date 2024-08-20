extends Node2D

@export var levels: Array[PackedScene]
var level_index: int = 0

var current_picture: Picture
var ant: Ant

const GUESS_UI = preload("res://guess_ui.tscn")
var guess_ui: GuessUI
var is_first_level = true

const PHEROMONE_TRAIL_WIDTH_DEFAULT = 7
const PHEROMONE_TRAIL_END = 20

func load_picture(picture_scene: PackedScene):
	if guess_ui != null:
		guess_ui.queue_free()
	guess_ui = GUESS_UI.instantiate()
	add_child(guess_ui)
	guess_ui.guess_button_pressed.connect(_on_guess_ui_guess_button_pressed)
	guess_ui.guess_text_focus_changed.connect(_on_guess_ui_guess_text_focus_changed)
	guess_ui.help_ui_visibility_changed.connect(_on_guess_ui_help_ui_visibility_changed)
	guess_ui.next_level_button_pressed.connect(_on_guess_ui_next_level_button_pressed)

	guess_ui.set_help_ui_visibility(is_first_level)

	var picture: Picture = picture_scene.instantiate()
	if current_picture != null:
		current_picture.queue_free()
	current_picture = picture
	add_child(picture)

	ant = current_picture.get_ant()
	# The ant is initially not allowed to move, until the help text is hidden
	ant.movement_allowed = not is_first_level

	ant.target_entered.connect(_on_ant_enter_target)
	ant.border_entered.connect(_on_ant_border_entered)

	%PheromoneTrail.clear_points()
	%PheromoneTrail.width = PHEROMONE_TRAIL_WIDTH_DEFAULT
	%PheromoneTrail.add_point(ant.global_position)

	is_first_level = false

func _ready():
	load_picture(levels[level_index])
	%Music.play()

func _unhandled_key_input(event):
	if OS.is_debug_build():
		if event.is_action_pressed("level_1"):
			load_picture(levels[0])
			level_index = 0
		if event.is_action_pressed("level_2"):
			load_picture(levels[1])
			level_index = 1
		if event.is_action_pressed("level_3"):
			load_picture(levels[2])
			level_index = 2
		if event.is_action_pressed("level_4"):
			load_picture(levels[3])
			level_index = 3
		if event.is_action_pressed("level_5"):
			load_picture(levels[4])
			level_index = 4
		if event.is_action_pressed("level_6"):
			load_picture(levels[5])
			level_index = 5
		if event.is_action_pressed("level_7"):
			load_picture(levels[6])
			level_index = 6

func _on_guess_ui_guess_text_focus_changed(focused):
	current_picture.get_ant().movement_allowed = not focused

func _on_guess_ui_guess_button_pressed(guess: String):
	guess = guess.to_lower()
	if guess in current_picture.get_valid_guesses():
		current_picture.correct_guess = guess
		guess_ui.guess_correct(guess, current_picture.get_target_description())
		ant.enable_target_search()

func end_level():
	current_picture.finished = true
	ant.disable_camera()
	guess_ui.handle_target_reached(current_picture.correct_guess)
	current_picture.show_full_image(ant.get_camera_position(), ant.zoom_default)

	var tween = create_tween()
	tween.tween_property(%PheromoneTrail, "width", PHEROMONE_TRAIL_END, Picture.END_CAMERA_ZOOM_DURATION).set_trans(Tween.TRANS_EXPO)

func _on_ant_enter_target():
	if current_picture.finished == false:
		end_level()

func _on_pheromone_timer_timeout():
	%PheromoneTrail.add_point(ant.global_position)


func _on_guess_ui_help_ui_visibility_changed(help_ui_visible: bool):
	if ant != null:
		ant.movement_allowed = not help_ui_visible

func _on_guess_ui_next_level_button_pressed():
	var next_level_index: int = (level_index + 1) % levels.size()
	load_picture(levels[next_level_index])
	level_index = next_level_index

func _on_ant_border_entered():
	guess_ui.show_border_reached_dialog()
