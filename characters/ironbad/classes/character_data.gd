class_name CharacterData
extends Resource

## Defines a playable character class: their base stats, starting deck, and
## starting item. Create one .tres per character (e.g. ironbad.tres).

@export_group("Identity")
@export var id: String
@export var character_name: String
@export var icon: Texture2D
@export var description: String

@export_group("Base Stats")
@export var base_max_health: int = 80
@export var base_max_energy: int = 3
@export var base_draw_per_turn: int = 5
@export var base_hand_size: int = 10

@export_group("Starting Deck")
## Each entry is a CardData resource. Duplicates allowed.
@export var starting_deck: Array[Resource] = []

@export_group("Starting Item")
@export var starting_item: ItemData = null


func make_stats() -> Stats:
	## Builds a fresh Stats object for this character at combat start.
	var s := Stats.new()
	s.max_health = base_max_health
	s.health = base_max_health
	s.max_energy = base_max_energy
	s.energy = base_max_energy
	s.draw_per_turn = base_draw_per_turn
	s.hand_size = base_hand_size
	s.block = 0
	s.strength = 0
	s.dexterity = 0
	return s


func make_starting_deck() -> Array[CardData]:
	## Returns deep copies of the starting deck cards.
	var deck: Array[CardData] = []
	for card_res in starting_deck:
		deck.append(card_res.duplicate(true) as CardData)
	return deck
