extends Node

# Exports
@export var snake_scene : PackedScene

# Constants
const INITIAL_SNAKE_LENGTH : int = 3

# Game state variables
var score : int
var game_started : bool = false

# Grid variables
var cells : int = 20
var cell_size : int = 50

# Snake variables
var old_data : Array
var snake_data : Array
var snake : Array

# Movement variables
var start_pos : Vector2 = Vector2(9, 9)
var up : Vector2 = Vector2(0, -1)
var down : Vector2 = Vector2(0, 1)
var left : Vector2 = Vector2(-1, 0)
var right : Vector2 = Vector2(1, 0)
var move_direction : Vector2
var can_move : bool = false

# Food variables
var food_pos : Vector2
var regen_food : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func new_game():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	score = 0
	$HUD.get_node("ScoreLabel").text = str(score)
	move_direction = up
	can_move = true
	generate_snake()
	move_food()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()

	# Starting with the start_pos, create tail segments on the same square
	for i in range(INITIAL_SNAKE_LENGTH):
		add_segment(start_pos)

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
		if Input.is_action_just_pressed(action) and (not game_started or move_direction != -direction):
			print(action)
			move_direction = direction
			can_move = false
			if not game_started:
				start_game()
			break

func start_game():
	game_started = true
	$MoveTimer.start()

func _on_move_timer_timeout():
	# Allow snake movement
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction

	for i in range(len(snake_data)):
		# Move all segments ahead by 1
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)

	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()

func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x >= cells or snake_data[0].y < 0 or snake_data[0].y >= cells:
		end_game()

func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()

func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
		$Food.position = (food_pos * cell_size) + Vector2(0, cell_size)
	regen_food = true

func check_food_eaten():
	if snake_data[0] == food_pos:
		score += 1
		$HUD.get_node("ScoreLabel").text = str(score)
		add_segment(old_data[-1])
		move_food()

func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true

func _on_game_over_menu_restart():
	new_game()
