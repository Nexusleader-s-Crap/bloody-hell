///A global list of singleton fish traits by their paths
GLOBAL_LIST_INIT(fish_traits, init_subtypes_w_path_keys(/datum/fish_trait, list()))

/**
 * A nested list of fish types and traits that they can spontaneously manifest with associated probabilities
 * e.g. list(/obj/item/fish = list(/datum/fish_trait = 100), etc...)
 */
GLOBAL_LIST_INIT(spontaneous_fish_traits, populate_spontaneous_fish_traits())

/proc/populate_spontaneous_fish_traits()
	var/list/list = list()
	for(var/trait_path as anything in GLOB.fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_path]
		if(isnull(trait.spontaneous_manifest_types))
			continue
		var/list/trait_typecache = zebra_typecacheof(trait.spontaneous_manifest_types) - /obj/item/fish
		for(var/fish_type in trait_typecache)
			var/trait_prob = trait_typecache[fish_type]
			if(!trait_prob)
				continue
			LAZYSET(list[fish_type], trait_path, trait_typecache[fish_type])
	return list

/datum/fish_trait
	var/name = "Unnamed Trait"
	/// Description of the trait in the fishing catalog and scanner
	var/catalog_description = "Uh uh, someone has forgotten to set description to this trait. Yikes!"
	///A list of traits fish cannot have in conjunction with this trait.
	var/list/incompatible_traits
	/// The probability this trait can be inherited by offsprings when both mates have it
	var/inheritability = 100
	/// Same as above, but for when only one has it.
	var/diff_traits_inheritability = 50
	/// A list of fish types and traits that they can spontaneously manifest with associated probabilities
	var/list/spontaneous_manifest_types
	/// An optional whitelist of fish that can get this trait
	var/list/fish_whitelist
	/// Depending on the value, fish with trait will be reported as more or less difficult in the catalog.
	var/added_difficulty = 0
	/// Reagents to add to the fish whenever the COMSIG_GENERATE_REAGENTS_TO_ADD signal is sent. Their values will be multiplied later.
	var/list/reagents_to_add

/// Difficulty modifier from this mod, needs to return a list with two values
/datum/fish_trait/proc/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	SHOULD_CALL_PARENT(TRUE) //Technically it doesn't but this makes it saner without custom unit test
	return list(ADDITIVE_FISHING_MOD = 0, MULTIPLICATIVE_FISHING_MOD = 1)

/// Catch weight table modifier from this mod, needs to return a list with two values
/datum/fish_trait/proc/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman, atom/location, obj/item/fish/fish_type)
	SHOULD_CALL_PARENT(TRUE)
	return list(ADDITIVE_FISHING_MOD = 0, MULTIPLICATIVE_FISHING_MOD = 1)

/// Returns special minigame rules and effects applied by this trait
/datum/fish_trait/proc/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	return

/// Applies some special qualities to the fish that has been spawned
/datum/fish_trait/proc/apply_to_fish(obj/item/fish/fish)
	SHOULD_CALL_PARENT(TRUE)
	if(length(reagents_to_add))
		RegisterSignal(fish, COMSIG_GENERATE_REAGENTS_TO_ADD, PROC_REF(add_reagents))

/// Applies some special qualities to basic mobs generated by fish (i.e. chasm chrab --> young lobstrosity --> lobstrosity).
/datum/fish_trait/proc/apply_to_mob(mob/living/basic/mob)
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(mob, COMSIG_MOB_CHANGED_TYPE, PROC_REF(on_transformed))

/datum/fish_trait/proc/on_transformed(mob/source, mob/desired_mob)
	SIGNAL_HANDLER
	apply_to_mob(desired_mob)

/// Proc used by both the predator and necrophage traits.
/datum/fish_trait/proc/eat_fish(obj/item/fish/predator, obj/item/fish/prey)
	var/message = prey.status == FISH_DEAD ? "[src] eats [prey]'s carcass." : "[src] hunts down and eats [prey]."
	predator.loc.visible_message(span_warning(message))
	SEND_SIGNAL(prey, COMSIG_FISH_EATEN_BY_OTHER_FISH, predator)
	qdel(prey)
	predator.sate_hunger()


/**
 * Signal sent when we need to generate an abstract holder containing
 * reagents to be transfered, usually as a result of the fish being eaten by someone
 */
/datum/fish_trait/proc/add_reagents(obj/item/fish/fish, list/reagents)
	SIGNAL_HANDLER
	for(var/reagent in reagents_to_add)
		reagents[reagent] += reagents_to_add[reagent]

