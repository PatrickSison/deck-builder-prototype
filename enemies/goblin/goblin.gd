## Goblin – example enemy for the prototype.
## Alternates between attacking and defending.
##
## Usage: call GoblinEnemy.create() to get the EnemyData resource.

class_name GoblinEnemy
extends Object


static func create() -> EnemyData:
	var data := EnemyData.new()
	data.id          = "goblin"
	data.enemy_name  = "Goblin"
	data.max_health  = 30
	data.strength    = 0
	data.dexterity   = 0
	data.is_boss     = false

	# Turn 0: attack for 6   Turn 1: defend (gain 4 block)   Turn 2: attack x2 for 3 each
	data.action_pattern = [
		{
			"intent":      EnemyData.IntentType.ATTACK,
			"damage":      6,
			"hits":        1,
			"block":       0,
			"description": "Deals 6 damage"
		},
		{
			"intent":      EnemyData.IntentType.DEFEND,
			"damage":      0,
			"hits":        0,
			"block":       4,
			"description": "Gains 4 Block"
		},
		{
			"intent":      EnemyData.IntentType.ATTACK,
			"damage":      3,
			"hits":        2,
			"block":       0,
			"description": "Attacks 2x for 3 damage"
		},
	]

	return data
