extends Node

# =============================================================
# GlobalData — Single source of truth untuk semua game state
# =============================================================
#
# DUA KATEGORI DATA:
#
# 1. PERSISTENT STATE — disave ke file per slot
#    Semua yang perlu survive restart game
#
# 2. RUNTIME STATE — tidak disave, reset tiap session
#    Data sementara antar scene (ganti root meta yang lama)
#
# SAVE SYSTEM:
#    3 slot, masing-masing file JSON terpisah
#    save_current_slot() — satu-satunya fungsi yang tulis ke disk
#    Dipanggil oleh: autosave timer, manual save, SceneManager.pop_overlay()
#    (kalau pending_save = true setelah battle menang / catch berhasil)
# =============================================================

# ── SAVE PATHS ──
const SAVE_PATHS: Dictionary = {
	1: "user://save_slot1.json",
	2: "user://save_slot2.json",
	3: "user://save_slot3.json"
}
const DEFAULT_MAP: String = "res://ui/test_map.tscn"
const DEFAULT_SPAWN: Vector2 = Vector2(448, 533)

# ─────────────────────────────────────────
# PERSISTENT STATE (disave ke file)
# ─────────────────────────────────────────

var current_slot: int = 0
var is_first_time: bool = true

# Player world state
var player_position: Vector2 = DEFAULT_SPAWN
var current_map: String = DEFAULT_MAP

# Team & collection
var active_team: Array = []
var caught_sentinels: Array = []
const MAX_TEAM_SIZE: int = 6

# Items
var items: Dictionary = {}

# Progress
var battles_won: int = 0
const ITEM_REWARD_INTERVAL: int = 3

# Save metadata
var save_timestamp: String = ""
var playtime_seconds: float = 0.0

# ─────────────────────────────────────────
# RUNTIME STATE (tidak disave)
# Menggantikan semua root.set_meta / root.get_meta yang lama
# ─────────────────────────────────────────

var encounter_enemy: String = ""
var encounter_zone: String = ""
var encounter_is_boss: bool = false

var pending_sentinel: String = ""

var battle_result: Dictionary = {}
# Format: {
#   "player_won": bool,
#   "player_name": String,
#   "enemy_name": String,
#   "moves_used": int
# }

# Flag untuk trigger save setelah pop_overlay
# Di-set true oleh Battle kalau menang atau catch berhasil
# Di-consume dan di-reset oleh SceneManager.pop_overlay()
var pending_save: bool = false
var inventory_return_path: String = ""  # path untuk kembali dari Inventory

# ─────────────────────────────────────────
# ITEM DEFINITIONS (static)
# ─────────────────────────────────────────

const ITEM_DATA: Dictionary = {
	"heal_potion": {
		"name": "Heal Potion",
		"description": "Memulihkan 40 HP sentinel aktif.",
		"icon": "💊",
		"heal_amount": 40,
		"usable_in_battle": true
	},
	"capture_key": {
		"name": "Capture Key",
		"description": "Mencoba menangkap sentinel lawan. Chance lebih tinggi jika HP lawan rendah.",
		"icon": "🔑",
		"usable_in_battle": true
	},
	"revive_chip": {
		"name": "Revive Chip",
		"description": "Memulihkan sentinel yang pingsan dengan 30 HP.",
		"icon": "⚡",
		"usable_in_battle": false
	}
}

# ─────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────

func _ready():
	pass

func _process(delta: float):
	if current_slot > 0:
		playtime_seconds += delta

# ─────────────────────────────────────────
# TEAM MANAGEMENT
# ─────────────────────────────────────────

func add_to_team(monster_id: String) -> bool:
	if active_team.size() >= MAX_TEAM_SIZE:
		return false
	if monster_id in active_team:
		return false
	active_team.append(monster_id)
	return true

func remove_from_team(monster_id: String):
	active_team.erase(monster_id)

func set_active_team(new_team: Array):
	active_team = new_team.slice(0, MAX_TEAM_SIZE)

func get_active_monster_id() -> String:
	if active_team.is_empty():
		return "encryp_pup"
	return active_team[0]

# ─────────────────────────────────────────
# CAUGHT SENTINEL MANAGEMENT
# ─────────────────────────────────────────

func catch_sentinel(monster_id: String):
	if monster_id not in caught_sentinels:
		caught_sentinels.append(monster_id)
	if active_team.size() < MAX_TEAM_SIZE and monster_id not in active_team:
		active_team.append(monster_id)
	pending_save = true

func has_caught(monster_id: String) -> bool:
	return monster_id in caught_sentinels

# ─────────────────────────────────────────
# ITEM MANAGEMENT
# ─────────────────────────────────────────

func get_item_count(item_id: String) -> int:
	return items.get(item_id, 0)

func add_item(item_id: String, amount: int = 1):
	items[item_id] = items.get(item_id, 0) + amount

func use_item(item_id: String) -> bool:
	if get_item_count(item_id) <= 0:
		return false
	items[item_id] -= 1
	if items[item_id] <= 0:
		items.erase(item_id)
	return true

