extends CharacterBody3D

@onready var cognite_node: CogniteNode = $CogniteNode
@onready var player: CharacterBody3D = $"../Player"
@onready var anima: AnimationPlayer = $Anima
@onready var model: Node3D = $Model
@export var path: Path3D

var state: StringName

var speed: float = 3.0
var life: float = 100

func _process(delta: float) -> void:
	cognite_node.life = life
	cognite_node.distance = global_position.distance_to(player.global_position)
	cognite_node.animation = anima.current_animation
	
	#$runtime_action.text = str(
	#	"Idle: ",cognite_node.runtime_action.get(44).current_process,"\n",
	#	"Chase: ",cognite_node.runtime_action.get(53).current_process,"\n",
	#	"Atack: ",cognite_node.runtime_action.get(54).current_process,"\n",
	#	)
	
	if Input.is_action_just_pressed("ui_accept"):
		life -= 25

func _physics_process(delta: float) -> void:
	velocity.x = 0
	velocity.z = 0
	
	apply_state()
	move_and_slide()

func apply_state() -> void:
	match state:
		"idle":
			anima.play("Idle")
		"walk":
			perseguir_player()
			anima.play("Walk")
		"atack":
			anima.play("Atack")

func perseguir_player() -> void:
	var to_player: Vector3 = global_position - player.global_position
	model.rotation.y = atan2(to_player.x, to_player.z) + (PI)
	
	velocity = global_position.direction_to(player.global_position).normalized() * speed

func _on_cognite_node_request(_deed_name: StringName) -> void:
	state = _deed_name
	print("Request: ", _deed_name)


func _on_cognite_node_started(_deed_name: StringName) -> void:
	state = _deed_name

func _on_cognite_node_finalized(_deed_name: StringName) -> void:
	state = _deed_name
