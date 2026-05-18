extends Node

var story = null
var dialogue_ui = null
var is_dialogue_active: bool = false
var player = null

var current_npc_id: String = ""
var current_npc_data: NPCData = null


func _ready() -> void:
	dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")


func start_dialogue(dialogue_json_path: String, npc_id: String = "", npc_data: NPCData = null) -> void:
	if is_dialogue_active:
		return

	var ink_resource = load(dialogue_json_path)
	if ink_resource == null:
		push_error("Dialogue file not found: " + dialogue_json_path)
		return

	current_npc_id = npc_id
	current_npc_data = npc_data

	story = InkStory.new(ink_resource.json)

	bind_external_functions()
	sync_godot_to_ink()

	is_dialogue_active = true

	dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	player = get_tree().get_first_node_in_group("player")

	if player != null:
		player.set_state(player.PlayerState.DIALOGUE)

	if dialogue_ui != null:
		var starting_portrait: Texture2D = null

		if current_npc_data != null:
			starting_portrait = current_npc_data.get_portrait("neutral")

		dialogue_ui.open_dialogue(starting_portrait)

	continue_story()


func continue_story() -> void:
	if story == null:
		return

	if story.can_continue:
		var text: String = story.continue_story().strip_edges()

		process_ink_tags()

		if text == "":
			continue_story()
			return

		if dialogue_ui != null:
			dialogue_ui.show_line(text)

		return

	if story.current_choices.size() > 0:
		if dialogue_ui != null:
			dialogue_ui.show_choices(story.current_choices)
		return

	end_dialogue()


func choose_choice(choice_index: int) -> void:
	if story == null:
		return

	if choice_index < 0 or choice_index >= story.current_choices.size():
		return

	story.choose_choice_index(choice_index)
	continue_story()


func end_dialogue() -> void:
	sync_ink_to_godot()

	is_dialogue_active = false
	story = null
	current_npc_id = ""
	current_npc_data = null

	if dialogue_ui != null:
		dialogue_ui.close_dialogue()

	if player != null:
		player.set_state(player.PlayerState.NORMAL)

	player = null


func process_ink_tags() -> void:
	if story == null:
		return

	if current_npc_data == null:
		return

	for tag in story.current_tags:
		var clean_tag: String = str(tag).strip_edges()

		if clean_tag.begins_with("portrait:"):
			var emotion := clean_tag.replace("portrait:", "").strip_edges()
			var portrait := current_npc_data.get_portrait(emotion)

			if dialogue_ui != null:
				dialogue_ui.set_portrait(portrait)


func sync_godot_to_ink() -> void:
	if story == null:
		return

	set_ink_variable_if_exists("sword_repaired", FlagManager.get_flag("sword_repaired", false))
	set_ink_variable_if_exists("met_karlach", FlagManager.get_flag("met_karlach", false))
	set_ink_variable_if_exists("has_cigar", FlagManager.get_flag("has_cigar", false))

	if current_npc_id != "":
		ReputationManager.register_npc(current_npc_id)
		set_ink_variable_if_exists("npc_reputation", ReputationManager.get_reputation(current_npc_id))


func sync_ink_to_godot() -> void:
	if story == null:
		return

	sync_flag_from_ink("sword_repaired", false)
	sync_flag_from_ink("met_karlach", false)
	sync_flag_from_ink("has_cigar", false)

	if current_npc_id != "":
		var new_reputation = get_ink_variable_if_exists("npc_reputation", ReputationManager.get_reputation(current_npc_id))

		if typeof(new_reputation) == TYPE_INT or typeof(new_reputation) == TYPE_FLOAT:
			ReputationManager.set_reputation(current_npc_id, int(new_reputation))


func sync_flag_from_ink(flag_name: String, default_value = false) -> void:
	var value = get_ink_variable_if_exists(flag_name, default_value)
	FlagManager.set_flag(flag_name, value)


func set_ink_variable_if_exists(variable_name: String, value) -> void:
	if story == null:
		return

	story.variables_state.set(variable_name, value)


func get_ink_variable_if_exists(variable_name: String, default_value = null):
	if story == null:
		return default_value

	var value = story.variables_state.get(variable_name)

	if value == null:
		return default_value

	return value


func bind_external_functions() -> void:
	if story == null:
		return

	story.bind_external_function("set_flag", self, "_ink_set_flag")
	story.bind_external_function("get_flag", self, "_ink_get_flag")
	story.bind_external_function("change_reputation", self, "_ink_change_reputation")
	story.bind_external_function("get_reputation", self, "_ink_get_reputation")


func _ink_set_flag(flag_name: String, value) -> void:
	FlagManager.set_flag(flag_name, value)


func _ink_get_flag(flag_name: String):
	return FlagManager.get_flag(flag_name, false)


func _ink_change_reputation(npc_id: String, amount: int) -> void:
	ReputationManager.change_reputation(npc_id, amount)


func _ink_get_reputation(npc_id: String) -> int:
	return ReputationManager.get_reputation(npc_id)
