extends CharacterBody3D

const GRAVITY_MAX: float = 30.0
const GRAVITY_FORCE: float = 0.1

@onready var cognite_node: CogniteNode = $CogniteNode
@onready var player: CharacterBody3D = $"../Player"
@onready var anima: AnimationPlayer = $Anima
@onready var model: Node3D = $Model
@export var path: Path3D
@onready var await_atack: Timer = $Timers/await_atack
@onready var shield_anima: AnimationPlayer = $shield_anima

var state: StringName
var motion: Vector3

var speed: float = 3.0
var life: float = 100

func _process(delta: float) -> void:
	cognite_node.life = life
	cognite_node.distance = global_position.distance_to(player.global_position)
	cognite_node.animation = anima.current_animation
	cognite_node.await_atack = !await_atack.is_stopped()
	
	$runtime_action.text = state
	
	if Input.is_action_just_pressed("ui_accept"):
		life -= 25

func _physics_process(delta: float) -> void:
	motion.x = 0
	motion.z = 0
	
	gravity()
	apply_state()
	
	velocity.x = lerp(velocity.x, motion.x, 10 * delta)
	velocity.z = lerp(velocity.z, motion.z, 10 * delta)
	
	move_and_slide()

func gravity() -> void:
	velocity.y += -GRAVITY_FORCE
	
	if velocity.y < -GRAVITY_MAX:
		velocity.y = -GRAVITY_MAX

func apply_state() -> void:
	match state:
		"idle":
			anima.play("Idle")
		"walk":
			perseguir_player()
			anima.play("Walk")
		"atack_one":
			if await_atack.is_stopped():
				anima.play("Atack_one")
		"atack_two":
			if await_atack.is_stopped():
				anima.play("Atack_two")
		"defense":
			look_player()
			anima.play("Defense")
		"await_combat":
			look_player()
			anima.play("Await_combat")

func look_player() -> void:
	var to_player: Vector3 = global_position - player.global_position
	model.rotation.y = atan2(to_player.x, to_player.z) + (PI)

func perseguir_player() -> void:
	look_player()
	
	var dir: Vector3 = global_position.direction_to(player.global_position).normalized() * speed
	
	motion.x = dir.x 
	motion.z = dir.z

func knockback(demage_position: Vector3, force: int, _owner: CharacterBody3D = null) -> void:
	if state == "defense":
		shield_anima.play("Defense")
		if _owner != null:
			_owner.knockback(global_position, 50)
		return
	motion = Vector3()
	velocity = demage_position.direction_to(global_position).normalized() * force

func _on_cognite_node_request(_deed_name: StringName) -> void:
	#state = _deed_name
	print("Request: ", _deed_name)

func _on_cognite_node_started(_deed_name: StringName) -> void:
	state = _deed_name
	print("started: ", _deed_name)

func _on_cognite_node_finalized(_deed_name: StringName) -> void:
	state = _deed_name
	print("finalized: ", _deed_name)


func _on_anima_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Atack_one":
			await_atack.start()
			await_atack.wait_time = randf_range(0.8,3.0)
			cognite_node.is_defense = bool(randi()%2)
			cognite_node.deed_action_finalized("atack_one")
		"Atack_two":
			await_atack.start()
			await_atack.wait_time = randf_range(0.8,3.0)
			cognite_node.is_defense = bool(randi()%2)
			cognite_node.deed_action_finalized("atack_two")


func _on_demage_body_entered(body: Node3D) -> void:
	body.knockback(global_position, randf_range(20, 40))
