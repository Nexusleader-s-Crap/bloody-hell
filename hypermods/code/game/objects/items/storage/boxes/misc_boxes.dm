/obj/item/storage/box/lights/mixed/radiation/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/light/tube/radiation(src)
	for(var/i in 1 to 6)
		new /obj/item/light/bulb/radiation(src)
