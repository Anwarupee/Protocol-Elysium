exextends Node

var player_monster: Monster
var enemy_monster: Monster
var monsters_data: Array = []
var pending_trojan_target: Monster = null
var trojan_turns_left: int = 0
var trojan_power: int = 0
var last_enemy_move: Dictionary = {}
var tutorial_mode: bool = false
var moves_used_this_battle: Array = []

# ── EDU POPUP SYSTEM ──
var move_popup_count: Dictionary = {}
const MAX_POPUP_PER_MOVE = 2

signal battle_log(message: String)
signal edu_log(message: String)
signal edu_popup(move_name: String, edu_text: String, domain: String)
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
	moves_used_this_battle.clear()
	player_monster = create_monster(player_id)
	enemy_monster = create_monster(enemy_id)
	move_popup_count.clear()

	# ── Trigger on-entry passives ──
	_apply_entry_passives(player_monster, enemy_monster)
	_apply_entry_passives(enemy_monster, player_monster)

	emit_signal("battle_log", "Battle Start! " + player_monster.monster_name + " VS " + enemy_monster.monster_name)
	emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
	emit_signal("cooldown_updated", get_cooldown_states())

func _apply_entry_passives(monster: Monster, opponent: Monster):
	match monster.passive["name"]:
		"Verificator":
			if not monster.verificator_applied:
				monster.accuracy_stage += 1
				monster.verificator_applied = true
				emit_signal("battle_log", monster.monster_name + "'s Verificator activated! Accuracy +1!")
		"Deep Scan":
			if not monster.deep_scan_applied:
				monster.accuracy_stage += 1
				monster.deep_scan_applied = true
				emit_signal("battle_log", monster.monster_name + "'s Deep Scan activated! Accuracy +1!")
		"Lure":
			if not monster.lure_applied:
				opponent.defense_stage -= 1
				monster.lure_applied = true
				emit_signal("battle_log", monster.monster_name + "'s Lure activated! " + opponent.monster_name + "'s Defense -1!")
		"Low Latency":
			emit_signal("battle_log", monster.monster_name + " moves first due to Low Latency!")

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

# ── SMART REPETITION POPUP ──
func should_show_popup(move_name: String) -> bool:
	if tutorial_mode:
		return true
	var count = move_popup_count.get(move_name, 0)
	return count < MAX_POPUP_PER_MOVE

func register_popup_shown(move_name: String):
	move_popup_count[move_name] = move_popup_count.get(move_name, 0) + 1

