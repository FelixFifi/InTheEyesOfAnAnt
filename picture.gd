extends Node

class_name Picture

const ANT = preload("res://ant.tscn")

@export var valid_guesses: Array[String] = []
@export var target_zones: Array[Area2D] = []
@export var target_description: String

var ant: Ant

func _ready():
	ant = ANT.instantiate()
	%SpawnPoint.add_child(ant)

func get_ant():
	return ant

func get_valid_guesses():
	return valid_guesses

func get_target_description():
	return target_description
