extends Node

class_name Picture

const ANT = preload("res://ant.tscn")

@export var valid_guesses: Array[String] = []
@export var target_description: String

const END_CAMERA_ZOOM_DURATION: float = 4

var ant: Ant
var finished: bool = false

func _ready():
	ant = ANT.instantiate()
	%SpawnPoint.add_child(ant)
	%EndCamera.enabled = false

func get_ant():
	return ant

func get_valid_guesses():
	return valid_guesses

func get_target_description():
	return target_description

func show_full_image(start_position: Vector2, start_zoom: float):
	var target_position: Vector2 = %EndCamera.position
	var target_camera_zoom: float = %EndCamera.zoom.x

	%EndCamera.enabled = true
	%EndCamera.zoom = Vector2(start_zoom, start_zoom)
	%EndCamera.position = start_position

	var tween = create_tween()
	tween.parallel().tween_property(%EndCamera, "zoom", Vector2(target_camera_zoom, target_camera_zoom), END_CAMERA_ZOOM_DURATION).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(%EndCamera, "position", target_position, END_CAMERA_ZOOM_DURATION).set_trans(Tween.TRANS_EXPO)
