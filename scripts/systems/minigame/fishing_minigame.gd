extends Control

@onready var fishing_bar: Control = $MinigamePanel/FishingBar
@onready var capture_zone: NinePatchRect = $MinigamePanel/FishingBar/CaptureZone
@onready var fish_icon: TextureRect = $MinigamePanel/FishingBar/FishIcon
@onready var capture_progress: TextureProgressBar = $MinigamePanel/CaptureProgress
@onready var escape_progress: TextureProgressBar = $MinigamePanel/EscapeProgress

@onready var success_icon: TextureRect = $MinigamePanel/SuccessIcon
@onready var failure_icon: TextureRect = $MinigamePanel/FailureIcon

@export_category("Capture Zone")
@export var capture_zone_fall_speed: float = 90.0
@export var capture_zone_rise_speed: float = 150.0

@export_category("Fish")
@export var fish_speed: float = 55.0
@export var fish_direction_change_min: float = 0.5
@export var fish_direction_change_max: float = 1.4
@export var fish_up_texture: Texture2D
@export var fish_down_texture: Texture2D

@export_category("Progress")
@export var capture_fill_time: float = 4.0
@export var capture_empty_time: float = 2.0
@export var escape_fill_time: float = 3.0
@export var escape_empty_time: float = 1.5

@export_category("Result")
@export var result_display_duration: float = 1.5

var capture_velocity: float = 0.0
var fish_direction: float = 1.0
var direction_timer: float = 0.0
var is_finished: bool = false


func _ready() -> void:
	capture_progress.value = 0.0
	escape_progress.value = 0.0
	choose_new_fish_direction()
	success_icon.hide()
	failure_icon.hide()


func _process(delta: float) -> void:
	if is_finished:
		return

	update_capture_zone(delta)
	update_fish(delta)
	update_progress_bars(delta)


func update_capture_zone(delta: float) -> void:
	if Input.is_action_pressed("fishing_control"):
		capture_velocity = -capture_zone_rise_speed
	else:
		capture_velocity = capture_zone_fall_speed

	capture_zone.position.y += capture_velocity * delta
	capture_zone.position.y = clamp(
		capture_zone.position.y,
		0.0,
		fishing_bar.size.y - capture_zone.size.y
	)


func update_fish(delta: float) -> void:
	direction_timer -= delta

	if direction_timer <= 0.0:
		choose_new_fish_direction()

	fish_icon.position.y += fish_direction * fish_speed * delta

	if fish_direction < 0.0:
		fish_icon.texture = fish_up_texture
	else:
		fish_icon.texture = fish_down_texture

	var maximum_y: float = fishing_bar.size.y - fish_icon.size.y

	if fish_icon.position.y <= 0.0:
		fish_icon.position.y = 0.0
		fish_direction = 1.0
	elif fish_icon.position.y >= maximum_y:
		fish_icon.position.y = maximum_y
		fish_direction = -1.0


func choose_new_fish_direction() -> void:
	fish_direction = [-1.0, 1.0].pick_random()
	direction_timer = randf_range(
		fish_direction_change_min,
		fish_direction_change_max
	)


func update_progress_bars(delta: float) -> void:
	var fish_is_inside: bool = is_fish_inside_capture_zone()

	if fish_is_inside:
		if escape_progress.value > 0.0:
			escape_progress.value -= 100.0 / escape_empty_time * delta
		else:
			capture_progress.value += 100.0 / capture_fill_time * delta
	else:
		if capture_progress.value > 0.0:
			capture_progress.value -= 100.0 / capture_empty_time * delta
		else:
			escape_progress.value += 100.0 / escape_fill_time * delta

	capture_progress.value = clamp(capture_progress.value, 0.0, 100.0)
	escape_progress.value = clamp(escape_progress.value, 0.0, 100.0)

	if capture_progress.value >= 100.0:
		finish_minigame(true)
	elif escape_progress.value >= 100.0:
		finish_minigame(false)


func is_fish_inside_capture_zone() -> bool:
	var fish_top: float = fish_icon.position.y
	var fish_bottom: float = fish_icon.position.y + fish_icon.size.y
	var zone_top: float = capture_zone.position.y
	var zone_bottom: float = capture_zone.position.y + capture_zone.size.y

	return fish_top >= zone_top and fish_bottom <= zone_bottom


func finish_minigame(success: bool) -> void:
	if is_finished:
		return

	is_finished = true

	fishing_bar.hide()
	capture_progress.hide()
	escape_progress.hide()

	success_icon.visible = success
	failure_icon.visible = not success

	if success:
		print("Fish captured!")
	else:
		print("The fish escaped!")

	await get_tree().create_timer(result_display_duration).timeout
	queue_free()
