extends Node2D

const DEBUG_FILE = "battle.gd v2"

@onready var battle_manager = $BattleManager
var edu_popup = null  # Di-assign di _ready() setelah scene siap

var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_hp_label: Label
var player_name_label: Label
var enemy_name_label: Label
var battle_log_label: Label
var move_buttons: Array = []
var battle_active: bool = true
var player_monster_moves: Array = []
var edu_scroll: ScrollContainer
var edu_vbox: VBoxContainer
var hit_particles: Array = []
var screen_shake_intensity: float = 0.0
var original_position: Vector2

func _ready():
	print("script file: ", DEBUG_FILE)
	original_position = position
	edu_popup = get_node_or_null("EduPopup")
	print("Battle _ready called")
	var player_choice = "encryp_pup"
	if has_meta("player_monster"):
		player_choice = get_meta("player_monster")

	var all_monsters = [
		"encryp_pup", "ping_go", "biti", "senti_shell", "octo_core", "chamele_auth",
		"vaultex", "cipher_ray", "routerex", "latencia", "ransom_rex", "worm_ling",
		"patchwork", "bastion", "daemon_x", "bios_wraith", "vish_ara", "bait_eel",
		"hash_hound", "key_lynx", "signal_snail", "warp_wolf", "login_leech",
		"trojan_taurus", "brick_bear", "gate_gorilla", "phish_falcon", "scam_serpent",
		"sentry_stinger", "radar_rhino"
	]
	all_monsters.erase(player_choice)
	var enemy_choice = all_monsters[randi() % all_monsters.size()]

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

func _process(_delta):
	if screen_shake_intensity > 0:
		screen_shake_intensity = lerp(screen_shake_intensity, 0.0, 0.2)
		position = original_position + Vector2(
			randf_range(-screen_shake_intensity, screen_shake_intensity),
			randf_range(-screen_shake_intensity, screen_shake_intensity)
		)
		if screen_shake_intensity < 0.5:
			position = original_position
			screen_shake_intensity = 0.0


func trigger_screen_shake(intensity: float):
	screen_shake_intensity = intensity

func spawn_hit_particles(pos: Vector2, color: Color, count: int = 12):
	for i in count:
		var particle = ColorRect.new()
		var sz = randf_range(3, 8)
		particle.size = Vector2(sz, sz)
		particle.color = Color(color.r, color.g, color.b, 0.9)
		particle.position = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		add_child(particle)
		var vel = Vector2(randf_range(-120, 120), randf_range(-150, -30))
		var lifetime = randf_range(0.3, 0.7)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", particle.position + vel * lifetime, lifetime)
		tween.tween_property(particle, "modulate:a", 0.0, lifetime)
		tween.tween_property(particle, "size", Vector2(0, 0), lifetime * 0.8)
		var t = lifetime
		get_tree().create_timer(t).timeout.connect(func(): 
			if is_instance_valid(particle):
				particle.queue_free())

func spawn_slash_effect(pos: Vector2, color: Color, is_player: bool):
	for i in 3:
		var slash = ColorRect.new()
		slash.color = Color(color.r, color.g, color.b, 0.8)
		var dir = 1 if is_player else -1
		slash.size = Vector2(60 + i * 15, 4 - i)
		slash.rotation = deg_to_rad(-30 + i * 20)
		slash.position = pos + Vector2(dir * (i * 10 - 10), -10 + i * 15)
		add_child(slash)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(slash, "modulate:a", 0.0, 0.25)
		tween.tween_property(slash, "position", slash.position + Vector2(dir * 40, -20), 0.25)
		get_tree().create_timer(0.3).timeout.connect(func(): 
			if is_instance_valid(slash):
				slash.queue_free())

func spawn_impact_flash(pos: Vector2, color: Color):
	var flash = ColorRect.new()
	flash.color = Color(color.r, color.g, color.b, 0.6)
	flash.size = Vector2(80, 80)
	flash.position = pos - Vector2(40, 40)
	add_child(flash)
	var tween = create_tween()
	tween.tween_property(flash, "size", Vector2(160, 160), 0.1)
	tween.tween_property(flash, "modulate:a", 0.0, 0.15)
	get_tree().create_timer(0.3).timeout.connect(func(): 
		if is_instance_valid(flash):
			flash.queue_free())

