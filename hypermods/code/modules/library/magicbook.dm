/obj/item/magicbook
	name = "magic book"
	desc = "You shouldn't see this."
	icon = 'hypermods/icons/obj/service/library.dmi'
	icon_state = "book"
	worn_icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL  //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb_continuous = list("bashes", "whacks", "educates")
	attack_verb_simple = list("bash", "whack", "educate")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	var/use_sound = 'hypermods/sound/items/bookopen.ogg'
	var/uses = 3
	var/usetime = 1.5 SECONDS

/obj/item/magicbook/examine(mob/user)
	. = ..()
	if(uses)
		. += span_notice("Has [uses] uses left.")

/obj/item/magicbook/attack_self(mob/user)
	to_chat(user, span_notice("You flip open the [src] and begin scouring it's contents..."))
	playsound(src, use_sound, 50, TRUE)
	if(do_after(user, usetime, user) && !QDELETED(src))
		playsound(src, 'hypermods/sound/effects/magebook_used.ogg', 50, TRUE)
		do_effect(user)

/obj/item/magicbook/proc/do_effect(mob/user)
	uses -= 1
	if(!uses)
		qdel(src)
		to_chat(user, span_notice("The [src] vanishes within your hands, it's power expended..."))
		return

/obj/item/magicbook/random

/obj/item/magicbook/random/Initialize(mapload)
	var/random_book = pick(subtypesof(/obj/item/magicbook) - /obj/item/magicbook/random)
	new random_book(loc)
	qdel(src)

/obj/item/magicbook/slimes
	name = "Slime Encyclopedia"
	desc = "An encyclopedia documenting all known slime subspecies, and the possible remedies their cores can provide. \
			Has the potential to invoke the existances of live slimes of a random subspecies near the user."
	icon_state = "slimes"
	use_sound = 'hypermods/sound/items/bookopenlong.ogg'
	usetime = 3 SECONDS

/obj/item/magicbook/slimes/do_effect(mob/user)
	var/turf/T = get_turf(user)

	for(var/i in 1 to 2 + rand(1,2))
		var/mob/living/basic/slime/random/random_slime = new (T)
		random_slime.visible_message(span_danger("After reading the book, [random_slime] emerges from it!"))
		for(var/j in 1 to rand(1, 3))
			step(random_slime, pick(NORTH,SOUTH,EAST,WEST))
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] at [ADMIN_VERBOSEJMP(T)]")
	user.log_message("used a [src] at [AREACOORD(T)].", LOG_ATTACK)
	..()

/obj/item/magicbook/food
	name = "Culinary Dreams"
	desc = "A book with a rather hard cover, a quick peer into the book's contents reveals eerily life-like foodstuffs. \
			Has the potential to conjure random ready-to-eat foods directly to the user."
	icon_state = "food"
	uses = 5

/obj/item/magicbook/food/do_effect(mob/user)
	playsound(get_turf(user), 'sound/effects/phasein.ogg', 100, TRUE)
	sleep(0.25 SECONDS) // small sound delay to prevent multiple sound effects from layering ontop of each other.
	var/food_type = get_random_food()
	var/obj/item/food/food_item = new food_type
	if(!user.put_in_inactive_hand(food_item))
		food_item.forceMove(user.drop_location())
		playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
		to_chat(span_danger("Before you can even read whats within it, [food_item] suddenly pops out from the book and onto the floor!"))
	else
		to_chat(span_danger("Before you can even read whats within it, [food_item] suddenly pops out from the book, and into your hand!"))

	..()

/obj/item/magicbook/healing
	name = "Applied Medicare"
	desc = "A book containing various medicine recipes and how to apply them effectively. \
			Has the potential to provide healing to yourself and all nearby humanoids."
	icon_state = "healing"
	use_sound = 'hypermods/sound/items/bookopenlong.ogg'
	usetime = 3 SECONDS