/// Proc that adds or changes the venomous when the fish size and/or weight are updated
/datum/fish_trait/proc/add_venom(obj/item/fish/source, venom_path, new_weight, mult = 0.25)
	if(source.size)
		var/old_amount = max(round((source.weight/FISH_GRIND_RESULTS_WEIGHT_DIVISOR) * mult, 0.1), mult)
		source.RemoveElement(/datum/element/venomous, venom_path, old_amount)

	var/new_amount = max(round((new_weight/FISH_GRIND_RESULTS_WEIGHT_DIVISOR) * mult, 0.1), mult)
	source.AddElement(/datum/element/venomous, venom_path, new_amount)

/// Proc that changes the venomous element based on if the fish is alive or dead (basically dead fish are weaker).
/datum/fish_trait/proc/change_venom_on_death(obj/item/fish/source, venom_path, live_mult, dead_mult)
	var/live_amount = max(round((source.weight/FISH_GRIND_RESULTS_WEIGHT_DIVISOR) * live_mult, 0.1), live_mult)
	var/dead_amount = max(round((source.weight/FISH_GRIND_RESULTS_WEIGHT_DIVISOR) * dead_mult, 0.1), dead_mult)
	var/is_dead = source.status == FISH_DEAD
	source.RemoveElement(/datum/element/venomous, venom_path, is_dead ? live_amount : dead_amount, thrown_effect = TRUE)
	source.AddElement(/datum/element/venomous, venom_path, is_dead ? dead_amount : live_amount, thrown_effect = TRUE)

/datum/fish_trait/wary
	name = "Wary"
	catalog_description = "This fish will avoid visible fish lines, cloaked line recommended."

/datum/fish_trait/wary/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// Wary fish require transparent line or they're harder
	if(!rod.line || !(rod.line.fishing_line_traits & FISHING_LINE_CLOAKED))
		.[ADDITIVE_FISHING_MOD] += FISH_TRAIT_MINOR_DIFFICULTY_BOOST

/datum/fish_trait/shiny_lover
	name = "Shiny Lover"
	catalog_description = "This fish loves shiny things, shiny lure recommended."

/datum/fish_trait/shiny_lover/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// These fish are easier to catch with shiny hook
	if(rod.hook && rod.hook.fishing_hook_traits & FISHING_HOOK_SHINY)
		.[ADDITIVE_FISHING_MOD] -= FISH_TRAIT_MINOR_DIFFICULTY_BOOST

/datum/fish_trait/shiny_lover/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// These fish are harder to find without a shiny hook
	if(rod.hook && rod.hook.fishing_hook_traits & FISHING_HOOK_SHINY)
		.[MULTIPLICATIVE_FISHING_MOD] = 0.5

/datum/fish_trait/picky_eater
	name = "Picky Eater"
	catalog_description = "This fish is very picky and will ignore low quality bait (unless it's amongst its favorites)."

/datum/fish_trait/picky_eater/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman, atom/location, obj/item/fish/fish_type)
	. = ..()
	if(!rod.bait)
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(HAS_TRAIT(rod.bait, TRAIT_OMNI_BAIT))
		return

	var/list/fav_baits = SSfishing.fish_properties[fish_type][FISH_PROPERTIES_FAV_BAIT]
	for(var/identifier in fav_baits)
		if(is_matching_bait(rod.bait, identifier)) //we like this bait anyway
			return

	var/list/bad_baits = SSfishing.fish_properties[fish_type][FISH_PROPERTIES_BAD_BAIT]
	for(var/identifier in bad_baits)
		if(is_matching_bait(rod.bait, identifier)) //we hate this bait.
			.[MULTIPLICATIVE_FISHING_MOD] = 0
			return

	if(!HAS_TRAIT(rod.bait, TRAIT_GOOD_QUALITY_BAIT) && !HAS_TRAIT(rod.bait, TRAIT_GREAT_QUALITY_BAIT))
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/nocturnal
	name = "Nocturnal"
	catalog_description = "This fish avoids bright lights, fishing and storing in darkness recommended."

/datum/fish_trait/nocturnal/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman, atom/location, obj/item/fish/fish_type)
	. = ..()
	if(rod.bait && HAS_TRAIT(rod.bait, TRAIT_BAIT_IGNORE_ENVIRONMENT))
		return
	var/turf/turf = get_turf(location)
	var/light_amount = turf?.get_lumcount()
	if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD)
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/nocturnal/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(check_light))

