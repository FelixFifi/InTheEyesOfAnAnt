extends Node2D

signal guess_correct(solution: String)

const valid_guesses = [ "cat", "feline", "pussy", "kitty", "maine coon", "kira" ]

func _on_guess_ui_guess_text_focus_changed(focused):
	%Ant.movement_allowed = not focused


func _on_guess_ui_guess_button_pressed(guess: String):
	if guess.to_lower() in valid_guesses:
		guess_correct.emit(guess.to_lower())
