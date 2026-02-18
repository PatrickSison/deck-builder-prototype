class_name EnemyUI
extends Control

## Displays a single enemy: portrait, health bar, block, and intent icon.
## Also owns the DropZone that cards are dragged onto.
##
## Expected scene children:
##   Portrait      (TextureRect)
##   HealthBar     (ProgressBar)
##   HealthLabel   (Label)  – "hp / max_hp"
##   BlockLabel    (Label)  – block shield count
##   IntentLabel   (Label)  – text description of the enemy's next action
##   IntentIcon    (TextureRect)
##   DropZone      (DropZone node)

var linked_enemy: Enemy = null

var _portrait: TextureRect = null
var _health_bar: ProgressBar = null
var _health_label: Label = null
var _block_label: Label = null
var _intent_label: Label = null
var _drop_zone: DropZone = null


func _ready() -> void:
	_portrait     = find_child("Portrait", true, false)
	_health_bar   = find_child("HealthBar", true, false)
	_health_label = find_child("HealthLabel", true, false)
	_block_label  = find_child("BlockLabel", true, false)
	_intent_label = find_child("IntentLabel", true, false)
	_drop_zone    = find_child("DropZone", true, false)


func setup(enemy: Enemy) -> void:
	linked_enemy = enemy

	if _drop_zone:
		_drop_zone.linked_enemy = enemy
		_drop_zone.zone_type = DropZone.ZoneType.ENEMY

	if _portrait and enemy.enemy_data and enemy.enemy_data.icon:
		_portrait.texture = enemy.enemy_data.icon

	_refresh_health()
	_refresh_block()

	Events.enemy_health_changed.connect(_on_enemy_health_changed)
	Events.enemy_block_changed.connect(_on_enemy_block_changed)
	Events.enemy_intent_changed.connect(_on_enemy_intent_changed)
	Events.enemy_died.connect(_on_enemy_died)


func _refresh_health() -> void:
	if not is_instance_valid(linked_enemy):
		return
	var s := linked_enemy.stats
	if _health_bar:
		_health_bar.max_value = s.max_health
		_health_bar.value     = s.health
	if _health_label:
		_health_label.text = "%d / %d" % [s.health, s.max_health]


func _refresh_block() -> void:
	if not is_instance_valid(linked_enemy):
		return
	if _block_label:
		var blk := linked_enemy.stats.block
		_block_label.text = "Block: %d" % blk
		_block_label.visible = blk > 0


func _on_enemy_health_changed(enemy: Node, health: int, max_health: int) -> void:
	if enemy != linked_enemy:
		return
	if _health_bar:
		_health_bar.max_value = max_health
		_health_bar.value     = health
	if _health_label:
		_health_label.text = "%d / %d" % [health, max_health]


func _on_enemy_block_changed(enemy: Node, block: int) -> void:
	if enemy != linked_enemy:
		return
	if _block_label:
		_block_label.text    = "Block: %d" % block
		_block_label.visible = block > 0


func _on_enemy_intent_changed(enemy: Node, intent: Dictionary) -> void:
	if enemy != linked_enemy:
		return
	if _intent_label:
		_intent_label.text = intent.get("description", "???")


func _on_enemy_died(enemy: Node) -> void:
	if enemy != linked_enemy:
		return
	# Animate death and remove
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
