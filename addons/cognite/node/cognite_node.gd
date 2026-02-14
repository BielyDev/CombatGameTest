@tool
class_name CogniteNode extends Node

enum ErrorCognite {NULL,OK,PERCEPTIONS_SIZE,DECISIONS_SIZE}

signal started(_deed_name: StringName)
signal finalized(_deed_name: StringName)
signal request(_deed_name: StringName)

@export var cognite_assemble: CogniteAssemble

var context: Dictionary
var updating: bool

var runtime_context: Dictionary
var runtime_decision: Dictionary
var runtime_action: Dictionary
var decisions: Dictionary

var action_by_decision: Dictionary
var best_score_decision: int = -1


func is_valid_cognite() -> ErrorCognite:
	if cognite_assemble == null:
		return ErrorCognite.NULL
	
	if cognite_assemble.perceptions.size() == 0:
		return ErrorCognite.PERCEPTIONS_SIZE
	
	if cognite_assemble.decisions.size() == 0 || decisions.size() == 0:
		return ErrorCognite.DECISIONS_SIZE
	
	return ErrorCognite.OK

static func print_error(error_value: ErrorCognite) -> void:
	match error_value:
		ErrorCognite.NULL:
			push_error("Resource cognite is null")
		ErrorCognite.PERCEPTIONS_SIZE:
			push_error("Perceptions size < 1")
		ErrorCognite.DECISIONS_SIZE:
			push_error("Decisions size < 1")

func deed_action_finalized(deed_name: StringName):
	var action_id: int = action_by_decision[best_score_decision]
	
	runtime_action[action_id].finalized_current_deed(deed_name)


func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	
	#print_error(is_valid_cognite())
	
	#if is_valid_cognite() != ErrorCognite.OK: return
	
	cognite_assemble.clear_deeds()
	
	for context_id in cognite_assemble.contexts:
		runtime_context[context_id] = CogniteRuntimeContext.new(cognite_assemble.contexts[context_id], cognite_assemble, self)
	
	for decision_id in cognite_assemble.decisions:
		decisions[decision_id] = 0
		runtime_decision[decision_id] = CogniteRuntimeDecision.new(cognite_assemble.decisions[decision_id], self)
	
	for action_id in cognite_assemble.actions:
		var action: Dictionary = cognite_assemble.actions[action_id]
		
		runtime_action[action_id] = CogniteRuntimeAction.new(action, self)
		action_by_decision[action.decision_id] = action_id

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	for id in cognite_assemble.perceptions:
		# or is_valid_cognite() != ErrorCognite.OK
		var per: Array = cognite_assemble.perceptions[id]
		
		if not cognite_assemble.perception_runtime_value.has(per[0]):
			match per[1]:
				0: cognite_assemble.perception_runtime_value[per[0]] = false
				1: cognite_assemble.perception_runtime_value[per[0]] = 0.0
				2: cognite_assemble.perception_runtime_value[per[0]] = ""
		
		#print(cognite_assemble.perception_runtime_value[per[0]])
	
	for crc in runtime_context:
		#print(runtime_context[crc])
		runtime_context[crc].check_is_valid()
	
	for dcs in runtime_decision:
		#print(runtime_decision[dcs])
		decisions[dcs] = runtime_decision[dcs].get_score()
	
	var keys = decisions.keys()
	keys.sort_custom(_sort_decision_score)
	
	if best_score_decision != keys[0]:
		action_cicle(keys[0])
		best_score_decision = keys[0]

func action_cicle(new_decision: int):
	
	if decisions.has(best_score_decision):
		var action_id = action_by_decision[best_score_decision]
		runtime_action[action_id].finish()
	
	if decisions.has(new_decision) and action_by_decision.has(new_decision):
		var action_id = action_by_decision[new_decision]
		runtime_action[action_id].start()
	else:
		print("asdsadasdasdadasdasa")

func _get_property_list():
	var props := []
	
	if not cognite_assemble or cognite_assemble.perceptions.is_empty():
		return props
	
	for id in cognite_assemble.perceptions:
		var per: Array = cognite_assemble.perceptions[id]
		var data: Dictionary = {"name": per[0]}
		
		match per[1]:
			0: data["type"] = TYPE_BOOL
			1: data["type"] = TYPE_FLOAT
			2: data["type"] = TYPE_STRING
		
		props.append(data)
	return props

func _get(property: StringName):
	if !cognite_assemble: return
	
	if cognite_assemble.perception_runtime_value.has(property):
		return cognite_assemble.perception_runtime_value[property]
	return null

func _set(property, value):
	if _is_dynamic_property(property):
		cognite_assemble.atualize_perception_runtime_value(property, value)
		return true
	return false


func _is_dynamic_property(prop_name: String) -> bool:
	if not cognite_assemble: return false
	for id in cognite_assemble.perceptions:
		if cognite_assemble.perceptions[id][0] == prop_name:
			return true
	return false


func _sort_decision_score(a, b):
	return decisions[a] > decisions[b]

func _on_deed_started(_deed_name: StringName):
	started.emit(_deed_name)

func _on_deed_finalized(_deed_name: StringName):
	finalized.emit(_deed_name)

func _on_deed_request(_deed_name: StringName):
	request.emit(_deed_name)