/obj/item/magicbook/healing/do_effect(mob/user)
	playsound(user, 'sound/magic/staff_healing.ogg', 50, TRUE)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		var/need_mob_update = FALSE
		need_mob_update += C.adjustBruteLoss(-5, updating_health = FALSE)
		need_mob_update += C.adjustFireLoss(-5, updating_health = FALSE)
		need_mob_update += C.adjustToxLoss(-5, updating_health = FALSE)
		need_mob_update += C.adjustOxyLoss(-5, updating_health = FALSE)
		if(need_mob_update)
			C.updatehealth()
		C.reagents.add_reagent(/datum/reagent/medicine/c2/libital, 2)
		C.reagents.add_reagent(/datum/reagent/medicine/c2/aiuri, 2)
		C.reagents.add_reagent(/datum/reagent/medicine/c2/syriniver, 2)
		C.reagents.add_reagent(/datum/reagent/medicine/c2/seiver, 2)

	..()

/obj/item/magicbook/lightning
	name = "The End is Nigh"
	desc = "A mysterious book that feels... deeply unholy. The contents remain unknown to most as few have lived to see it. \
			Has the potential to call forth lightning from an unknown source upon everyone nearby."
	icon_state = "lightning"
	use_sound = 'hypermods/sound/items/bookopenlong.ogg'
	usetime = 3 SECONDS
	var/zap_flags = ZAP_MOB_DAMAGE

/obj/item/magicbook/lightning/do_effect(mob/user, mob/living/target)
	tesla_zap(user, rand(4, 6), 30000, cutoff = 10 KILO JOULES, zap_flags = zap_flags)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/blink
	name = "Blink Tome"
	desc = "A tome of sapphire blue covers that makes anyone feel... unstable just by staring at it. \
			Has the potential to warp everyone nearby including the reader to a random location nearby."
	icon_state = "blink"

/obj/item/magicbook/blink/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		do_teleport(C, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/freeze
	name = "Chilling Pages"
	desc = "A mysterious book that's chilling to the touch, occasionally a few vapors emit from it. \
			Has the potential to freeze the user and nearby people for an extended period of time."
	icon_state = "freeze"

/obj/item/magicbook/freeze/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		if(C != user)
			C.reagents.add_reagent(/datum/reagent/inverse/cryostylane, 30)
		else
			C.reagents.add_reagent(/datum/reagent/inverse/cryostylane, 10)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/sleepy
	name = "Sleepytime Stories"
	desc = "A book containing countless soothing tales to send you off to dreamland. \
			Has the potential to induce instant sleep in the user and nearby people for an extended period of time."
	icon_state = "sleep"

/obj/item/magicbook/sleepy/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		if(C != user)
			C.Sleeping(20 SECONDS)
		else
			C.Sleeping(10 SECONDS)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/gardening
	name = "Applied Horticulture"
	desc = "A book written by an unknown author, it's pages describe botanical techniques completely unheard of... until now. \
			Has the potential to instantly grow nearby plants by a decent margin."
	icon_state = "gardening"

/obj/item/magicbook/gardening/do_effect(mob/user)
	for(var/obj/machinery/hydroponics/constructable/I in range(6, get_turf(user)))
		if(I.myseed)
			I.age = (I.age + (I.myseed.production / 4))
			I.update_appearance()
	..()

/obj/item/magicbook/gardening2
	name = "Applied Horticulture Vol. 2"
	desc = "A book written by an unknown author, it's pages describe botanical techniques that seemingly transcend mortal comprehension. \
			Has the potential to instantly grow nearby plants by a decent margin and heal them slightly."
	icon_state = "gardening2"

/obj/item/magicbook/gardening2/do_effect(mob/user)
	for(var/obj/machinery/hydroponics/constructable/I in range(6, get_turf(user)))
		if(I.myseed)
			I.age = (I.age + (I.myseed.production / 4))
			I.adjust_plant_health(rand(4,10))
			I.update_appearance()
	..()

/obj/item/magicbook/gardening3
	name = "Applied Horticulture Vol. 3"
	desc = "A book written by an unknown author, it's pages describe botanical techniques in a nearly incomprehensible language. \
			Has the potential to instantly grow nearby plants to the point where they are harvestable."
	icon_state = "gardening3"

/obj/item/magicbook/gardening3/do_effect(mob/user)
	for(var/obj/machinery/hydroponics/constructable/I in range(6, get_turf(user)))
		if(I.myseed)
			I.age = (I.age + I.myseed.production)
			I.update_appearance()
	..()

/obj/item/magicbook/birds
	name = "Birds of the World"
	desc = "A book written by an unknown author, occasionally this book... chirps? \
			Has the potential to birth a raptor into existance."
	icon_state = "birds"

/obj/item/magicbook/birds/do_effect(mob/user)
	var/turf/T = get_turf(user)

	var/list/raptor_list = list(
		/mob/living/basic/raptor/red,
		/mob/living/basic/raptor/white,
		/mob/living/basic/raptor/purple,
		/mob/living/basic/raptor/green,
		/mob/living/basic/raptor/yellow,
		/mob/living/basic/raptor/black
	)

	for(var/i in 1 to 1)
		var/raptor = pick(raptor_list)
		new raptor(T)

	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)

	..()

