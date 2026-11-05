/* this is a playing card deck based off of the Rider-Waite Tarot Deck.
*/

/obj/item/deck/tarot
	name = "deck of tarot cards"
	desc = "For all your occult needs!"
	icon_state = "deck_tarot"

/obj/item/deck/tarot/build_deck()
	for(var/tarotname in list("The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit", "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"))
		cards += new /datum/playingcard("[tarotname]", "tarot_major", "card_back_tarot")
	for(var/suit in list("wands","pentacles","cups","swords"))
		for(var/number in list("Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Page", "Knight", "Queen", "King"))
			cards += new /datum/playingcard("[number] of [suit]", "tarot_[suit]", "card_back_tarot")

/obj/item/deck/tarot/deckshuffle(mob/user)
	if(!COOLDOWN_FINISHED(src, shuffle_cooldown) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	COOLDOWN_START(src, shuffle_cooldown, 1 SECONDS)
	var/list/newcards = list()
	while(length(cards))
		var/datum/playingcard/card = pick_n_take(cards)
		card.name = replacetext(card.name," reversed", "")
		if(prob(50))
			card.name += " reversed"
		newcards += card
	cards = newcards
	playsound(user, 'sound/items/cardshuffle.ogg', 50, TRUE)
	user.visible_message(
		span_notice("[user] тасу[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы тасуете [declent_ru(ACCUSATIVE)].")
	)

