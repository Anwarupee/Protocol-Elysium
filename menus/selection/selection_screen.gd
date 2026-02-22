extends Node2D

var selected_monster: String = ""
var active_tab: String = "Data"
var card_nodes = []
var tab_buttons = {}
var cards_container: Node2D
var confirm_btn: Button
var detail_labels = {}
var detail_panel: Node2D

var monsters_info = [
	{
		"id": "encryp_pup",
		"name": "ENCRYP-PUP",
		"type": "Data",
		"color": Color(0.4, 0.8, 1),
		"hp": 120,
		"speed": 60,
		"role": "Defender",
		"desc": "Anjing gembok yang tangguh. Makin kuat saat diserang.",
		"moves": ["Encrypt", "Firewall Bark", "Backup Howl"]
	},
	{
		"id": "ping_go",
		"name": "PING-GO",
		"type": "Connection",
		"color": Color(1, 0.9, 0.3),
		"hp": 90,
		"speed": 100,
		"role": "Speedster",
		"desc": "Burung puyuh super cepat. Selalu menyerang duluan.",
		"moves": ["Packet Dash", "Traceroute", "DDoS Feathers"]
	},
	{
		"id": "biti",
		"name": "BITI",
		"type": "Malware",
		"color": Color(1, 0.4, 0.4),
		"hp": 95,
		"speed": 80,
		"role": "Strategist",
		"desc": "Makhluk nakal yang bisa meniru jurus lawan.",
		"moves": ["Mimic Byte", "Inject", "Trojan Gift"]
	},
	{
		"id": "senti_shell",
		"name": "SENTI-SHELL",
		"type": "Defensive",
		"color": Color(0.2, 0.9, 0.6),
		"hp": 150,
		"speed": 40,
		"role": "Tank",
		"desc": "Kura-kura mekanik dengan cangkang berlian data. Tidak bisa ditembus.",
		"moves": ["Diamond Layer", "Immutable Lock", "Restore Point"]
	},
	{
		"id": "octo_core",
		"name": "OCTO-CORE",
		"type": "System",
		"color": Color(0.6, 0.3, 1),
		"hp": 110,
		"speed": 70,
		"role": "Controller",
		"desc": "Gurita CPU yang menguasai kernel. Berbahaya bahkan saat kalah.",
		"moves": ["Memory Overflow", "Process Kill", "System Hijack"]
	},
	{
		"id": "chamele_auth",
		"name": "CHAMELE-AUTH",
		"type": "Social Engineering",
		"color": Color(1, 0.7, 0.2),
		"hp": 95,
		"speed": 85,
		"role": "Trickster",
		"desc": "Bunglon piksel yang mencuri identitas. Tidak pernah menyerang langsung.",
		"moves": ["Phishing Cast", "Spoofed Token", "Social Override"]
	}
]

var type_colors = {
	"Data": Color(0.4, 0.8, 1),
	"Connection": Color(1, 0.9, 0.3),
	"Malware": Color(1, 0.4, 0.4),
	"Defensive": Color(0.2, 0.9, 0.6),
	"System": Color(0.6, 0.3, 1),
	"Social Engineering": Color(1, 0.7, 0.2)
}

var passive_texts = {
	"encryp_pup": "Hardened Shell\nDefense naik tiap kena serangan",
	"ping_go": "Low Latency\nSelalu menyerang duluan",
	"biti": "Polymorphic\n30% chance serangan lawan miss",
	"senti_shell": "Redundancy\nBertahan di 1 HP saat pertama kali KO",
	"octo_core": "Kernel Panic\nDeal 25 damage saat dikalahkan",
	"chamele_auth": "Identity Theft\n20% chance salin tipe lawan"
}

var advantage_texts = {
	"encryp_pup": "Kuat vs Malware\nLemah vs Connection",
	"ping_go": "Kuat vs Data\nLemah vs Malware",
	"biti": "Kuat vs Connection\nLemah vs Data",
	"senti_shell": "Kuat vs Social Engineering\nLemah vs System",
	"octo_core": "Kuat vs Data\nLemah vs Social Engineering",
	"chamele_auth": "Kuat vs System\nLemah vs Connection"
}

