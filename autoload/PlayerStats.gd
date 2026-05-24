extends Node

signal stats_changed
signal health_changed(current_health: int, max_health: int)
signal energy_changed(current_energy: int, max_energy: int)
signal spirit_changed(current_spirit: int, max_spirit: int)
signal player_died

var level: int = 1
var experience: int = 0

var max_health: int = 100
var max_energy: int = 100
var max_spirit: int = 100

var current_health: int = 100
var current_energy: int = 100
var current_spirit: int = 100

var strength: int = 5
var defense: int = 5
var intelligence: int = 5


func take_damage(amount: int) -> void:
	var final_damage: int = max(amount - defense, 1)
	current_health = max(current_health - final_damage, 0)

	emit_health_changed()

	if current_health <= 0:
		player_died.emit()


func restore_health(percent: float) -> void:
	current_health = min(current_health + int(max_health * percent), max_health)
	emit_health_changed()


func consume_energy(amount: int) -> bool:
	if current_energy < amount:
		return false

	current_energy -= amount
	emit_energy_changed()
	return true


func restore_energy(percent: float) -> void:
	current_energy = min(current_energy + int(max_energy * percent), max_energy)
	emit_energy_changed()


func consume_spirit(amount: int) -> bool:
	if current_spirit < amount:
		return false

	current_spirit -= amount
	emit_spirit_changed()
	return true


func restore_spirit(percent: float) -> void:
	current_spirit = min(current_spirit + int(max_spirit * percent), max_spirit)
	emit_spirit_changed()


func set_health(value: int) -> void:
	current_health = clamp(value, 0, max_health)
	emit_health_changed()


func set_energy(value: int) -> void:
	current_energy = clamp(value, 0, max_energy)
	emit_energy_changed()


func set_spirit(value: int) -> void:
	current_spirit = clamp(value, 0, max_spirit)
	emit_spirit_changed()


func emit_all_changed() -> void:
	emit_health_changed()
	emit_energy_changed()
	emit_spirit_changed()
	stats_changed.emit()


func emit_health_changed() -> void:
	health_changed.emit(current_health, max_health)
	stats_changed.emit()


func emit_energy_changed() -> void:
	energy_changed.emit(current_energy, max_energy)
	stats_changed.emit()


func emit_spirit_changed() -> void:
	spirit_changed.emit(current_spirit, max_spirit)
	stats_changed.emit()
