extends Node2D

# ════════════════════════════════════════════════════════════════
# InventoryMenu.gd
# Menu akses dari MainMenu / SelectionScreen / ResultScreen
# Tab 1: PARTY    — sentinel aktif + cadangan
# Tab 2: ITEMS    — item yang dimiliki + deskripsi
# Tab 3: COLLECTION — jumlah sentinel yang sudah ditangkap
#
# Scene: InventoryMenu.tscn
# Root node: Node2D
# ════════════════════════════════════════════════════════════════

var current_tab: int = 0  # 0=Party, 1=Items, 2=Collection
var tab_buttons: Array = []
var content_node: Node2D = null

var selected_slot: int = -1
var monsters_data: Array = []

func _ready():
	_load_monsters_data()
	_build_ui()
	_show_tab(0)

func _load_monsters_data():
	if not FileAccess.file_exists("res://data/monsters.json"):
		push_error("InventoryMenu: File res://data/monsters.json tidak ditemukan!")
		return

	var file = FileAccess.open("res://data/monsters.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		file.close()
		
		if parse_result == OK and json.get_data() is Dictionary and json.get_data().has("monsters"):
			monsters_data = json.get_data()["monsters"]
		else:
			push_error("InventoryMenu: Gagal parsing JSON dari monsters.json")

func _get_monster_data(id: String) -> Dictionary:
	for d in monsters_data:
		if d.get("id", "") == id:
			return d
	return {}

# ════════════════════════════════════════════
# ── MAIN UI BUILD ──
# ════════════════════════════════════════════

func _build_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.12)
	bg.size = Vector2(3200, 1800)
	add_child(bg)

	# Grid lines (NieR aesthetic)
	for i in range(0, 1920, 80):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.04)
		line.size = Vector2(2, 1080)
		line.position = Vector2(i, 0)
		add_child(line)
	for i in range(0, 1080, 60):
		var line = ColorRect.new()
		line.color = Color(0.2, 0.3, 0.6, 0.03)
		line.size = Vector2(1920, 2)
		line.position = Vector2(0, i)
		add_child(line)

	# Header
	var header_bg = ColorRect.new()
	header_bg.color = Color(0.08, 0.1, 0.25)
	header_bg.size = Vector2(1920, 117)
	add_child(header_bg)

	var header_accent = ColorRect.new()
	header_accent.color = Color(0.3, 0.6, 1.0)
	header_accent.size = Vector2(1920, 5)
	header_accent.position = Vector2(0, 117)
	add_child(header_accent)

	var title = Label.new()
	title.text = "[ TERMINAL — INVENTORY ]"
	title.position = Vector2(67, 30)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	add_child(title)

	# Back button
	var back_btn = Button.new()
	back_btn.text = "← BACK"
	back_btn.position = Vector2(1667, 30)
	back_btn.size = Vector2(200, 63)
	_style_btn(back_btn, Color(0.3, 0.3, 0.5))
	back_btn.pressed.connect(_go_back)
	add_child(back_btn)

	# Tab buttons
	var tab_names = ["PARTY", "ITEMS", "COLLECTION"]
	var tab_colors = [Color(0.2, 0.5, 0.9), Color(0.2, 0.7, 0.4), Color(0.7, 0.4, 0.1)]
	for i in tab_names.size():
		var tab_btn = Button.new()
		tab_btn.text = tab_names[i]
		tab_btn.position = Vector2(67 + i * 270, 130)
		tab_btn.size = Vector2(250, 55)
		var captured_i = i
		tab_btn.pressed.connect(func(): _show_tab(captured_i))
		_style_btn(tab_btn, tab_colors[i])
		add_child(tab_btn)
		tab_buttons.append(tab_btn)

	# Content area
	var content_area = Node2D.new()
	content_area.position = Vector2(0, 217)
	content_area.name = "ContentArea"
	add_child(content_area)
	content_node = content_area

# ════════════════════════════════════════════
# ── TAB ROUTING ──
# ════════════════════════════════════════════

