extends Area2D

# ══════════════════════════════════════════════
#  EncounterZone.gd
#  Taruh di: res://battle/EncounterZone.gd
#
#  Cara pakai:
#  1. Buat node Area2D di map
#  2. Tambah CollisionShape2D sebagai child
#  3. Attach script ini
#  4. Set zone_id di Inspector (harus sama dengan key di world_data.json)
#  5. Set encounter_type: "random" untuk grinding, "fixed" untuk boss/event
# ══════════════════════════════════════════════

@export var zone_id: String = "data_haven"
@export var encounter_type: String = "random"   # "random" | "fixed"
@export var fixed_enemy_id: String = ""          # Hanya dipakai kalau encounter_type = "fixed"
@export var is_boss_encounter: bool = false
@export var steps_to_trigger: int = 10           # Override default dari world_data.json

var _world_data: Dictionary = {}
var _zone_data: Dictionary = {}
var _player_inside: bool = false
var _step_counter: float = 0.0
var _defeated: bool = false     # Fixed encounter tidak spawn ulang setelah kalah
var _player_ref: Node = null

func _ready():
	_load_world_data()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _load_world_data():
	var path = "res://data/world_data.json"
	if not FileAccess.file_exists(path):
		push_error("EncounterZone: world_data.json tidak ditemukan di " + path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	if err != OK:
		push_error("EncounterZone: Gagal parse world_data.json")
		return

	_world_data = json.get_data()
	if _world_data["zones"].has(zone_id):
		_zone_data = _world_data["zones"][zone_id]

		# Override steps dari world_data kalau tidak di-set manual
		var settings = _world_data.get("encounter_settings", {})
		if steps_to_trigger == 10:  # Default value — pakai dari JSON
			var min_s = settings.get("steps_per_encounter_min", 8)
			var max_s = settings.get("steps_per_encounter_max", 15)
			steps_to_trigger = randi_range(min_s, max_s)
	else:
		push_warning("EncounterZone: zone_id '" + zone_id + "' tidak ditemukan di world_data.json")

func _on_body_entered(body):
	if not _is_player(body):
		return
	if _defeated and encounter_type == "fixed":
		return

	_player_ref = body
	_player_inside = true
	_step_counter = 0.0

	if encounter_type == "fixed":
		_trigger_encounter()
	elif encounter_type == "random":
		# Connect ke sinyal player_moved kalau ada
		if body.has_signal("player_moved"):
			if not body.player_moved.is_connected(_on_player_stepped):
				body.player_moved.connect(_on_player_stepped)

func _on_body_exited(body):
	if not _is_player(body):
		return
	_player_inside = false
	_player_ref = null

	if body.has_signal("player_moved"):
		if body.player_moved.is_connected(_on_player_stepped):
			body.player_moved.disconnect(_on_player_stepped)

func _on_player_stepped():
	if not _player_inside:
		return
	_step_counter += 1.0
	if _step_counter >= steps_to_trigger:
		_step_counter = 0.0
		steps_to_trigger = randi_range(
			_world_data.get("encounter_settings", {}).get("steps_per_encounter_min", 8),
			_world_data.get("encounter_settings", {}).get("steps_per_encounter_max", 15)
		)
		_trigger_encounter()

func _trigger_encounter():
	var enemy_id = _pick_enemy()
	if enemy_id == "":
		return

	if encounter_type == "fixed":
		_defeated = true

	# Simpan encounter data ke GlobalData (ganti root meta yang lama)
	GlobalData.set_encounter(enemy_id, zone_id, is_boss_encounter)

	# Kalau sudah punya team, langsung ke Battle via overlay
	# Kalau belum, ke SelectionScreen dulu (via menu layer)
	if GlobalData.active_team.size() > 0:
		SceneManager.push_overlay("res://battle/Battle.tscn")
	else:
		SceneManager.goto_menu("res://menus/selection/SelectionScreen.tscn")

func _pick_enemy() -> String:
	if _zone_data.is_empty():
		return ""

	# Boss encounter — langsung dari zone data
	if is_boss_encounter:
		var boss = _zone_data.get("boss", null)
		if boss != null:
			return boss["id"]

	# Cek wildcard
	var settings = _world_data.get("encounter_settings", {})
	var wildcard_chance = settings.get("wildcard_chance", 0.20)

	if randf() < wildcard_chance:
		var wildcards = _world_data.get("wildcard_pool", [])
		if wildcards.size() > 0:
			return wildcards[randi() % wildcards.size()]["id"]

	# Pilih dari enemy_pool berdasarkan weight
	var pool: Array = _zone_data.get("enemy_pool", [])
	if pool.is_empty():
		return ""

	var total_weight: int = 0
	for entry in pool:
		total_weight += int(entry.get("weight", 1))

	var roll: int = randi() % total_weight
	var cumulative: int = 0
	for entry in pool:
		cumulative += int(entry.get("weight", 1))
		if roll < cumulative:
			return entry["id"]

	return pool[0]["id"]

func _is_player(body: Node) -> bool:
	return body.name == "Player" or body.is_in_group("player")

# ── Debug helper — bisa dipanggil dari Godot console ──
func debug_roll_enemy() -> void:
	print("Zone: ", zone_id)
	print("Rolled enemy: ", _pick_enemy())
