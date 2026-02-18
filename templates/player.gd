## CharacterTemplate – copy this file to create a new playable character.
##
## Quick-start guide:
##   1. Duplicate to characters/<mychar>/character.gd
##   2. Change class_name
##   3. Fill in create() with the character's stats and starting deck
##   4. Pass the CharacterData to CombatScene.setup() or main.gd

class_name CharacterTemplate
extends Object


static func create() -> CharacterData:
	var data := CharacterData.new()
	data.id              = "my_character"
	data.character_name  = "My Character"
	data.description     = "A brave hero."
	data.base_max_health = 75
	data.base_max_energy = 3
	data.base_draw_per_turn = 5
	data.base_hand_size  = 10

	# Build starting deck (10 cards is typical)
	var deck: Array[Resource] = []
	for _i in range(5):
		deck.append(IronbadStrike.create())   # Replace with character-specific cards
	for _i in range(4):
		deck.append(IronbadDefend.create())
	deck.append(IronbadBash.create())
	data.starting_deck = deck

	return data
