extends CanvasLayer

var speaker_label: Label
var dialogue_label: RichTextLabel
var choices_container: VBoxContainer
var portrait_texture_rect: TextureRect

var choices_visible: bool = false


func _ready() -> void:
	speaker_label = find_child("SpeakerLabel", true, false)
	dialogue_label = find_child("DialogueLabel", true, false)
	choices_container = find_child("ChoicesContainer", true, false)
	portrait_texture_rect = find_child("PortraitTextureRect", true, false)

	hide()


func open_dialogue(starting_portrait: Texture2D = null) -> void:
	set_portrait(starting_portrait)
	show()


func close_dialogue() -> void:
	hide()

	choices_visible = false
	speaker_label.text = ""
	dialogue_label.clear()
	set_portrait(null)

	for child in choices_container.get_children():
		child.queue_free()


func show_line(text: String) -> void:
	choices_visible = false

	var speaker_name := ""
	var dialogue_text := text.strip_edges()

	if dialogue_text.contains(":"):
		var split_text = dialogue_text.split(":", false, 1)

		if split_text.size() >= 2:
			speaker_name = split_text[0].strip_edges()
			dialogue_text = split_text[1].strip_edges()

	speaker_label.text = speaker_name

	dialogue_label.clear()
	dialogue_label.append_text(dialogue_text)

	for child in choices_container.get_children():
		child.queue_free()


func show_choices(choices) -> void:
	choices_visible = true

	for child in choices_container.get_children():
		child.queue_free()

	for i in range(choices.size()):
		var button := Button.new()
		button.text = choices[i].text

		var choice_index := i
		button.pressed.connect(
			func():
				choices_visible = false
				DialogueManager.choose_choice(choice_index)
		)

		choices_container.add_child(button)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("interact"):
		if choices_visible:
			return

		DialogueManager.continue_story()
		get_viewport().set_input_as_handled()


func set_portrait(texture: Texture2D) -> void:
	if portrait_texture_rect == null:
		return

	portrait_texture_rect.texture = texture
	portrait_texture_rect.visible = texture != null
