extends ItemData
class_name EquipmentData

enum EquipmentSlot {
	WEAPON,
	HEAD,
	CHEST,
	LEGS,
	ACCESSORY
}

@export var slot: EquipmentSlot

@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
