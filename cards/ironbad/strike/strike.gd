## Strike – basic attack card for Ironbad.
## Deals 6 damage to a single enemy. Cost: 1 energy.
##
## Usage: call IronbadStrike.create() to get a configured CardData resource.

class_name IronbadStrike
extends Object


static func create() -> CardData:
	var card := CardData.new()
	card.id          = "ironbad_strike"
	card.card_name   = "Strike"
	card.type        = CardData.Type.ATTACK
	card.target      = CardData.Target.SINGLE_ENEMY
	card.cost        = 1
	card.description = "Deal 6 damage."
	card.exhaust     = false

	var dmg := Damage.new()
	dmg.amount = 6
	dmg.hits   = 1
	card.effects = [dmg]

	return card
