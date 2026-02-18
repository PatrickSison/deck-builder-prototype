class_name ItemData
extends Resource

## Template resource for items/relics the player can acquire.
## Items persist for the entire run and modify player behavior.

enum TriggerType {
	PASSIVE,            ## Always active (stat modifier)
	ON_COMBAT_START,    ## Triggers once at the start of each combat
	ON_TURN_START,      ## Triggers at the start of each player turn
	ON_TURN_END,        ## Triggers at the end of each player turn
	ON_CARD_PLAYED,     ## Triggers each time a card is played
	ON_KILL,            ## Triggers when the player kills an enemy
	ON_TAKE_DAMAGE,     ## Triggers when the player takes damage
}

@export_group("Identity")
@export var id: String
@export var item_name: String
@export var icon: Texture2D
@export_multiline var description: String
@export var flavor_text: String

@export_group("Trigger")
@export var trigger: TriggerType = TriggerType.PASSIVE

@export_group("Stat Modifiers (Passive)")
@export var bonus_max_health: int = 0
@export var bonus_max_energy: int = 0
@export var bonus_draw_per_turn: int = 0
@export var bonus_hand_size: int = 0
@export var bonus_strength: int = 0
@export var bonus_dexterity: int = 0

@export_group("Trigger Effects")
@export var trigger_energy_gain: int = 0   ## Energy granted on trigger
@export var trigger_block_gain: int = 0    ## Block granted on trigger
@export var trigger_draw_cards: int = 0    ## Cards drawn on trigger
@export var trigger_heal: int = 0          ## HP healed on trigger


func apply_passive(stats: Stats) -> void:
	## Call this once when the item is picked up to apply permanent stat changes.
	stats.max_health += bonus_max_health
	stats.health = min(stats.health + bonus_max_health, stats.max_health)
	stats.max_energy += bonus_max_energy
	stats.draw_per_turn += bonus_draw_per_turn
	stats.hand_size += bonus_hand_size
	stats.strength += bonus_strength
	stats.dexterity += bonus_dexterity
