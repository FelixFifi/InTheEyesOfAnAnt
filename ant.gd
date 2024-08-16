extends Node2D

@export var speed: float = 5
@export var zoom_speed: float = 5
@export var rotate_speed: float = 0.75


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_local_y(-Input.get_axis("ant_backward", "ant_forward") * delta * speed)

	rotate(delta * rotate_speed * Input.get_axis("ant_turn_left", "ant_turn_right"))



func _unhandled_input(event):
	if event.is_action_pressed("zoom_decrease"):
		%Camera.zoom -= Vector2(1,1) * zoom_speed
		print(%Camera.zoom)
	if event.is_action_pressed("zoom_increase"):
		%Camera.zoom += Vector2(1,1) * zoom_speed
		print(%Camera.zoom)
