extends Node2D

class Particle:
	var node: ColorRect
	var vel: Vector2
	var base_alpha: float
	var phase: float

var particles: Array[Particle] = []
var time: float = 0.0

func _ready():
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

	# Grid & Scanlines
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

	var div = ColorRect.new()
	div.color = Color(0.4, 0.6, 1, 0.5)
	div.size = Vector2(667, 2)
	div.position = Vector2(627, 490)
	add_child(div)

	# ── 4 TOMBOL UTAMA DI TENGAH ──
	var btn_x = 710
	
	var play_btn = create_menu_button("▶   PLAY", Vector2(btn_x, 520), Color(0.08, 0.4, 0.15))
	play_btn.pressed.connect(go_to_selection)
	add_child(play_btn)

	var dex_btn = create_menu_button("◈   The Archive", Vector2(btn_x, 610), Color(0.08, 0.25, 0.5))
	dex_btn.pressed.connect(go_to_thearchive)
	add_child(dex_btn)

	var inv_btn = create_menu_button("🎒  Inventory", Vector2(btn_x, 700), Color(0.2, 0.2, 0.45))
	inv_btn.pressed.connect(go_to_inventory)
	add_child(inv_btn)

	var quit_btn = create_menu_button("✕   QUIT", Vector2(btn_x, 790), Color(0.35, 0.08, 0.08))
	quit_btn.pressed.connect(quit_game)
	add_child(quit_btn)

	# ── BOTTOM BAR (UTILITY) ──
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

	# ── TOMBOL RESET SAVE (KIRI BAWAH) ──
	var reset_btn = Button.new()
	reset_btn.text = "↺ RESET SAVE"
	reset_btn.position = Vector2(30, 1038)
	reset_btn.size = Vector2(160, 35)
	reset_btn.z_index = 1
	reset_btn.add_theme_font_size_override("font_size", 12)
	reset_btn.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
	reset_btn.pressed.connect(reset_save_data)
	add_child(reset_btn)

	# ── TOMBOL RESET TUTORIAL (KIRI BAWAH, DI SEBELAH RESET SAVE) ──
	var reset_tut_btn = Button.new()
	reset_tut_btn.text = "🎓 RESET TUTORIAL"
	reset_tut_btn.position = Vector2(200, 1038)
	reset_tut_btn.size = Vector2(160, 35)
	reset_tut_btn.z_index = 1
	reset_tut_btn.add_theme_font_size_override("font_size", 12)
	reset_tut_btn.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	reset_tut_btn.pressed.connect(reset_tutorial_status)
	add_child(reset_tut_btn)

func create_menu_button(text: String, pos: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(500, 65)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_color = Color(0.4, 0.7, 1.0, 0.6)
	style.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.2)
	hover.border_color = Color(0.6, 0.9, 1.0)
	btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func animate_title():
	var title = find_child("title_label", true, false)
	if title:
		var start_y = title.position.y
		var tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(title, "position:y", start_y - 12, 2.0)
		tw.tween_property(title, "position:y", start_y, 2.0)

func go_to_selection():
	SceneManager.goto_menu("res://menus/selection/SelectionScreen.tscn")

func go_to_thearchive():
	SceneManager.goto_menu("res://menus/the_archive/TheArchive.tscn")

func go_to_inventory():
	GlobalData.inventory_return_path = "res://menus/main_menu/MainMenu.tscn"
	SceneManager.goto_menu("res://menus/inventory/InventoryMenu.tscn")

func quit_game():
	get_tree().quit()

func reset_save_data():
	if GlobalData.has_method("reset_data"):
		GlobalData.reset_data()
	elif GlobalData.has_method("reset_save"):
		GlobalData.reset_save()

# ── LOGIKA RESET STATUS TUTORIAL ──
func reset_tutorial_status():
	if "tutorial_completed" in GlobalData:
		GlobalData.tutorial_completed = false
	if "has_completed_tutorial" in GlobalData:
		GlobalData.has_completed_tutorial = false
	if GlobalData.has_method("reset_tutorial"):
		GlobalData.reset_tutorial()
	
	print("Tutorial status has been reset! Tutorial will trigger on next battle.")

func spawn_particles():
	particles.clear()
	for i in 40:
		var p = ColorRect.new()
		var sz = randf_range(2.0, 4.0)
		p.size = Vector2(sz, sz)
		p.position = Vector2(randf_range(0, 1920), randf_range(0, 1080))
		var brightness = randf_range(0.3, 0.7)
		p.color = Color(brightness * 0.4, brightness * 0.7, brightness, randf_range(0.2, 0.5))
		add_child(p)
		
		var pt = Particle.new()
		pt.node = p
		pt.vel = Vector2(randf_range(-10, 10), randf_range(-18, -4))
		pt.base_alpha = randf_range(0.2, 0.5)
		pt.phase = randf_range(0, TAU)
		particles.append(pt)

func update_particles(delta: float):
	for p in particles:
		p.node.position += p.vel * delta
		if p.node.position.y < -10:
			p.node.position.y = 1090
			p.node.position.x = randf_range(0, 1920)
		if p.node.position.x < -10:  p.node.position.x = 1930
		if p.node.position.x > 1930: p.node.position.x = -10
		
		var alpha = p.base_alpha + sin(time * 2.0 + p.phase) * 0.15
		p.node.color.a = clamp(alpha, 0.05, 0.8)