func animate_attack(is_player: bool):
	var sprite_name = "player_sprite" if is_player else "enemy_sprite"
	var target_name = "enemy_sprite" if is_player else "player_sprite"
	var sprite = find_child(sprite_name, true, false)
	var target = find_child(target_name, true, false)
	if sprite == null or target == null:
		return
	var original_pos = sprite.position
	var direction = Vector2(120, -20) if is_player else Vector2(-120, 20)
	var target_pos = target.position
	var tween = create_tween()
	tween.tween_property(sprite, "position", original_pos - direction * 0.3, 0.1)
	await tween.finished
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(sprite, "position", original_pos + direction, 0.12).set_trans(Tween.TRANS_EXPO)
	await tween2.finished
	spawn_slash_effect(target_pos, sprite.get_child(0).color if sprite.get_child_count() > 0 else Color.WHITE, is_player)
	spawn_impact_flash(target_pos, Color.WHITE)
	trigger_screen_shake(6.0)
	var flash_tween = create_tween()
	flash_tween.tween_property(target, "modulate", Color(2, 0.3, 0.3), 0.06)
	flash_tween.tween_property(target, "modulate", Color(1, 1, 1), 0.06)
	flash_tween.tween_property(target, "modulate", Color(2, 0.3, 0.3), 0.06)
	flash_tween.tween_property(target, "modulate", Color(1, 1, 1), 0.08)
	var target_orig = target.position
	var shake_tween = create_tween()
	shake_tween.tween_property(target, "position", target_orig + Vector2(8, -4), 0.05)
	shake_tween.tween_property(target, "position", target_orig + Vector2(-8, 4), 0.05)
	shake_tween.tween_property(target, "position", target_orig + Vector2(5, -2), 0.04)
	shake_tween.tween_property(target, "position", target_orig, 0.04)
	spawn_hit_particles(target_pos, Color(1, 0.4, 0.4))
	await get_tree().create_timer(0.15).timeout
	var tween3 = create_tween()
	tween3.tween_property(sprite, "position", original_pos, 0.2).set_trans(Tween.TRANS_BACK)