/datum/fish_trait/nocturnal/proc/check_light(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(isturf(source.loc) || isaquarium(source))
		var/turf/turf = get_turf(source)
		var/light_amount = turf.get_lumcount()
		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD)
			source.adjust_health(source.health - 0.5 * seconds_per_tick)

/datum/fish_trait/nocturnal/apply_to_mob(mob/living/basic/mob)
	. = ..()
	// Make sure the mob can also ee in the dark
	mob.lighting_cutoff_red = min(mob.lighting_cutoff_red, 20)
	mob.lighting_cutoff_green = min(mob.lighting_cutoff_green, 20)
	mob.lighting_cutoff_blue = min(mob.lighting_cutoff_blue, 20)
	mob.update_sight()

	RegisterSignal(mob, COMSIG_LIVING_HANDLE_BREATHING, PROC_REF(on_non_stasis_life))

/datum/fish_trait/nocturnal/proc/on_non_stasis_life(mob/living/basic/mob, seconds_per_tick = SSMOBS_DT)
	SIGNAL_HANDLER
	var/turf/our_turf = mob.loc
	if(!isturf(our_turf))
		return
	var/light_amount = our_turf.get_lumcount()

	if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
		mob.apply_status_effect(/datum/status_effect/shadow_regeneration)

/datum/fish_trait/heavy
	name = "Demersal"
	catalog_description = "This fish tends to stay near the waterbed."

/datum/fish_trait/heavy/apply_to_mob(mob/living/basic/mob)
	. = ..()
	mob.add_movespeed_modifier(/datum/movespeed_modifier/heavy_fish)
	mob.maxHealth *= 1.5
	mob.health *= 1.5
	mob.melee_damage_lower *= 1.3
	mob.melee_damage_upper *= 1.3
	mob.obj_damage *= 1.3

/datum/fish_trait/heavy/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.mover.fish_idle_velocity -= 10

/datum/fish_trait/carnivore
	name = "Carnivore"
	catalog_description = "This fish can only be baited with meat."
	incompatible_traits = list(/datum/fish_trait/vegan)

/datum/fish_trait/carnivore/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman, atom/location, obj/item/fish/fish_type)
	. = ..()
	if(!rod.bait)
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(HAS_TRAIT(rod.bait, TRAIT_OMNI_BAIT))
		return
	if(isfish(rod.bait))
		return
	if(!istype(rod.bait, /obj/item/food))
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	var/obj/item/food/food_bait = rod.bait
	if(!(food_bait.foodtypes & (MEAT|SEAFOOD|BUGS)))
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/vegan
	name = "Herbivore"
	catalog_description = "This fish can only be baited with fresh produce."
	incompatible_traits = list(/datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/necrophage)

/datum/fish_trait/vegan/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman, atom/location, obj/item/fish/fish_type)
	. = ..()
	if(!rod.bait)
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(HAS_TRAIT(rod.bait, TRAIT_OMNI_BAIT))
		return
	if(!istype(rod.bait, /obj/item/food))
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(istype(rod.bait, /obj/item/food/grown))
		return
	var/obj/item/food/food_bait = rod.bait
	if(food_bait.foodtypes & (MEAT|SEAFOOD|GORE|BUGS|DAIRY) || !(food_bait.foodtypes & (VEGETABLES|FRUIT)))
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/emulsijack
	name = "Emulsifier"
	catalog_description = "This fish emits an invisible toxin that emulsifies other fish for it to feed on."

/datum/fish_trait/emulsijack/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(emulsify))
	ADD_TRAIT(fish, TRAIT_RESIST_EMULSIFY, FISH_TRAIT_DATUM)

/datum/fish_trait/emulsijack/proc/emulsify(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!isaquarium(source.loc))
		return
	var/emulsified = FALSE
	for(var/obj/item/fish/victim in source.loc)
		if(HAS_TRAIT(victim, TRAIT_RESIST_EMULSIFY) || HAS_TRAIT(victim, TRAIT_FISH_TOXIN_IMMUNE)) //no team killing
			continue
		victim.adjust_health(victim.health - 3 * seconds_per_tick) //the victim may heal a bit but this will quickly kill
		emulsified = TRUE
	if(emulsified)
		source.adjust_health(source.health + 3 * seconds_per_tick)
		source.sate_hunger()

/datum/fish_trait/emulsijack/apply_to_mob(mob/living/basic/mob)
	. = ..()
	RegisterSignal(mob, COMSIG_LIVING_HANDLE_BREATHING, PROC_REF(on_non_stasis_life))