func try_show_edu_popup(move: Dictionary, attacker: Monster) -> bool:
	var move_name = move["name"]
	var edu_text = move.get("edu_popup", move.get("edu_log", ""))
	if edu_text == "":
		return false
	if not should_show_popup(move_name):
		return false
	register_popup_shown(move_name)
	emit_signal("edu_popup", move_name, edu_text, attacker.type)
	return true

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

	if player_monster.dot_turns > 0 and player_monster.dot_target != null:
		player_monster.dot_target.hp = max(0, player_monster.dot_target.hp - player_monster.dot_power)
		player_monster.dot_turns -= 1
		emit_signal("battle_log", "DoT damage! " + str(player_monster.dot_power) + " damage over time!")
		if player_monster.dot_turns <= 0:
			player_monster.dot_target = null

	if enemy_monster.is_alive():
		await get_tree().create_timer(1.0).timeout
		emit_signal("enemy_attacking")
		await get_tree().create_timer(0.3).timeout
		enemy_turn()

	if enemy_monster.dot_turns > 0 and enemy_monster.dot_target != null:
		enemy_monster.dot_target.hp = max(0, enemy_monster.dot_target.hp - enemy_monster.dot_power)
		enemy_monster.dot_turns -= 1
		emit_signal("battle_log", "DoT damage! " + str(enemy_monster.dot_power) + " damage!")
		if enemy_monster.dot_turns <= 0:
			enemy_monster.dot_target = null

	if enemy_monster.passive["name"] == "Background Process" and randf() < 0.2:
		player_monster.hp = max(0, player_monster.hp - 10)
		emit_signal("battle_log", "Background Process triggered! 10 automatic damage!")
	if player_monster.passive["name"] == "Background Process" and randf() < 0.2:
		enemy_monster.hp = max(0, enemy_monster.hp - 10)
		emit_signal("battle_log", "Background Process triggered! 10 automatic damage!")

	enemy_monster.tick_cooldowns()
	enemy_monster.tick_status()

	# Track move
	var already_tracked = false
	for m in moves_used_this_battle:
		if m["name"] == move["name"]:
			already_tracked = true
			break
	if not already_tracked:
		moves_used_this_battle.append(move)

	emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
	emit_signal("cooldown_updated", get_cooldown_states())
	check_battle_end()

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

	# ── Confused check (Disinformation passive) ──
	if attacker.confused and attacker.confused_turns > 0:
		if randf() < 0.33:
			emit_signal("battle_log", attacker.monster_name + " is confused and hurt itself!")
			attacker.hp = max(0, attacker.hp - int(move.get("power", 10) * 0.5))
			emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
			return

	# ── Port Blocker — cancel serangan jika primed ──
	if defender.port_blocker_primed:
		defender.port_blocker_primed = false
		emit_signal("battle_log", "Port Blocker! " + attacker.monster_name + "'s attack was cancelled!")
		return

	if attacker.blocked_next_turn:
		emit_signal("battle_log", attacker.monster_name + "'s move was blocked!")
		attacker.blocked_next_turn = false
		return

	# ── Stable Ping — skip miss check ──
	var skip_miss = attacker.stable_ping_active

	var poly_chance = 0.3
	if defender.polymorphic_boosted:
		poly_chance = 0.6
	if not skip_miss and defender.passive["name"] == "Polymorphic" and randf() < poly_chance:
		emit_signal("battle_log", "Attack missed! " + defender.monster_name + " morphed away!")
		return

	if defender.passive["name"] == "Vishing" and randf() < 0.25:
		attacker.hp = max(0, attacker.hp - int(move.get("power", 0) * 0.5))
		emit_signal("battle_log", "Vishing! Attack backfired on " + attacker.monster_name + "!")
		emit_signal("edu_log", move["edu_log"])
		if is_player:
			try_show_edu_popup(move, attacker)
		return

	# ── Master Key — kebal efek Social Engineering ──
	if defender.master_key_active and attacker.type == "Social Engineering":
		var social_effects = ["confuse", "defense_debuff", "speed_debuff", "heal_lock", "guaranteed_hit"]
		if move.get("effect", "") in social_effects:
			emit_signal("battle_log", "Master Key! " + defender.monster_name + " resists " + move["name"] + "!")
			# Tetap kena damage, tapi efek statusnya diblokir
			MoveEffects.execute_damage_only(move, attacker, defender, self)
			emit_signal("edu_log", move["edu_log"])
			if is_player:
				try_show_edu_popup(move, attacker)
			return

	if attacker.passive["name"] != "Legacy Code" and defender.passive["name"] == "Legacy Code" and randf() < 0.15:
		emit_signal("battle_log", "Compatibility Error! " + attacker.monster_name + "'s move failed!")
		return

	if defender.passive["name"] == "Honeypot" and move.get("power", 0) > 60 and randf() < 0.3:
		emit_signal("battle_log", "Honeypot triggered! " + attacker.monster_name + " is trapped!")
		attacker.blocked_next_turn = true

	emit_signal("battle_log", who + " " + move["name"] + "!")
	emit_signal("edu_log", move["edu_log"])

	if is_player:
		try_show_edu_popup(move, attacker)

	if move.get("cooldown", 0) > 0:
		attacker.set_cooldown(move["name"], move["cooldown"])

	if is_player and player_monster.passive["name"] == "Identity Theft" and randf() < 0.2:
		player_monster.type = enemy_monster.type
		emit_signal("battle_log", "Identity Theft! Type changed to " + player_monster.type + "!")
	elif not is_player and enemy_monster.passive["name"] == "Identity Theft" and randf() < 0.2:
		enemy_monster.type = player_monster.type
		emit_signal("battle_log", "Identity Theft! Type changed to " + enemy_monster.type + "!")

	if attacker.passive["name"] == "AES-256" and randf() < 0.2:
		attacker.defense_stage += 1
		emit_signal("battle_log", "AES-256 encrypted attacker! Defense +1!")

	MoveEffects.execute(move, attacker, defender, self)

	# ── Post-attack passive triggers ──

	# Drainer — serap 5 HP setelah serang
	if attacker.drainer_active and move.get("power", 0) > 0:
		var drain = 5
		attacker.hp = min(attacker.max_hp, attacker.hp + drain)
		emit_signal("battle_log", attacker.monster_name + "'s Drainer absorbed " + str(drain) + " HP!")

	# Warp Overclock — 20% double hit
	if attacker.warp_overclock_active and move.get("power", 0) > 0 and randf() < 0.2:
		emit_signal("battle_log", "Overclock triggered! " + attacker.monster_name + " attacks again!")
		MoveEffects.execute(move, attacker, defender, self)

	# Disinformation — 25% chance Confused
	if attacker.disinformation_active and move.get("power", 0) > 0 and randf() < 0.25:
		defender.confused = true
		defender.confused_turns = 2
		emit_signal("battle_log", "Disinformation! " + defender.monster_name + " is confused!")

	# Auto-Alert — attack naik jika lawan pakai buff
	var buff_effects = ["defense_buff", "speed_buff", "accuracy_buff", "evasion_buff"]
	if defender.auto_alert_active and move.get("effect", "") in buff_effects:
		defender.accuracy_stage += 1
		emit_signal("battle_log", "Auto-Alert! " + defender.monster_name + "'s systems adapt! Attack +1!")

	if not is_player:
		last_enemy_move = move

	if pending_trojan_target != null:
		trojan_turns_left -= 1
		if trojan_turns_left <= 0:
			pending_trojan_target.take_damage(trojan_power)
			emit_signal("battle_log", "Trojan Gift EXPLODED!")
			pending_trojan_target = null