func _ready():
	build_ui()

func build_ui():
	# Background
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

	# Title
	var title = create_label("CHOOSE YOUR CYBER-MON", Vector2(0, 25), 28, Color(0.4, 0.9, 1))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(1152, 40)
	add_child(title)

	var subtitle = create_label("Pilih tipe lalu pilih partner untuk melawan ancaman siber!", Vector2(0, 65), 13, Color(0.6, 0.6, 0.8))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.custom_minimum_size = Vector2(1152, 20)
	add_child(subtitle)

	# Tab buttons
	build_tabs()

	# Cards area
	cards_container = Node2D.new()
	cards_container.position = Vector2(0, 175)
	add_child(cards_container)

	# Detail panel (kanan)
	detail_panel = build_detail_panel()
	add_child(detail_panel)
	detail_panel.visible = false

	# Confirm button
	confirm_btn = create_styled_button("⚔️  START BATTLE!", Vector2(426, 610), Vector2(300, 35), Color(0.15, 0.5, 0.15))
	confirm_btn.pressed.connect(start_battle)
	confirm_btn.visible = false
	add_child(confirm_btn)

	# Show first tab
	show_tab("Data")
	
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(20, 610)
	back_btn.size = Vector2(100, 30)
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.15, 0.15, 0.35)
	back_style.corner_radius_top_left = 5
	back_style.corner_radius_top_right = 5
	back_style.corner_radius_bottom_left = 5
	back_style.corner_radius_bottom_right = 5
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_font_size_override("font_size", 12)
	back_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
	back_btn.pressed.connect(func():
		var scene = load("res://menus/main_menu/MainMenu.tscn").instantiate()
		get_tree().root.add_child(scene)
		get_tree().current_scene = scene
		queue_free()
	)
	add_child(back_btn)

func build_tabs():
	var types = ["Data", "Connection", "Malware", "Defensive", "System", "Social Engineering"]
	var tab_width = 160
	var start_x = (1152 - (types.size() * tab_width + (types.size() - 1) * 8)) / 2

	for i in types.size():
		var t = types[i]
		var col = type_colors[t]
		var x = start_x + i * (tab_width + 8)

		# Tab background
		var tab_bg = ColorRect.new()
		tab_bg.size = Vector2(tab_width, 42)
		tab_bg.position = Vector2(x, 105)
		tab_bg.color = Color(col.r, col.g, col.b, 0.15)
		tab_bg.name = "tab_bg_" + t
		add_child(tab_bg)

		# Tab border bottom
		var tab_border = ColorRect.new()
		tab_border.size = Vector2(tab_width, 3)
		tab_border.position = Vector2(x, 144)
		tab_border.color = Color(col.r, col.g, col.b, 0.4)
		tab_border.name = "tab_border_" + t
		add_child(tab_border)

		# Tab button
		var btn = Button.new()
		btn.text = t
		btn.size = Vector2(tab_width, 42)
		btn.position = Vector2(x, 105)
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", col)
		btn.pressed.connect(func(): show_tab(t))
		add_child(btn)

		tab_buttons[t] = {"bg": tab_bg, "border": tab_border, "btn": btn, "color": col}

	# Divider line
	var divider = ColorRect.new()
	divider.color = Color(0.3, 0.3, 0.5, 0.5)
	divider.size = Vector2(1152, 1)
	divider.position = Vector2(0, 148)
	add_child(divider)