func play_intro_animation():
	battle_active = false
	set_buttons_disabled(true)
	var player_sprite = get_node_or_null("player_sprite")
	var enemy_sprite = get_node_or_null("enemy_sprite")
	if player_sprite == null or enemy_sprite == null:
		battle_active = true
		set_buttons_disabled(false)
		return
	var player_original_pos = player_sprite.position
	var enemy_original_pos = enemy_sprite.position
	player_sprite.position = Vector2(-250, player_original_pos.y)
	enemy_sprite.position = Vector2(1400, enemy_original_pos.y)
	player_sprite.modulate.a = 0.0
	enemy_sprite.modulate.a = 0.0
	battle_log_label.text = ""
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(player_sprite, "modulate:a", 1.0, 0.3)
	fade_tween.tween_property(enemy_sprite, "modulate:a", 1.0, 0.3)
	await fade_tween.finished
	battle_log_label.text = "A wild " + enemy_sprite.get_meta("monster_name", "Enemy") + " appeared!"
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_sprite, "position", player_original_pos, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(enemy_sprite, "position", enemy_original_pos, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	await tween.finished
	trigger_screen_shake(4.0)
	spawn_hit_particles(player_sprite.position, get_type_color("Data"), 8)
	spawn_hit_particles(enemy_sprite.position, Color.WHITE, 8)
	await get_tree().create_timer(0.5).timeout
	var vs_label = create_label("⚔ VS ⚔", Vector2(0, 260), 36, Color(1, 0.9, 0.2))
	vs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs_label.custom_minimum_size = Vector2(1152, 50)
	vs_label.modulate.a = 0.0
	add_child(vs_label)
	var vs_tween = create_tween()
	vs_tween.tween_property(vs_label, "modulate:a", 1.0, 0.2)
	vs_tween.tween_property(vs_label, "modulate:a", 0.0, 0.5)
	await vs_tween.finished
	vs_label.queue_free()
	battle_log_label.text = "Battle Start!"
	battle_active = true
	set_buttons_disabled(false)

# ── BUILD UI ──

func build_ui(player_data: Dictionary, enemy_data: Dictionary):
	var sky = ColorRect.new()
	sky.color = Color(0.08, 0.08, 0.25)
	sky.size = Vector2(1152, 648)
	add_child(sky)
	var far_bg = ColorRect.new()
	far_bg.color = Color(0.12, 0.15, 0.35)
	far_bg.size = Vector2(1152, 320)
	add_child(far_bg)
	var horizon = ColorRect.new()
	horizon.color = Color(0.2, 0.3, 0.6, 0.3)
	horizon.size = Vector2(1152, 40)
	horizon.position = Vector2(0, 290)
	add_child(horizon)
	var near_bg = ColorRect.new()
	near_bg.color = Color(0.05, 0.06, 0.18)
	near_bg.size = Vector2(1152, 340)
	near_bg.position = Vector2(0, 310)
	add_child(near_bg)
	for i in range(0, 1152, 120):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.02)
		line.size = Vector2(1, 300)
		line.position = Vector2(i, 0)
		add_child(line)
	for i in range(0, 1152, 80):
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.03)
		line.size = Vector2(1, 340)
		line.position = Vector2(i, 310)
		add_child(line)
	var ep = ColorRect.new(); ep.color = Color(0.18, 0.22, 0.45)
	ep.size = Vector2(220, 18); ep.position = Vector2(690, 262); add_child(ep)
	var eps = ColorRect.new(); eps.color = Color(0,0,0,0.3)
	eps.size = Vector2(200, 8); eps.position = Vector2(700, 274); add_child(eps)
	var epp = ColorRect.new(); epp.color = Color(0.4, 0.5, 0.9, 0.3)
	epp.size = Vector2(220, 3); epp.position = Vector2(690, 258); add_child(epp)
	var pp = ColorRect.new(); pp.color = Color(0.12, 0.16, 0.35)
	pp.size = Vector2(280, 22); pp.position = Vector2(130, 342); add_child(pp)
	var pps = ColorRect.new(); pps.color = Color(0,0,0,0.4)
	pps.size = Vector2(240, 10); pps.position = Vector2(150, 358); add_child(pps)
	var ppp = ColorRect.new(); ppp.color = Color(0.3, 0.4, 0.8, 0.3)
	ppp.size = Vector2(260, 4); ppp.position = Vector2(140, 338); add_child(ppp)
	var divider = ColorRect.new()
	divider.color = Color(0.3, 0.4, 0.7, 0.5)
	divider.size = Vector2(1152, 2); divider.position = Vector2(0, 308); add_child(divider)

	var enemy_color = get_type_color(enemy_data["type"])
	add_child(create_panel_styled(Vector2(620, 30), Vector2(460, 140), enemy_color))
	enemy_name_label = create_label(enemy_data["name"], Vector2(640, 45), 22, enemy_color)
	add_child(enemy_name_label)
	var etb = ColorRect.new(); etb.color = Color(enemy_color.r, enemy_color.g, enemy_color.b, 0.2)
	etb.size = Vector2(100, 20); etb.position = Vector2(640, 72); add_child(etb)
	add_child(create_label("  " + enemy_data["type"], Vector2(640, 72), 12, enemy_color))
	enemy_hp_bar = create_hp_bar(Vector2(640, 105), Color(1, 0.3, 0.3))
	add_child(enemy_hp_bar)
	enemy_hp_label = create_label("HP: " + str(enemy_data["hp"]) + "/" + str(enemy_data["hp"]), Vector2(640, 128), 12, Color(0.9,0.9,0.9))
	add_child(enemy_hp_label)

	var player_color = get_type_color(player_data["type"])
	add_child(create_panel_styled(Vector2(50, 320), Vector2(460, 140), player_color))
	player_name_label = create_label(player_data["name"], Vector2(70, 335), 22, player_color)
	add_child(player_name_label)
	var advantage_map = {
		"Crypto": "⚡ Kuat vs Malware  |  ⚠ Lemah vs Network",
		"Network": "⚡ Kuat vs Crypto  |  ⚠ Lemah vs Firewall",
		"Malware": "⚡ Kuat vs Firewall  |  ⚠ Lemah vs Crypto",
		"Monitor": "⚡ Kuat vs Social Engineering  |  ⚠ Lemah vs Malware",
		"Social Engineering": "⚡ Kuat vs Crypto  |  ⚠ Lemah vs Monitor",
		"Firewall": "⚡ Kuat vs Network  |  ⚠ Lemah vs Malware",
	}
	add_child(create_label(advantage_map[player_data["type"]], Vector2(70, 440), 10, Color(0.6, 0.6, 0.8)))
	var ptb = ColorRect.new(); ptb.color = Color(player_color.r, player_color.g, player_color.b, 0.2)
	ptb.size = Vector2(100, 20); ptb.position = Vector2(70, 362); add_child(ptb)
	add_child(create_label("  " + player_data["type"], Vector2(70, 362), 12, player_color))
	player_hp_bar = create_hp_bar(Vector2(70, 395), Color(0.2, 0.8, 0.4))
	add_child(player_hp_bar)
	player_hp_label = create_label("HP: " + str(player_data["hp"]) + "/" + str(player_data["hp"]), Vector2(70, 418), 12, Color(0.9,0.9,0.9))
	add_child(player_hp_label)

	add_child(create_panel_styled(Vector2(50, 472), Vector2(610, 55), Color(0.5, 0.5, 0.8)))
	battle_log_label = create_label("Battle Start!", Vector2(65, 482), 15, Color(1, 1, 0.7))
	battle_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	battle_log_label.custom_minimum_size = Vector2(585, 40)
	add_child(battle_log_label)

	var edu_panel = create_panel_styled(Vector2(50, 530), Vector2(610, 110), Color(0.3, 0.5, 0.3))
	add_child(edu_panel)
	add_child(create_label("EDU-LOG", Vector2(65, 538), 12, Color(0.5, 1, 0.5)))
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(55, 555)
	scroll.size = Vector2(598, 80)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	edu_scroll = scroll
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(580, 0)
	scroll.add_child(vbox)
	edu_vbox = vbox

	var moves = player_data["moves"]
	var btn_colors = [Color(0.15, 0.35, 0.75), Color(0.75, 0.35, 0.05), Color(0.15, 0.6, 0.25), Color(0.5, 0.15, 0.6)]
	var btn_positions = [Vector2(690, 478), Vector2(910, 478), Vector2(690, 535), Vector2(910, 535)]
	for i in moves.size():
		player_monster_moves.append(moves[i]["name"])
		var btn = create_move_button(moves[i]["name"], btn_positions[i], btn_colors[i], i)
		add_child(btn)
		move_buttons.append(btn)

	var enemy_sprite_node = SentinelSprites.draw(self, enemy_data["id"], Vector2(800, 240), enemy_color, 85)
	enemy_sprite_node.name = "enemy_sprite"
	enemy_sprite_node.set_meta("monster_name", enemy_data["name"])
	var player_sprite_node = SentinelSprites.draw(self, player_data["id"], Vector2(270, 310), player_color, 100)
	player_sprite_node.name = "player_sprite"
	player_sprite_node.set_meta("monster_name", player_data["name"])

