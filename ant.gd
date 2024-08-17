extends Node2D

@export var speed: float = 5
@export var rotate_speed: float = 0.75
@export var fly_speed: float = 30

@export var zoom_speed: float = 5
@export var zoom_default: float = 30
@export var zoom_flying: float = 20

var movement_allowed: bool = true
var flying: bool = false
var fly_available: bool = true

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
	if event.is_action_pressed("zoom_decrease"):
		%Camera.zoom -= Vector2(1,1) * zoom_speed
		print(%Camera.zoom)
	if event.is_action_pressed("zoom_increase"):
		%Camera.zoom += Vector2(1,1) * zoom_speed
		print(%Camera.zoom)

	if not flying and fly_available and event.is_action_pressed("ant_fly"):
		start_flying()

func start_flying():
	flying = true
	fly_available = false
	%FlyTimer.start()

	var tween = create_tween()
	tween.parallel().tween_property(%Camera, "zoom", Vector2(zoom_flying, zoom_flying), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "scale", Vector2(zoom_default / zoom_flying, zoom_default / zoom_flying), 0.5)


func stop_flying():
	flying = false
	%FlyCooldownTimer.start()

	var tween = create_tween()
	tween.parallel().tween_property(%Camera, "zoom", Vector2(zoom_default, zoom_default), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "scale", Vector2(1, 1), 0.5)


func _on_fly_timer_timeout():
	stop_flying()

func _on_fly_cooldown_timer_timeout():
	fly_available = true
