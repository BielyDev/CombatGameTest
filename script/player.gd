extends CharacterBody3D

const GRAVITY_MAX: float = 30.0
const GRAVITY_FORCE: float = 0.3

var motion: Vector3
var motion_rotated: Vector3

@onready var cognite_node: CogniteNode = $CogniteNode
@onready var spring: SpringArm3D = $Spring
@onready var anima: AnimationPlayer = $Anima
@onready var model: Node3D = $Model
@onready var sword: AnimationPlayer = $Sword

@export var sensi: float = 1.0
@export var speed: float = 4.0

var state: StringName

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	cognite_node.x = motion.x
	cognite_node.y = motion.y
	cognite_node.z = motion.z
	
	apply_state()

func _physics_process(delta: float) -> void:
	motion.x = 0
	motion.z = 0
	
	gravity()
	
	var foward: Vector3 = spring.global_basis.z
	foward.y = 0
	foward = foward.normalized()
	var right: Vector3 = foward.cross(Vector3.UP).normalized()
	
	motion.z += (Input.get_axis("up","down") * foward.z) * speed
	motion.x += (Input.get_axis("up","down") * right.z) * speed
	motion.x += -(Input.get_axis("left","right") * right.x) * speed
	motion.z += -(Input.get_axis("left","right") * right.z) * speed
	
	
	model.rotation.y = lerp_angle(model.rotation.y, motion_rotated.y, 15 * delta)
	velocity.x = lerp(velocity.x, motion.x, 10 * delta)
	velocity.z = lerp(velocity.z, motion.z, 10 * delta)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse: Vector2 = event.relative
		
		spring.rotation.y += -(mouse.x * 0.01) * sensi
		spring.rotation.x += -(mouse.y * 0.01) * sensi
		
		spring.rotation_degrees.x = clamp(spring.rotation_degrees.x, -80, 30)
	
	if Input.is_action_just_pressed("atack"):
		sword.play("Atack")

func gravity() -> void:
	velocity.y += -GRAVITY_FORCE
	
	if velocity.y < -GRAVITY_MAX:
		velocity.y = -GRAVITY_MAX

func knockback(demage_position: Vector3, force: int) -> void:
	motion = Vector3()
	velocity = demage_position.direction_to(global_position).normalized() * force

func look_direction() -> void:
	motion_rotated.y = Vector2(velocity.z, velocity.x).angle()
	
	#velocity = global_position.direction_to(player.global_position).normalized() * speed

func _on_cognite_node_started(_deed_name: StringName) -> void:
	match _deed_name:
		"atack":
			anima.play("Atack")
		_:
			state = _deed_name

func apply_state() -> void:
	match state:
		"idle":
			anima.play("Idle")
		"walk":
			look_direction()
			anima.play("Walk")


func _on_demage_body_entered(body: Node3D) -> void:
	body.knockback(global_position, randf_range(20, 40), self)
