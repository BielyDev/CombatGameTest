@tool
class_name CogniteRuntimeContext extends RefCounted

enum PropertyType {BOOL, EQUAL, LESS, MORE, BETWEEN}
enum ValidationMode { ANY, ALL }

var cognite_node: CogniteNode
var perpection_list: Array[Callable]
var validate: bool

var validation_mode: ValidationMode = ValidationMode.ANY

func _init(context: Dictionary, assemble: CogniteAssemble, _cognite_node: CogniteNode) -> void:
	cognite_node = _cognite_node;
	
	validation_mode = context.validate_mode
	
	for perception_id in context.perception_ids:
		for unique_id in context.perception_ids[perception_id]:
			var perception: Array = assemble.get_perception(perception_id)
			var perception_data: Dictionary = context.perception_ids[perception_id][unique_id]
			
			match perception[1]:
				0: perpection_list.append(Callable(self, "test_perception_is"     ).bind(perception[0], perception_data.bool ))
				1: perpection_list.append(Callable(self, "test_perception_between").bind(perception[0], perception_data.min, perception_data.max))
				2: perpection_list.append(Callable(self, "test_perception_string" ).bind(perception[0], perception_data.text ))


func check_is_valid():
	var result: Array = []
	
	for perception in perpection_list:
		result.append(perception.call())
	
	match validation_mode:
		ValidationMode.ALL:
			validate = not result.has(false)
		ValidationMode.ANY:
			validate = result.has(true)

func test_perception_is(perception_name: StringName, value: bool):
	return cognite_node.get(perception_name) == value


func test_perception_between(perception_name: StringName, min: float, max: float):
	var value: float
	if cognite_node.get(perception_name): value = cognite_node.get(perception_name)
	return value > min and value < max 


func test_perception_string(perception_name: StringName, value: String):
	return cognite_node.get(perception_name) == value
