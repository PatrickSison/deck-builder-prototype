## Bash – a heavier attack card for Ironbad.
## Deals 8 damage to a single enemy. Cost: 2 energy.
##
## Usage: call IronbadBash.create() to get a configured CardData resource.

class_name IronbadBash
extends Object


static func create() -> CardData:
	var card := CardData.new()
	card.id          = "ironbad_bash"
	card.card_name   = "Bash"
	card.type        = CardData.Type.ATTACK
	card.target      = CardData.Target.SINGLE_ENEMY
	card.cost        = 2
	card.description = "Deal 8 damage."
	card.exhaust     = false

	var dmg := Damage.new()
	dmg.amount = 8
	dmg.hits   = 1
	card.effects = [dmg]

	return card