/datum/fish_trait/emulsijack/proc/on_non_stasis_life(mob/living/basic/mob, seconds_per_tick = SSMOBS_DT)
	SIGNAL_HANDLER
	var/turf/open/our_turf = get_turf(mob)
	if(our_turf.return_air().return_pressure() > ONE_ATMOSPHERE * 1.5) //put a cap otherwise closed spaces may overpressurize
		return

	var/datum/gas_mixture/stench = new
	ADD_GAS(/datum/gas/miasma, stench.gases)
	stench.gases[/datum/gas/miasma][MOLES] = MIASMA_CORPSE_MOLES * 2 * seconds_per_tick
	stench.temperature = mob.bodytemperature
	our_turf.assume_air(stench)

/datum/fish_trait/necrophage
	name = "Necrophage"
	catalog_description = "This fish will eat carcasses of dead fish when hungry."
	incompatible_traits = list(/datum/fish_trait/vegan)

/datum/fish_trait/necrophage/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(eat_dead_fishes))

/datum/fish_trait/necrophage/proc/eat_dead_fishes(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source.get_hunger() > 0.75 || !isaquarium(source.loc))
		return
	for(var/obj/item/fish/victim in source.loc)
		if(victim.status != FISH_DEAD || victim == source || HAS_TRAIT(victim, TRAIT_YUCKY_FISH))
			continue
		eat_fish(source, victim)
		return

/datum/fish_trait/parthenogenesis
	name = "Parthenogenesis"
	catalog_description = "This fish can reproduce asexually, without the need of a mate."
	inheritability = 80
	diff_traits_inheritability = 25

/datum/fish_trait/parthenogenesis/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_SELF_REPRODUCE, FISH_TRAIT_DATUM)

/**
 * Useful for those species with the parthenogenesis trait if you don't want them to mate with each other,
 * or for similar shenanigans, I don't know.
 * Otherwise you could just set the stable_population to 1.
 */
/datum/fish_trait/no_mating
	name = "Mateless"
	catalog_description = "This fish cannot reproduce with other fishes."
	incompatible_traits = list(/datum/fish_trait/crossbreeder)
	spontaneous_manifest_types = list(/obj/item/fish/fryish = 100)

/datum/fish_trait/no_mating/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_NO_MATING, FISH_TRAIT_DATUM)

///Prevent offsprings of fish with this trait from being of the same type (unless self-mating or the partner also has the trait)
/datum/fish_trait/recessive
	name = "Recessive"
	catalog_description = "If crossbred, offsprings will always be of the mate species, unless it also possess the trait."
	diff_traits_inheritability = 0

/datum/fish_trait/no_mating/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_RECESSIVE, FISH_TRAIT_DATUM)

/datum/fish_trait/revival
	diff_traits_inheritability = 15
	name = "Self-Revival"
	catalog_description = "This fish shows a peculiar ability of reviving itself a minute or two after death."
	spontaneous_manifest_types = list(/obj/item/fish/boned = 100, /obj/item/fish/mastodon = 100)

/datum/fish_trait/revival/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_STATUS_CHANGED, PROC_REF(check_status))

/datum/fish_trait/revival/proc/check_status(obj/item/fish/source)
	SIGNAL_HANDLER
	if(source.status == FISH_DEAD)
		addtimer(CALLBACK(src, PROC_REF(revive), WEAKREF(source)), rand(1 MINUTES, 2 MINUTES))

/datum/fish_trait/revival/proc/revive(datum/weakref/fish_ref)
	var/obj/item/fish/source = fish_ref.resolve()
	if(QDELETED(source) || source.status != FISH_DEAD)
		return
	source.set_status(FISH_ALIVE)
	var/message = span_nicegreen("[source] twitches. It's alive!")
	if(isaquarium(source.loc))
		source.loc.visible_message(message)
	else
		source.visible_message(message)

/datum/fish_trait/revival/apply_to_mob(mob/living/basic/mob)
	. = ..()
	mob.AddComponent(/datum/component/regenerator, regeneration_delay = 6 SECONDS, brute_per_second = 2 SECONDS, outline_colour = COLOR_BLUE)

/datum/fish_trait/predator
	name = "Predator"
	catalog_description = "It's a predatory fish. It'll hunt down and eat live fishes of smaller size when hungry."
	incompatible_traits = list(/datum/fish_trait/vegan)

/datum/fish_trait/predator/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman, atom/location, obj/item/fish/fish_type)
	. = ..()
	if(isfish(rod.bait))
		.[MULTIPLICATIVE_FISHING_MOD] *= 2

