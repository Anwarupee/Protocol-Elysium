extends Node2D

var particles: Array = []
var time: float = 0.0

func _ready():
	if GlobalData.is_first_time:
		GlobalData.mark_played()
	build_ui()
	spawn_particles()
	animate_title()

func _process(delta):
	time += delta
	update_particles(delta)

func build_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12)
	bg.size = Vector2(1920, 1080)
	add_child(bg)

	for i in range(0, 1920, 100):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1, 1080)
		line.position = Vector2(i, 0)
		add_child(line)
	for i in range(0, 1080, 100):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1920, 1)
		line.position = Vector2(0, i)
		add_child(line)

	for i in range(0, 1080, 7):
		var scan = ColorRect.new()
		scan.color = Color(0, 0, 0, 0.03)
		scan.size = Vector2(1920, 3)
		scan.position = Vector2(0, i)
		add_child(scan)

	# ── LOGO (centered) ──
	var logo_outer = ColorRect.new()
	logo_outer.color = Color(0.1, 0.2, 0.5)
	logo_outer.size = Vector2(217, 217)
	logo_outer.position = Vector2(852, 92)
	add_child(logo_outer)

	var logo_border_top = ColorRect.new()
	logo_border_top.color = Color(0.4, 0.9, 1)
	logo_border_top.size = Vector2(217, 5)
	logo_border_top.position = Vector2(852, 92)
	add_child(logo_border_top)

	var logo_border_left = ColorRect.new()
	logo_border_left.color = Color(0.4, 0.9, 1, 0.5)
	logo_border_left.size = Vector2(5, 217)
	logo_border_left.position = Vector2(852, 92)
	add_child(logo_border_left)

	var logo_inner = ColorRect.new()
	logo_inner.color = Color(0.3, 0.8, 1)
	logo_inner.size = Vector2(133, 133)
	logo_inner.position = Vector2(894, 133)
	logo_inner.name = "logo_inner"
	add_child(logo_inner)

	var logo_shine = ColorRect.new()
	logo_shine.color = Color(1, 1, 1, 0.25)
	logo_shine.size = Vector2(47, 20)
	logo_shine.position = Vector2(902, 142)
	add_child(logo_shine)

	var logo_text = create_label("PE", Vector2(913, 147), 47, Color(0.05, 0.1, 0.3))
	add_child(logo_text)

	# ── TITLE ──
	var title_shadow = create_label("Protocol: Elysium", Vector2(3, 337), 90, Color(0.1, 0.3, 0.6, 0.5))
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.custom_minimum_size = Vector2(1920, 117)
	add_child(title_shadow)

	var title = create_label("Protocol: Elysium", Vector2(0, 333), 90, Color(0.4, 0.9, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1920, 117)
	title.name = "title_label"
	add_child(title)

	var subtitle = create_label("C Y B E R S E C U R I T Y   B A T T L E   S I M U L A T O R", Vector2(0, 440), 22, Color(0.4, 0.5, 0.7))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1920, 40)
	add_child(subtitle)

	var line_left = ColorRect.new()
	line_left.color = Color(0.3, 0.4, 0.7, 0.6)
	line_left.size = Vector2(300, 2)
	line_left.position = Vector2(300, 460)
	add_child(line_left)
	var line_right = ColorRect.new()
	line_right.color = Color(0.3, 0.4, 0.7, 0.6)
	line_right.size = Vector2(300, 2)
	line_right.position = Vector2(1287, 460)
	add_child(line_right)

	var div = ColorRect.new()
	div.color = Color(0.4, 0.6, 1, 0.5)
	div.size = Vector2(667, 2)
	div.position = Vector2(627, 505)
	add_child(div)

	# ── MENU BUTTONS (centered) ──
	var btn_x = 710
	var play_btn = create_menu_button("▶   PLAY", Vector2(btn_x, 530), Color(0.08, 0.4, 0.15))
	play_btn.pressed.connect(go_to_selection)
	add_child(play_btn)

	var dex_btn = create_menu_button("◈   The Archive", Vector2(btn_x, 630), Color(0.08, 0.25, 0.5))
	dex_btn.pressed.connect(go_to_thearchive)
	add_child(dex_btn)

	var inv_btn = create_menu_button("🎒  Inventory", Vector2(btn_x, 730), Color(0.2, 0.2, 0.45))
	inv_btn.pressed.connect(go_to_inventory)
	add_child(inv_btn)

	var quit_btn = create_menu_button("✕   QUIT", Vector2(btn_x, 830), Color(0.35, 0.08, 0.08))
	quit_btn.pressed.connect(quit_game)
	add_child(quit_btn)

	# ── RESET SAVE (pojok kiri bawah) ──
	var reset_btn = Button.new()
	reset_btn.text = "↺ RESET SAVE"
	reset_btn.position = Vector2(30, 1030)
	reset_btn.size = Vector2(200, 35)
	reset_btn.add_theme_font_size_override("font_size", 14)
	reset_btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
	reset_btn.flat = true
	reset_btn.pressed.connect(func():
		for path in ["user://savedata_v2.cfg", "user://savedata.cfg"]:
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		GlobalData.is_first_time = true
		GlobalData.active_team = []
		GlobalData.caught_sentinels = []
		GlobalData.items = {}
		GlobalData.battles_won = 0
		print("Save reset!")
	)
	add_child(reset_btn)

	# ── ITEM COUNT INDICATOR (pojok kanan bawah) ──
	var item_info = create_label(
		"💊 ×" + str(GlobalData.get_item_count("heal_potion")) +
		"   🔑 ×" + str(GlobalData.get_item_count("capture_key")),
		Vector2(1600, 1038), 20, Color(0.5, 0.7, 0.5)
	)
	add_child(item_info)

	# ── BOTTOM BAR ──
	var bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.06, 0.06, 0.18)
	bottom_bar.size = Vector2(1920, 45)
	bottom_bar.position = Vector2(0, 1035)
	add_child(bottom_bar)
	var bottom_border = ColorRect.new()
	bottom_border.color = Color(0.2, 0.3, 0.6, 0.5)
	bottom_border.size = Vector2(1920, 2)
	bottom_border.position = Vector2(0, 1035)
	add_child(bottom_border)
	var version = create_label("v0.3  —  Protocol: Elysium  —  Made with Godot", Vector2(0, 1046), 17, Color(0.3, 0.3, 0.5))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.custom_minimum_size = Vector2(1920, 30)
	add_child(version)

