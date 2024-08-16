extends Control

signal guess_button_pressed(guess: String)
signal guess_text_focus_changed(focused: bool)

func _ready():
	%GuessContainer.visible = false

func _on_guess_button_pressed():
	guess_button_pressed.emit(%GuessText.text)


func _on_guess_text_focus_entered():
	guess_text_focus_changed.emit(true)


func _on_guess_text_focus_exited():
	guess_text_focus_changed.emit(false)


func _on_game_master_guess_correct(solution):
	%GuessCorrectLabel.text = "You guessed correctly!
	This is a {0}".format([solution])
	%GuessContainer.visible = true

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_accept"):
		if not %GuessText.has_focus():
			%GuessText.grab_focus()


func _on_guess_text_text_submitted(new_text):
	%GuessButton.pressed.emit()
