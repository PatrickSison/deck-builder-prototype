class_name CardData
extends Resource

## Template resource for defining a card. Create .tres files from this class
## to define individual cards for each character.

enum Type { ATTACK, SKILL, POWER }
enum Target { SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE }

@export_group("Card Identity")
@export var id: String
@export var card_name: String
@export var type: Type = Type.ATTACK

@export_group("Card Mechanics")
@export var target: Target = Target.SINGLE_ENEMY
@export var cost: int = 1
@export var effects: Array[Resource] = []  ## Array of Effect subclass instances
@export var exhaust: bool = false           ## If true, card is removed from deck on use

@export_group("Card Visuals")
@export var icon: Texture2D
@export_multiline var description: String
@export var sound: AudioStream


func execute(targets: Array[Node]) -> void:
	## Runs all effects on the given targets.
	for effect in effects:
		(effect as Effect).execute(targets)


func get_type_label() -> String:
	match type:
		Type.ATTACK: return "Attack"
		Type.SKILL:  return "Skill"
		Type.POWER:  return "Power"
	return ""


func requires_target() -> bool:
	## Returns true if the player must click/drag onto a specific enemy.
	return target == Target.SINGLE_ENEMY