/datum/fish_trait/predator/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(eat_fishes))

/datum/fish_trait/predator/proc/eat_fishes(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source.get_hunger() > 0.75 || !isaquarium(source.loc))
		return
	var/obj/structure/aquarium/aquarium = source.loc
	for(var/obj/item/fish/victim in aquarium.get_fishes(TRUE, source))
		if(victim.size < source.size * 0.7) // It's a big fish eat small fish world
			continue
		if(victim.status != FISH_ALIVE || victim == source || HAS_TRAIT(victim, TRAIT_YUCKY_FISH) || SPT_PROB(80, seconds_per_tick))
			continue
		eat_fish(source, victim)
		return

/datum/fish_trait/yucky
	name = "Yucky"
	catalog_description = "This fish tastes so repulsive, other fishes won't try to eat it."
	reagents_to_add = list(/datum/reagent/yuck = 1.2)

/datum/fish_trait/yucky/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_YUCKY_FISH, FISH_TRAIT_DATUM)

/datum/fish_trait/toxic
	name = "Toxic"
	catalog_description = "This fish contains toxins. Feeding it to predatory fishes or people is not recommended."
	diff_traits_inheritability = 25
	reagents_to_add = list(/datum/reagent/toxin/tetrodotoxin = 1)

/datum/fish_trait/toxic/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT, PROC_REF(make_venomous))
	RegisterSignal(fish, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_status_change))
	RegisterSignal(fish, COMSIG_FISH_EATEN_BY_OTHER_FISH, PROC_REF(on_eaten))

/datum/fish_trait/toxic/proc/make_venomous(obj/item/fish/source, new_size, new_weight)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_FISH_STINGER))
		return
	add_venom(source, /datum/reagent/toxin/tetrodotoxin, new_weight, mult = source.status == FISH_DEAD ? 0.1 : 0.25)

/datum/fish_trait/toxic/proc/on_status_change(obj/item/fish/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_FISH_STINGER))
		return
	change_venom_on_death(source, /datum/reagent/toxin/tetrodotoxin, 0.25, 0.1)

/datum/fish_trait/toxic/proc/on_eaten(obj/item/fish/source, obj/item/fish/predator)
	if(HAS_TRAIT(predator, TRAIT_FISH_TOXIN_IMMUNE))
		return
	RegisterSignal(predator, COMSIG_FISH_LIFE, PROC_REF(damage_predator), TRUE)
	RegisterSignal(predator, COMSIG_FISH_STATUS_CHANGED, PROC_REF(stop_damaging), TRUE)

/datum/fish_trait/toxic/proc/damage_predator(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	source.adjust_health(source.health - 3 * seconds_per_tick)

/datum/fish_trait/toxic/proc/stop_damaging(obj/item/fish/source)
	SIGNAL_HANDLER
	if(source.status == FISH_DEAD)
		UnregisterSignal(source, list(COMSIG_FISH_LIFE, COMSIG_FISH_STATUS_CHANGED))

/datum/fish_trait/toxic/apply_to_mob(mob/living/basic/mob)
	. = ..()
	mob.AddElement(/datum/element/venomous, /datum/reagent/toxin/tetrodotoxin, 0.5 * mob.mob_size)

/datum/fish_trait/toxin_immunity
	name = "Toxin Immunity"
	catalog_description = "This fish has developed an ample-spected immunity to toxins."
	diff_traits_inheritability = 40

/datum/fish_trait/toxin_immunity/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_TOXIN_IMMUNE, FISH_TRAIT_DATUM)

/datum/fish_trait/crossbreeder
	name = "Crossbreeder"
	catalog_description = "This fish's adaptive genetics allows it to crossbreed with other fish species."
	inheritability = 80
	diff_traits_inheritability = 20
	incompatible_traits = list(/datum/fish_trait/no_mating)

/datum/fish_trait/crossbreeder/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_CROSSBREEDER, FISH_TRAIT_DATUM)

/datum/fish_trait/aggressive
	name = "Aggressive"
	inheritability = 80
	diff_traits_inheritability = 40
	catalog_description = "This fish is aggressively territorial, and may attack fish that come close to it."

/datum/fish_trait/aggressive/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(try_attack_fish))

