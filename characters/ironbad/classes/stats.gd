class_name Stats
extends Resource

## Holds all runtime stats for a combat entity (player or enemy).

@export_group("Health")
@export var max_health: int = 80
@export var health: int = 80

@export_group("Combat")
@export var block: int = 0
@export var strength: int = 0   ## Adds to attack damage
@export var dexterity: int = 0  ## Adds to block gained

@export_group("Energy")
@export var max_energy: int = 3
@export var energy: int = 3

@export_group("Draw")
@export var hand_size: int = 10    ## Max cards in hand
@export var draw_per_turn: int = 5 ## Cards drawn at start of turn


func reset_block() -> void:
	block = 0


func reset_energy() -> void:
	energy = max_energy


func take_damage(amount: int) -> int:
	## Returns actual damage dealt after block reduction.
	var damage_after_block := max(0, amount - block)
	block = max(0, block - amount)
	health = max(0, health - damage_after_block)
	return damage_after_block


func add_block(amount: int) -> void:
	block += max(0, amount + dexterity)


func heal(amount: int) -> void:
	health = min(max_health, health + amount)


func is_dead() -> bool:
	return health <= 0
