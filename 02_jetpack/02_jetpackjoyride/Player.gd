extends CharacterBody2D


const VERTICAL_IMPULSE: float = 2250.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump_boost"):
		velocity.y -= VERTICAL_IMPULSE * delta

	move_and_slide()