func get_type_multiplier(attacker_type: String, defender_type: String) -> float:
	var advantage = {
		"Malware":            {"strong": "Firewall",           "weak": "Crypto"},
		"Firewall":           {"strong": "Network",            "weak": "Malware"},
		"Network":            {"strong": "Crypto",             "weak": "Firewall"},
		"Crypto":             {"strong": "Malware",            "weak": "Network"},
		"Social Engineering": {"strong": "Crypto",             "weak": "Monitor"},
		"Monitor":            {"strong": "Social Engineering", "weak": "Malware"}
	}
	if not advantage.has(attacker_type):
		return 1.0
	if advantage[attacker_type]["strong"] == defender_type:
		return 1.5
	elif advantage[attacker_type]["weak"] == defender_type:
		return 0.5
	return 1.0

func get_moves_used() -> Array:
	return moves_used_this_battle

func check_battle_end():
	if player_monster == null or enemy_monster == null:
		return
	if player_monster.max_hp == 0 or enemy_monster.max_hp == 0:
		return

	if not enemy_monster.is_alive():
		# Last Payload passive (Trojan-Taurus)
		if enemy_monster.last_payload_active and not enemy_monster.last_payload_triggered:
			enemy_monster.last_payload_triggered = true
			player_monster.hp = max(0, player_monster.hp - 30)
			emit_signal("battle_log", "LAST PAYLOAD detonated! 30 damage to " + player_monster.monster_name + "!")
			emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
			await get_tree().create_timer(0.8).timeout

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
		# Last Payload passive (player side)
		if player_monster.last_payload_active and not player_monster.last_payload_triggered:
			player_monster.last_payload_triggered = true
			enemy_monster.hp = max(0, enemy_monster.hp - 30)
			emit_signal("battle_log", "LAST PAYLOAD detonated! 30 damage to " + enemy_monster.monster_name + "!")
			emit_signal("hp_updated", player_monster.hp, player_monster.max_hp, enemy_monster.hp, enemy_monster.max_hp)
			await get_tree().create_timer(0.8).timeout
			# Re-check setelah Last Payload
			if not enemy_monster.is_alive():
				emit_signal("battle_log", "You won!")
				emit_signal("battle_ended", true)
				return

		emit_signal("battle_log", "You lost!")
		emit_signal("battle_ended", false)
