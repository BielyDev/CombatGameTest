@tool
class_name CogniteDock extends PanelContainer


@onready var assemble_list: GraphNode = $graph_edit/assemble_list
@onready var percepition_list: GraphNode = $graph_edit/percepition_list
@onready var context_list: GraphNode = $graph_edit/context_list
@onready var decision_list: GraphNode = $graph_edit/decision_list
@onready var action_list: GraphNode = $graph_edit/action_list

@onready var create_perception_item: Button = $graph_edit/percepition_list/VBoxContainer/PanelContainer/VBoxContainer/create_perception_item
@onready var create_context_item: Button = $graph_edit/context_list/VBoxContainer/PanelContainer/VBoxContainer/create_perception_item
@onready var create_decision_item: Button = $graph_edit/decision_list/VBoxContainer/PanelContainer/VBoxContainer/create_decision_item
@onready var create_new_action: MenuButton = $graph_edit/action_list/VBoxContainer/PanelContainer/VBoxContainer/PanelContainer/create_new_action
@onready var correction: CheckButton = $correction

var current_assemble: CogniteAssemble

func set_current_assemble(assemble: CogniteAssemble):
	current_assemble = assemble
	
	percepition_list.set_assemble(assemble)
	context_list.set_assemble(assemble)
	decision_list.set_assemble(assemble)
	action_list.set_assemble(assemble)
	
	create_perception_item.set_disabled(false)
	create_context_item.set_disabled(false)
	create_decision_item.set_disabled(false)
	create_new_action.set_disabled(false)


#region Graph View
var distance: float = 22
var is_resized: bool = false

@onready var list_node: Array[GraphNode] = [
	assemble_list,
	percepition_list,
	context_list,
	decision_list,
	action_list,
]

var origin: Array[Rect2] = [
	Rect2(10, 10, 300, 400),
	Rect2(10, 430, 300, 580),

	Rect2(330, 10, 400, 1000),
	Rect2(750, 10, 400, 1000),
	Rect2(1170, 10, 400, 1000),
]

func _process(delta: float) -> void:
	if correction.button_pressed:
		var other: GraphNode
		
		for graph: GraphNode in list_node:
			if other != null:
				if graph.get_index() != 0 and !graph.selected:
					graph.position_offset.x = lerp(graph.position_offset.x, other.position_offset.x + other.size.x + distance, delta * 7)
					graph.position_offset.y = lerp(graph.position_offset.y, other.position_offset.y, delta * 7)
					graph.size.y = lerp(graph.size.y, other.size.y, delta * 7)
			other = graph
	else:
		for graph_idx in range(list_node.size()):
			var graph: GraphNode = list_node[graph_idx]
			
			graph.position_offset = lerp(graph.position_offset, origin[graph_idx].position, delta * 7)
			if !is_resized:
				graph.size = lerp(graph.size, origin[graph_idx].size, delta * 7)



func _on_list_position_offset_changed() -> void:
	if !correction.button_pressed:
		EditorInterface.get_editor_undo_redo()
		
		for graph_idx in range(list_node.size()):
			var graph: GraphNode = list_node[graph_idx]
			
			if graph.selected:
				origin[graph_idx].position = graph.position_offset

func _on_correction_pressed() -> void:
	for graph: GraphNode in list_node:
		graph.selected = false

func _on_list_resize_request(new_size: Vector2) -> void:
	is_resized = true

func _on_list_resize_end(new_size: Vector2) -> void:
	if !correction.button_pressed:
		for graph_idx in range(list_node.size()):
			var graph: GraphNode = list_node[graph_idx]
			
			origin[graph_idx].size = graph.size
	
	is_resized = false
