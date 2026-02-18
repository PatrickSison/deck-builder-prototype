## Ironbad – the warrior character class.
## Call IronbadCharacter.create() to get the CharacterData resource.

class_name IronbadCharacter
extends Object


static func create() -> CharacterData:
	var data := CharacterData.new()
	data.id              = "ironbad"
	data.character_name  = "Ironbad"
	data.description     = "A mighty warrior who punches things very hard."
	data.base_max_health = 80
	data.base_max_energy = 3
	data.base_draw_per_turn = 5
	data.base_hand_size  = 10

	# Starting deck: 5x Strike, 4x Defend, 1x Bash
	var deck: Array[Resource] = []
	for _i in range(5):
		deck.append(IronbadStrike.create())
	for _i in range(4):
		deck.append(IronbadDefend.create())
	deck.append(IronbadBash.create())
	data.starting_deck = deck

	return data