func _show_tab(tab_index: int):
	current_tab = tab_index

	for child in content_node.get_children():
		child.queue_free()

	var tab_colors = [Color(0.2, 0.5, 0.9), Color(0.2, 0.7, 0.4), Color(0.7, 0.4, 0.1)]
	for i in tab_buttons.size():
		var btn = tab_buttons[i]
		var base_color = tab_colors[i]
		var style = StyleBoxFlat.new()
		style.bg_color = base_color if i == tab_index else base_color.darkened(0.5)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", style)

	match tab_index:
		0: _build_party_tab()
		1: _build_items_tab()
		2: _build_collection_tab()

# ════════════════════════════════════════════
# ── TAB 0: PARTY ──
# ════════════════════════════════════════════

func _build_party_tab():
	var c = content_node

	var lbl = _make_label("Tim Aktif (maks. " + str(GlobalData.MAX_TEAM_SIZE) + ")", Vector2(67, 10), 18, Color(0.4, 0.8, 1.0))
	c.add_child(lbl)

	var hint = _make_label("Sentinel pertama di slot PARTY akan dipakai utama dalam battle.", Vector2(67, 42), 12, Color(0.5, 0.6, 0.8))
	c.add_child(hint)

	# Active team slots (Diperbaiki jarak Y-nya agar tidak bertumpukan)
	for i in GlobalData.MAX_TEAM_SIZE:
		var slot_y = 70 + i * 175
		_build_team_slot(c, i, Vector2(67, slot_y))

	# Divider
	var div = ColorRect.new()
	div.color = Color(0.3, 0.4, 0.6, 0.4)
	div.size = Vector2(3, 760)
	div.position = Vector2(733, 10)
	c.add_child(div)

	# Caught sentinels (Reservoir kanan)
	var res_lbl = _make_label("Sentinel Tertangkap", Vector2(767, 10), 18, Color(0.4, 0.8, 1.0))
	c.add_child(res_lbl)

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(767, 50)
	scroll.size = Vector2(1085, 720)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	c.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(1060, 0)
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	var caught = GlobalData.caught_sentinels
	if caught.is_empty():
		var empty = _make_label("Belum ada sentinel tertangkap.", Vector2(0, 0), 14, Color(0.5, 0.5, 0.5))
		vbox.add_child(empty)
	else:
		for monster_id in caught:
			var data = _get_monster_data(monster_id)
			if data.is_empty():
				continue
			var row = _build_reservoir_row(data, monster_id)
			vbox.add_child(row)

func _build_team_slot(parent: Node2D, slot_index: int, pos: Vector2):
	var slot_container = Node2D.new()
	slot_container.position = pos
	parent.add_child(slot_container)

	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.10, 0.25, 0.8)
	bg.size = Vector2(633, 160)
	slot_container.add_child(bg)

	var slot_label = _make_label("SLOT " + str(slot_index + 1), Vector2(15, 10), 11, Color(0.4, 0.5, 0.8))
	slot_container.add_child(slot_label)

	var active_team = GlobalData.active_team
	if slot_index >= active_team.size():
		var empty_lbl = _make_label("[ EMPTY ]", Vector2(233, 65), 16, Color(0.3, 0.3, 0.5))
		slot_container.add_child(empty_lbl)
		return

	var monster_id = active_team[slot_index]
	var data = _get_monster_data(monster_id)
	if data.is_empty():
		return

	var type_color = _get_type_color(data.get("type", ""))

	var sprite_bg = ColorRect.new()
	sprite_bg.color = Color(type_color.r, type_color.g, type_color.b, 0.15)
	sprite_bg.size = Vector2(110, 110)
	sprite_bg.position = Vector2(15, 35)
	slot_container.add_child(sprite_bg)

	SentinelSprites.draw(slot_container, monster_id, Vector2(70, 90), type_color, 42)

	var name_lbl = _make_label(data.get("name", "?"), Vector2(140, 35), 16, type_color)
	slot_container.add_child(name_lbl)
	var type_lbl = _make_label(data.get("type", ""), Vector2(140, 68), 12, Color(type_color.r, type_color.g, type_color.b, 0.8))
	slot_container.add_child(type_lbl)
	var hp_lbl = _make_label("HP: " + str(data.get("hp", "?")) + "  SPD: " + str(data.get("speed", "?")), Vector2(140, 95), 12, Color(0.7, 0.9, 0.7))
	slot_container.add_child(hp_lbl)

	var border = ColorRect.new()
	border.color = type_color
	border.size = Vector2(6, 160)
	slot_container.add_child(border)

	if slot_index > 0:
		var rem_btn = Button.new()
		rem_btn.text = "× Remove"
		rem_btn.position = Vector2(483, 105)
		rem_btn.size = Vector2(135, 40)
		_style_btn(rem_btn, Color(0.5, 0.1, 0.1))
		var captured_id = monster_id
		rem_btn.pressed.connect(func():
			GlobalData.remove_from_team(captured_id)
			_show_tab(0))
		slot_container.add_child(rem_btn)