func show_tab(type_name: String):
	active_tab = type_name

	# Update tab visuals
	for t in tab_buttons:
		var col = tab_buttons[t]["color"]
		if t == type_name:
			tab_buttons[t]["bg"].color = Color(col.r, col.g, col.b, 0.35)
			tab_buttons[t]["border"].color = col
			tab_buttons[t]["border"].size = Vector2(160, 4)
		else:
			tab_buttons[t]["bg"].color = Color(col.r, col.g, col.b, 0.1)
			tab_buttons[t]["border"].color = Color(col.r, col.g, col.b, 0.3)
			tab_buttons[t]["border"].size = Vector2(160, 3)

	# Clear cards
	for child in cards_container.get_children():
		child.queue_free()
	card_nodes.clear()

	# Filter monsters by type
	var filtered = monsters_info.filter(func(m): return m["type"] == type_name)

	# Type info header
	var type_col = type_colors[type_name]
	var header = create_label(type_name.to_upper() + " TYPE", Vector2(0, 5), 16, type_col)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.custom_minimum_size = Vector2(1152, 25)
	cards_container.add_child(header)

	var count_label = create_label(str(filtered.size()) + " monster tersedia", Vector2(0, 28), 12, Color(0.6, 0.6, 0.7))
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.custom_minimum_size = Vector2(1152, 20)
	cards_container.add_child(count_label)

	# Type advantage info
	var adv_map = {
		"Data": "⚡ Kuat vs Malware   ⚠ Lemah vs Connection",
		"Connection": "⚡ Kuat vs Data   ⚠ Lemah vs Malware",
		"Malware": "⚡ Kuat vs Connection   ⚠ Lemah vs Data",
		"Defensive": "⚡ Kuat vs Social Engineering   ⚠ Lemah vs System",
		"System": "⚡ Kuat vs Data   ⚠ Lemah vs Social Engineering",
		"Social Engineering": "⚡ Kuat vs System   ⚠ Lemah vs Connection"
	}
	var adv_label = create_label(adv_map[type_name], Vector2(0, 50), 11, Color(type_col.r, type_col.g, type_col.b, 0.8))
	adv_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	adv_label.custom_minimum_size = Vector2(1152, 18)
	cards_container.add_child(adv_label)

	# Cards — centered
	var card_w = 270
	var spacing = 30
	var total_w = filtered.size() * card_w + (filtered.size() - 1) * spacing
	var start_x = (1152 - total_w) / 2

	for i in filtered.size():
		var card = build_monster_card(filtered[i], Vector2(start_x + i * (card_w + spacing), 78))
		cards_container.add_child(card)
		card_nodes.append(card)

	# Reset selection jika pindah tab dan monster yang dipilih bukan tipe ini
	var current_type = ""
	for m in monsters_info:
		if m["id"] == selected_monster:
			current_type = m["type"]
	if current_type != type_name:
		detail_panel.visible = false
		confirm_btn.visible = false

func build_monster_card(info: Dictionary, pos: Vector2) -> Node2D:
	var card = Node2D.new()
	card.position = pos
	var col = info["color"]

	# Card bg
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.22, 0.95)
	style.border_color = col
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	var panel = PanelContainer.new()
	panel.size = Vector2(270, 330)
	panel.add_theme_stylebox_override("panel", style)
	card.add_child(panel)

	# Sprite area
	var sprite_bg = ColorRect.new()
	sprite_bg.color = Color(col.r, col.g, col.b, 0.08)
	sprite_bg.size = Vector2(270, 140)
	card.add_child(sprite_bg)

	var glow = ColorRect.new()
	glow.color = Color(col.r, col.g, col.b, 0.15)
	glow.size = Vector2(90, 90)
	glow.position = Vector2(90, 25)
	card.add_child(glow)

	var sprite = ColorRect.new()
	sprite.color = col
	sprite.size = Vector2(70, 70)
	sprite.position = Vector2(100, 35)
	card.add_child(sprite)

	# Shine
	var shine = ColorRect.new()
	shine.color = Color(1, 1, 1, 0.15)
	shine.size = Vector2(25, 12)
	shine.position = Vector2(105, 40)
	card.add_child(shine)

	# Name
	var name_lbl = create_label(info["name"], Vector2(0, 148), 17, col)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.custom_minimum_size = Vector2(270, 24)
	card.add_child(name_lbl)

	# Role
	var role_lbl = create_label(info["role"], Vector2(0, 172), 13, Color(1, 0.8, 0.3))
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.custom_minimum_size = Vector2(270, 20)
	card.add_child(role_lbl)

	# Divider
	var div = ColorRect.new()
	div.color = Color(col.r, col.g, col.b, 0.3)
	div.size = Vector2(230, 1)
	div.position = Vector2(20, 196)
	card.add_child(div)

	# Stats
	var stat_lbl = create_label("HP: " + str(info["hp"]) + "     SPD: " + str(info["speed"]), Vector2(20, 204), 12, Color(0.8, 0.8, 0.8))
	card.add_child(stat_lbl)

	# Moves
	var moves_lbl = create_label("Moves:", Vector2(20, 225), 11, Color(0.5, 0.8, 1))
	card.add_child(moves_lbl)
	for j in info["moves"].size():
		var m = create_label("• " + info["moves"][j], Vector2(20, 242 + j * 18), 11, Color(0.7, 0.7, 0.7))
		card.add_child(m)

	# Click button
	var btn = Button.new()
	btn.size = Vector2(270, 330)
	btn.flat = true
	btn.modulate = Color(1, 1, 1, 0)
	btn.pressed.connect(func(): select_monster(card, info))
	card.add_child(btn)

	return card