/datum/fish_trait/aggressive/proc/try_attack_fish(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!isaquarium(source.loc) || !SPT_PROB(1, seconds_per_tick))
		return
	var/obj/structure/aquarium/aquarium = source.loc
	for(var/obj/item/fish/victim in aquarium.get_fishes(TRUE, source))
		if(victim.status != FISH_ALIVE)
			continue
		aquarium.visible_message(span_warning("[source] violently [pick("whips", "bites", "attacks", "slams")] [victim]"))
		var/damage = round(rand(4, 20) * (source.size / victim.size)) //smaller fishes take extra damage.
		victim.adjust_health(victim.health - damage)
		return

/datum/fish_trait/lubed
	name = "Lubed"
	inheritability = 90
	diff_traits_inheritability = 45
	spontaneous_manifest_types = list(/obj/item/fish/clownfish/lube = 100)
	catalog_description = "This fish exudes a viscous, slippery lubrificant. It's recommended not to step on it."
	added_difficulty = 5
	reagents_to_add = list(/datum/reagent/lube = 1.2)

/datum/fish_trait/lubed/apply_to_fish(obj/item/fish/fish)
	. = ..()
	fish.AddComponent(/datum/component/slippery, 8 SECONDS, SLIDE|GALOSHES_DONT_HELP)

/datum/fish_trait/lubed/apply_to_mob(mob/living/basic/mob)
	. = ..()
	mob.AddElement(/datum/element/lube_walking)

/datum/fish_trait/lubed/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.reeling_velocity *= 1.4
	minigame.gravity_velocity *= 1.4

/datum/fish_trait/amphibious
	name = "Amphibious"
	inheritability = 80
	diff_traits_inheritability = 40
	catalog_description = "This fish has developed a primitive adaptation to life on both land and water."

/datum/fish_trait/amphibious/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_AMPHIBIOUS, FISH_TRAIT_DATUM)
	if(fish.required_fluid_type == AQUARIUM_FLUID_AIR)
		fish.required_fluid_type = AQUARIUM_FLUID_FRESHWATER

/datum/fish_trait/mixotroph
	name = "Mixotroph"
	inheritability = 75
	diff_traits_inheritability = 25
	catalog_description = "This fish is capable of substaining itself by producing its own sources of energy (food)."
	incompatible_traits = list(/datum/fish_trait/predator, /datum/fish_trait/necrophage)

/datum/fish_trait/mixotroph/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_NO_HUNGER, FISH_TRAIT_DATUM)

/datum/fish_trait/antigrav
	name = "Anti-Gravity"
	inheritability = 75
	diff_traits_inheritability = 25
	catalog_description = "This fish will invert the gravity of the bait at random. May fall upward outside after being caught."
	added_difficulty = 20

/datum/fish_trait/antigrav/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.special_effects |= FISHING_MINIGAME_RULE_ANTIGRAV

/datum/fish_trait/antigrav/apply_to_fish(obj/item/fish/fish)
	. = ..()
	fish.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)

/datum/fish_trait/antigrav/apply_to_mob(mob/living/basic/mob)
	. = ..()
	mob.add_traits(list(TRAIT_FREE_HYPERSPACE_MOVEMENT, TRAIT_SPACEWALK), FISH_TRAIT_DATUM)
	mob.AddElement(/datum/element/simple_flying)

///Anxiety means the fish will die if in a location with more than 3 fish (including itself)
///This is just barely enough to crossbreed out of anxiety, but it severely limits the potential of
/datum/fish_trait/anxiety
	name = "Anxiety"
	inheritability = 100
	diff_traits_inheritability = 70
	catalog_description = "This fish tends to die of stress when forced to be around too many other fish."

/datum/fish_trait/anxiety/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(on_fish_life))

///signal sent when the anxiety fish is fed, killing it if sharing contents with too many fish.
/datum/fish_trait/anxiety/proc/on_fish_life(obj/item/fish/fish, seconds_per_tick)
	SIGNAL_HANDLER
	var/fish_tolerance = 3
	if(!fish.loc || fish.status == FISH_DEAD)
		return
	for(var/obj/item/fish/other_fish in fish.loc.contents)
		if(fish_tolerance <= 0)
			fish.loc.visible_message(span_warning("[fish] seems to freak out for a moment, then it stops moving..."))
			fish.set_status(FISH_DEAD)
			return
		fish_tolerance -= 1

/datum/fish_trait/electrogenesis
	name = "Electrogenesis"
	inheritability = 60
	diff_traits_inheritability = 30
	catalog_description = "This fish is electroreceptive, and will generate electric fields. Can be harnessed inside a bioelectric generator."
	reagents_to_add = list(/datum/reagent/consumable/liquidelectricity = 1.5)