func _build_reservoir_row(data: Dictionary, monster_id: String) -> Control:
	var row_bg = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.22, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	row_bg.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	row_bg.add_child(hbox)

	var type_color = _get_type_color(data.get("type", ""))

	var sprite_holder = ColorRect.new()
	sprite_holder.color = Color(0, 0, 0, 0)
	sprite_holder.custom_minimum_size = Vector2(83, 83)
	hbox.add_child(sprite_holder)
	
	var _sprite_node_83 = Node2D.new()
	sprite_holder.add_child(_sprite_node_83)
	SentinelSprites.draw(_sprite_node_83, monster_id, Vector2(42, 42), type_color, 35)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)
	
	var n = Label.new()
	n.text = data.get("name", "?")
	n.add_theme_font_size_override("font_size", 20)
	n.add_theme_color_override("font_color", type_color)
	vbox.add_child(n)
	
	var t = Label.new()
	t.text = data.get("type", "") + "  ·  HP " + str(data.get("hp", "?")) + "  ·  SPD " + str(data.get("speed", "?"))
	t.add_theme_font_size_override("font_size", 14)
	t.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(t)

	var in_team = monster_id in GlobalData.active_team
	var team_full = GlobalData.active_team.size() >= GlobalData.MAX_TEAM_SIZE

	var add_btn = Button.new()
	add_btn.custom_minimum_size = Vector2(160, 48)
	add_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if in_team:
		add_btn.text = "✓ In Team"
		add_btn.disabled = true
		_style_btn(add_btn, Color(0.2, 0.4, 0.2))
	elif team_full:
		add_btn.text = "Team Full"
		add_btn.disabled = true
		_style_btn(add_btn, Color(0.3, 0.3, 0.3))
	else:
		add_btn.text = "+ Add to Team"
		_style_btn(add_btn, Color(0.2, 0.5, 0.25))
		var captured_id = monster_id
		add_btn.pressed.connect(func():
			GlobalData.add_to_team(captured_id)
			_show_tab(0))
	hbox.add_child(add_btn)

	return row_bg

# ════════════════════════════════════════════
# ── TAB 1: ITEMS ──
# ════════════════════════════════════════════

