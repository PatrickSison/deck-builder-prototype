class_name DropZone
extends Control

## An invisible area that cards can be dragged onto.
## Attach to enemies (SINGLE_ENEMY), the player (SELF), or the field (AOE).
##
## Each DropZone must be in the "drop_zones" group.

enum ZoneType { ENEMY, PLAYER_SELF, FIELD }

@export var zone_type: ZoneType = ZoneType.ENEMY

## The enemy node this zone represents (set at runtime for enemy zones).
var linked_enemy: Enemy = null

var _original_modulate: Color = Color.TRANSPARENT
var _highlight_color: Color = Color(1.0, 1.0, 0.3, 0.35)


func _ready() -> void:
	add_to_group("drop_zones")
	mouse_filter = Control.MOUSE_FILTER_IGNORE  ## Don't block card mouse events


func accepts_card(card: CardData) -> bool:
	if card == null:
		return false
	match zone_type:
		ZoneType.ENEMY:
			return card.target in [CardData.Target.SINGLE_ENEMY, CardData.Target.ALL_ENEMIES]
		ZoneType.PLAYER_SELF:
			return card.target == CardData.Target.SELF
		ZoneType.FIELD:
			return card.target in [CardData.Target.ALL_ENEMIES, CardData.Target.EVERYONE]
	return false


func get_targets() -> Array[Node]:
	match zone_type:
		ZoneType.ENEMY:
			if linked_enemy and not linked_enemy.stats.is_dead():
				return [linked_enemy] as Array[Node]
			return []
		ZoneType.PLAYER_SELF:
			var players := get_tree().get_nodes_in_group("player")
			return players as Array[Node]
		ZoneType.FIELD:
			var all_enemies := get_tree().get_nodes_in_group("enemies")
			return all_enemies as Array[Node]
	return []


func highlight(card: CardData) -> void:
	if accepts_card(card):
		modulate = _highlight_color


func clear_highlight() -> void:
	modulate = Color.WHITE
