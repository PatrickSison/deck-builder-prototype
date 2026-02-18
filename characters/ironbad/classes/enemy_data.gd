class_name EnemyData
extends Resource

## Template resource for defining an enemy type.
## Create .tres files from this class for each enemy variant.

enum IntentType {
	ATTACK,         ## Will deal damage
	DEFEND,         ## Will gain block
	BUFF,           ## Will apply a buff to itself
	DEBUFF,         ## Will apply a debuff to the player
	UNKNOWN         ## Unpredictable
}

## An action the enemy can take on its turn.
class EnemyAction:
	var intent: IntentType = IntentType.ATTACK
	var damage: int = 0         ## Damage dealt (if ATTACK)
	var hits: int = 1           ## Number of hits (if ATTACK)
	var block: int = 0          ## Block gained (if DEFEND)
	var description: String = ""

@export_group("Identity")
@export var id: String
@export var enemy_name: String
@export var icon: Texture2D

@export_group("Stats")
@export var max_health: int = 20
@export var strength: int = 0
@export var dexterity: int = 0

@export_group("Patterns")
## Each inner array is one possible action set the enemy cycles through.
## Override get_action_for_turn() to implement custom AI.
@export var action_pattern: Array[Dictionary] = []

## Optional: set to true for boss behavior (no escape, special intro)
@export var is_boss: bool = false


func get_action_for_turn(turn: int) -> Dictionary:
	## Returns the action dictionary the enemy takes on the given turn.
	## Dictionary keys: intent (IntentType), damage, hits, block, description
	if action_pattern.is_empty():
		return {
			"intent": IntentType.ATTACK,
			"damage": 6,
			"hits": 1,
			"block": 0,
			"description": "Deals 6 damage"
		}
	return action_pattern[turn % action_pattern.size()]
