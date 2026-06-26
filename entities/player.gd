extends CharacterBody2D
enum State{
	IDLE
}

@export_category("Stats")
@export var speed: int = 400

var move_direction :Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	movement_loop()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
