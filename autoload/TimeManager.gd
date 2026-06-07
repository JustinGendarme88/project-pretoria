extends Node

signal day_advanced(day: int)
signal time_changed

enum DayPart {
	DAY,
	NIGHT
}

var current_day: int = 1
var current_month: int = 1
var current_year: int = 1

var day_part: DayPart = DayPart.DAY

const DAYS_PER_MONTH := 30
const MONTHS_PER_YEAR := 4


func advance_time() -> void:
	if day_part == DayPart.DAY:
		day_part = DayPart.NIGHT
	else:
		day_part = DayPart.DAY
		advance_day()

	print(get_date_text())
	time_changed.emit()


func advance_day() -> void:
	current_day += 1

	if current_day > DAYS_PER_MONTH:
		current_day = 1
		current_month += 1

	if current_month > MONTHS_PER_YEAR:
		current_month = 1
		current_year += 1

	day_advanced.emit(current_day)


func get_date_text() -> String:
	var part_text := "Day"

	if day_part == DayPart.NIGHT:
		part_text = "Night"

	return "Year %d - Month %d - Day %d - %s" % [
		current_year,
		current_month,
		current_day,
		part_text
	]


func get_save_data() -> Dictionary:
	return {
		"current_day": current_day,
		"current_month": current_month,
		"current_year": current_year,
		"day_part": day_part
	}


func load_save_data(data: Dictionary) -> void:
	current_day = data.get("current_day", 1)
	current_month = data.get("current_month", 1)
	current_year = data.get("current_year", 1)
	day_part = data.get("day_part", DayPart.DAY)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			advance_time()