/obj/item/magicbook/fire
	name = "Pyrokinetics Explored"
	desc = "A guidebook containing the scramblings of an author who's clearly a bit too excited by fires. \
			Has the potential to light all nearby people ablaze with glorious flames."
	icon_state = "fire"

/obj/item/magicbook/fire/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		if(C != user)
			C.adjust_fire_stacks(2)
			C.ignite_mob()

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/trees
	name = "Applied Silviculture"
	desc = "A book made from bark, it's pages document the 'outdoors' experience perhaps a bit too well. \
			Has the potential to spring a singular tree into existance."
	icon_state = "trees"
	uses = 5

/obj/item/magicbook/trees/do_effect(mob/user)
	var/turf/T = get_turf(user)

	for(var/i in 1 to 1)
		new /obj/structure/flora/tree/random(T)
		//random_trees.to_chat(span_danger("After reading the book, [random_trees] emerges from it!"))
		//do_teleport(random_trees, get_turf(src), 3, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	do_teleport(user, get_turf(src), 1, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] at [ADMIN_VERBOSEJMP(T)]")
	user.log_message("used a [src] at [AREACOORD(T)].", LOG_ATTACK)
	..()

/obj/item/magicbook/fishing
	name = "The Angler's Guide"
	desc = "A book with a scale-like cover, it's pages are wet and slimey. \
			Has the potential to summon a school of randomized fish."
	icon_state = "fishing"

/obj/item/magicbook/fishing/do_effect(mob/user)
	var/turf/T = get_turf(user)

	var/fish_list = pick(subtypesof(/obj/item/fish))

	for(var/i in 1 to 4)
		var/fishy = pick(fish_list)
		new fishy(T)

	..()

/obj/item/magicbook/volcano
	name = "Joy of Volcanology"
	desc = "An ominous book that scalds those it touches. Makes for a decent house-warmer. \
			Has the potential to turn nearby tiles into lava and back."
	icon_state = "volcano"
	uses = 1
	var/turntolavatime = 3 SECONDS
	var/turntobasalttime = 1 SECONDS
	var/turf_type = /turf/open/lava/smooth/weak
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/misc/asteroid/basalt
	var/reset_string = "basalt"
	var/static/list/banned_turfs = typecacheof(list(/turf/open/space, /turf/closed))
	var/usedrecently = FALSE

