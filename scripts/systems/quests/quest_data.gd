extends Resource
class_name QuestData

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export var category: String = "Main Quest"
@export var steps: Array[QuestStepData] = []
