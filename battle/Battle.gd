extends Node2D

@onready var battle_manager = $BattleManager

var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_hp_label: Label
var player_name_label: Label
var enemy_name_label: Label
var battle_log_label: Label
var edu_log_label: Label
var move_buttons: Array = []
var battle_active: bool = true
var player_monster_moves: Array = []
var edu_scroll: ScrollContainer
var edu_vbox: VBoxContainer

func _ready():
	var player_choice = "encryp_pup"
	if has_meta("player_monster"):
		player_choice = get_meta("player_monster")
	
	var all_monsters = [
	"encryp_pup", "ping_go", "biti", "senti_shell", "octo_core", "chamele_auth",
	"vaultex", "cipher_ray", "routerex", "latencia", "ransom_rex", "worm_ling",
	"patchwork", "bastion", "daemon_x", "bios_wraith", "vish_ara", "bait_eel"
]
	all_monsters.erase(player_choice)
	var enemy_choice = all_monsters[randi() % all_monsters.size()]
	
	battle_manager.load_monsters()
	
	var player_data = battle_manager.get_monster_data(player_choice)
	var enemy_data = battle_manager.get_monster_data(enemy_choice)
	print("Player choice: ", player_choice)
	print("Enemy choice: ", enemy_choice)
	print("Player data: ", player_data)
	print("Enemy data: ", enemy_data)
	if player_data.is_empty() or enemy_data.is_empty():
		push_error("Monster data not found!")
		return
	
	build_ui(player_data, enemy_data)
	connect_signals()
	battle_manager.start_battle(player_choice, enemy_choice)
	await play_intro_animation()
	
	print("Player data: ", player_data)
	print("Enemy data: ", enemy_data)

func play_intro_animation():
	battle_active = false
	set_buttons_disabled(true)

	var player_sprite = get_node("player_sprite")
	var enemy_sprite = get_node("enemy_sprite")

	if player_sprite == null or enemy_sprite == null:
		battle_active = true
		set_buttons_disabled(false)
		return

	# Simpan posisi asli
	var player_original_pos = player_sprite.position
	var enemy_original_pos = enemy_sprite.position

	# Taruh di luar layar
	player_sprite.position = Vector2(-200, player_original_pos.y)
	enemy_sprite.position = Vector2(1350, enemy_original_pos.y)

	# Sembunyikan move buttons dan log dulu
	battle_log_label.text = ""

	# Intro text
	battle_log_label.text = "A wild " + enemy_sprite.get_meta("monster_name", "Enemy") + " appeared!"

	# Animasi masuk — tween player
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_sprite, "position", player_original_pos, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(enemy_sprite, "position", enemy_original_pos, 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await tween.finished
	await get_tree().create_timer(0.5).timeout

	# VS flash
	battle_log_label.text = player_sprite.get_meta("monster_name", "Player") + "⚔" + enemy_sprite.get_meta("monster_name", "Enemy")
	await get_tree().create_timer(0.8).timeout

	battle_log_label.text = "Battle Start!"
	battle_active = true
	set_buttons_disabled(false)

func create_panel_styled(pos: Vector2, size: Vector2, accent: Color) -> Node2D:
	var container = Node2D.new()
	container.position = pos

	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.22, 0.95)
	bg.size = size
	container.add_child(bg)

	# Accent border top
	var border = ColorRect.new()
	border.color = accent
	border.size = Vector2(size.x, 3)
	border.position = Vector2(0, 0)
	container.add_child(border)

	# Subtle side border
	var side = ColorRect.new()
	side.color = Color(accent.r, accent.g, accent.b, 0.4)
	side.size = Vector2(3, size.y)
	side.position = Vector2(0, 0)
	container.add_child(side)

	return container