func _build_items_tab():
	var c = content_node

	var lbl = _make_label("Item Inventory", Vector2(67, 10), 18, Color(0.4, 1.0, 0.6))
	c.add_child(lbl)

	var note = _make_label("Heal Potion & Capture Key bisa dipakai langsung saat battle.", Vector2(67, 42), 12, Color(0.5, 0.7, 0.6))
	c.add_child(note)

	var battles_to_next = GlobalData.ITEM_REWARD_INTERVAL - (GlobalData.battles_won % GlobalData.ITEM_REWARD_INTERVAL)
	if battles_to_next == GlobalData.ITEM_REWARD_INTERVAL:
		battles_to_next = 0
	var reward_info_text = "Kemenangan berikutnya: mendapat item gratis!" if battles_to_next == 1 else str(battles_to_next) + " kemenangan lagi untuk reward item."
	var reward_info = _make_label("🏆 " + reward_info_text, Vector2(67, 68), 12, Color(1.0, 0.8, 0.3))
	c.add_child(reward_info)

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(67, 105)
	scroll.size = Vector2(1767, 670)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	c.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(1733, 0)
	vbox.add_theme_constant_override("separation", 16)
	scroll.add_child(vbox)

	var has_items = false
	for item_id in GlobalData.ITEM_DATA.keys():
		var count = GlobalData.get_item_count(item_id)
		var item_def = GlobalData.ITEM_DATA[item_id]
		var row = _build_item_row(item_id, item_def, count)
		vbox.add_child(row)
		if count > 0:
			has_items = true

	if not has_items:
		var empty = _make_label("Inventory kosong. Menangkan battle untuk mendapat item!", Vector2(0, 0), 14, Color(0.5, 0.5, 0.5))
		vbox.add_child(empty)

func _build_item_row(item_id: String, item_def: Dictionary, count: int) -> Control:
	var row = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.22, 0.9) if count > 0 else Color(0.05, 0.05, 0.10, 0.5)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	row.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	row.add_child(hbox)

	var icon_lbl = Label.new()
	icon_lbl.text = item_def.get("icon", "?")
	icon_lbl.custom_minimum_size = Vector2(70, 70)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 36)
	if count == 0:
		icon_lbl.modulate = Color(0.4, 0.4, 0.4)
	hbox.add_child(icon_lbl)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = item_def.get("name", item_id)
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0) if count > 0 else Color(0.4, 0.4, 0.5))
	vbox.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = item_def.get("description", "")
	desc_lbl.add_theme_font_size_override("font_size", 14)
	desc_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_lbl)

	var battle_tag = item_def.get("usable_in_battle", false)
	var tag_lbl = Label.new()
	tag_lbl.text = "⚔ Bisa dipakai saat battle" if battle_tag else "🏠 Hanya di luar battle"
	tag_lbl.add_theme_font_size_override("font_size", 12)
	tag_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6) if battle_tag else Color(0.7, 0.5, 0.3))
	vbox.add_child(tag_lbl)

	var right_vbox = VBoxContainer.new()
	right_vbox.custom_minimum_size = Vector2(180, 0)
	right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(right_vbox)

	var count_lbl = Label.new()
	count_lbl.text = "×" + str(count)
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_lbl.add_theme_font_size_override("font_size", 30)
	count_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3) if count > 0 else Color(0.3, 0.3, 0.4))
	right_vbox.add_child(count_lbl)

	if item_id == "revive_chip" and count > 0:
		var use_btn = Button.new()
		use_btn.text = "Gunakan"
		use_btn.custom_minimum_size = Vector2(150, 40)
		_style_btn(use_btn, Color(0.3, 0.6, 0.3))
		use_btn.pressed.connect(func(): _use_revive_chip())
		right_vbox.add_child(use_btn)

	return row

func _use_revive_chip():
	pass

# ════════════════════════════════════════════
# ── TAB 2: COLLECTION ──
# ════════════════════════════════════════════

func _build_collection_tab():
	var c = content_node

	var caught_count = GlobalData.caught_sentinels.size()
	var total = monsters_data.size()

	var lbl = _make_label("Collection — " + str(caught_count) + "/" + str(total) + " Sentinel", Vector2(67, 10), 18, Color(1.0, 0.7, 0.3))
	c.add_child(lbl)

	# Fixed Progress Bar width calculation
	var bar_width = 1767.0
	var bar_bg = ColorRect.new()
	bar_bg.color = Color(0.15, 0.15, 0.3)
	bar_bg.size = Vector2(bar_width, 16)
	bar_bg.position = Vector2(67, 45)
	c.add_child(bar_bg)

	var bar_fill = ColorRect.new()
	var fill_pct = float(caught_count) / max(total, 1)
	bar_fill.color = Color(1.0, 0.7, 0.2)
	bar_fill.size = Vector2(bar_width * fill_pct, 16)
	bar_fill.position = Vector2(67, 45)
	c.add_child(bar_fill)

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(67, 80)
	scroll.size = Vector2(1767, 690)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	c.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	scroll.add_child(grid)

	var all_ids = []
	for d in monsters_data:
		all_ids.append(d["id"])

	var caught_ids = GlobalData.caught_sentinels
	var sorted_ids = []
	for id in caught_ids:
		sorted_ids.append(id)
	for id in all_ids:
		if id not in caught_ids:
			sorted_ids.append(id)

	for monster_id in sorted_ids:
		var data = _get_monster_data(monster_id)
		if data.is_empty():
			continue
		var card = _build_collection_card(data, monster_id in caught_ids)
		grid.add_child(card)