/datum/fish_trait/electrogenesis/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_ELECTROGENESIS, FISH_TRAIT_DATUM)
	RegisterSignal(fish, COMSIG_FISH_FORCE_UPDATED, PROC_REF(on_force_updated))
	RegisterSignals(fish, list(COMSIG_ITEM_FRIED, TRAIT_FOOD_BBQ_GRILLED), PROC_REF(on_fish_cooked))

/datum/fish_trait/electrogenesis/proc/on_fish_cooked(obj/item/fish/fish, cooked_time)
	SIGNAL_HANDLER
	if(cooked_time >= FISH_SAFE_COOKING_DURATION)
		fish.reagents.del_reagent(/datum/reagent/consumable/liquidelectricity)
	else
		fish.reagents.multiply_single_reagent(/datum/reagent/consumable/liquidelectricity, 0.66)

/datum/fish_trait/electrogenesis/add_reagents(obj/item/fish/fish, list/reagents)
	. = ..()
	if(HAS_TRAIT(fish, TRAIT_FISH_WELL_COOKED)) // Cooking it well removes all liquid electricity
		reagents -= /datum/reagent/consumable/liquidelectricity
	else
		reagents -= /datum/reagent/blood
		//Otherwise, undercooking it will remove 2/3 of it.
		if(!HAS_TRAIT(fish, TRAIT_FOOD_FRIED) && !HAS_TRAIT(fish, TRAIT_FOOD_BBQ_GRILLED))
			reagents[/datum/reagent/consumable/liquidelectricity] -= 1

/datum/fish_trait/electrogenesis/proc/on_force_updated(obj/item/fish/fish, weight_rank, bonus_or_malus)
	SIGNAL_HANDLER
	if(fish.status == FISH_ALIVE)
		fish.force += 10 - fish.w_class
		fish.damtype = BURN
		fish.attack_verb_continuous = list("shocks", "zaps")
		fish.attack_verb_simple = list("shock", "zap")
		fish.hitsound = 'sound/effects/sparks4.ogg'

/datum/fish_trait/electrogenesis/apply_to_mob(mob/living/basic/mob)
	. = ..()
	ADD_TRAIT(mob, TRAIT_SHOCKIMMUNE, FISH_TRAIT_DATUM)
	mob.grant_actions_by_list(list(/datum/action/cooldown/mob_cooldown/charge_apc))
	mob.AddElement(/datum/element/venomous, /datum/reagent/teslium, 3 * mob.mob_size)

/datum/fish_trait/stunted
	name = "Stunted Growth"
	catalog_description = "This chrab's development is stunted, and will not properly reach adulthood."
	spontaneous_manifest_types = list(/obj/item/fish/chasm_crab = 12, /obj/item/fish/chasm_crab/ice = 12)
	fish_whitelist = list(/obj/item/fish/chasm_crab, /obj/item/fish/chasm_crab/ice)
	diff_traits_inheritability = 40

/datum/fish_trait/stunted/apply_to_mob(mob/living/basic/mob)
	. = ..()
	qdel(mob.GetComponent(/datum/component/growth_and_differentiation))

/datum/fish_trait/stinger
	name = "Stinger"
	inheritability = 80
	diff_traits_inheritability = 35
	catalog_description = "This fish is equipped with a sharp stringer or bill capable of delivering damage and toxins."
	spontaneous_manifest_types = list(
		/obj/item/fish/stingray = 100,
		/obj/item/fish/swordfish = 100,
		/obj/item/fish/chainsawfish = 100,
		/obj/item/fish/pike/armored = 100,
	)

/datum/fish_trait/stinger/apply_to_fish(obj/item/fish/fish)
	. = ..()
	ADD_TRAIT(fish, TRAIT_FISH_STINGER, FISH_TRAIT_DATUM)
	RegisterSignal(fish, COMSIG_FISH_FORCE_UPDATED, PROC_REF(on_force_updated))

/datum/fish_trait/stinger/proc/on_force_updated(obj/item/fish/fish, weight_rank, bonus_or_malus)
	SIGNAL_HANDLER
	fish.force += 1 + fish.w_class + bonus_or_malus

/datum/fish_trait/toxic_barbs
	name = "Toxic Barbs"
	catalog_description = "This fish' stinger, bill or otherwise, is coated with simple, yet effetive venom."
	spontaneous_manifest_types = list(/obj/item/fish/stingray = 35)

/datum/fish_trait/toxic_barbs/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT, PROC_REF(make_venomous))
	RegisterSignal(fish, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_status_change))

