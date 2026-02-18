class_name HandUI
extends Control

## Displays the player's hand at the bottom of the screen.
## Listens to Events.hand_updated to refresh.
## Instantiates CardUI scenes for each card.

## Path to the CardUI packed scene – set this in the editor or via setup().
@export var card_ui_scene: PackedScene

var _combat_manager: CombatManager = null
var _card_nodes: Array[CardUI] = []

## Horizontal spacing between cards (can be negative to overlap)
const CARD_SPACING: float = 160.0
const CARD_WIDTH: float = 120.0


func setup(manager: CombatManager, scene: PackedScene) -> void:
	_combat_manager = manager
	card_ui_scene = scene
	Events.hand_updated.connect(_on_hand_updated)
	Events.player_energy_changed.connect(_on_energy_changed)


func _on_hand_updated(hand: Array) -> void:
	_rebuild_hand(hand)


func _on_energy_changed(_energy: int, _max_energy: int) -> void:
	_refresh_playability()


func _rebuild_hand(hand: Array) -> void:
	## Clear existing card nodes
	for card_node in _card_nodes:
		if is_instance_valid(card_node):
			card_node.queue_free()
	_card_nodes.clear()

	if card_ui_scene == null:
		return

	var count := hand.size()
	var total_width := count * CARD_WIDTH + (count - 1) * (CARD_SPACING - CARD_WIDTH)
	var start_x := (size.x - total_width) / 2.0

	for i in range(count):
		var card_data: CardData = hand[i] as CardData
		if card_data == null:
			continue

		var card_ui: CardUI = card_ui_scene.instantiate() as CardUI
		add_child(card_ui)
		card_ui.setup(card_data, _combat_manager)

		# Position card in a row, centred in the hand area
		var x := start_x + i * CARD_SPACING
		card_ui.position = Vector2(x, 0.0)

		# Connect play signal
		card_ui.card_drag_ended.connect(_on_card_drag_ended.bind(card_ui))

		_card_nodes.append(card_ui)

	_refresh_playability()


func _refresh_playability() -> void:
	if _combat_manager == null or _combat_manager.player == null:
		return
	var energy := _combat_manager.player.stats.energy
	for card_node in _card_nodes:
		if is_instance_valid(card_node) and card_node.card_data:
			card_node.set_playable(card_node.card_data.cost <= energy)


func _on_card_drag_ended(_card_ui: CardUI) -> void:
	## HandUI does NOT remove the card node here – CombatManager will emit
	## hand_updated after the card is discarded/exhausted, which triggers _rebuild_hand.
	pass