func _build_collection_card(data: Dictionary, is_caught: bool) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(420, 150)
	var style = StyleBoxFlat.new()
	var type_color = _get_type_color(data.get("type", ""))
	style.bg_color = Color(0.08, 0.10, 0.22, 0.9) if is_caught else Color(0.05, 0.05, 0.12, 0.7)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	if is_caught:
		style.border_color = Color(type_color.r, type_color.g, type_color.b, 0.6)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
	card.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)

	var sprite_color = type_color if is_caught else Color(0.3, 0.3, 0.3)
	var sprite_holder = ColorRect.new()
	sprite_holder.color = Color(0, 0, 0, 0)
	sprite_holder.custom_minimum_size = Vector2(100, 120)
	hbox.add_child(sprite_holder)
	
	var _sprite_node_100 = Node2D.new()
	sprite_holder.add_child(_sprite_node_100)
	SentinelSprites.draw(_sprite_node_100, data.get("id", ""), Vector2(50, 60), sprite_color, 38)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)

	var name_lbl = Label.new()
	name_lbl.text = data.get("name", "?") if is_caught else "???"
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.add_theme_color_override("font_color", type_color if is_caught else Color(0.3, 0.3, 0.4))
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_lbl)

	if is_caught:
		var type_lbl = Label.new()
		type_lbl.text = data.get("type", "")
		type_lbl.add_theme_font_size_override("font_size", 13)
		type_lbl.add_theme_color_override("font_color", Color(type_color.r, type_color.g, type_color.b, 0.7))
		vbox.add_child(type_lbl)

		var stats_lbl = Label.new()
		stats_lbl.text = "HP " + str(data.get("hp", "?")) + " · SPD " + str(data.get("speed", "?"))
		stats_lbl.add_theme_font_size_override("font_size", 13)
		stats_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
		vbox.add_child(stats_lbl)
	else:
		var locked_lbl = Label.new()
		locked_lbl.text = "[ BELUM DITEMUKAN ]"
		locked_lbl.add_theme_font_size_override("font_size", 12)
		locked_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.4))
		vbox.add_child(locked_lbl)

	return card

# ════════════════════════════════════════════
# ── NAVIGATION ──
# ════════════════════════════════════════════

func _go_back():
	var dest = GlobalData.inventory_return_path
	GlobalData.inventory_return_path = ""
	if dest != "":
		SceneManager.goto_menu(dest)
	else:
		SceneManager.goto_menu("res://menus/selection/SelectionScreen.tscn")

# ════════════════════════════════════════════
# ── HELPERS ──
# ════════════════════════════════════════════

func _make_label(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.position = pos
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	return lbl

func _style_btn(btn: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.2)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", Color.WHITE)

# Updated Type Color Mapper (Disesuaikan dengan tipe-tipeSentinel di Protocol Elysium)
func _get_type_color(type: String) -> Color:
	match type:
		"Data":               return Color(0.4, 0.8, 1.0)
		"Connection":         return Color(1.0, 0.9, 0.3)
		"Malware":            return Color(1.0, 0.4, 0.4)
		"Defensive", "Firewall": return Color(0.2, 0.9, 0.6)
		"System":             return Color(0.6, 0.3, 1.0)
		"Social Engineering": return Color(1.0, 0.7, 0.2)
	return Color(0.7, 0.7, 0.7)
