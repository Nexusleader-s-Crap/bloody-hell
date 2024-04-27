/// A briefcase for holding EVERYTHING.

/obj/item/storage/briefcase/secure/bluespace
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon_state = "secure"
	base_icon_state = "secure"
	inhand_icon_state = "sec-case"

/obj/item/storage/briefcase/secure/bluespace/Initialize(mapload)
	. = ..()
	atom_storage.max_total_storage = 80
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	AddComponent(/datum/component/lockable_storage)

/// A briefcase that contains various sought-after spoils
/obj/item/storage/briefcase/secure/riches

/obj/item/storage/briefcase/secure/riches/PopulateContents()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/suppressor(src)
	new /obj/item/melee/baton/telescopic(src)
	new /obj/item/clothing/mask/balaclava(src)
	new /obj/item/bodybag(src)
	new /obj/item/soap/nanotrasen(src)

/// A special counterfeiting briefcase.

/obj/item/storage/briefcase/secure/cargonia
	name = "secure briefcase"
	desc = "A large briefcase with a digital locking system."
	icon_state = "secure"
	base_icon_state = "secure"
	inhand_icon_state = "sec-case"
	force = 25

/obj/item/storage/briefcase/secure/cargonia/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 60
	regenerate_cash()

/obj/item/storage/briefcase/secure/cargonia/proc/regenerate_cash()
	addtimer(CALLBACK(src, PROC_REF(regenerate_cash)), 30 SECONDS)

	var/mob/user = get(loc, /mob)
	if(!istype(user))
		return
	if(IS_TRAITOR(user))
		var/turf/floor = get_turf(src)
		var/obj/item/I = new /obj/item/stack/spacecash/c1000(floor)
		if(!atom_storage.attempt_insert(I, user, override = TRUE, force = STORAGE_SOFT_LOCKED))
			qdel(I)
