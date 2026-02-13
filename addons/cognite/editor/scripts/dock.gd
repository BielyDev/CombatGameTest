@tool
class_name CogniteDock extends PanelContainer


@onready var assemble_list: GraphNode = $graph_edit/assemble_list
@onready var percepition_list: GraphNode = $graph_edit/percepition_list
@onready var context_list: GraphNode = $graph_edit/context_list
@onready var decision_list: GraphNode = $graph_edit/decision_list
@onready var action_list: GraphNode = $graph_edit/action_list

@onready var create_perception_item: Button = $graph_edit/percepition_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/create_perception_item
@onready var create_context_item: Button = $graph_edit/context_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/create_perception_item
@onready var create_decision_item: Button = $graph_edit/decision_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/create_decision_item
@onready var create_new_action: MenuButton = $graph_edit/action_list/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer/PanelContainer/create_new_action

@onready var list_node: Array[GraphNode] = [
	assemble_list,
	percepition_list,
	context_list,
	decision_list,
	action_list,
]

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


var distance: float = 45

func _process(delta: float) -> void:
	var other: GraphNode
	
	for graph: GraphNode in list_node:
		if other != null:
			if graph.get_index() != 0 and !graph.selected:
				graph.position_offset.x = lerp(graph.position_offset.x, other.position_offset.x + other.size.x + distance, delta * 7)
		
		other = graph
