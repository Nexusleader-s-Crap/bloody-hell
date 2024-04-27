/obj/item/knife/combat/survival/chemical
	name = "survival knife"
	var/chemicalinuse = null
	var/chemicalamount = 1
	var/chemicalexamine = null

/obj/item/knife/combat/survival/chemical/examine(mob/user)
	. = ..()
	if(IS_TRAITOR(user) || IS_NUKE_OP(user)) //helpful to other syndicates
		. += "This knife has an internal redspace reagent generator producing [chemicalexamine]."

/obj/item/knife/combat/survival/chemical/afterattack(atom/target, mob/user, proximity = TRUE)
	. = ..()
	var/mob/living/carbon/H = target
	if(IS_TRAITOR(user) || IS_NUKE_OP(user))
		H.reagents.add_reagent(chemicalinuse, chemicalamount)

/obj/item/knife/combat/survival/chemical/venom
	chemicalinuse = /datum/reagent/toxin/venom
	chemicalamount = 4
	chemicalexamine = "Venom"

/obj/item/knife/combat/survival/chemical/lexorin
	chemicalinuse = /datum/reagent/toxin/lexorin
	chemicalamount = 3
	chemicalexamine = "Lexorin"

/obj/item/knife/combat/survival/chemical/amanitin
	chemicalinuse = /datum/reagent/toxin/amanitin
	chemicalamount = 5
	chemicalexamine = "Amanitin"

/obj/item/knife/combat/survival/chemical/staminatoxin
	chemicalinuse = /datum/reagent/toxin/staminatoxin
	chemicalamount = 6
	chemicalexamine = "Tirizene"

/obj/item/knife/combat/survival/chemical/curare
	chemicalinuse = /datum/reagent/toxin/curare
	chemicalamount = 2
	chemicalexamine = "Curare"

/obj/item/knife/combat/survival/chemical/initropidril
	chemicalinuse = /datum/reagent/toxin/initropidril
	chemicalamount = 3
	chemicalexamine = "Initropidril"

/obj/item/knife/combat/survival/chemical/pancuronium
	chemicalinuse = /datum/reagent/toxin/pancuronium
	chemicalamount = 3
	chemicalexamine = "Pancuronium"

/obj/item/knife/combat/survival/chemical/heparin
	chemicalinuse = /datum/reagent/toxin/heparin
	chemicalamount = 5
	chemicalexamine = "Heparin"
