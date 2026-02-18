extends Node2D

## Entry point for the prototype. Loads a combat scene immediately.
## In a full game this would show a title screen / map first.

const COMBAT_SCENE := preload("res://scenes/combat/combat.tscn")


func _ready() -> void:
	var combat: CombatScene = COMBAT_SCENE.instantiate() as CombatScene

	# Configure the encounter
	combat.character_data  = IronbadCharacter.create()
	combat.enemy_data_list = [GoblinEnemy.create(), GoblinEnemy.create()]
	combat.player_items    = []

	add_child(combat)

	# Return to main menu (just reload the scene) when combat ends
	Events.battle_won.connect(_on_combat_over.bind("WIN"))
	Events.battle_lost.connect(_on_combat_over.bind("LOSE"))


func _on_combat_over(_result: String) -> void:
	# For the prototype, press R to restart
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()
