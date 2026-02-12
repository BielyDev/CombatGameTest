extends CharacterBody3D

var motion: Vector3

@export var sensi: float = 1.0
@export var speed: float = 4.0
@onready var spring: SpringArm3D = $Spring

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	motion.x = 0
	motion.z = 0
	
	var foward: Vector3 = spring.global_basis.z
	foward.y = 0
	foward = foward.normalized()
	var right: Vector3 = foward.cross(Vector3.UP).normalized()
	
	motion.z += (Input.get_axis("up","down") * foward.z) * speed
	motion.x += (Input.get_axis("up","down") * right.z) * speed
	motion.x += -(Input.get_axis("left","right") * right.x) * speed
	motion.z += -(Input.get_axis("left","right") * right.z) * speed
	
	velocity = lerp(velocity, motion, 7 * delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse: Vector2 = event.relative
		
		spring.rotation.y += -(mouse.x * 0.01) * sensi
		spring.rotation.x += -(mouse.y * 0.01) * sensi
		
		spring.rotation_degrees.x = clamp(spring.rotation_degrees.x, -80, 30)


func _on_anima_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