func spawn_particles():
	for i in 55:
		var p = ColorRect.new()
		var size = randf_range(2.0, 6.0)
		p.size = Vector2(size, size)
		p.position = Vector2(randf_range(0, 1920), randf_range(0, 1080))
		var brightness = randf_range(0.3, 0.8)
		p.color = Color(brightness * randf_range(0.3, 0.6), brightness * randf_range(0.5, 0.9), brightness, randf_range(0.3, 0.7))
		p.name = "particle_" + str(i)
		add_child(p)
		particles.append({
			"node": p,
			"vel": Vector2(randf_range(-15, 15), randf_range(-25, -8)),
			"base_alpha": randf_range(0.3, 0.7),
			"phase": randf_range(0, TAU)
		})

func update_particles(delta: float):
	for p in particles:
		p["node"].position += p["vel"] * delta
		if p["node"].position.y < -10:
			p["node"].position.y = 1090
			p["node"].position.x = randf_range(0, 1920)
		if p["node"].position.x < -10:
			p["node"].position.x = 1930
		if p["node"].position.x > 1930:
			p["node"].position.x = -10
		var alpha = p["base_alpha"] + sin(time * 2.0 + p["phase"]) * 0.2
		p["node"].color.a = clamp(alpha, 0.1, 0.9)
	var logo = get_node_or_null("logo_inner")
	if logo:
		var pulse = 0.85 + sin(time * 1.5) * 0.08
		logo.scale = Vector2(pulse, pulse)
		logo.position = Vector2(894 + (1 - pulse) * 67, 133 + (1 - pulse) * 67)

func animate_title():
	var title = get_node_or_null("title_label")
	if title == null:
		return
	title.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(title, "position:y", 333, 1.5).set_trans(Tween.TRANS_BACK).from(300)

func create_menu_button(text: String, pos: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(500, 83)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_color = Color(0.4, 0.6, 1, 0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	btn.add_theme_stylebox_override("normal", style)
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	hover_style.border_color = Color(0.5, 0.8, 1, 0.8)
	hover_style.border_width_left = 3
	hover_style.border_width_right = 3
	hover_style.border_width_top = 3
	hover_style.border_width_bottom = 3
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_font_size_override("font_size", 27)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func go_to_selection():
	# PLAY selalu ke SlotSelectScreen
	# SlotSelectScreen yang handle load/new game dan routing setelahnya
	SceneManager.goto_menu("res://menus/selection/SelectionScreen.tscn")

func go_to_thearchive():
	SceneManager.goto_menu("res://menus/archive/TheArchive.tscn")

func go_to_inventory():
	GlobalData.inventory_return_path = "res://menus/main_menu/MainMenu.tscn"
	SceneManager.goto_menu("res://menus/inventory/InventoryMenu.tscn")

func quit_game():
	get_tree().quit()
