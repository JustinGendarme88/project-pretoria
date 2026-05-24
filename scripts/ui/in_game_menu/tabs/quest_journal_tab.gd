extends Control

@onready var quest_list: VBoxContainer = $MarginContainer/HBoxContainer/QuestListPanel/PanelContainer/ScrollContainer/QuestList
@onready var quest_details: VBoxContainer = $MarginContainer/HBoxContainer/QuestDetailsPanel/PanelContainer/ScrollContainer/QuestDetails

var selected_quest_id: String = ""


func _ready() -> void:
	QuestManager.quests_changed.connect(refresh)
	refresh()


func refresh() -> void:
	clear_container(quest_list)
	clear_container(quest_details)

	var quests := QuestManager.get_discovered_quests()

	for quest in quests:
		create_quest_button(quest)

	if selected_quest_id != "":
		show_quest_details(selected_quest_id)


func create_quest_button(quest: QuestData) -> void:
	var button := Button.new()

	button.text = quest.title
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	button.pressed.connect(func():
		select_quest(quest.id)
	)

	quest_list.add_child(button)


func select_quest(quest_id: String) -> void:
	selected_quest_id = quest_id
	show_quest_details(quest_id)


func show_quest_details(quest_id: String) -> void:
	clear_container(quest_details)

	var quest: QuestData = QuestManager.quests.get(quest_id)

	if quest == null:
		return

	var state := QuestManager.get_quest_state(quest_id)

	create_title(quest.title)

	for step in quest.steps:
		create_step_ui(quest_id, step, state)


func create_title(title: String) -> void:
	var title_label := Label.new()

	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	quest_details.add_child(title_label)

	add_spacing(16)


func create_step_ui(
	quest_id: String,
	step: QuestStepData,
	state: Dictionary
) -> void:

	var step_title := Label.new()
	step_title.text = step.title

	var completed := QuestManager.is_step_completed(quest_id, step.id)
	var current := QuestManager.is_current_step(quest_id, step.id)

	if completed:
		step_title.modulate = Color(0.5, 0.5, 0.5)

	elif current:
		step_title.modulate = Color(1.0, 0.85, 0.3)
		step_title.text = "> " + step.title

	else:
		step_title.modulate = Color(1, 1, 1)

	quest_details.add_child(step_title)

	if current:
		var description := Label.new()

		description.text = step.description
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.modulate = Color(0.85, 0.85, 0.85)

		quest_details.add_child(description)

	add_spacing(12)


func add_spacing(height: int) -> void:
	var spacer := Control.new()

	spacer.custom_minimum_size.y = height

	quest_details.add_child(spacer)


func clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
