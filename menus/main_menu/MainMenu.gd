extends Node2D

var particles: Array = []
var time: float = 0.0

func _ready():
	build_ui()
	spawn_particles()
	animate_title()

func _process(delta):
	time += delta
	update_particles(delta)

func build_ui():
	# ── BACKGROUND ──
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.03, 0.12)
	bg.size = Vector2(1152, 648)
	add_child(bg)

	# Radial glow center
	for i in range(5, 0, -1):
		var glow = ColorRect.new()
		var s = i * 180.0
		glow.color = Color(0.1, 0.2, 0.5, 0.04 * i)
		glow.size = Vector2(s, s)
		glow.position = Vector2(576 - s/2, 324 - s/2)
		add_child(glow)

	# Grid lines horizontal
	for i in range(0, 648, 60):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1152, 1)
		line.position = Vector2(0, i)
		add_child(line)

	# Grid lines vertical
	for i in range(0, 1152, 60):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(1, 648)
		line.position = Vector2(i, 0)
		add_child(line)

	# Scanline overlay
	for i in range(0, 648, 4):
		var scan = ColorRect.new()
		scan.color = Color(0, 0, 0, 0.03)
		scan.size = Vector2(1152, 2)
		scan.position = Vector2(0, i)
		add_child(scan)

	# ── LOGO ──
	var logo_glow = ColorRect.new()
	logo_glow.color = Color(0.2, 0.6, 1, 0.08)
	logo_glow.size = Vector2(180, 180)
	logo_glow.position = Vector2(486, 40)
	logo_glow.name = "logo_glow"
	add_child(logo_glow)

	var logo_outer = ColorRect.new()
	logo_outer.color = Color(0.1, 0.2, 0.5)
	logo_outer.size = Vector2(130, 130)
	logo_outer.position = Vector2(511, 55)
	add_child(logo_outer)

	var logo_border_top = ColorRect.new()
	logo_border_top.color = Color(0.4, 0.9, 1)
	logo_border_top.size = Vector2(130, 3)
	logo_border_top.position = Vector2(511, 55)
	add_child(logo_border_top)

	var logo_border_left = ColorRect.new()
	logo_border_left.color = Color(0.4, 0.9, 1, 0.5)
	logo_border_left.size = Vector2(3, 130)
	logo_border_left.position = Vector2(511, 55)
	add_child(logo_border_left)

	var logo_inner = ColorRect.new()
	logo_inner.color = Color(0.3, 0.8, 1)
	logo_inner.size = Vector2(80, 80)
	logo_inner.position = Vector2(536, 80)
	logo_inner.name = "logo_inner"
	add_child(logo_inner)

	var logo_shine = ColorRect.new()
	logo_shine.color = Color(1, 1, 1, 0.25)
	logo_shine.size = Vector2(28, 12)
	logo_shine.position = Vector2(541, 85)
	add_child(logo_shine)

	# PE monogram di dalam logo
	var logo_text = create_label("PE", Vector2(548, 88), 28, Color(0.05, 0.1, 0.3))
	add_child(logo_text)

	# ── TITLE ──
	var title_shadow = create_label("Protocol: Elysium", Vector2(2, 202), 54, Color(0.1, 0.3, 0.6, 0.5))
	title_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_shadow.custom_minimum_size = Vector2(1152, 70)
	add_child(title_shadow)

	var title = create_label("Protocol: Elysium", Vector2(0, 200), 54, Color(0.4, 0.9, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1152, 70)
	title.name = "title_label"
	add_child(title)

	var subtitle = create_label("C Y B E R S E C U R I T Y  B A T T L E  S I M U L A T O R", Vector2(0, 264), 13, Color(0.4, 0.5, 0.7))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1152, 25)
	add_child(subtitle)

	# Accent lines kiri kanan subtitle
	var line_left = ColorRect.new()
	line_left.color = Color(0.3, 0.4, 0.7, 0.6)
	line_left.size = Vector2(180, 1)
	line_left.position = Vector2(200, 276)
	add_child(line_left)

	var line_right = ColorRect.new()
	line_right.color = Color(0.3, 0.4, 0.7, 0.6)
	line_right.size = Vector2(180, 1)
	line_right.position = Vector2(772, 276)
	add_child(line_right)

	# ── DIVIDER ──
	var div_glow = ColorRect.new()
	div_glow.color = Color(0.3, 0.5, 0.9, 0.15)
	div_glow.size = Vector2(400, 6)
	div_glow.position = Vector2(376, 303)
	add_child(div_glow)

	var div = ColorRect.new()
	div.color = Color(0.4, 0.6, 1, 0.5)
	div.size = Vector2(400, 1)
	div.position = Vector2(376, 306)
	add_child(div)

	# ── BUTTONS ──
	var play_btn = create_menu_button("▶   PLAY", Vector2(426, 330), Color(0.08, 0.4, 0.15))
	play_btn.pressed.connect(go_to_selection)
	add_child(play_btn)

	var dex_btn = create_menu_button("◈   PROTOCOL-LINK", Vector2(426, 405), Color(0.08, 0.25, 0.5))
	dex_btn.pressed.connect(go_to_cyberdex)
	add_child(dex_btn)

	var quit_btn = create_menu_button("✕   QUIT", Vector2(426, 480), Color(0.35, 0.08, 0.08))
	quit_btn.pressed.connect(quit_game)
	add_child(quit_btn)

	# ── BOTTOM INFO ──
	var bottom_bar = ColorRect.new()
	bottom_bar.color = Color(0.06, 0.06, 0.18)
	bottom_bar.size = Vector2(1152, 30)
	bottom_bar.position = Vector2(0, 618)
	add_child(bottom_bar)

	var bottom_border = ColorRect.new()
	bottom_border.color = Color(0.2, 0.3, 0.6, 0.5)
	bottom_border.size = Vector2(1152, 1)
	bottom_border.position = Vector2(0, 618)
	add_child(bottom_border)

	var version = create_label("v0.2  —  Protocol: Elysium  —  Made with Godot", Vector2(0, 623), 11, Color(0.3, 0.3, 0.5))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.custom_minimum_size = Vector2(1152, 20)
	add_child(version)

