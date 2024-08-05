// ~~ China-Lake Bundle ~~ (The one and ONLY.) Also has a 35 TC price tag for how destructive it is.

/datum/uplink_item/weapon_kits/extreme_cost
	cost = 35
	surplus = 10
	purchasable_from = UPLINK_SERIOUS_OPS

/datum/uplink_item/weapon_kits/extreme_cost/chinalake
	name = "China Lake Case (???)"
	desc = "A classic grenade launcher favored for it's incredible destructive capabilities and decisive battles. \
			The launcher comes fully loaded with blast grenades with several blast grenades to spare, and two FRAG grenades for extra-powerful shots."
	item = /obj/item/storage/toolbox/guncase/chinalake

/datum/uplink_item/ammo_nuclear/basic/blastnade
	name = "Blast Grenade Casing"
	desc = "A 40mm Grenade Round specifically designed to be fired from a China-Lake Grenade Launcher."
	item = /obj/item/ammo_casing/caseless/chinalake/blast
	cost = 3

/datum/uplink_item/ammo_nuclear/basic/fragnade
	name = "Frag Grenade Casing"
	desc = "A 40mm Grenade Round specifically designed to be fired from a China-Lake Grenade Launcher. \
			Highly explosive, stay clear when firing."
	item = /obj/item/ammo_casing/caseless/chinalake/frag
	cost = 5

// ~~ Tommy-Gun Bundle ~~

/datum/uplink_item/weapon_kits/high_cost/tommygun
	name = "Tommy Gun Case (Moderate)"
	desc = "A fully-loaded classical Thompson SMG with a 50-round .45 drum magazine. \
			This deadly weapon fires exceptionally quickly with deadly accuracy. Comes with two extra magazines."
	item = /obj/item/storage/toolbox/guncase/tommygun
	cost = 20

// ~~ Dual-Pistol Bundle ~~

/datum/uplink_item/weapon_kits/low_cost/pistols
	name = "Dual-Pistol Case (Hard)"
	desc = "A case containing a Viper and a Cobra. Also contained within are 2 10mm magazines and 2 .45 caseless magazines. \
			For all you pistol lovers out there."
	item = /obj/item/storage/toolbox/guncase/pistols
	cost = 11 // Bit of even pricing between low and med cost

// ~~ Elemental-Pistol Bundle ~~

/datum/uplink_item/weapon_kits/medium_cost/elementals
	name = "Elemental Pistol Case (Hard)"
	desc = "A case containing two specialized energy handcannons of both hot and cold variety. \
			Both handcannons recharge automatically and produce additional... results when used against hot or cold targets. \
			Also contained within are 2 stimpacks, and an armored jumpsuit to sweeten the deal."
	item = /obj/item/storage/toolbox/guncase/elementalguns

// Explosives and Grenades
// ~~ Grenades ~~



// Stealthy Tools



// Modsuits



// Devices

/datum/uplink_item/device_tools/syndie_rcd
	name = "Syndicate Rapid-Construction-Device"
	desc = "Based on a Nanotrasen model, this powerful tool can repair or destroy structures very quickly. Holds 1000 matter. Can be recharged much like a regular RCD."
	item = /obj/item/construction/rcd/syndicate
	cost = 15
	purchasable_from = UPLINK_ALL_SYNDIE_OPS | UPLINK_SPY

/datum/uplink_item/device_tools/syndie_arcd
	name = "Syndicate Advanced Rapid-Construction-Device"
	desc = "Based on a prototype Nanotrasen model, this powerful tool can repair or destroy structures very quickly from a distance! Holds 1000 matter. Can be recharged much like a regular RCD."
	item = /obj/item/construction/rcd/syndicate/ranged
	cost = 30
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/device_tools/syndie_forcefields
	name = "Syndicate Forcefield Generator"
	desc = "Manufactured by Cybersun Industries, this powerful tool projects impassable walls of pure energy for a lengthy time. Forcefields can only sustain so much damage before dispersing. \
			Can project up to 6 forcefields at any time and will only be sustained should the projector be nearby. Perfect for holding off the hordes."
	item = /obj/item/forcefield_projector/syndicate
	cost = 12
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

// Ammo

/datum/uplink_item/ammo/syndie_rcd_ammo
	name = "Syndicate Rapid-Construction-Device Ammo"
	desc = "A highly compressed package of solid matter for recharging a Rapid-Construction-Device. Holds 1000 matter in total."
	item = /obj/item/rcd_ammo/syndicate
	cost = 5
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

// Medical

/datum/uplink_item/medical/syndie_medibeam
	name = "Medical Beam Gun"
	desc = "A wonder of Syndicate engineering, the Medbeam gun, or Medi-Gun enables a medic to keep his fellow \
			operatives in the fight, even while under fire. Don't cross the streams!"
	item = /obj/item/gun/medbeam
	cost = 12
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/medical/medicalreagentgun
	name = "Medical Reagent Gun"
	desc = "A wonder of Syndicate engineering, this reagent gun does little damage on impact, but it will inject a compound of various healing chemicals. \
			It's filled with a 400u concoction specifically designed to get your fellow operatives back on their feet in a pinch. \
			The gun shoots 40u each shot, and will inevitably run out of chemicals. You may refill it with whatever you desire. Synthesises syringes automatically."
	item = /obj/item/gun/medicalreagentgun
	cost = 15
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

/datum/uplink_item/medical/hypospray_kit
	name = "Syndicate Combat Hypospray Kit"
	desc = "An medical kit containing a wide variety of bottles containing \"perfectly legal chemicals\" to treat combatants. \
			Pair with one of our Gorlex Hypospray's for optimal application."
	item = /obj/item/storage/medkit/hypospray
	cost = 5
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

// Implants

/datum/uplink_item/implants/nuclear/reviver
	name = "Superior Reviver Implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness, these superior versions have a drastically lowered cooldown than most. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/reviver/better/hidden/single_use
	cost = 8

/datum/uplink_item/implants/nuclear/regenerativeops
	name = "Regenerative Implants"
	desc = "Three surgical implants that when inserted into the body will very slowly repair the host. Allowing for VERY slow recovery of all forms of damage."
	item = /obj/item/storage/box/syndie_kit/regen_implant_box
	cost = 10

/datum/uplink_item/implants/nuclear/medibeam
	name = "Integrated Medical Beam Gun Implant"
	desc = "A complete, miniaturized medical healing beam gun straight from our factories, it'll fit perfectly within one of your arms to support your fellow operatives in the midst of battle. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/medibeam/hidden/single_use
	cost = 15

// Conspicous weapons

/datum/uplink_item/dangerous/advchemsprayer
	name = "Bluespace Chemical Sprayer"
	desc = "One of our chemical sprayers that have been upgraded with our bluespace technology, unlike the regular version, this one can contain 1500 units of chemicals and shoot 50u's of it's contents forward for up to 5 meters ahead. \
			The sprayer comes loaded with 250's of: Sodium Thiopental, Coniine, Venom, Condensed Capsaicin, Initropidril, and Polonium."
	item = /obj/item/reagent_containers/spray/chemsprayer/adv
	surplus = 0
	cost = 25
	cant_discount = TRUE
	purchasable_from = UPLINK_ALL_SYNDIE_OPS

// Badass (meme items)



// Base Keys



// Hats
// It is fundamental for the game's health for there to be a hat crate for nuclear operatives.


