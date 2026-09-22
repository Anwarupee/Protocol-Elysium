extends Node

# InteractionManager — Autoload
# Tidak butuh scene/child node — label dibuat programmatically

var player = null
var label: Label = null

const base_text = "[E] TO "

var active_areas = []
var can_interact = true

func _ready():
	# Buat label secara programmatic — tidak bergantung pada $Label dari scene
	label = Label.new()
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.WHITE)
	# Shadow biar terbaca di atas background apapun
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.hide()
	add_child(label)

func _get_player():
	# Lazy-fetch player — tidak bisa di @onready karena Autoload ready sebelum scene load
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	return player

func register_area(area: InteractionArea):
	if area not in active_areas:
		active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(_delta):
	var p = _get_player()
	if active_areas.size() > 0 and can_interact and p != null:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 50
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(area1, area2):
	var p = _get_player()
	if p == null:
		return false
	return p.global_position.distance_to(area1.global_position) < \
		   p.global_position.distance_to(area2.global_position)

func _input(event):
	if event.is_action_pressed("interact") and can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			await active_areas[0].interact.call()
			can_interact = true
