class_name Enemy
extends Node2D

## An enemy combat entity.
## Set enemy_data before adding to the scene, then call setup().

var stats: Stats = Stats.new()
var enemy_data: EnemyData = null
var current_intent: Dictionary = {}


func setup(data: EnemyData) -> void:
	enemy_data = data
	stats = Stats.new()
	stats.max_health = data.max_health
	stats.health = data.max_health
	stats.strength = data.strength
	stats.dexterity = data.dexterity
	add_to_group("enemies")


func get_stats() -> Stats:
	return stats


# ---------------------------------------------------------------------------
# Combat actions
# ---------------------------------------------------------------------------

func take_damage(amount: int) -> void:
	var actual := stats.take_damage(amount)
	Events.enemy_health_changed.emit(self, stats.health, stats.max_health)
	Events.enemy_block_changed.emit(self, stats.block)
	if actual > 0:
		Events.damage_dealt.emit(self, actual)
	if stats.is_dead():
		Events.enemy_died.emit(self)


func apply_block(amount: int) -> void:
	stats.add_block(amount)
	Events.enemy_block_changed.emit(self, stats.block)


func refresh_intent(turn: int) -> void:
	## Pick the action this enemy will take on the upcoming enemy phase.
	if enemy_data == null:
		return
	current_intent = enemy_data.get_action_for_turn(turn)
	Events.enemy_intent_changed.emit(self, current_intent)


func execute_intent(target_player: Player) -> void:
	## Carry out the chosen intent against the player (or self for buffs).
	if current_intent.is_empty() or enemy_data == null:
		return

	var intent_type: EnemyData.IntentType = current_intent.get("intent", EnemyData.IntentType.ATTACK)

	match intent_type:
		EnemyData.IntentType.ATTACK:
			var dmg: int = current_intent.get("damage", 0) + stats.strength
			var hits: int = current_intent.get("hits", 1)
			for _i in range(hits):
				target_player.take_damage(dmg)

		EnemyData.IntentType.DEFEND:
			var blk: int = current_intent.get("block", 0)
			apply_block(blk)

		EnemyData.IntentType.BUFF:
			stats.strength += current_intent.get("strength_gain", 0)
			stats.dexterity += current_intent.get("dexterity_gain", 0)

		EnemyData.IntentType.DEBUFF:
			# Extend with status effects (weak, vulnerable, etc.) as needed
			pass

		EnemyData.IntentType.UNKNOWN:
			pass