func draw_monster_sprite(pos: Vector2, color: Color, size: float, is_player: bool, monster_name: String = ""):
	# Outer glow ring
	var ring = ColorRect.new()
	ring.color = Color(color.r, color.g, color.b, 0.08)
	ring.size = Vector2(size + 40, size + 40)
	ring.position = pos - Vector2((size+40)/2, (size+40)/2)
	add_child(ring)

	# Mid glow
	var mid = ColorRect.new()
	mid.color = Color(color.r, color.g, color.b, 0.15)
	mid.size = Vector2(size + 20, size + 20)
	mid.position = pos - Vector2((size+20)/2, (size+20)/2)
	add_child(mid)

	# Main body
	var body = ColorRect.new()
	body.color = color
	body.size = Vector2(size, size)
	body.position = pos - Vector2(size/2, size/2)
	body.name = "enemy_sprite" if not is_player else "player_sprite"
	if monster_name != "":
		body.set_meta("monster_name", monster_name)
	add_child(body)

	# Shine effect
	var shine = ColorRect.new()
	shine.color = Color(1, 1, 1, 0.15)
	shine.size = Vector2(size * 0.4, size * 0.2)
	shine.position = pos - Vector2(size/2, size/2) + Vector2(5, 5)
	add_child(shine)

func build_ui(player_data: Dictionary, enemy_data: Dictionary):
	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.15)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	# Grid lines
	for i in range(0, 1152, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.015)
		line.size = Vector2(1, 648)
		line.position = Vector2(i, 0)
		add_child(line)
	for i in range(0, 648, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.015)
		line.size = Vector2(1152, 1)
		line.position = Vector2(0, i)
		add_child(line)

	# Arena divider
	var divider = ColorRect.new()
	divider.color = Color(0.3, 0.3, 0.6, 0.4)
	divider.size = Vector2(1152, 2)
	divider.position = Vector2(0, 300)
	add_child(divider)

	# Arena glow top (enemy side)
	var top_glow = ColorRect.new()
	top_glow.color = Color(1, 0.2, 0.2, 0.04)
	top_glow.size = Vector2(1152, 300)
	top_glow.position = Vector2(0, 0)
	add_child(top_glow)

	# Arena glow bottom (player side)
	var bot_glow = ColorRect.new()
	bot_glow.color = Color(0.1, 0.3, 0.6, 0.04)
	bot_glow.size = Vector2(1152, 298)
	bot_glow.position = Vector2(0, 302)
	add_child(bot_glow)

	# ── ENEMY PANEL ──
	var enemy_color = get_type_color(enemy_data["type"])
	add_child(create_panel_styled(Vector2(620, 30), Vector2(460, 140), enemy_color))

	enemy_name_label = create_label(enemy_data["name"], Vector2(640, 45), 22, enemy_color)
	add_child(enemy_name_label)

	var enemy_type_bg = ColorRect.new()
	enemy_type_bg.color = Color(enemy_color.r, enemy_color.g, enemy_color.b, 0.2)
	enemy_type_bg.size = Vector2(100, 20)
	enemy_type_bg.position = Vector2(640, 72)
	add_child(enemy_type_bg)
	add_child(create_label("  " + enemy_data["type"], Vector2(640, 72), 12, enemy_color))

	enemy_hp_bar = create_hp_bar(Vector2(640, 105), Color(1, 0.3, 0.3))
	add_child(enemy_hp_bar)
	enemy_hp_label = create_label("HP: " + str(enemy_data["hp"]) + "/" + str(enemy_data["hp"]), Vector2(640, 128), 12, Color(0.9,0.9,0.9))
	add_child(enemy_hp_label)

	# ── PLAYER PANEL ──
	var player_color = get_type_color(player_data["type"])
	add_child(create_panel_styled(Vector2(50, 320), Vector2(460, 140), player_color))

	player_name_label = create_label(player_data["name"], Vector2(70, 335), 22, player_color)
	add_child(player_name_label)
	var advantage_map = {
		"Data": "⚡ Kuat vs Malware  |  ⚠ Lemah vs Connection",
		"Connection": "⚡ Kuat vs Data  |  ⚠ Lemah vs Malware",
		"Malware": "⚡ Kuat vs Connection  |  ⚠ Lemah vs Data",
		"System": "⚡ Kuat vs Data  |  ⚠ Lemah vs Social Engineering",
		"Social Engineering": "⚡ Kuat vs System  |  ⚠ Lemah vs Connection",
		"Defensive": "⚡ Kuat vs Social Engineering  |  ⚠ Lemah vs System",
	}
	add_child(create_label(
		advantage_map[player_data["type"]], 
		Vector2(70, 440), 
		10, 
		Color(0.6, 0.6, 0.8)
	))

	var player_type_bg = ColorRect.new()
	player_type_bg.color = Color(player_color.r, player_color.g, player_color.b, 0.2)
	player_type_bg.size = Vector2(100, 20)
	player_type_bg.position = Vector2(70, 362)
	add_child(player_type_bg)
	add_child(create_label("  " + player_data["type"], Vector2(70, 362), 12, player_color))

	player_hp_bar = create_hp_bar(Vector2(70, 395), Color(0.2, 0.8, 0.4))
	add_child(player_hp_bar)
	player_hp_label = create_label("HP: " + str(player_data["hp"]) + "/" + str(player_data["hp"]), Vector2(70, 418), 12, Color(0.9,0.9,0.9))
	add_child(player_hp_label)

	# ── BATTLE LOG ──
	add_child(create_panel_styled(Vector2(50, 472), Vector2(610, 110), Color(0.5, 0.5, 0.8)))
	battle_log_label = create_label("Battle Start!", Vector2(65, 482), 15, Color(1, 1, 0.7))
	battle_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	battle_log_label.custom_minimum_size = Vector2(585, 95)
	add_child(battle_log_label)

	# EDU-LOG panel dengan scroll
	var edu_panel = create_panel_styled(Vector2(50, 530), Vector2(450, 135), Color(0.3, 0.5, 0.3))
	add_child(edu_panel)

	var edu_title = create_label("EDU-LOG", Vector2(65, 538), 12, Color(0.5, 1, 0.5))
	add_child(edu_title)

	# ScrollContainer
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(55, 555)
	scroll.size = Vector2(438, 105)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	edu_scroll = scroll

	# VBox di dalam scroll
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(430, 0)
	scroll.add_child(vbox)
	edu_vbox = vbox

	# Move buttons — 2 baris, 2 kolom
	var moves = player_data["moves"]
	var btn_colors = [Color(0.15, 0.35, 0.75), Color(0.75, 0.35, 0.05), Color(0.15, 0.6, 0.25), Color(0.5, 0.15, 0.6)]
	var btn_positions = [
		Vector2(690, 478),
		Vector2(910, 478),
		Vector2(690, 535),
		Vector2(910, 535)
	]
	for i in moves.size():
		player_monster_moves.append(moves[i]["name"])
		var btn = create_move_button(moves[i]["name"], btn_positions[i], btn_colors[i], i)
		add_child(btn)
		move_buttons.append(btn)

	# ── MONSTER SPRITES ──
	draw_monster_sprite(Vector2(800, 185), enemy_color, 65, false, enemy_data["name"])
	draw_monster_sprite(Vector2(270, 295), player_color, 55, true, player_data["name"])

