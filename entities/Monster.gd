class_name Monster
extends Resource

var id: String
var monster_name: String
var type: String
var hp: int
var max_hp: int
var speed: int
var passive: Dictionary
var moves: Array
var defense_stage: int = 0
var accuracy_stage: int = 0
var speed_debuffed: bool = false
var blocked_next_turn: bool = false
var redundancy_triggered: bool = false
var polymorphic_boosted: bool = false
var polymorphic_boost_turns: int = 0
var pretexting_active: bool = false
var move_cooldowns: Dictionary = {}
var heal_locked: bool = false
var heal_lock_turns: int = 0
var dot_target = null
var dot_turns: int = 0
var dot_power: int = 0
var decoy_active: bool = false
var zero_day_shield_active: bool = false
var memory_leak_stacks: int = 0
var overclock_turns: int = 0
var firmware_locked: bool = false
var firmware_lock_turns: int = 0
var worm_damage_bonus: int = 0

func load_from_dict(data: Dictionary):
	id = data["id"]
	monster_name = data["name"]
	type = data["type"]
	hp = data["hp"]
	max_hp = data["hp"]
	speed = data["speed"]
	passive = data["passive"]
	moves = data["moves"]
	move_cooldowns = {}
	for move in moves:
		move_cooldowns[move["name"]] = 0

func is_alive() -> bool:
	return hp > 0

func take_damage(amount: int):
	# Zero-Day Shield
	if zero_day_shield_active:
		zero_day_shield_active = false
		emit_signal  # tidak bisa emit dari Monster, handle di BattleManager
		return

	var reduction = defense_stage * 5
	var final_damage = max(1, amount - reduction)
	
	# Worm-Ling bonus
	final_damage += worm_damage_bonus

	hp = max(0, hp - final_damage)

	if hp <= 0 and passive["name"] == "Redundancy" and not redundancy_triggered:
		hp = 1
		defense_stage += 2
		redundancy_triggered = true

	if passive["name"] == "Hardened Shell":
		defense_stage += 1

	# Hot Patch passive
	if passive["name"] == "Hot Patch" and final_damage > 30:
		defense_stage += 1

	# Self-Replicating passive (Worm-Ling)
	if passive["name"] == "Self-Replicating" and worm_damage_bonus < 15:
		worm_damage_bonus += 5

func heal(amount: int):
	hp = min(max_hp, hp + amount)

func get_effective_speed() -> int:
	if speed_debuffed:
		return speed / 2
	return speed

func tick_cooldowns():
	for move_name in move_cooldowns:
		if move_cooldowns[move_name] > 0:
			move_cooldowns[move_name] -= 1

func is_move_on_cooldown(move_name: String) -> bool:
	return move_cooldowns.get(move_name, 0) > 0

func set_cooldown(move_name: String, turns: int):
	move_cooldowns[move_name] = turns

func tick_status():
	# Polymorphic boost
	if polymorphic_boost_turns > 0:
		polymorphic_boost_turns -= 1
		if polymorphic_boost_turns <= 0:
			polymorphic_boosted = false

	# Pretexting
	pretexting_active = false

	# Heal lock
	if heal_lock_turns > 0:
		heal_lock_turns -= 1
		if heal_lock_turns <= 0:
			heal_locked = false

	# Firmware lock
	if firmware_lock_turns > 0:
		firmware_lock_turns -= 1
		if firmware_lock_turns <= 0:
			firmware_locked = false

	# Overclock expiry
	if overclock_turns > 0:
		overclock_turns -= 1
		if overclock_turns <= 0:
			speed = max(speed - 50, 1)

	# DoT tick
	if dot_turns > 0 and dot_target != null:
		dot_target.hp = max(0, dot_target.hp - dot_power)
		dot_turns -= 1
		if dot_turns <= 0:
			dot_target = null
