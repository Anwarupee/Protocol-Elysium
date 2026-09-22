extends CharacterBody2D

signal player_moved

enum State { IDLE, WALK }

@export_category("Stats")
@export var speed: int = 400

var move_direction: Vector2 = Vector2.ZERO
var _last_tile: Vector2i = Vector2i(-9999, -9999)
const TILE_SIZE: int = 64  # sesuai tile_size di test_map.tscn

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	movement_loop()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down"))  - int(Input.is_action_pressed("up"))
	set_velocity(move_direction.normalized() * speed)
	move_and_slide()

	# Emit player_moved setiap pindah 1 tile (bukan per frame)
	var current_tile = Vector2i(int(global_position.x) / TILE_SIZE, int(global_position.y) / TILE_SIZE)
	if current_tile != _last_tile:
		_last_tile = current_tile
		emit_signal("player_moved")
		# Update posisi ke GlobalData untuk save system
		GlobalData.player_position = global_position
