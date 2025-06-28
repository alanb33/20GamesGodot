class_name FireworksManager
extends Node2D

@export var particle_scene: PackedScene
@export var fireworks_cd: float = 0.25
var fireworks_timer: Timer = null

const fireworks_scene: PackedScene = preload("res://scenes/FurShredderParticles.tscn")

enum Side {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	MAX
}

func get_random_edge_position() -> Vector2:
	var win_w: int = get_viewport_rect().size.x
	var win_h: int = get_viewport_rect().size.y
	
	var x_pos: int = 0
	var y_pos: int = 0
	
	var side = randi_range(0, Side.MAX)
	match side:
		Side.LEFT:
			x_pos = 0
			y_pos = randi_range(0, win_h)
		Side.RIGHT:
			x_pos = win_w
			y_pos = randi_range(0, win_h)
		Side.UP:
			x_pos = randi_range(0, win_w)
			y_pos = 0
		Side.DOWN:
			x_pos = randi_range(0, win_w)
			y_pos = win_h
	
	return Vector2(x_pos, y_pos)

func start_fireworks():
	fireworks_timer = Timer.new()
	add_child(fireworks_timer)
	fireworks_timer.start(fireworks_cd)
	fireworks_timer.timeout.connect(_on_fireworks_timer_done)
	
func stop_fireworks():
	fireworks_timer.timeout.disconnect(_on_fireworks_timer_done)
	fireworks_timer.queue_free()
	fireworks_timer = null
		
## Private Functions

func _on_fireworks_timer_done() -> void:
	var fireworks_pos = get_random_edge_position()
	var particles = fireworks_scene.instantiate()
	add_child(particles)
	
	particles.position = fireworks_pos
	particles.look_at(get_viewport_rect().size / 2)
	particles.emitting = true
	particles.one_shot = true
	
	await particles.finished
	particles.queue_free()
	

## Godot Functions
		
func _ready() -> void:
	assert(particle_scene, "Fireworks Manager has no particle scene")
