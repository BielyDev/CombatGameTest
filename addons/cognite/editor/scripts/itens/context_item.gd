@tool
extends PanelContainer

const PERCEPTION_CONTEXT_ITEM = preload("res://addons/cognite/editor/perception_context_item.tscn")

var assemble: CogniteAssemble
var context_id: int
var perception_count: int
var context_data: Dictionary
var context_percetion_list: Array[Control]

@onready var context_name: LineEdit = $context_folder/VBoxContainer/HBoxContainer/context_name
@onready var create_perception_item: MenuButton = $context_folder/VBoxContainer/PanelContainer/perception_list/create_perception_item
@onready var perception_list: VBoxContainer = $context_folder/VBoxContainer/PanelContainer/perception_list
@onready var panel_perception_list: PanelContainer = $context_folder/VBoxContainer/PanelContainer
@onready var context_activated: CheckButton = $context_folder/VBoxContainer/header/activated
@onready var context_folder: FoldableContainer = $context_folder
@onready var validate_value: OptionButton = $context_folder/VBoxContainer/validate_hbox/validate_value


func _ready() -> void:
	create_perception_item.get_popup().id_pressed.connect(_on_create_perception_item_pressed)


func load_context(_assemble: CogniteAssemble, _context_id: int, _context_data: Dictionary):
	assemble = _assemble; context_id = _context_id; context_data = _context_data
	
	context_folder.title = str(context_data.name.capitalize()," : ",context_id)
	context_name.text = context_data.name
	validate_value.select(context_data.validate_mode)
	context_activated.set_pressed_no_signal(context_data.activated)
	
	refresh_itens()
	reset_perception_item_menu()


func refresh_itens():
	for item in context_percetion_list:
		item.queue_free()
	context_percetion_list.clear()
	
	var erase_ids: Array
	for p in context_data.perception_ids:
		for u in context_data.perception_ids[p]:
			var item: Array = assemble.get_perception(p)
			if item.is_empty(): erase_ids.append(p)
			else: create_context_perception_item(p, u, context_data.perception_ids[p])
		
	for p in erase_ids:
		context_data.perception_ids.erase(p)
	
	assemble.atualize_context(context_id, context_data)
	perception_count = context_data.perception_ids.size()


func create_context_perception_item(perception_id: int, unique_id: int, perception: Dictionary):
	var per = PERCEPTION_CONTEXT_ITEM.instantiate()
	perception_list.add_child(per)
	context_percetion_list.append(per)
	per.load_perception(perception_id, unique_id, perception, context_id, assemble)

func get_unique_id(id: int) -> int:
	var now_id: int = 0
	
	for child in perception_list.get_children():
		if child.get("id") != null and child.id == id:
			now_id += 1
	
	return now_id

func _on_context_name_text_changed(new_text: String) -> void:
	var caret_position = context_name.caret_column
	var word := Cognite.filter_string(new_text, "[A-Za-z_]")
	context_name.set_text(word)
	context_name.caret_column = caret_position
	
	context_folder.title = str(word.capitalize()," : ",context_id)
	
	context_data.name = word
	assemble.atualize_context(context_id, context_data)


func _on_activated_toggled(toggled_on: bool) -> void:
	context_data.activated = toggled_on
	assemble.atualize_context(context_id, context_data)


func _on_delete_pressed() -> void:
	assemble.contexts.erase(context_id)
	assemble.actualize.call_deferred()
	queue_free()


func _on_create_perception_item_pressed(id: int) -> void:
	var unique_id: int = get_unique_id(id)
	var dic: Dictionary = context_data.perception_ids.get_or_add(id,{})
	dic[unique_id] = assemble.PERCEPTION_CONTEXT_TEMPLATE.duplicate(true)
	context_data.perception_ids[id] = dic
	
	create_context_perception_item(id, unique_id, context_data.perception_ids[id][unique_id])
	assemble.atualize_context(context_id, context_data)
	perception_count = context_data.perception_ids.size()


func _on_show_perception_list_toggled(toggled_on: bool) -> void:
	panel_perception_list.set_visible(toggled_on)


func _on_create_perception_item_about_to_popup() -> void:
	reset_perception_item_menu()


func reset_perception_item_menu():
	create_perception_item.get_popup().clear()
	create_perception_item.get_popup().add_item("Perception", 0)
	create_perception_item.get_popup().set_item_as_separator(0, true)
	create_perception_item.get_popup().set_item_disabled(0, true)
	
	for perception_id in assemble.perceptions:
		var perception: Array = assemble.perceptions[perception_id]
		create_perception_item.get_popup().add_item(perception[0], perception_id)


func _on_validate_value_item_selected(index: int) -> void:
	context_data["validate_mode"] = index
	print(context_data)
	assemble.atualize_context(context_id, context_data)
