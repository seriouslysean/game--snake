extends Node

@export var snake_scene : PackedScene

var score : int
var game_started : bool = false

# grid variables
var cells : int = 20
var cells_size : int = 50

# snake variables
var old_data : Array
var snake_data : Array
var snake : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
