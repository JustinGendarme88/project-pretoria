extends Resource
class_name QuestStepData

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export var hidden_until_active: bool = false
@export var optional: bool = false
