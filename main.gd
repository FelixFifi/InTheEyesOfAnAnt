extends Node2D

signal guess_correct(solution: String, target_description: String)
signal target_reached()

var current_picture: Picture
var ant: Ant


func _ready():
	current_picture = $KiraKarton
	ant = current_picture.get_ant()
	ant.target_entered.connect(_on_ant_enter_target)
	%PheromoneTrail.add_point(ant.global_position)

func _on_guess_ui_guess_text_focus_changed(focused):
	current_picture.get_ant().movement_allowed = not focused

func _on_guess_ui_guess_button_pressed(guess: String):
	if guess.to_lower() in current_picture.get_valid_guesses():
		guess_correct.emit(guess.to_lower(), current_picture.get_target_description())
		ant.enable_target_search()

func end_level():
	current_picture.finished = true
	ant.disable_camera()
	target_reached.emit()
	current_picture.show_full_image(ant.get_camera_position(), ant.zoom_default)
	%PheromoneTrail.width = 2

func _on_ant_enter_target():
	if current_picture.finished == false:
		end_level()

func _on_pheromone_timer_timeout():
	%PheromoneTrail.add_point(ant.global_position)