# ── HELPER FUNCTIONS ──

func get_type_color(type: String) -> Color:
	match type:
		"Malware":            return Color(1.0, 0.3, 0.3)
		"Firewall":           return Color(0.2, 0.5, 1.0)
		"Network":            return Color(1.0, 0.9, 0.2)
		"Crypto":             return Color(0.3, 0.9, 1.0)
		"Social Engineering": return Color(1.0, 0.6, 0.1)
		"Monitor":            return Color(0.2, 0.9, 0.4)
	return Color(1, 1, 1)

func create_panel_styled(pos: Vector2, size: Vector2, accent: Color) -> Node2D:
	var container = Node2D.new()
	container.position = pos
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.22, 0.6)
	bg.size = size
	container.add_child(bg)
	var border = ColorRect.new()
	border.color = accent
	border.size = Vector2(size.x, 3)
	container.add_child(border)
	var side = ColorRect.new()
	side.color = Color(accent.r, accent.g, accent.b, 0.4)
	side.size = Vector2(3, size.y)
	container.add_child(side)
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
	bar.min_value = 0; bar.max_value = 100; bar.value = 100
	bar.show_percentage = false
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4; style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4; style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", style)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2)
	bar.add_theme_stylebox_override("background", bg_style)
	return bar

func create_move_button(text: String, pos: Vector2, color: Color, index: int) -> Button:
	var btn = Button.new()
	btn.text = text; btn.position = pos; btn.size = Vector2(205, 48)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8; style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8; style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.3)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(func(): on_move_pressed(index))
	return btn

