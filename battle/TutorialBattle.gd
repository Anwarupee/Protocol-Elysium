extends "res://battle/Battle.gd"

var tutorial_active: bool = false

func _ready():
	original_position = position
	edu_popup = get_node_or_null("EduPopup")
	var player_choice = "encryp_pup"
	if has_meta("player_monster"):
		player_choice = get_meta("player_monster")

	# Enemy selalu Biti supaya kontras dan edukatif
	var enemy_choice = "biti"

	battle_manager.load_monsters()

	var player_data = battle_manager.get_monster_data(player_choice)
	var enemy_data = battle_manager.get_monster_data(enemy_choice)

	if player_data.is_empty() or enemy_data.is_empty():
		push_error("Monster data not found!")
		return

	build_ui(player_data, enemy_data)
	connect_signals()
	battle_manager.start_battle(player_choice, enemy_choice)
	await play_intro_animation()
	await start_tutorial_flow()

func start_tutorial_flow():
	tutorial_active = true
	set_buttons_disabled(true)
	await show_tutorial_dialog("Selamat datang di Protocol: Elysium!\nGame ini mengajarkan cybersecurity lewat battle.")
	await show_tutorial_dialog("Sentinel kamu mewakili alat PERTAHANAN siber.\nLawanmu adalah ancaman siber nyata!")
	await show_tutorial_dialog("Coba gunakan salah satu move di bawah.\nPerhatikan EDU-LOG untuk belajar konsepnya!")
	set_buttons_disabled(false)
	tutorial_active = false

func show_tutorial_dialog(text: String) -> void:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = Vector2(1152, 648)
	add_child(overlay)

	var panel = ColorRect.new()
	panel.color = Color(0.08, 0.1, 0.28)
	panel.size = Vector2(700, 160)
	panel.position = Vector2(226, 244)
	overlay.add_child(panel)

	var border = ColorRect.new()
	border.color = Color(0.4, 0.9, 1)
	border.size = Vector2(700, 3)
	border.position = Vector2(0, 0)
	panel.add_child(border)

	var tag = Label.new()
	tag.text = "[ ELYSIUM INTEL ]"
	tag.position = Vector2(20, 10)
	tag.add_theme_font_size_override("font_size", 12)
	tag.add_theme_color_override("font_color", Color(0.4, 0.9, 1))
	panel.add_child(tag)

	var msg = Label.new()
	msg.text = text
	msg.position = Vector2(20, 34)
	msg.size = Vector2(660, 80)
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD
	msg.add_theme_font_size_override("font_size", 15)
	msg.add_theme_color_override("font_color", Color(0.9, 0.95, 1))
	panel.add_child(msg)

	var btn = Button.new()
	btn.text = "Mengerti  ▶"
	btn.position = Vector2(530, 118)
	btn.size = Vector2(150, 36)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.4, 0.2)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(btn)

	overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.2)
	await tween.finished

	# Tunggu tombol diklik dengan await signal
	await btn.pressed

	var tween2 = create_tween()
	tween2.tween_property(overlay, "modulate:a", 0.0, 0.15)
	await tween2.finished
	overlay.queue_free()

func on_battle_ended(player_won: bool):
	battle_active = false
	set_buttons_disabled(true)
	var loser_name = "player_sprite" if not player_won else "enemy_sprite"
	var loser = find_child(loser_name, true, false)
	if loser:
		spawn_hit_particles(loser.position, Color(1, 0.5, 0.2), 20)
		var death_tween = create_tween()
		death_tween.set_parallel(true)
		death_tween.tween_property(loser, "modulate:a", 0.0, 0.8)
		death_tween.tween_property(loser, "position", loser.position + Vector2(0, 30), 0.8)
		trigger_screen_shake(10.0)

	await show_tutorial_dialog("Tutorial selesai! Sekarang kamu siap battle sungguhan.\nGood luck, defender!")
	await get_tree().create_timer(1.0).timeout

	var selection = load("res://menus/selection/SelectionScreen.tscn").instantiate()
	get_tree().root.add_child(selection)
	get_tree().current_scene = selection
	queue_free()