func build_detail_panel() -> Node2D:
	var panel = Node2D.new()
	panel.position = Vector2(972, 175)

	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.2, 0.95)
	bg.size = Vector2(168, 420)
	panel.add_child(bg)

	var border = ColorRect.new()
	border.color = Color(0.3, 0.3, 0.6)
	border.size = Vector2(168, 3)
	panel.add_child(border)

	detail_labels["title"] = create_label("SELECTED", Vector2(10, 15), 13, Color(0.4, 0.9, 1))
	panel.add_child(detail_labels["title"])

	detail_labels["desc"] = create_label("", Vector2(10, 42), 11, Color(0.8, 0.8, 0.8))
	detail_labels["desc"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["desc"].custom_minimum_size = Vector2(148, 70)
	panel.add_child(detail_labels["desc"])

	panel.add_child(create_label("PASSIVE:", Vector2(10, 120), 11, Color(1, 0.8, 0.3)))
	detail_labels["passive"] = create_label("", Vector2(10, 138), 10, Color(0.9, 0.9, 0.6))
	detail_labels["passive"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["passive"].custom_minimum_size = Vector2(148, 55)
	panel.add_child(detail_labels["passive"])

	panel.add_child(create_label("ADVANTAGE:", Vector2(10, 202), 11, Color(0.4, 1, 0.4)))
	detail_labels["advantage"] = create_label("", Vector2(10, 220), 10, Color(0.7, 1, 0.7))
	detail_labels["advantage"].autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_labels["advantage"].custom_minimum_size = Vector2(148, 55)
	panel.add_child(detail_labels["advantage"])

	return panel

func select_monster(card: Node2D, info: Dictionary):
	selected_monster = info["id"]

	# Reset semua card border
	for c in card_nodes:
		var p = c.get_child(0)
		var s = p.get_theme_stylebox("panel").duplicate()
		s.border_width_top = 2
		s.border_width_bottom = 2
		s.border_width_left = 2
		s.border_width_right = 2
		p.add_theme_stylebox_override("panel", s)

	# Highlight selected
	var sel_panel = card.get_child(0)
	var sel_style = sel_panel.get_theme_stylebox("panel").duplicate()
	sel_style.border_width_top = 4
	sel_style.border_width_bottom = 4
	sel_style.border_width_left = 4
	sel_style.border_width_right = 4
	sel_panel.add_theme_stylebox_override("panel", sel_style)

	# Update detail panel
	detail_labels["title"].text = info["name"]
	detail_labels["title"].add_theme_color_override("font_color", info["color"])
	detail_labels["desc"].text = info["desc"]
	detail_labels["passive"].text = passive_texts[info["id"]]
	detail_labels["advantage"].text = advantage_texts[info["id"]]

	detail_panel.visible = true
	confirm_btn.visible = true
	confirm_btn.text = "⚔️  Battle with " + info["name"] + "!"

func start_battle():
	if selected_monster == "":
		return
	var battle_scene = load("res://battle/Battle.tscn").instantiate()
	battle_scene.set_meta("player_monster", selected_monster)
	get_tree().root.add_child(battle_scene)
	get_tree().current_scene = battle_scene
	queue_free()

func create_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func create_styled_button(text: String, pos: Vector2, size: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = size

	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.3)
	btn.add_theme_stylebox_override("hover", hover_style)

	btn.add_theme_font_size_override("font_size", 15)
	btn.add_theme_color_override("font_color", Color.WHITE)
	return btn
