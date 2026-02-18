## CardTemplate – copy this file and rename the class to create a new card.
##
## Quick-start guide:
##   1. Duplicate this file (e.g. cards/mychar/my_card.gd)
##   2. Change the class_name
##   3. Fill in the create() static method with your card's stats and effects
##   4. Add the card to your CharacterData.starting_deck
##
## Available effect classes (res://effects/):
##   Damage       – deal damage; set .amount and .hits
##   Block        – gain block;  set .amount
##   DrawCards    – draw cards;  set .amount
##   GainEnergy   – gain energy; set .amount
##   Heal         – restore HP;  set .amount
##
## Card.Target values:
##   SELF         – drag onto the player's portrait / self-drop-zone
##   SINGLE_ENEMY – drag onto a specific enemy
##   ALL_ENEMIES  – drag onto any enemy or the field drop-zone
##   EVERYONE     – drag onto the field drop-zone

class_name CardTemplate
extends Object


static func create() -> CardData:
	var card := CardData.new()
	card.id          = "template_card"
	card.card_name   = "Template Card"
	card.type        = CardData.Type.ATTACK
	card.target      = CardData.Target.SINGLE_ENEMY
	card.cost        = 1
	card.description = "Deal X damage."
	card.exhaust     = false

	var dmg := Damage.new()
	dmg.amount = 6
	card.effects = [dmg]

	return card
