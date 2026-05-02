class_name MoveEffects
extends RefCounted

static func execute(move: Dictionary, attacker: Monster, defender: Monster, battle_manager: Node) -> void:
	var multiplier = 1.0
	if move.get("power", 0) > 0:
		multiplier = battle_manager.get_type_multiplier(attacker.type, defender.type)
		if multiplier > 1.0:
			battle_manager.emit_signal("battle_log", "Super effective! (x1.5)")
		elif multiplier < 1.0:
			battle_manager.emit_signal("battle_log", "Not very effective... (x0.5)")

	# ── Pre-checks ──

	# Zero-Day Shield blocks damage
	if defender.zero_day_shield_active and move.get("power", 0) > 0:
		defender.zero_day_shield_active = false
		battle_manager.emit_signal("battle_log", defender.monster_name + "'s Zero-Day Shield blocked the attack!")
		return

	# Decoy Payload reflects damage
	if defender.decoy_active and move.get("power", 0) > 0:
		defender.decoy_active = false
		attacker.hp = max(0, attacker.hp - int(move["power"] * 0.5))
		battle_manager.emit_signal("battle_log", "Decoy Payload triggered! Damage reflected!")
		return

	# Heal lock check
	if attacker.heal_locked and move["effect"] == "heal":
		battle_manager.emit_signal("battle_log", attacker.monster_name + " cannot heal — locked!")
		return

	# Firmware lock check
	if attacker.firmware_locked:
		var utility_effects = ["defense_buff", "accuracy_buff", "heal", "cleanse_debuff", "super_defense", "pretexting", "type_steal", "zero_day_shield", "patch_deploy"]
		if move["effect"] in utility_effects:
			battle_manager.emit_signal("battle_log", attacker.monster_name + "'s utility move firmware locked!")
			return

	match move["effect"]:
		# ── BASIC ATTACK — was missing, causing no damage! ──
		"attack":
			var dmg = int(move.get("power", 0) * multiplier)
			dmg = max(1, dmg - defender.defense_stage * 5)
			defender.take_damage(dmg)

		"defense_buff":
			attacker.defense_stage += 2
			battle_manager.emit_signal("battle_log", attacker.monster_name + "'s defense rose!")

		"block_move":
			var dmg = int(move["power"] * multiplier)
			if attacker.accuracy_stage > 0:
				dmg += attacker.accuracy_stage * 5
			defender.take_damage(dmg)
			defender.blocked_next_turn = true
			battle_manager.emit_signal("battle_log", defender.monster_name + " is blocked next turn!")

		"heal":
			var heal_amount = int(attacker.max_hp * 0.3)
			attacker.heal(heal_amount)
			battle_manager.emit_signal("battle_log", attacker.monster_name + " restored " + str(heal_amount) + " HP!")

		"double_hit":
			for i in 2:
				defender.take_damage(int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", "Hit twice!")

		"accuracy_buff":
			attacker.accuracy_stage += 2
			battle_manager.emit_signal("battle_log", attacker.monster_name + "'s accuracy rose!")

		"speed_debuff":
			defender.take_damage(int(move["power"] * multiplier))
			defender.speed_debuffed = true
			battle_manager.emit_signal("battle_log", defender.monster_name + "'s speed halved!")

		"speed_buff":
			attacker.speed = int(attacker.speed * 1.5)
			battle_manager.emit_signal("battle_log", attacker.monster_name + "'s speed rose!")

		"defense_debuff":
			defender.take_damage(int(move["power"] * multiplier))
			defender.defense_stage = max(-3, defender.defense_stage - 2)
			battle_manager.emit_signal("battle_log", defender.monster_name + "'s defense fell!")

		"accuracy_debuff":
			defender.take_damage(int(move["power"] * multiplier))
			defender.accuracy_stage = max(-3, defender.accuracy_stage - 2)
			battle_manager.emit_signal("battle_log", defender.monster_name + "'s accuracy fell!")

		"guaranteed_hit":
			var dmg = int(move.get("power", 0) * multiplier)
			dmg = max(1, dmg - defender.defense_stage * 5)
			defender.take_damage(dmg)
			battle_manager.emit_signal("battle_log", "Guaranteed hit!")

		"copy_move":
			if not battle_manager.last_enemy_move.is_empty():
				battle_manager.emit_signal("battle_log", attacker.monster_name + " copied " + battle_manager.last_enemy_move["name"] + "!")
				var copied = battle_manager.last_enemy_move.duplicate()
				copied["cooldown"] = 0
				battle_manager.execute_move(attacker, defender, copied, attacker == battle_manager.player_monster)
			else:
				battle_manager.emit_signal("battle_log", "No move to copy!")

		"requires_debuff":
			var dmg = int(move["power"] * multiplier)
			if defender.speed_debuffed or defender.blocked_next_turn:
				defender.take_damage(dmg)
				battle_manager.emit_signal("battle_log", "Critical exploit!")
			else:
				defender.take_damage(int(dmg * 0.5))
				battle_manager.emit_signal("battle_log", "Weak inject — target not debuffed.")

		"trojan":
			battle_manager.pending_trojan_target = defender
			battle_manager.trojan_turns_left = move.get("duration", 2)
			battle_manager.trojan_power = int(move.get("power", 40) * multiplier)
			battle_manager.emit_signal("battle_log", "Trojan Gift planted! Explodes in " + str(battle_manager.trojan_turns_left) + " turns!")

		"delayed_damage":
			battle_manager.pending_trojan_target = defender
			battle_manager.trojan_turns_left = move.get("duration", 2)
			battle_manager.trojan_power = int(move["power"] * multiplier)
			battle_manager.emit_signal("battle_log", "Trojan Gift planted! Explodes in " + str(battle_manager.trojan_turns_left) + " turns!")

		"super_defense":
			attacker.defense_stage += 4
			battle_manager.emit_signal("battle_log", attacker.monster_name + " activates Immutable Lock!")

		"overflow":
			defender.take_damage(int(move["power"] * multiplier))
			if randf() < 0.3:
				defender.speed_debuffed = true
				battle_manager.emit_signal("battle_log", "Memory overflow caused lag!")

		"steal_buff":
			if defender.defense_stage > 0:
				attacker.defense_stage += defender.defense_stage
				defender.defense_stage = 0
				battle_manager.emit_signal("battle_log", attacker.monster_name + " hijacked enemy buffs!")
			else:
				battle_manager.emit_signal("battle_log", "No buffs to steal!")

		"confuse":
			defender.take_damage(int(move.get("power", 0) * multiplier))
			defender.confused = true
			defender.confused_turns = 2
			battle_manager.emit_signal("battle_log", defender.monster_name + " is confused!")

		"type_steal":
			attacker.type = defender.type
			battle_manager.emit_signal("battle_log", attacker.monster_name + " copied type: " + defender.type + "!")

		"bypass_defense":
			defender.hp = max(0, defender.hp - int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", "Defense bypassed! Direct damage!")

		"shell_slam":
			var bonus = attacker.defense_stage * 8
			var dmg = int((move["power"] + bonus) * multiplier)
			defender.take_damage(dmg)
			battle_manager.emit_signal("battle_log", "Shell Slam! +" + str(bonus) + " bonus from defense!")

		"ssl_handshake":
			var dmg = move["power"]
			if attacker.defense_stage > 0:
				dmg = int(dmg * 1.5)
				battle_manager.emit_signal("battle_log", "SSL Handshake amplified!")
			defender.take_damage(int(dmg * multiplier))

		"ping_flood":
			var dmg = move["power"]
			if defender.speed_debuffed:
				dmg = int(dmg * 1.6)
				battle_manager.emit_signal("battle_log", "Ping Flood overwhelms slowed target!")
			defender.take_damage(int(dmg * multiplier))

		"evasion_buff", "rootkit_hide":
			attacker.polymorphic_boosted = true
			attacker.polymorphic_boost_turns = 2
			battle_manager.emit_signal("battle_log", attacker.monster_name + " hides in kernel! Evasion 60% for 2 turns!")

		"fork_bomb":
			var hits = randi_range(3, 5)
			for i in hits:
				defender.take_damage(int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", "Fork Bomb hit " + str(hits) + " times!")

		"pretexting":
			attacker.pretexting_active = true
			attacker.accuracy_stage += 1
			battle_manager.emit_signal("battle_log", attacker.monster_name + " sets pretext! Next move guaranteed hit!")

		"cleanse_debuff":
			attacker.speed_debuffed = false
			attacker.blocked_next_turn = false
			attacker.accuracy_stage = max(0, attacker.accuracy_stage)
			battle_manager.emit_signal("battle_log", attacker.monster_name + " cleansed all debuffs!")

		"shred_defense":
			defender.take_damage(int(move["power"] * multiplier))
			defender.defense_stage = 0
			battle_manager.emit_signal("battle_log", "Defense shredded to zero!")

		"mirror_defense":
			if defender.defense_stage > 0:
				attacker.defense_stage += defender.defense_stage
				battle_manager.emit_signal("battle_log", attacker.monster_name + " mirrored " + str(defender.defense_stage) + " defense stages!")
			else:
				battle_manager.emit_signal("battle_log", "Nothing to mirror!")

		"brute_decrypt":
			defender.take_damage(int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", "Brute force hit hard!")

		"cipher_strike":
			var dmg = move["power"]
			if defender.defense_stage > 0:
				dmg = int(dmg * 1.5)
				battle_manager.emit_signal("battle_log", "Cipher Strike exploits encryption layers!")
			defender.take_damage(int(dmg * multiplier))

		"zero_knowledge":
			defender.take_damage(move["power"])
			battle_manager.emit_signal("battle_log", "Zero-Knowledge — type advantage ignored!")

		"redirect_debuff", "reroute_debuff":
			var transferred = false
			if attacker.speed_debuffed:
				attacker.speed_debuffed = false
				defender.speed_debuffed = true
				transferred = true
			if attacker.blocked_next_turn:
				attacker.blocked_next_turn = false
				defender.blocked_next_turn = true
				transferred = true
			if transferred:
				battle_manager.emit_signal("battle_log", "Debuffs rerouted to " + defender.monster_name + "!")
			else:
				battle_manager.emit_signal("battle_log", "No debuffs to reroute!")

		"packet_loss":
			if randf() < 0.4:
				battle_manager.emit_signal("battle_log", "Packet Loss missed!")
			else:
				defender.take_damage(int(move["power"] * multiplier))
				battle_manager.emit_signal("battle_log", "Packet Loss connected!")

		"qos_drain":
			defender.speed_debuffed = true
			defender.accuracy_stage -= 2
			battle_manager.emit_signal("battle_log", defender.monster_name + "'s speed and accuracy drained!")

		"heal_lock", "lock_heal":
			defender.take_damage(int(move["power"] * multiplier))
			defender.heal_locked = true
			defender.heal_lock_turns = 2
			battle_manager.emit_signal("battle_log", defender.monster_name + " cannot heal for 2 turns!")

		"dot", "dot_damage":
			attacker.dot_target = defender
			attacker.dot_turns = 2
			attacker.dot_power = 15
			battle_manager.emit_signal("battle_log", "DoT applied! 15 damage for 2 turns!")

		"double_extortion":
			var dmg = move["power"]
			if defender.speed_debuffed or defender.blocked_next_turn or defender.heal_locked:
				dmg = int(dmg * 1.5)
				battle_manager.emit_signal("battle_log", "Double Extortion exploits status!")
			defender.take_damage(int(dmg * multiplier))

		"decoy_payload":
			attacker.decoy_active = true
			battle_manager.emit_signal("battle_log", attacker.monster_name + " planted Decoy Payload!")

		"patch_deploy":
			var heal_amount = int(attacker.max_hp * 0.25)
			attacker.heal(heal_amount)
			attacker.speed_debuffed = false
			attacker.blocked_next_turn = false
			battle_manager.emit_signal("battle_log", "Patched! Healed " + str(heal_amount) + " HP and cleared debuffs!")

		"zero_day_shield":
			attacker.zero_day_shield_active = true
			battle_manager.emit_signal("battle_log", attacker.monster_name + " activated Zero-Day Shield!")

		"hardened_kernel":
			attacker.defense_stage += 3
			attacker.speed_debuffed = true
			defender.take_damage(int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", "Kernel hardened! Defense surged, speed dropped!")

		"access_denied":
			defender.blocked_next_turn = true
			defender.take_damage(25)
			battle_manager.emit_signal("battle_log", "Access Denied! 25 rebound damage!")

		"failover":
			if attacker.hp < attacker.max_hp * 0.25:
				attacker.speed += 40
				battle_manager.emit_signal("battle_log", "Failover! Speed surged!")
			else:
				var heal_amount = int(attacker.max_hp * 0.2)
				attacker.heal(heal_amount)
				battle_manager.emit_signal("battle_log", "Failover backup engaged!")

		"execute_low_hp", "kill_switch":
			if defender.hp < defender.max_hp * 0.2:
				defender.hp = 0
				battle_manager.emit_signal("battle_log", "KILL SWITCH! Instant elimination!")
			else:
				defender.take_damage(int(move.get("power", 10) * multiplier))
				battle_manager.emit_signal("battle_log", "Kill Switch failed — HP above 20%!")

		"memory_leak":
			attacker.memory_leak_stacks = min(attacker.memory_leak_stacks + 1, 3)
			var dmg = int((move["power"] + attacker.memory_leak_stacks * 15) * multiplier)
			defender.take_damage(dmg)
			battle_manager.emit_signal("battle_log", "Memory Leak stack " + str(attacker.memory_leak_stacks) + "/3!")

		"reset_buffs", "bios_flash":
			battle_manager.player_monster.defense_stage = 0
			battle_manager.player_monster.accuracy_stage = 0
			battle_manager.player_monster.speed_debuffed = false
			battle_manager.enemy_monster.defense_stage = 0
			battle_manager.enemy_monster.accuracy_stage = 0
			battle_manager.enemy_monster.speed_debuffed = false
			battle_manager.emit_signal("battle_log", "BIOS Flash! All buffs/debuffs reset!")

		"overclock":
			attacker.speed += 50
			attacker.overclock_turns = 2
			battle_manager.emit_signal("battle_log", attacker.monster_name + " overclocked! Speed surged 2 turns!")

		"firmware_lock":
			defender.take_damage(int(move["power"] * multiplier))
			defender.firmware_locked = true
			defender.firmware_lock_turns = 2
			battle_manager.emit_signal("battle_log", defender.monster_name + "'s utility moves locked 2 turns!")

		"lure_strike":
			defender.take_damage(int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", attacker.monster_name + " lures the target!")

		"polymorphic":
			attacker.polymorphic_boosted = true
			attacker.polymorphic_boost_turns = 2
			defender.take_damage(int(move.get("power", 35) * multiplier))
			battle_manager.emit_signal("battle_log", attacker.monster_name + " morphed and attacked!")

		"syn_flood":
			defender.blocked_next_turn = true
			defender.take_damage(int(move["power"] * multiplier))
			battle_manager.emit_signal("battle_log", "SYN Flood! " + defender.monster_name + " blocked next turn!")

		"guaranteed_hit":
			var dmg = int(move.get("power", 0) * multiplier)
			dmg = max(1, dmg - defender.defense_stage * 5)
			defender.take_damage(dmg)

		_:
			# Fallback — jika effect tidak dikenali, lakukan basic damage
			if move.get("power", 0) > 0:
				var dmg = int(move["power"] * multiplier)
				dmg = max(1, dmg - defender.defense_stage * 5)
				defender.take_damage(dmg)
				battle_manager.emit_signal("battle_log", "Attack connected!")


static func execute_damage_only(move: Dictionary, attacker: Monster, defender: Monster, battle_manager: Node) -> void:
	var power = move.get("power", 0)
	if power <= 0:
		return

	var multiplier = battle_manager.get_type_multiplier(attacker.type, defender.type)
	var damage = int(power * multiplier)
	var defense_reduction = defender.defense_stage * 5
	damage = max(1, damage - defense_reduction)

	defender.hp = max(0, defender.hp - damage)
	battle_manager.emit_signal("battle_log", defender.monster_name + " took " + str(damage) + " damage!")
	battle_manager.emit_signal("hp_updated",
		battle_manager.player_monster.hp, battle_manager.player_monster.max_hp,
		battle_manager.enemy_monster.hp, battle_manager.enemy_monster.max_hp)
