extends Node2D

# =============================================================
# SlotSelectScreen — pilih slot save atau mulai game baru
# =============================================================
# Flow:
#   Slot ada data → konfirmasi load → load_slot() → load_map()
#   Slot kosong   → new_game() → goto SelectionScreen (pilih sentinel pertama)
#   BACK          → goto MainMenu
# =============================================================

var _slot_buttons: Array = []

func _ready():
	build_ui()

func build_ui():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.12)
	bg.size = Vector2(1920, 1080)
	add_child(bg)

	# Grid lines dekoratif
	for i in range(0, 1920, 120):
		var l = ColorRect.new()
		l.color = Color(0.1, 0.3, 0.5, 0.05)
		l.size = Vector2(1, 1080); l.position = Vector2(i, 0)
		add_child(l)

	# Title
	var title = Label.new()
	title.text = "SELECT SAVE FILE"
	title.position = Vector2(0, 80)
	title.size = Vector2(1920, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Pilih slot untuk melanjutkan atau mulai petualangan baru"
	subtitle.position = Vector2(0, 148)
	subtitle.size = Vector2(1920, 40)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
	add_child(subtitle)

	# Tiga slot card
	var card_width: float = 480.0
	var card_height: float = 520.0
	var total_width: float = card_width * 3 + 60 * 2
	var start_x: float = (1920 - total_width) / 2

	for i in 3:
		var slot = i + 1
		var x = start_x + i * (card_width + 60)
		var y = 220.0
		_build_slot_card(slot, Vector2(x, y), Vector2(card_width, card_height))

	# Back button
	var back_btn = _make_btn("← BACK", Vector2(60, 1000), Vector2(180, 55), Color(0.12, 0.12, 0.28))
	back_btn.pressed.connect(func(): SceneManager.goto_menu("res://menus/main_menu/MainMenu.tscn"))
	add_child(back_btn)

func _build_slot_card(slot: int, pos: Vector2, size: Vector2):
	var info = GlobalData.get_slot_info(slot)
	var is_empty = info.is_empty()

	# Card background
	var card = ColorRect.new()
	card.position = pos
	card.size = size
	card.color = Color(0.08, 0.12, 0.22) if not is_empty else Color(0.06, 0.08, 0.14)
	add_child(card)

	# Card border
	var border = ColorRect.new()
	border.position = pos - Vector2(2, 2)
	border.size = size + Vector2(4, 4)
	border.color = Color(0.2, 0.5, 0.8, 0.6) if not is_empty else Color(0.15, 0.2, 0.35, 0.4)
	border.z_index = -1
	add_child(border)

	# Slot number
	var slot_lbl = Label.new()
	slot_lbl.text = "SLOT %d" % slot
	slot_lbl.position = pos + Vector2(20, 18)
	slot_lbl.add_theme_font_size_override("font_size", 18)
	slot_lbl.add_theme_color_override("font_color",
		Color(0.4, 0.7, 1.0) if not is_empty else Color(0.3, 0.4, 0.5))
	add_child(slot_lbl)

	if is_empty:
		# Empty slot display
		var empty_lbl = Label.new()
		empty_lbl.text = "— EMPTY —"
		empty_lbl.position = pos + Vector2(0, size.y / 2 - 60)
		empty_lbl.size = Vector2(size.x, 50)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 26)
		empty_lbl.add_theme_color_override("font_color", Color(0.3, 0.4, 0.5))
		add_child(empty_lbl)

		var new_lbl = Label.new()
		new_lbl.text = "Start New Game"
		new_lbl.position = pos + Vector2(0, size.y / 2 - 10)
		new_lbl.size = Vector2(size.x, 40)
		new_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_lbl.add_theme_font_size_override("font_size", 18)
		new_lbl.add_theme_color_override("font_color", Color(0.4, 0.6, 0.4))
		add_child(new_lbl)
	else:
		# Team sentinels
		var team: Array = info.get("active_team", [])
		var team_lbl = Label.new()
		team_lbl.text = "PARTY"
		team_lbl.position = pos + Vector2(20, 55)
		team_lbl.add_theme_font_size_override("font_size", 14)
		team_lbl.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
		add_child(team_lbl)

		var team_names = Label.new()
		team_names.text = ", ".join(team) if not team.is_empty() else "No sentinels"
		team_names.position = pos + Vector2(20, 75)
		team_names.size = Vector2(size.x - 40, 60)
		team_names.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		team_names.add_theme_font_size_override("font_size", 18)
		team_names.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
		add_child(team_names)

		# Playtime
		var seconds = int(info.get("playtime_seconds", 0))
		var h = seconds / 3600
		var m = (seconds % 3600) / 60
		var playtime_lbl = Label.new()
		playtime_lbl.text = "Playtime: %02d:%02d" % [h, m]
		playtime_lbl.position = pos + Vector2(20, 160)
		playtime_lbl.add_theme_font_size_override("font_size", 16)
		playtime_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 0.5))
		add_child(playtime_lbl)

		# Timestamp
		var ts = info.get("save_timestamp", "")
		var ts_lbl = Label.new()
		ts_lbl.text = "Saved: " + ts
		ts_lbl.position = pos + Vector2(20, 190)
		ts_lbl.size = Vector2(size.x - 40, 40)
		ts_lbl.add_theme_font_size_override("font_size", 14)
		ts_lbl.add_theme_color_override("font_color", Color(0.4, 0.5, 0.6))
		add_child(ts_lbl)

		# Delete button
		var del_btn = _make_btn("🗑 DELETE", pos + Vector2(size.x - 130, 15), Vector2(115, 36), Color(0.35, 0.08, 0.08))
		del_btn.add_theme_font_size_override("font_size", 13)
		var captured_slot = slot
		del_btn.pressed.connect(func(): _confirm_delete(captured_slot))
		add_child(del_btn)

	# Main action button (load atau new game)
	var btn_label = "▶ CONTINUE" if not is_empty else "+ NEW GAME"
	var btn_color = Color(0.08, 0.35, 0.12) if not is_empty else Color(0.15, 0.25, 0.5)
	var action_btn = _make_btn(btn_label, pos + Vector2(20, size.y - 75), Vector2(size.x - 40, 55), btn_color)
	action_btn.add_theme_font_size_override("font_size", 22)
	var captured_slot = slot
	var captured_empty = is_empty
	action_btn.pressed.connect(func(): _on_slot_pressed(captured_slot, captured_empty))
	add_child(action_btn)

func _on_slot_pressed(slot: int, is_empty: bool):
	if is_empty:
		# New game — mulai fresh, ke SelectionScreen untuk pilih sentinel pertama
		GlobalData.new_game(slot)
		SceneManager.goto_menu("res://menus/selection/SelectionScreen.tscn")
	else:
		# Load save — langsung ke map di posisi terakhir
		var success = GlobalData.load_slot(slot)
		if success:
			SceneManager.load_map(GlobalData.current_map)
		else:
			push_error("SlotSelectScreen: Gagal load slot " + str(slot))

func _confirm_delete(slot: int):
	# Simple konfirmasi via popup label sementara
	# TODO: ganti dengan dialog proper saat InGameMenu sudah ada
	GlobalData.delete_slot(slot)
	# Rebuild UI untuk refresh tampilan
	for child in get_children():
		child.queue_free()
	build_ui()

func _make_btn(text: String, pos: Vector2, size: Vector2, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = size
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 18)
	return btn
