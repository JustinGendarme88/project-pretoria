extends CanvasLayer

@export var day_icon: Texture2D
@export var night_icon: Texture2D

@onready var date_label: Label = $HBoxContainer/Label
@onready var day_part_icon: TextureRect = $HBoxContainer/TextureRect


func _ready() -> void:
	TimeManager.time_changed.connect(update_date)
	update_date()


func update_date() -> void:
	date_label.text = "Year %d - Month %d - Day %d" % [
		TimeManager.current_year,
		TimeManager.current_month,
		TimeManager.current_day
	]

	if TimeManager.day_part == TimeManager.DayPart.DAY:
		day_part_icon.texture = day_icon
	else:
		day_part_icon.texture = night_icon