/datum/fish_trait/toxic_barbs/proc/make_venomous(obj/item/fish/source, new_size, new_weight)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_FISH_STINGER))
		///Remove the trait from the fish so it doesn't show on the analyzer as it doesn't do anything on stingerless ones.
		source.fish_traits -= type
		UnregisterSignal(source, list(COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT, COMSIG_FISH_STATUS_CHANGED))
		return
	add_venom(source, /datum/reagent/toxin/venom, new_weight, mult = source.status == FISH_DEAD ? 0.3 : 0.7)

/datum/fish_trait/toxic_barbs/proc/on_status_change(obj/item/fish/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_FISH_STINGER))
		return
	change_venom_on_death(source, /datum/reagent/toxin/venom, 0.7, 0.3)

/datum/fish_trait/hallucinogenic
	name = "Hallucinogenic"
	catalog_description = "This fish is coated with hallucinogenic neurotoxin. We advise cooking it before consumption."
	reagents_to_add = list(/datum/reagent/toxin/mindbreaker/fish = 1)

/datum/fish_trait/hallucinogenic/add_reagents(obj/item/fish/fish, list/reagents)
	if(!HAS_TRAIT(src, TRAIT_FOOD_FRIED) && !HAS_TRAIT(src, TRAIT_FOOD_BBQ_GRILLED))
		return ..()

/datum/fish_trait/ink
	name = "Ink Production"
	catalog_description = "This fish possess a sac that produces ink."
	diff_traits_inheritability = 70
	spontaneous_manifest_types = list(/obj/item/fish/squid = 35)

/datum/fish_trait/ink/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_ATOM_PROCESSED, PROC_REF(on_process))
	RegisterSignal(fish, COMSIG_ITEM_ATTACK_ZONE, PROC_REF(attacked_someone))

/datum/fish_trait/ink/proc/attacked_someone(obj/item/fish/source, mob/living/target, mob/living/user, zone)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_FISH_INK_ON_COOLDOWN) || source.status == FISH_DEAD)
		return
	if(!iscarbon(target) || target.get_bodypart(BODY_ZONE_HEAD))
		target.adjust_temp_blindness_up_to(4 SECONDS, 8 SECONDS)
		target.adjust_confusion_up_to(1.5 SECONDS, 4 SECONDS)
		target.AddComponent(/datum/component/face_decal/splat, \
			color = COLOR_NEARLY_ALL_BLACK, \
			memory_type = /datum/memory/witnessed_inking, \
			mood_event_type = /datum/mood_event/inked, \
		)
	target.visible_message(span_warning("[target] is inked by [source]!"), span_userdanger("You've been inked by [source]!"))
	playsound(target, SFX_DESECRATION, 50, TRUE)
	ADD_TRAIT(source, TRAIT_FISH_INK_ON_COOLDOWN, FISH_TRAIT_DATUM)
	addtimer(TRAIT_CALLBACK_REMOVE(source, TRAIT_FISH_INK_ON_COOLDOWN, FISH_TRAIT_DATUM), 9 SECONDS)

/datum/fish_trait/ink/proc/on_process(obj/item/fish/source, mob/living/user, obj/item/process_item, list/results)
	SIGNAL_HANDLER
	new /obj/item/food/ink_sac(source.drop_location())

/datum/fish_trait/camouflage
	name = "Camouflage"
	catalog_description = "This fish possess the ability to blend with its surroundings."
	spontaneous_manifest_types = list(/obj/item/fish/squid = 35)
	added_difficulty = 5

/datum/fish_trait/camouflage/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.special_effects |= FISHING_MINIGAME_RULE_CAMO

/datum/fish_trait/camouflage/apply_to_fish(obj/item/fish/fish)
	. = ..()
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(fade_out))
	RegisterSignals(fish, list(COMSIG_MOVABLE_MOVED, COMSIG_FISH_STATUS_CHANGED), PROC_REF(reset_alpha))

/datum/fish_trait/camouflage/proc/fade_out(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source.status == FISH_DEAD || source.last_move + 5 SECONDS >= world.time)
		return
	source.alpha = max(source.alpha - 10 * seconds_per_tick, 10)

/datum/fish_trait/camouflage/proc/reset_alpha(obj/item/fish/source)
	SIGNAL_HANDLER
	var/init_alpha = initial(source.alpha)
	if(init_alpha != source.alpha)
		animate(source.alpha, alpha = init_alpha, time = 1.2 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