func connect_signals():
	battle_manager.battle_log.connect(on_battle_log)
	battle_manager.edu_log.connect(on_edu_log)
	battle_manager.edu_popup.connect(on_edu_popup)   # ← BARU
	battle_manager.battle_ended.connect(on_battle_ended)
	battle_manager.hp_updated.connect(on_hp_updated)
	battle_manager.enemy_attacking.connect(func(): animate_attack(false))
	battle_manager.cooldown_updated.connect(on_cooldown_updated)
	print("Signals connected, battle_manager: ", battle_manager)

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
	entry.custom_minimum_size = Vector2(575, 0)
	entry.add_theme_font_size_override("font_size", 11)
	entry.add_theme_color_override("font_color", Color(0.6, 1, 0.6))
	edu_vbox.add_child(entry)
	var sep = ColorRect.new()
	sep.color = Color(0.3, 0.5, 0.3, 0.4)
	sep.custom_minimum_size = Vector2(575, 1)
	edu_vbox.add_child(sep)
	await get_tree().process_frame
	edu_scroll.scroll_vertical = int(edu_scroll.get_v_scroll_bar().max_value)

# ── EDU POPUP HANDLER ──
func on_edu_popup(move_name: String, edu_text: String, domain: String):
	if edu_popup:
		edu_popup.show_popup(move_name, edu_text, domain)

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
			btn.text = player_monster_moves[i] + ("\n[COOLDOWN]" if cooldowns[i] else "")

func on_battle_ended(player_won: bool):
	battle_active = false
	set_buttons_disabled(true)
	print("on_battle_ended called, moves: ", battle_manager.get_moves_used().size())
	
	var loser_name = "player_sprite" if not player_won else "enemy_sprite"
	var loser = find_child(loser_name, true, false)
	if loser:
		spawn_hit_particles(loser.position, Color(1, 0.5, 0.2), 20)
		var death_tween = create_tween()
		death_tween.set_parallel(true)
		death_tween.tween_property(loser, "modulate:a", 0.0, 0.8)
		death_tween.tween_property(loser, "position", loser.position + Vector2(0, 30), 0.8)
		trigger_screen_shake(10.0)
	await get_tree().create_timer(2.5).timeout
	var result_scene = load("res://menus/result/ResultScreen.tscn").instantiate()
	result_scene.set_meta("player_won", player_won)
	result_scene.set_meta("player_monster_name", player_name_label.text)
	result_scene.set_meta("enemy_monster_name", enemy_name_label.text)
	result_scene.set_meta("moves_used", battle_manager.get_moves_used())
	print("set_meta moves_used: ", battle_manager.get_moves_used().size())
	get_tree().root.add_child(result_scene)
	get_tree().current_scene = result_scene
	queue_free()

func set_buttons_disabled(disabled: bool):
	for btn in move_buttons:
		btn.disabled = disabled
		
func enable_move_button(index: int, enabled: bool):
	if index < move_buttons.size():
		move_buttons[index].disabled = not enabled

func show_tutorial_message(text: String):
	battle_log_label.text = text