func get_type_color(type: String) -> Color:
	match type:
		"Data": return Color(0.4, 0.8, 1)
		"Connection": return Color(1, 0.9, 0.3)
		"Malware": return Color(1, 0.4, 0.4)
		"System": return Color(0.6, 0.3, 1)
		"Social Engineering": return Color(1, 0.7, 0.2)
		"Defensive": return Color(0.2, 0.9, 0.6)
	return Color(1, 1, 1)

func draw_monster_placeholder(pos: Vector2, color: Color, size: float):
	var glow = ColorRect.new()
	glow.color = Color(color.r, color.g, color.b, 0.2)
	glow.size = Vector2(size + 20, size + 20)
	glow.position = pos - Vector2((size+20)/2, (size+20)/2)
	add_child(glow)

	var rect = ColorRect.new()
	rect.color = color
	rect.size = Vector2(size, size)
	rect.position = pos - Vector2(size/2, size/2)
	add_child(rect)

func create_panel(pos: Vector2, size: Vector2) -> Node2D:
	var container = Node2D.new()
	container.position = pos
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.25, 0.9)
	bg.size = size
	container.add_child(bg)
	return container

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func create_hp_bar(pos: Vector2, color: Color) -> ProgressBar:
	var bar = ProgressBar.new()
	bar.position = pos
	bar.size = Vector2(380, 18)
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2)
	bar.add_theme_stylebox_override("background", bg_style)
	return bar

func create_move_button(text: String, pos: Vector2, color: Color, index: int) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(205, 48)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = color.lightened(0.3)
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(func(): on_move_pressed(index))
	return btn

