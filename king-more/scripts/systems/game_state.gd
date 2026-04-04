extends Node

## The central game state machine.
## anages screen transitions, pause, and win/lose conditions.
## registered as an autoload


enum State { MENU, PLAYING, PAUSED, GAME_OVER, WIN }

var current_state: State = State.MENU
var pause_overlay: CanvasLayer = null
var is_transitioning: bool = false

var waves_survived: int = 0
var total_waves: int = 0

const MENU_SCENE = "res://scenes/screens/MenuScreen.tscn"
const LEVEL_SCENE = "res://scenes/levels/level.tscn"
const GAME_OVER_SCENE = "res://scenes/screens/GameOverScreen.tscn"
const WIN_SCENE = "res://scenes/screens/WinScreen.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return

	match current_state:
		State.MENU:
			if event.keycode == KEY_SPACE:
				start_game()
		State.PLAYING:
			if event.keycode == KEY_P:
				pause_game()
		State.PAUSED:
			if event.keycode == KEY_P:
				resume_game()
			elif event.keycode == KEY_R:
				restart_game()
		State.GAME_OVER:
			if event.keycode == KEY_SPACE:
				go_to_menu()
		State.WIN:
			if event.keycode == KEY_SPACE:
				go_to_menu()

func start_game() -> void:
	current_state = State.PLAYING
	get_tree().change_scene_to_file(LEVEL_SCENE)

func pause_game() -> void:
	current_state = State.PAUSED
	get_tree().paused = true
	_show_pause_overlay()

func resume_game() -> void:
	current_state = State.PLAYING
	get_tree().paused = false
	_hide_pause_overlay()

func restart_game() -> void:
	_hide_pause_overlay()
	get_tree().paused = false
	current_state = State.PLAYING
	is_transitioning = true
	get_tree().change_scene_to_file(LEVEL_SCENE)

func game_over() -> void:
	current_state = State.GAME_OVER
	get_tree().paused = false
	is_transitioning = true
	get_tree().call_deferred("change_scene_to_file", GAME_OVER_SCENE)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var label = get_tree().current_scene.get_node_or_null("CanvasLayer/Label")
	
	if label:
		var stats = "\n\nYou have survived %d/%d waves" % [waves_survived, total_waves]
		label.text += stats
	else:
		print("Could not find the Label! Check your Game Over scene tree paths.")

func win() -> void:
	current_state = State.WIN
	is_transitioning = true
	get_tree().call_deferred("change_scene_to_file",WIN_SCENE)

func go_to_menu() -> void:
	current_state = State.MENU
	is_transitioning
	get_tree().change_scene_to_file(MENU_SCENE)

func _show_pause_overlay() -> void: # dont need pause screen technically
	pause_overlay = CanvasLayer.new()
	pause_overlay.layer = 100
	pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS

	# Semi-transparent background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(bg)

	# Pause text
	var label = Label.new()
	label.text = "PAUSED\n\nP - Resume\nR - Restart"
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_overlay.add_child(label)

	get_tree().current_scene.add_child(pause_overlay)

func _hide_pause_overlay() -> void:
	if pause_overlay:
		pause_overlay.queue_free()
		pause_overlay = null
