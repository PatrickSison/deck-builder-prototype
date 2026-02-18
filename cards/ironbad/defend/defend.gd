## Defend – basic block card for Ironbad.
## Gains 5 block. Cost: 1 energy.
##
## Usage: call IronbadDefend.create() to get a configured CardData resource.

class_name IronbadDefend
extends Object


static func create() -> CardData:
	var card := CardData.new()
	card.id          = "ironbad_defend"
	card.card_name   = "Defend"
	card.type        = CardData.Type.SKILL
	card.target      = CardData.Target.SELF
	card.cost        = 1
	card.description = "Gain 5 Block."
	card.exhaust     = false

	var blk := Block.new()
	blk.amount = 5
	card.effects = [blk]

	return card