/obj/item/magicbook/volcano/do_effect(mob/user)
	if(!usedrecently)
		usedrecently = TRUE
		src.visible_message(span_danger("the [src] glows ominously!")) // Better give a heads up!
		for(var/turf/open/T in range(1, get_turf(user)))
			if(!islava(T))
				sleep(turntolavatime)
				var/old_name = T.name
				if(T.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
					user.visible_message(span_danger("[user] turns \the [old_name] into [transform_string]!"))
					message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] at [ADMIN_VERBOSEJMP(T)]")
					user.log_message("used a [src] at [AREACOORD(T)].", LOG_ATTACK)
					playsound(T,'sound/magic/fireball.ogg', 200, TRUE)
			else // no delay on turning turfs back from lava.
				sleep(turntobasalttime)
				var/old_name = T.name
				if(T.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
					user.visible_message(span_danger("[user] turns \the [old_name] into [reset_string]!"))
					playsound(T,'sound/magic/fireball.ogg', 200, TRUE)
		usedrecently = FALSE
	else
		to_chat(span_notice("[src]'s powers cannot be invoked right now!"))
		return // refunded.
	..()

/obj/item/magicbook/spiders
	name = "Arachnophobia 101"
	desc = "A book with a large, seemingly authentic spider web printed upon it's cover. It makes your flesh crawl just by looking at it. \
			Has the potential to summon forth random spiderlings from... the spiderverse?"
	icon_state = "spiders"

/obj/item/magicbook/spiders/do_effect(mob/user)
	var/turf/T = get_turf(user)

	var/list/spider_list = list(
		/mob/living/basic/spider/growing/spiderling/guard,
		/mob/living/basic/spider/growing/spiderling/ambush,
		/mob/living/basic/spider/growing/spiderling/scout,
		/mob/living/basic/spider/growing/spiderling/hunter,
		/mob/living/basic/spider/growing/spiderling/nurse,
		/mob/living/basic/spider/growing/spiderling/tangle,
		/mob/living/basic/spider/growing/spiderling/tank,
		/mob/living/basic/spider/growing/spiderling/breacher,
		/mob/living/basic/spider/growing/spiderling/midwife,
		/mob/living/basic/spider/growing/spiderling/viper,
		/mob/living/basic/spider/growing/spiderling/tarantula
	)

	for(var/i in 1 to 4)
		var/spider = pick(spider_list)
		new spider(T)

	to_chat(span_danger("After reading the book, a bunch of spiderlings emerge from it and leap to the floor!"))
	playsound(src, 'sound/effects/phasein.ogg', 100, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] at [ADMIN_VERBOSEJMP(T)]")
	user.log_message("used a [src] at [AREACOORD(T)].", LOG_ATTACK)
	..()

/obj/item/magicbook/temperature
	name = "Tempering Temperatures"
	desc = "A detailed guide on how to: Not die to extreme temperatures. \
			Has the potential to temporarily render everyone nearby resistant to extreme temperatures."
	icon_state = "temperature"

/obj/item/magicbook/temperature/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		C.reagents.add_reagent(/datum/reagent/medicine/leporazine, 20)
	..()

/obj/item/magicbook/light
	name = "Lux Aeterna Vol. 1"
	desc = "A strange tome which looks remarkably... lit up? It's difficult to notice any shadows upon it. \
			Has the potential to fix light fixtures nearby."
	icon_state = "light"

/obj/item/magicbook/light/do_effect(mob/user)
	for(var/obj/machinery/light/L in urange(10, user, 1))
		L.fix()
	..()

/obj/item/magicbook/light2
	name = "Lux Aeterna Vol. 2"
	desc = "A powerful tome containing incredible light. Rays of light can be seen pouring out of it from between the pages. \
			Has the potential to fix light fixtures nearby and blind everyone."
	icon_state = "light2"

/obj/item/magicbook/light2/do_effect(mob/user)
	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		M.visible_message(span_danger("An unbelievably bright light fills [M]'s eyes!"))
		M.flash_act(1, 1)
		M.adjustOrganLoss(ORGAN_SLOT_EYES, 25, 95)
		M.adjust_eye_blur(20)
		M.Knockdown(rand(25, 50))
	for(var/obj/machinery/light/L in urange(10, user, 1))
		L.fix()
	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/wetness
	name = "Rainy Days"
	desc = "A book containing pages that seem to be soaked with water, the words within are barely legible. \
			Has the potential to extinguish fires and leave everyone nearby soaked. Can spew water vapor."
	icon_state = "wetness"

/obj/item/magicbook/wetness/do_effect(mob/user, turf/open/exposed_turf)
	var/turf/T = get_turf(user)

	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		C.adjust_fire_stacks(-4)
		C.adjust_wet_stacks(4)
		C.visible_message(span_notice("[C] is suddenly drenched with what appears to be water!"))

	if(prob(10))
		src.visible_message(span_notice("[src] suddenly spews water vapor outward!"))
		T.atmos_spawn_air("[GAS_WATER_VAPOR]=20")

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] at [ADMIN_VERBOSEJMP(T)]")
	user.log_message("used a [src] at [AREACOORD(T)].", LOG_ATTACK)
	..()

