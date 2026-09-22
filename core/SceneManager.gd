extends Node

# =============================================================
# SceneManager — kontrol penuh semua navigasi scene
# =============================================================
#
# TIDAK ADA change_scene_to_file di manapun.
# SceneManager yang instantiate dan queue_free semua scene.
#
# TIGA LAYER:
#
#   _menu_layer  (CanvasLayer, layer=20)
#     Untuk: MainMenu, SelectionScreen, SlotSelectScreen
#     Selalu full-screen, tidak coexist dengan map
#     Saat menu aktif: map dan overlay di-clear
#
#   _map_layer   (Node)
#     Untuk: Map + Player + World
#     Camera2D di dalam player bekerja normal di Node biasa
#     Di-pause saat ada overlay aktif
#
#   _overlay_layer (CanvasLayer, layer=10)
#     Untuk: Battle, InGameMenu, Dialog, Shop
#     Stack-based — bisa ada beberapa overlay sekaligus
#     Semua overlay di-set PROCESS_MODE_ALWAYS supaya jalan saat tree pause
#
# AUTOSAVE:
#     Timer 5 menit, hanya fire kalau:
#     - _map_layer punya child (player di map)
#     - _overlay_stack kosong (tidak ada battle/menu aktif)
#     - GlobalData.current_slot > 0 (sudah pilih slot)
# =============================================================

const AUTOSAVE_INTERVAL: float = 300.0  # 5 menit

var _menu_layer: Node = null
var _map_layer: Node = null
var _overlay_layer: CanvasLayer = null

var _current_menu: Node = null
var _current_map: Node = null
var _overlay_stack: Array = []

var _autosave_timer: float = 0.0

# ─────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────

func _ready():
	_setup_layers()

func _setup_layers():
	# Map layer — Node biasa supaya Camera2D bekerja normal
	_map_layer = Node.new()
	_map_layer.name = "MapLayer"
	add_child(_map_layer)

	# Overlay layer — CanvasLayer supaya render di atas map
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.name = "OverlayLayer"
	_overlay_layer.layer = 10
	add_child(_overlay_layer)

	# Menu layer — CanvasLayer paling atas, selalu full-screen
	_menu_layer = Node.new()
	_menu_layer.name = "MenuLayer"
	add_child(_menu_layer)

func _process(delta: float):
	_tick_autosave(delta)

func _tick_autosave(delta: float):
	# Safety net: hanya autosave kalau kondisi aman
	if not _is_safe_to_autosave():
		return
	_autosave_timer += delta
	if _autosave_timer >= AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		_do_autosave()

func _is_safe_to_autosave() -> bool:
	return (
		GlobalData.current_slot > 0 and          # sudah pilih slot
		_current_map != null and                  # ada map aktif
		_overlay_stack.is_empty()                 # tidak ada battle/menu overlay
	)

func _do_autosave():
	# Update posisi player sebelum save
	_update_player_position()
	GlobalData.current_map = GlobalData.current_map  # sudah di-set saat load_map
	GlobalData.save_current_slot()
	print("SceneManager: Autosave selesai")

func _update_player_position():
	# Cari player node di dalam map
	if _current_map == null:
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		GlobalData.player_position = players[0].global_position

# ─────────────────────────────────────────
# MENU NAVIGATION
# Untuk: MainMenu, SelectionScreen, SlotSelectScreen
# ─────────────────────────────────────────

func goto_menu(path: String):
	# Clear semua overlay dulu
	_clear_all_overlays()
	# Unload map kalau ada
	_unload_map()
	# Unpause tree
	get_tree().paused = false
	# Reset runtime state
	GlobalData.reset_runtime_state()
	# Swap menu
	_swap_menu(path)

func _swap_menu(path: String):
	# Queue free menu lama
	if _current_menu != null and is_instance_valid(_current_menu):
		_current_menu.queue_free()
		_current_menu = null

	# Load menu baru
	var scene = load(path).instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	_menu_layer.add_child(scene)
	_current_menu = scene

# ─────────────────────────────────────────
# MAP
# ─────────────────────────────────────────

func load_map(path: String):
	# Clear overlay dan menu
	_clear_all_overlays()
	_unload_menu()
	get_tree().paused = false

	# Update GlobalData
	GlobalData.current_map = path

	# Unload map lama
	_unload_map()

	# Load map baru
	var map_scene = load(path).instantiate()
	_map_layer.add_child(map_scene)
	_current_map = map_scene

	# Restore posisi player setelah map ready
	# Pakai call_deferred supaya map sudah fully ready
	await get_tree().process_frame
	await get_tree().process_frame
	_restore_player_position()

	# Reset autosave timer saat masuk map
	_autosave_timer = 0.0

func _restore_player_position():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		players[0].global_position = GlobalData.player_position

func _unload_map():
	if _current_map != null and is_instance_valid(_current_map):
		_current_map.queue_free()
		_current_map = null

func _unload_menu():
	if _current_menu != null and is_instance_valid(_current_menu):
		_current_menu.queue_free()
		_current_menu = null

# ─────────────────────────────────────────
# OVERLAY
# Untuk: Battle, InGameMenu, Dialog, Shop
# ─────────────────────────────────────────

func push_overlay(path: String):
	# Pause seluruh tree (map berhenti, encounter zone berhenti)
	get_tree().paused = true

	var scene = load(path).instantiate()
	# Overlay harus ALWAYS supaya bisa jalan saat tree pause
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay_layer.add_child(scene)
	_overlay_stack.append(scene)

func pop_overlay():
	if _overlay_stack.is_empty():
		push_warning("SceneManager.pop_overlay() dipanggil tapi stack kosong")
		get_tree().paused = false
		return

	var top = _overlay_stack.pop_back()
	if is_instance_valid(top):
		top.queue_free()

	if _overlay_stack.is_empty():
		# Semua overlay sudah ditutup — unpause map
		get_tree().paused = false

		# Cek apakah perlu save (post-battle win atau catch)
		if GlobalData.pending_save and GlobalData.current_slot > 0:
			GlobalData.pending_save = false
			# Update posisi sebelum save
			_update_player_position()
			GlobalData.save_current_slot()

		# Reset autosave timer supaya tidak langsung autosave
		_autosave_timer = 0.0

# Ganti overlay teratas dengan scene baru
# Dipakai untuk Battle → ResultScreen transition
func replace_overlay(path: String):
	if not _overlay_stack.is_empty():
		var top = _overlay_stack.pop_back()
		if is_instance_valid(top):
			top.queue_free()

	# Tree tetap pause
	var scene = load(path).instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay_layer.add_child(scene)
	_overlay_stack.append(scene)

# ─────────────────────────────────────────
# UTILITY
# ─────────────────────────────────────────

func has_overlay() -> bool:
	return not _overlay_stack.is_empty()

func get_top_overlay() -> Node:
	if _overlay_stack.is_empty():
		return null
	return _overlay_stack.back()

func get_current_map_path() -> String:
	return GlobalData.current_map

func is_in_map() -> bool:
	return _current_map != null

func _clear_all_overlays():
	for scene in _overlay_stack:
		if is_instance_valid(scene):
			scene.queue_free()
	_overlay_stack.clear()