func connect_signals():
	battle_manager.battle_log.connect(on_battle_log)
	battle_manager.edu_log.connect(on_edu_log)
	battle_manager.battle_ended.connect(on_battle_ended)
	battle_manager.hp_updated.connect(on_hp_updated)
	battle_manager.enemy_attacking.connect(func(): animate_attack(false))
	battle_manager.cooldown_updated.connect(on_cooldown_updated)

func on_move_pressed(index: int):
	if not battle_active:
		return
	set_buttons_disabled(true)
	animate_attack(true)
	battle_manager.player_use_move(index)

func on_battle_log(message: String):
	battle_log_label.text = message

func on_edu_log(message: String):
	var entry = Label.new()
	entry.text = "▸ " + message
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD
	entry.custom_minimum_size = Vector2(425, 0)
	entry.add_theme_font_size_override("font_size", 11)
	entry.add_theme_color_override("font_color", Color(0.6, 1, 0.6))
	edu_vbox.add_child(entry)

	# Separator tipis antar entry
	var sep = ColorRect.new()
	sep.color = Color(0.3, 0.5, 0.3, 0.4)
	sep.custom_minimum_size = Vector2(425, 1)
	edu_vbox.add_child(sep)

	# Auto scroll ke bawah
	await get_tree().process_frame
	edu_scroll.scroll_vertical = edu_scroll.get_v_scroll_bar().max_value

func on_hp_updated(p_hp: int, p_max: int, e_hp: int, e_max: int):
	player_hp_bar.value = (float(p_hp) / p_max) * 100
	player_hp_label.text = "HP: " + str(p_hp) + "/" + str(p_max)
	enemy_hp_bar.value = (float(e_hp) / e_max) * 100
	enemy_hp_label.text = "HP: " + str(e_hp) + "/" + str(e_max)

	if p_hp < p_max * 0.3:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1, 0.6, 0)
		player_hp_bar.add_theme_stylebox_override("fill", style)

	if e_hp < e_max * 0.3:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1, 0.6, 0)
		enemy_hp_bar.add_theme_stylebox_override("fill", style)

	if battle_active:
		set_buttons_disabled(false)

func on_cooldown_updated(cooldowns: Array):
	for i in move_buttons.size():
		if i < cooldowns.size():
			var btn = move_buttons[i]
			btn.disabled = cooldowns[i] or not battle_active
			if cooldowns[i]:
				btn.text = player_monster_moves[i] + "\n[COOLDOWN]"
			else:
				btn.text = player_monster_moves[i]

func on_battle_ended(player_won: bool):
	battle_active = false
	set_buttons_disabled(true)
	
	await get_tree().create_timer(2.0).timeout
	
	var result_scene = load("res://menus/result/ResultScreen.tscn").instantiate()
	result_scene.set_meta("player_won", player_won)
	result_scene.set_meta("player_monster_name", player_name_label.text)
	result_scene.set_meta("enemy_monster_name", enemy_name_label.text)
	get_tree().root.add_child(result_scene)
	get_tree().current_scene = result_scene
	queue_free()

func set_buttons_disabled(disabled: bool):
	for btn in move_buttons:
		btn.disabled = disabled

func animate_attack(is_player: bool):
	var sprite_name = "player_sprite" if is_player else "enemy_sprite"
	var target_name = "enemy_sprite" if is_player else "player_sprite"
	var sprite = find_child(sprite_name, true, false)
	var target = find_child(target_name, true, false)
	
	if sprite == null or target == null:
		return
	
	var original_pos = sprite.position
	var direction = Vector2(80, 0) if is_player else Vector2(-80, 0)
	
	# Lunge forward
	var tween = create_tween()
	tween.tween_property(sprite, "position", original_pos + direction, 0.15)
	tween.tween_property(sprite, "position", original_pos, 0.15)
	
	# Flash target
	await get_tree().create_timer(0.15).timeout
	if target:
		var flash = create_tween()
		flash.tween_property(target, "modulate", Color(2, 2, 2), 0.08)
		flash.tween_property(target, "modulate", Color(1, 1, 1), 0.08)
		flash.tween_property(target, "modulate", Color(2, 2, 2), 0.08)
		flash.tween_property(target, "modulate", Color(1, 1, 1), 0.08)
