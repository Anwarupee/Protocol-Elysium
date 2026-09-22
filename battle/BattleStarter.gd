extends Node

# ══════════════════════════════════════════════
#  BattleStarter.gd
#  Taruh di: res://battle/BattleStarter.gd
#
#  Dipanggil dari SelectionScreen setelah player
#  memilih Sentinel-nya. Membaca meta dari
#  EncounterZone dan mulai battle yang tepat.
#
#  Di SelectionScreen.gd, ganti bagian
#  "start battle" dengan:
#    BattleStarter.start(player_id, get_tree())
# ══════════════════════════════════════════════

static func start(player_sentinel_id: String, tree: SceneTree) -> void:
	var root = tree.root

	# Baca data encounter yang di-set EncounterZone
	var enemy_id    = root.get_meta("encounter_enemy", "biti")
	var zone_id     = root.get_meta("encounter_zone", "data_haven")
	var is_boss     = root.get_meta("encounter_is_boss", false)
	var from_map    = root.get_meta("came_from_map", false)

	# Set data untuk Battle.gd
	var battle_scene = load("res://battle/Battle.tscn").instantiate()
	battle_scene.set_meta("player_monster", player_sentinel_id)
	battle_scene.set_meta("enemy_monster", enemy_id)
	battle_scene.set_meta("zone_id", zone_id)
	battle_scene.set_meta("is_boss", is_boss)
	battle_scene.set_meta("return_to_map", from_map)

	root.add_child(battle_scene)
	tree.current_scene = battle_scene

static func get_return_scene(tree: SceneTree) -> Node:
	# Dipanggil dari ResultScreen untuk kembali ke map atau selection
	var from_map = tree.root.get_meta("came_from_map", false)
	if from_map:
		# Kembali ke map — scene path disesuaikan nanti
		return load("res://menus/main_menu/MainMenu.tscn").instantiate()
	else:
		return load("res://menus/selection/SelectionScreen.tscn").instantiate()