/obj/item/magicbook/moon
	name = "Lunar Grimoire"
	desc = "A rare grimoire containing the 'secrets of the moon', whatever that means. \
			Has the potential to temporarily turn the reader nearly invisible for a short time."
	icon_state = "moon"
	var/usedrecently = FALSE
	var/duration = 10 SECONDS

/obj/item/magicbook/moon/do_effect(mob/user)
	if(!usedrecently)
		usedrecently = TRUE
		user.alpha = 30
		user.visible_message(span_notice("[user] suddenly becomes transparent!"))
		sleep(duration) // 10 second duration
		usedrecently = FALSE
		user.visible_message(span_notice("[user] suddenly becomes opaque!"))
		user.alpha = 255
	else
		to_chat(span_notice("[src]'s powers cannot be invoked right now!"))
		return // refunded.
	..()

/obj/item/magicbook/bees
	name = "Apicultural Notes"
	desc = "A notebook that seemingly buzzes on it's own, it's probably best you never open it. \
			Has the potential to bring several bees into existance. Small chance for a toxic bee to be summoned."
	icon_state = "bees"

/obj/item/magicbook/bees/do_effect(mob/user)
	var/turf/T = get_turf(user)

	for(var/i in 1 to 2 + rand(1,2))
		var/mob/living/basic/bee/beespawn = new (T)
		to_chat(span_danger("After reading the book, [beespawn] emerges from it!"))
		for(var/j in 1 to rand(1, 3))
			step(beespawn, pick(NORTH,SOUTH,EAST,WEST))
	if(prob(20))
		var/mob/living/basic/bee/toxin/beespawn2 = new (T)
		to_chat(span_danger("After reading the book, [beespawn2] emerges from it!"))
		for(var/j in 1 to rand(1, 3))
			step(beespawn2, pick(NORTH,SOUTH,EAST,WEST))
	playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] at [ADMIN_VERBOSEJMP(T)]")
	user.log_message("used a [src] at [AREACOORD(T)].", LOG_ATTACK)
	..()

/obj/item/magicbook/everything
	name = "Everything Encyclopedia Vol. 1"
	desc = "A strange encyclopedia containing texts native across it's entire family of arcane literature. \
			Has the potential to birth a random arcane book with only 1 use."
	icon_state = "everything"

/obj/item/magicbook/everything/do_effect(mob/user)
	var/book_type = pick(subtypesof(/obj/item/magicbook))
	var/obj/item/magicbook/book_item = new book_type
	book_item.forceMove(get_turf(user))
	//book_item.do_effect()
	book_item.uses = 1
	//to_chat(span_danger("[src]'s powers invoke a [book_item]!"))
	to_chat(span_danger("The [src]'s words burn away from the page and coalesce into a new [book_item]!"))
	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src] which became a [book_item]")
	user.log_message("used a [src] which became a [book_item].", LOG_ATTACK)
	..()

/obj/item/magicbook/everything2
	name = "Everything Encyclopedia Vol. 2"
	desc = "A strange encyclopedia containing a wide variety of documentations and listings for items all across the galaxy, illegal or not. \
			Has the potential to bring forth a completely random item. Are you feeling lucky?"
	icon_state = "everything2"
	uses = 1

/obj/item/magicbook/everything2/do_effect(mob/user)
	playsound(get_turf(user), 'sound/effects/phasein.ogg', 100, TRUE)
	var/item_type = pick(subtypesof(/obj/item/))
	var/obj/item/item_chosen = new item_type
	if(!user.put_in_inactive_hand(item_chosen))
		item_chosen.forceMove(user.drop_location())
		to_chat(span_danger("Flipping to a random page, [item_chosen] suddenly pops out from the book and onto the floor!"))
	else
		to_chat(span_danger("Flipping to a random page, [item_chosen] suddenly pops out from the book, and into your hand!"))

	..()
