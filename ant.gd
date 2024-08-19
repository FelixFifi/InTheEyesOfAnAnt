extends Node2D

class_name Ant

@export var speed: float = 5
@export var rotate_speed: float = 0.75
@export var fly_speed: float = 30

@export var zoom_speed: float = 5
@export var zoom_default: float = 30
@export var zoom_flying: float = 20

var movement_allowed: bool = true
var flying: bool = false
var fly_available: bool = true
const FLY_ANIMATION_DURATION: float = 0.5

signal target_entered()
signal flying_started()
signal flying_stopped()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not movement_allowed:
		return

	if flying:
		move_local_y(-delta * fly_speed)
	else:
		move_local_y(-Input.get_axis("ant_backward", "ant_forward") * delta * speed)

		rotate(delta * rotate_speed * Input.get_axis("ant_turn_left", "ant_turn_right"))



func _unhandled_input(event):
	if not flying and fly_available and event.is_action_pressed("ant_fly"):
		start_flying()

func start_flying():
	flying = true
	fly_available = false
	%FlyTimer.start()

	# zooms out to give illusion of more distance to surface while keeping the ant the same size
	var tween = create_tween()
	tween.parallel().tween_property(%Camera, "zoom", Vector2(zoom_flying, zoom_flying), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "scale", Vector2(zoom_default / zoom_flying, zoom_default / zoom_flying), 0.5)

	flying_started.emit()


func stop_flying():
	flying = false
	%FlyCooldownTimer.start()

	# TODO: Start landing animation before flying stops
	var tween = create_tween()
	tween.parallel().tween_property(%Camera, "zoom", Vector2(zoom_default, zoom_default), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.5)

	flying_stopped.emit()


func enable_target_search():
	%Area2D.monitoring = true

func disable_camera():
	%Camera.enabled = false

func get_camera_position():
	return %Camera.global_position

func _on_fly_timer_timeout():
	stop_flying()

func _on_fly_cooldown_timer_timeout():
	fly_available = true


func _on_area_2d_area_entered(_area):
	target_entered.emit()