func spawn_particles():
	for i in 40:
		var p = ColorRect.new()
		var size = randf_range(1.5, 4.0)
		p.size = Vector2(size, size)
		p.position = Vector2(randf_range(0, 1152), randf_range(0, 648))
		var brightness = randf_range(0.3, 0.8)
		p.color = Color(
			brightness * randf_range(0.3, 0.6),
			brightness * randf_range(0.5, 0.9),
			brightness,
			randf_range(0.3, 0.7)
		)
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
		# Wrap around
		if p["node"].position.y < -10:
			p["node"].position.y = 658
			p["node"].position.x = randf_range(0, 1152)
		if p["node"].position.x < -10:
			p["node"].position.x = 1162
		if p["node"].position.x > 1162:
			p["node"].position.x = -10
		# Twinkle
		var alpha = p["base_alpha"] + sin(time * 2.0 + p["phase"]) * 0.2
		p["node"].color.a = clamp(alpha, 0.1, 0.9)

	# Logo pulse
	var logo = get_node_or_null("logo_inner")
	if logo:
		var pulse = 0.85 + sin(time * 1.5) * 0.08
		logo.scale = Vector2(pulse, pulse)
		logo.position = Vector2(536 + (1 - pulse) * 40, 80 + (1 - pulse) * 40)

func animate_title():
	var title = get_node_or_null("title_label")
	if title == null:
		return
	title.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(title, "position:y", 200, 1.5).set_trans(Tween.TRANS_BACK).from(180)

func create_menu_button(text: String, pos: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(300, 58)

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.border_color = Color(0.4, 0.6, 1, 0.3)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	hover_style.border_color = Color(0.5, 0.8, 1, 0.8)
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	btn.add_theme_font_size_override("font_size", 18)
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
	var scene = load("res://menus/selection/SelectionScreen.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func go_to_cyberdex():
	var scene = load("res://menus/cyberdex/CyberDex.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	queue_free()

func quit_game():
	get_tree().quit()