/**
/obj/item/magicbook/antag_reveal
	name = "Enemy Catalouge"
	desc = ""
	icon_state = "antag_reveal"

/obj/item/magicbook/antag_reveal/do_effect(mob/user)
	var/list/crewmembers = list() // All crew members on station.
	var/list/antags = list() // All antagonists involved
	var/list/crewlist = list() // Used to randomize names in the feedback.
	var/list/antagtypes = list() // What antagonists can the player be informed of?

	for(var/mob/living/carbon/human/C in range(100, get_turf(user)))
		if(C != user && C.mind) // No, i don't want to antag-check myself.
			crewmembers += C

	for(var/mob/living/carbon/human/A in range(100, get_turf(user)))
		if(A != user && A.mind && (IS_TRAITOR(A)) || (IS_CULTIST(A)) || (IS_CHANGELING(A)) || (IS_HERETIC(A)) || (IS_REVOLUTIONARY(A)) || (IS_SPY(A))) // No, i don't want to antag-check myself.
			antags += A
			for(var/datum/antagonist/antag_datum as anything in A.mind.antag_datums)
				antagtypes += antag_datum

	var/crewmember1 = pick(crewmembers)
	var/crewmember2 = pick(crewmembers)
	var/antagonist = pick(antags)

	crewlist += crewmember1
	crewlist += crewmember2
	crewlist += antagonist

	//to_chat(span_notice("After flipping the book open the following can be read upon all of it's pages: There is an [total_antagonists] among the following:"))
	//to_chat(span_notice("[antagtypes]"))
	//to_chat(span_notice("[antagonist]"))
	to_chat(span_notice("[crewmember1]"))

	..()

/obj/item/magicbook/antag_reveal2
	name = "Enemy Catalouge Vol. 2"
	desc = ""
	icon_state = "antag_reveal2"

/obj/item/magicbook/antag_reveal2/do_effect(mob/user)

	..()
**/
/obj/item/magicbook/deconversion
	name = "Deconversion Tactics"
	desc = "A seemingly holy text containing ancient arcane techniques in subdueing subversion within another's mind. \
			Has the potential to deconvert Hypnosis Victims, Brainwashed People, Revolutionaries, and weaken Cultists."
	icon_state = "deconversion"
	use_sound = 'hypermods/sound/items/bookopenlong.ogg'
	usetime = 3 SECONDS

/obj/item/magicbook/deconversion/do_effect(mob/user)
	for(var/mob/living/carbon/human/target in range(2, get_turf(user)))
		if(target.mind?.has_antag_datum(/datum/antagonist/rev) && (!target.mind?.has_antag_datum(/datum/antagonist/rev/head)))
			target.mind?.remove_antag_datum(/datum/antagonist/rev)
			target.Knockdown(10)
		if(target.mind?.has_antag_datum(/datum/antagonist/brainwashed))
			target.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
			target.Knockdown(10)
		if(target.mind?.has_antag_datum(/datum/antagonist/hypnotized))
			target.mind?.remove_antag_datum(/datum/antagonist/hypnotized)
			target.Knockdown(10)
		if(target.mind?.has_antag_datum(/datum/antagonist/cult))
			target.reagents.add_reagent(/datum/reagent/water/holywater, 30)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/hypnotizing
	name = "Hypnosis and You"
	desc = "An tome containing symbols you don't recognize, made by an unknown author. \
			Has the potential to drug nearby people, and potentially induce a trance in those of weak minds."
	icon_state = "hypnotizing"
	use_sound = 'hypermods/sound/items/bookopenlong.ogg'
	usetime = 3 SECONDS

/obj/item/magicbook/hypnotizing/do_effect(mob/user, mob/living/living_mob)
	for(var/mob/living/carbon/human/target in range(2, get_turf(user)))
		if(target != user)
			if(target.hypnosis_vulnerable())
				target.Stun(2 SECONDS)
				target.apply_status_effect(/datum/status_effect/trance, 100, TRUE)
			else
				target.reagents.add_reagent(/datum/reagent/drug/space_drugs, 10)

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/vision
	name = "Optical Augmentation"
	desc = "A tome containing strange, glowing letters written in a font unknown to most. Just looking at the letters invokes a strange feeling within one's eyes. \
			Has the potential to augment the reader's eyes for a short time."
	icon_state = "vision"
	var/augduration = 30 SECONDS
	var/usedrecently = FALSE

