extends Node

var player_monster: Monster
var enemy_monster: Monster
var monsters_data: Array = []
var pending_trojan_target: Monster = null
var trojan_turns_left: int = 0
var trojan_power: int = 0
var last_enemy_move: Dictionary = {}

signal battle_log(message: String)
signal edu_log(message: String)
signal battle_ended(player_won: bool)
signal hp_updated(player_hp: int, player_max: int, enemy_hp: int, enemy_max: int)
signal enemy_attacking
signal cooldown_updated(cooldowns: Array)

func _ready():
	load_monsters()

func load_monsters():
	var file = FileAccess.open("res://data/monsters.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		monsters_data = json.get_data()["monsters"]
		file.close()

func get_monster_data(id: String) -> Dictionary:
	for data in monsters_data:
		if data["id"] == id:
			return data
	return {}

func start_battle(player_id: String, enemy_id: String):
	player_monster = create_monster(player_id)
	enemy_monster = create_monster(enemy_id)
	emit_signal("battle_log", "Battle Start! " + player_monster.monster_name + " VS " + enemy_monster.monster_name)
	emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
	emit_signal("cooldown_updated", get_cooldown_states())

func create_monster(id: String) -> Monster:
	for data in monsters_data:
		if data["id"] == id:
			var m = Monster.new()
			m.load_from_dict(data)
			return m
	return null

func get_cooldown_states() -> Array:
	var states = []
	for move in player_monster.moves:
		states.append(player_monster.is_move_on_cooldown(move["name"]))
	return states

func player_use_move(move_index: int):
	if not player_monster.is_alive() or not enemy_monster.is_alive():
		return

	var move = player_monster.moves[move_index]

	if player_monster.is_move_on_cooldown(move["name"]):
		emit_signal("battle_log", move["name"] + " is on cooldown!")
		emit_signal("cooldown_updated", get_cooldown_states())
		return

	execute_move(player_monster, enemy_monster, move, true)
	player_monster.tick_cooldowns()
	player_monster.tick_status()
	_tick_dot(player_monster)

	if enemy_monster.is_alive():
		await get_tree().create_timer(1.0).timeout
		emit_signal("enemy_attacking")
		await get_tree().create_timer(0.3).timeout
		enemy_turn()

	_tick_dot(enemy_monster)
	_tick_background_process()

	enemy_monster.tick_cooldowns()
	enemy_monster.tick_status()

	emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
	emit_signal("cooldown_updated", get_cooldown_states())
	check_battle_end()

func _tick_dot(source: Monster):
	if source.dot_turns > 0 and source.dot_target != null:
		source.dot_target.hp = max(0, source.dot_target.hp - source.dot_power)
		source.dot_turns -= 1
		emit_signal("battle_log", "DoT! " + str(source.dot_power) + " damage!")
		if source.dot_turns <= 0:
			source.dot_target = null

func _tick_background_process():
	if enemy_monster.passive["name"] == "Background Process" and randf() < 0.2:
		player_monster.hp = max(0, player_monster.hp - 10)
		emit_signal("battle_log", "Background Process! 10 auto damage!")
	if player_monster.passive["name"] == "Background Process" and randf() < 0.2:
		enemy_monster.hp = max(0, enemy_monster.hp - 10)
		emit_signal("battle_log", "Background Process! 10 auto damage!")

func enemy_turn():
	var available_moves = []
	for move in enemy_monster.moves:
		if not enemy_monster.is_move_on_cooldown(move["name"]):
			if move["effect"] != "copy_move" or not last_enemy_move.is_empty():
				available_moves.append(move)

	if available_moves.is_empty():
		emit_signal("battle_log", enemy_monster.monster_name + " has no available moves!")
		return

	var move = available_moves[randi() % available_moves.size()]
	for m in available_moves:
		if enemy_monster.hp < enemy_monster.max_hp * 0.3 and m["effect"] == "heal":
			move = m
			break
		if m.get("power", 0) > 0 and randf() < 0.6:
			move = m

	execute_move(enemy_monster, player_monster, move, false)

func execute_move(attacker: Monster, defender: Monster, move: Dictionary, is_player: bool):
	var who = "You used" if is_player else (attacker.monster_name + " used")

	if attacker.blocked_next_turn:
		emit_signal("battle_log", attacker.monster_name + "'s move was blocked!")
		attacker.blocked_next_turn = false
		return

	# Polymorphic miss
	var poly_chance = 0.3
	if defender.polymorphic_boosted:
		poly_chance = 0.6
	if defender.passive["name"] == "Polymorphic" and randf() < poly_chance:
		emit_signal("battle_log", "Attack missed! " + defender.monster_name + " morphed away!")
		return

	# Vishing passive
	if defender.passive["name"] == "Vishing" and randf() < 0.25:
		attacker.hp = max(0, attacker.hp - int(move.get("power", 0) * 0.5))
		emit_signal("battle_log", "Vishing! Attack backfired on " + attacker.monster_name + "!")
		emit_signal("edu_log", move["edu_log"])
		return

	# Legacy Code passive
	if attacker.passive["name"] != "Legacy Code" and defender.passive["name"] == "Legacy Code" and randf() < 0.15:
		emit_signal("battle_log", "Compatibility Error! " + attacker.monster_name + "'s move failed!")
		return

	# Honeypot passive
	if defender.passive["name"] == "Honeypot" and move.get("power", 0) > 60 and randf() < 0.3:
		emit_signal("battle_log", "Honeypot triggered! " + attacker.monster_name + " is trapped!")
		attacker.blocked_next_turn = true

	emit_signal("battle_log", who + " " + move["name"] + "!")
	emit_signal("edu_log", move["edu_log"])

	if move.get("cooldown", 0) > 0:
		attacker.set_cooldown(move["name"], move["cooldown"])

	# Identity Theft passive
	if is_player and player_monster.passive["name"] == "Identity Theft" and randf() < 0.2:
		player_monster.type = enemy_monster.type
		emit_signal("battle_log", "Identity Theft! Type changed to " + player_monster.type + "!")
	elif not is_player and enemy_monster.passive["name"] == "Identity Theft" and randf() < 0.2:
		enemy_monster.type = player_monster.type
		emit_signal("battle_log", "Identity Theft! Type changed to " + enemy_monster.type + "!")

	# AES-256 passive
	if attacker.passive["name"] == "AES-256" and randf() < 0.2:
		attacker.defense_stage += 1
		emit_signal("battle_log", "AES-256 encrypted attacker! Defense +1!")

	MoveEffects.execute(move, attacker, defender, self)

	if not is_player:
		last_enemy_move = move

	# Trojan tick
	if pending_trojan_target != null:
		trojan_turns_left -= 1
		if trojan_turns_left <= 0:
			pending_trojan_target.take_damage(trojan_power)
			emit_signal("battle_log", "Trojan Gift EXPLODED!")
			pending_trojan_target = null

func get_type_multiplier(attacker_type: String, defender_type: String) -> float:
	var advantage = {
		"Data": {"strong": "Malware", "weak": "Connection"},
		"Connection": {"strong": "Data", "weak": "Malware"},
		"Malware": {"strong": "Connection", "weak": "Data"},
		"Defensive": {"strong": "Social Engineering", "weak": "System"},
		"System": {"strong": "Data", "weak": "Social Engineering"},
		"Social Engineering": {"strong": "System", "weak": "Connection"}
	}
	if not advantage.has(attacker_type):
		return 1.0
	if advantage[attacker_type]["strong"] == defender_type:
		return 1.5
	elif advantage[attacker_type]["weak"] == defender_type:
		return 0.5
	return 1.0

func check_battle_end():
	if player_monster == null or enemy_monster == null:
		return
	if player_monster.max_hp == 0 or enemy_monster.max_hp == 0:
		return

	if not enemy_monster.is_alive():
		if enemy_monster.passive["name"] == "Kernel Panic":
			player_monster.hp = max(0, player_monster.hp - 25)
			emit_signal("battle_log", "KERNEL PANIC! 25 damage reflected!")
			emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
			await get_tree().create_timer(1.0).timeout

		if not player_monster.is_alive():
			emit_signal("battle_log", "Kernel Panic knocked you out!")
			emit_signal("battle_ended", false)
		else:
			emit_signal("battle_log", "You won!")
			emit_signal("battle_ended", true)

	elif not player_monster.is_alive():
		emit_signal("battle_log", "You lost!")
		emit_signal("battle_ended", false)