func give_starter_items():
	add_item("heal_potion", 3)
	add_item("capture_key", 2)

# ─────────────────────────────────────────
# BATTLE REWARD
# ─────────────────────────────────────────

func on_battle_won() -> bool:
	battles_won += 1
	var got_reward = false
	if battles_won % ITEM_REWARD_INTERVAL == 0:
		add_item("heal_potion", 1)
		add_item("capture_key", 1)
		got_reward = true
	pending_save = true
	return got_reward

# ─────────────────────────────────────────
# FIRST TIME
# ─────────────────────────────────────────

func mark_played():
	is_first_time = false
	give_starter_items()

# ─────────────────────────────────────────
# RUNTIME STATE HELPERS
# ─────────────────────────────────────────

func set_encounter(enemy_id: String, zone: String, is_boss: bool):
	encounter_enemy = enemy_id
	encounter_zone = zone
	encounter_is_boss = is_boss

func clear_encounter():
	encounter_enemy = ""
	encounter_zone = ""
	encounter_is_boss = false

func set_battle_result(player_won: bool, p_name: String, e_name: String, moves: Array):
	battle_result = {
		"player_won": player_won,
		"player_name": p_name,
		"enemy_name": e_name,
		"moves_used": moves
	}

func clear_battle_result():
	battle_result = {}

func reset_runtime_state():
	clear_encounter()
	clear_battle_result()
	pending_sentinel = ""
	pending_save = false
	inventory_return_path = ""

# ─────────────────────────────────────────
# SAVE / LOAD
# ─────────────────────────────────────────

func save_current_slot():
	if current_slot == 0:
		push_warning("GlobalData.save_current_slot() dipanggil tapi current_slot = 0")
		return

	save_timestamp = Time.get_datetime_string_from_system()

	var data = {
		"is_first_time": is_first_time,
		"player_position": {"x": player_position.x, "y": player_position.y},
		"current_map": current_map,
		"active_team": active_team,
		"caught_sentinels": caught_sentinels,
		"items": items,
		"battles_won": battles_won,
		"save_timestamp": save_timestamp,
		"playtime_seconds": playtime_seconds
	}

	var path = SAVE_PATHS[current_slot]
	var f = FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()
		print("GlobalData: Saved slot ", current_slot, " at ", save_timestamp)
	else:
		push_error("GlobalData: Gagal save ke " + path)

func load_slot(slot: int) -> bool:
	if slot not in SAVE_PATHS:
		push_error("GlobalData.load_slot(): slot tidak valid — " + str(slot))
		return false

	var path = SAVE_PATHS[slot]
	if not FileAccess.file_exists(path):
		return false

	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return false

	var raw = f.get_as_text()
	f.close()

	var json = JSON.new()
	if json.parse(raw) != OK:
		push_error("GlobalData: Save slot " + str(slot) + " corrupt")
		return false

	var data = json.get_data()
	current_slot     = slot
	is_first_time    = data.get("is_first_time", true)
	active_team      = data.get("active_team", [])
	caught_sentinels = data.get("caught_sentinels", [])
	items            = data.get("items", {})
	battles_won      = data.get("battles_won", 0)
	save_timestamp   = data.get("save_timestamp", "")
	playtime_seconds = data.get("playtime_seconds", 0.0)
	current_map      = data.get("current_map", DEFAULT_MAP)

	var pos          = data.get("player_position", {"x": DEFAULT_SPAWN.x, "y": DEFAULT_SPAWN.y})
	player_position  = Vector2(pos.get("x", DEFAULT_SPAWN.x), pos.get("y", DEFAULT_SPAWN.y))

	print("GlobalData: Loaded slot ", slot, " — team: ", active_team, " | pos: ", player_position)
	return true

func new_game(slot: int):
	if slot not in SAVE_PATHS:
		push_error("GlobalData.new_game(): slot tidak valid")
		return

	current_slot     = slot
	is_first_time    = true
	player_position  = DEFAULT_SPAWN
	current_map      = DEFAULT_MAP
	active_team      = []
	caught_sentinels = []
	items            = {}
	battles_won      = 0
	playtime_seconds = 0.0
	save_timestamp   = ""

	mark_played()
	save_current_slot()

func get_slot_info(slot: int) -> Dictionary:
	if slot not in SAVE_PATHS:
		return {}

	var path = SAVE_PATHS[slot]
	if not FileAccess.file_exists(path):
		return {}

	var f = FileAccess.open(path, FileAccess.READ)
	if not f:
		return {}

	var raw = f.get_as_text()
	f.close()

	var json = JSON.new()
	if json.parse(raw) != OK:
		return {}

	var data = json.get_data()
	return {
		"slot": slot,
		"active_team": data.get("active_team", []),
		"save_timestamp": data.get("save_timestamp", ""),
		"playtime_seconds": data.get("playtime_seconds", 0.0),
		"current_map": data.get("current_map", DEFAULT_MAP)
	}

func delete_slot(slot: int):
	if slot not in SAVE_PATHS:
		return
	var path = SAVE_PATHS[slot]
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		print("GlobalData: Deleted slot ", slot)