/obj/item/magicbook/vision/do_effect(mob/user)
	if(!usedrecently)
		usedrecently = TRUE
		if(prob(95))
			ADD_TRAIT(user, TRAIT_THERMAL_VISION, STATUS_EFFECT_TRAIT)
			user.update_sight()
			to_chat(span_notice("After flipping through the [src], you notice shapes within the walls!"))
			sleep(augduration)
			REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, STATUS_EFFECT_TRAIT)
			user.update_sight()
			to_chat(span_notice("Your vision has returned to normal."))
		else
			ADD_TRAIT(user, TRAIT_XRAY_VISION, STATUS_EFFECT_TRAIT)
			user.update_sight()
			to_chat(span_notice("After flipping through the [src], you notice the walls give way!"))
			sleep(augduration)
			REMOVE_TRAIT(user, TRAIT_XRAY_VISION, STATUS_EFFECT_TRAIT)
			user.update_sight()
			to_chat(span_notice("Your vision has returned to normal."))
	usedrecently = FALSE
	..()

/obj/item/magicbook/pressure
	name = "Pressurized Predicts"
	desc = "A book written by an unknown author, the first page only contains one word: 'Space.' \
			Has the potential to infuse a rare reagent within everyone nearby, protecting them fron low and high pressure environments."
	icon_state = "pressure"

/obj/item/magicbook/pressure/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		if(!C.reagents.has_reagent(/datum/reagent/medicine/barozine)) // Trying not to OD people here.
			C.reagents.add_reagent(/datum/reagent/medicine/barozine, 10)
	..()

/obj/item/magicbook/holyness
	name = "The Good Book"
	desc = "Not to be confused with the bible, this seemingly holy textbook is written in such a way to be understood even if one cannot read. \
			Has the potential to render the reader and everyone nearby into a holy being for a limited time, protecting them from magic."
	icon_state = "holyness"

/obj/item/magicbook/holyness/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(10, get_turf(user)))
		C.reagents.add_reagent(/datum/reagent/medicine/antimagic, 10)
	..()

/obj/item/magicbook/silence
	name = "Silent Secrets"
	desc = "This 'book' if you can call it that, seemingly has no words? \
			Has the potential to render everyone near the user mute for a short time."
	icon_state = "silence"

/obj/item/magicbook/silence/do_effect(mob/user)
	for(var/mob/living/carbon/human/C in viewers(user, null)) // Everyone except the user.
		C.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 10)
	..()

/obj/item/magicbook/pestilence
	name = "Immuno Inductionary"
	desc = "A medical textbook documenting every disease ever discovered, it's rumored to actually inflict the disease the reader stumbles upon. \
			Has the potential to bestow a random disease upon everyone nearby, including the reader."
	icon_state = "pestilence"

/obj/item/magicbook/pestilence/do_effect(mob/user)
	for(var/mob/living/carbon/C in range(4, get_turf(user)))
		C.ForceContractDisease(new /datum/disease/advance/random(), FALSE, TRUE)
	..()

/obj/item/magicbook/shelter
	name = "Sheltered Texts"
	desc = "A textbook documenting the effects of a 'Stabilized Bluespace Extract' written by someone named 'Hyper'. \
			Has the potential to teleport the reader to a random safe location."
	icon_state = "shelter"

/obj/item/magicbook/shelter/do_effect(mob/user)
	do_sparks(5,FALSE,user)
	var/F = find_safe_turf(zlevel = user.z, extended_safety_checks = TRUE)
	var/range = 0
	if(!F)
		F = get_turf(user)
		range = 50
	to_chat(span_warning("As you read the [src], you suddenly find yourself somewhere else!"))
	if(do_teleport(user, F, range, channel = TELEPORT_CHANNEL_BLUESPACE))
		do_sparks(5,FALSE,user)
	..()

