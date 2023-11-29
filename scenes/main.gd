extends Node

@export var snake_scene : PackedScene

var score : int
var game_started : bool = false

# grid variables
var cells : int = 20
var cell_size : int = 50

# snake variables
var old_data : Array
var snake_data : Array
var snake : Array

# movement variables
var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2
var can_move : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	
func new_game():
	score = 0
	$HUD.get_node("ScoreLabel").text = str(score)
	move_direction = up
	can_move = true
	generate_snake()
	
func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	#starting with the start_pos, create tail segments vertically down
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	
func move_snake():
	if not can_move:
		return

	var direction_mapping = {
		"move_up": up,
		"move_right": right,
		"move_down": down,
		"move_left": left
	}

	for action in direction_mapping.keys():
		var direction = direction_mapping[action]
		
		if Input.is_action_just_pressed(action) and move_direction != direction:
			move_direction = direction
			can_move = false
			if not game_started:
				start_game()
			break
			
func start_game():
	game_started = true
	$MoveTimer.start()

func _on_move_timer_timeout():
	# allow snake movement
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		# move all segments ahead by 1
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
