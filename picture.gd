extends Node

class_name Picture

const ANT = preload("res://ant.tscn")
const BLUR_MATERIAL = preload("res://blur_material.tres")

@export var valid_guesses: Array[String] = []
var correct_guess: String = ""
@export var target_description: String
var blur_radius: float = 120
var blur_radius_flying: float = blur_radius / 2.5
@export var blur_texture: Texture2D

const END_CAMERA_ZOOM_DURATION: float = 4

var ant: Ant
var finished: bool = false


func _ready():
	ant = ANT.instantiate()
	ant.position = %SpawnPoint.global_position
	ant.rotation = %SpawnPoint.global_rotation
	ant.flying_started.connect(_on_ant_flying_started)
	ant.flying_stopped.connect(_on_ant_flying_stopped)
	add_child(ant)

	%EndCamera.enabled = false

	var image_size = %Sprite.texture.get_size()

	%Sprite.material = BLUR_MATERIAL
	%Sprite.material.set_shader_parameter("ant_uv", get_ant_on_image_uv())
	%Sprite.material.set_shader_parameter("picture_size", image_size * %Sprite.scale)
	%Sprite.material.set_shader_parameter("gradual_blur_radius", blur_radius)
	%Sprite.material.set_shader_parameter("blur_texture", blur_texture)

	# Lowercase with type hack, as map returns generic Array and not Array[String]
	valid_guesses.assign(valid_guesses.map(func (s: String) -> String: return s.to_lower()))

func _process(_delta):
	if finished:
		return
	%Sprite.material.set_shader_parameter("ant_uv", get_ant_on_image_uv())

func get_ant_on_image_uv():
	var total_size: Vector2 = %Sprite.scale * %Sprite.texture.get_size()
	var uv_position = (%Sprite.to_local(ant.global_position) * %Sprite.scale + total_size / 2.0) / total_size;
	return uv_position

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


	var picture_size: Vector2 = %Sprite.texture.get_size() * %Sprite.scale

	var tween = create_tween()
	tween.parallel().tween_property(%EndCamera, "zoom", Vector2(target_camera_zoom, target_camera_zoom), END_CAMERA_ZOOM_DURATION).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(%EndCamera, "position", target_position, END_CAMERA_ZOOM_DURATION).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_method(set_shader_blur_radius, blur_radius, max(picture_size.x, picture_size.y), END_CAMERA_ZOOM_DURATION).set_trans(Tween.TRANS_EXPO)

	await tween.finished
	finished = true
	%Sprite.material = null

func set_shader_blur_radius(value: float):
	%Sprite.material.set_shader_parameter("gradual_blur_radius", value)

func _on_ant_flying_started():
	if finished:
		return
	var tween = create_tween()
	tween.tween_method(set_shader_blur_radius, blur_radius, blur_radius_flying, ant.FLY_ANIMATION_DURATION).set_trans(Tween.TRANS_QUAD)

func _on_ant_flying_stopped():
	if finished:
		return
	var tween = create_tween()
	tween.tween_method(set_shader_blur_radius, blur_radius_flying, blur_radius, ant.FLY_ANIMATION_DURATION).set_trans(Tween.TRANS_QUAD)