/obj/item/magicbook/charge
	name = "Charged Propaganda"
	desc = "A propagandized piece of literature made by an unknown ethereal author. The text has become far too dated to read. \
			Has the potential to charge a random item on everyone nearby by 10%. Rare chance to charge APC's in a large radius by 25%."
	icon_state = "charge"

/obj/item/magicbook/charge/do_effect(mob/user)
	for(var/mob/living/carbon/human/C in viewers(user, null))
		var/list/batteries = list()
		for(var/obj/item/stock_parts/power_store/P in C.get_all_contents())
			if(P.charge < P.maxcharge)
				batteries += P
		if(batteries.len)
			var/obj/item/stock_parts/power_store/ToCharge = pick(batteries)
			ToCharge.charge += min(ToCharge.maxcharge - ToCharge.charge, ToCharge.maxcharge/10) //10% of the cell, or to maximum.

	if(prob(25)) // 25% chance for this secondary effect.
		for(var/obj/machinery/power/apc/target in range(20, get_turf(user)))
			if(target.cell)
				target.cell.charge += min(target.cell.maxcharge - target.cell.charge, target.cell.maxcharge/4) // 25% recharge on the apc
	..()

/obj/item/magicbook/honk
	name = "Tome of the Circus Vol. 1"
	desc = "A... unique tome... all of it's pages simply read: 'HONK HONK HONK HONK HONK' \
			Has the potential to grant the reader a banana cream pie! Fresh from the oven!"
	icon_state = "honk"

/obj/item/magicbook/honk/do_effect(mob/user)
	var/turf/T = get_turf(user)

	var/obj/item/food/pie/cream/pie_item = new (T)
	if(!user.put_in_inactive_hand(pie_item))
		pie_item.forceMove(user.drop_location())
		to_chat(span_danger("As you open the book, an arm reaches out from it and drops [pie_item] onto the floor!"))
	else
		to_chat(span_danger("As you open the book, an arm reaches out from it and hands you [pie_item]!"))
	..()

/obj/item/magicbook/honk2
	name = "Tome of the Circus Vol. 2"
	desc = "A mysterious tome written by an unknown author, while the text only reads 'HONK HONK HONK', the text seemingly blends into itself to create a spiral pattern. \
			Has the potential to grant the reader the rarest banana cream pie ever known."
	icon_state = "honk2"

/obj/item/magicbook/honk2/do_effect(mob/user)
	var/turf/T = get_turf(user)

	var/obj/item/food/pie/cream/bluespace/pie_item = new (T)
	if(!user.put_in_inactive_hand(pie_item))
		pie_item.forceMove(user.drop_location())
		to_chat(span_danger("As you open the book, an arm reaches out from it and drops [pie_item] onto the floor!"))
	else
		to_chat(span_danger("As you open the book, an arm reaches out from it and hands you [pie_item]!"))
	..()

/obj/item/magicbook/event
	name = "Event Calender"
	desc = "A sheet of pages that are barely glued into a book cover properly, they contain the findings of a self-proclaimed 'archmage' who once completed a 'grand ritual'. \
			Has the potential to invoke a random event into existance."
	icon_state = "event"
	uses = 1

/obj/item/magicbook/event/do_effect(mob/user)
	var/random_event = pick(subtypesof(/datum/round_event_control))
	force_event(random_event, "a [src]")

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/obj/item/magicbook/threat
	name = "Threat Report"
	desc = "A sturdy book detailing a myriad of possible threats near the user's location. At the very back of the book is a red button that reads: 'Feeling lucky?' \
			Has the potential to shift the station's orbit into more dangerous territory, leading to increased threats."
	icon_state = "threat"
	uses = 1

/obj/item/magicbook/threat/do_effect(mob/user)
	SSdynamic.mid_round_budget += 10

	message_admins("[ADMIN_LOOKUPFLW(user)] used a [src]")
	user.log_message("used a [src].", LOG_ATTACK)
	..()

/**
/obj/item/magicbook/
	name = ""
	desc = ""
	icon_state = ""

/obj/item/magicbook//do_effect(mob/user)

	..()
**/
