class_name PlayerUI
extends Control

## Displays the player's portrait, health bar, and block counter.
## Also owns the self-targeting DropZone for SELF-target cards.
##
## Expected scene children:
##   Portrait    (TextureRect)
##   HealthBar   (ProgressBar)
##   HealthLabel (Label)
##   BlockLabel  (Label)
##   DropZone    (DropZone, zone_type = PLAYER_SELF)

var _portrait: TextureRect     = null
var _health_bar: ProgressBar   = null
var _health_label: Label       = null
var _block_label: Label        = null
var _drop_zone: DropZone       = null


func _ready() -> void:
	_portrait     = find_child("Portrait", true, false)
	_health_bar   = find_child("HealthBar", true, false)
	_health_label = find_child("HealthLabel", true, false)
	_block_label  = find_child("BlockLabel", true, false)
	_drop_zone    = find_child("DropZone", true, false)

	if _drop_zone:
		_drop_zone.zone_type = DropZone.ZoneType.PLAYER_SELF

	Events.player_health_changed.connect(_on_health_changed)
	Events.player_block_changed.connect(_on_block_changed)


func setup(player: Player) -> void:
	if _health_bar:
		_health_bar.max_value = player.stats.max_health
		_health_bar.value     = player.stats.health
	if _health_label:
		_health_label.text = "%d / %d" % [player.stats.health, player.stats.max_health]
	if _block_label:
		_block_label.text    = "Block: 0"
		_block_label.visible = false
	if _portrait and player.character_data and player.character_data.icon:
		_portrait.texture = player.character_data.icon


func _on_health_changed(health: int, max_health: int) -> void:
	if _health_bar:
		_health_bar.max_value = max_health
		_health_bar.value     = health
	if _health_label:
		_health_label.text = "%d / %d" % [health, max_health]


func _on_block_changed(block: int) -> void:
	if _block_label:
		_block_label.text    = "Block: %d" % block
		_block_label.visible = block > 0
