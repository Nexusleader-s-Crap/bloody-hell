/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	panel_type = "panel11"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	products = list(
		/obj/item/stack/medical/gauze = 8,
		/obj/item/reagent_containers/syringe = 12,
		/obj/item/reagent_containers/dropper = 3,
		/obj/item/healthanalyzer = 4,
		/obj/item/wrench/medical = 1,
		/obj/item/stack/sticky_tape/surgical = 3,
		/obj/item/healthanalyzer/simple = 4,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/bone_gel = 4,
		/obj/item/cane/crutch = 2,
		/obj/item/cane/white = 2,
		/obj/item/clothing/glasses/eyepatch/medical = 2,
		/obj/item/storage/box/bandages = 2,
		/obj/item/reagent_containers/hypospray/medipen/blood_loss = 5,
		/obj/item/storage/pill_bottle/inaprovaline = 3,
	)
	contraband = list(
		/obj/item/storage/box/gum/happiness = 3,
		/obj/item/storage/box/hug/medical = 1,
		/obj/item/storage/pill_bottle/tricordrazine = 3,
		/obj/item/reagent_containers/hypospray/medipen/formaldehyde = 5,
		/obj/item/reagent_containers/cup/bottle/toxin = 3,
		/obj/item/storage/medkit/expanded/brute = 1,
		/obj/item/storage/medkit/expanded/fire = 1,
		/obj/item/storage/medkit/expanded/toxin = 1,
		/obj/item/storage/medkit/expanded/o2 = 1,
		/obj/item/storage/medkit/expanded/advanced = 1,
	)
	premium = list(
		/obj/item/reagent_containers/hypospray/medipen = 3,
		/obj/item/storage/belt/medical = 3,
		/obj/item/sensor_device = 2,
		/obj/item/pinpointer/crew = 2,
		/obj/item/shears = 1,
		/obj/item/storage/organbox = 1,
		/obj/item/storage/medkit = 2,
		/obj/item/storage/medkit/brute = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/storage/medkit/toxin = 1,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/reagent_containers/medigel/synthflesh = 1,
		/obj/item/reagent_containers/hypospray/medipen/ekit = 3,
		/obj/item/reagent_containers/cup/beaker/cryoxadone = 2,
	)
	refill_canister = /obj/item/vending_refill/medical
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_MED
	light_mask = "med-light-mask"

	emagvendorreplace = TRUE
	replacewith = /obj/machinery/vending/emagged/medical


/obj/item/vending_refill/medical
	machine_name = "NanoMed Plus"
	icon_state = "refill_medical"

/obj/machinery/vending/medical/syndicate
	name = "\improper SyndiMed Plus"
	initial_language_holder = /datum/language_holder/syndicate

	emagvendorreplace = FALSE

/obj/machinery/vending/medical/infested_frigate
	products = list(
		/obj/item/stack/medical/gauze = 0,
		/obj/item/reagent_containers/syringe = 7,
		/obj/item/reagent_containers/dropper = 3,
		/obj/item/healthanalyzer = 0,
		/obj/item/wrench/medical = 0,
		/obj/item/stack/sticky_tape/surgical = 0,
		/obj/item/healthanalyzer/simple = 0,
		/obj/item/stack/medical/ointment = 0,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/cane/crutch = 2,
		/obj/item/cane/white = 2,
		/obj/item/clothing/glasses/eyepatch/medical = 2,
	)

	emagvendorreplace = FALSE
//Created out of a necessity to get these dumb chems out of the medical tools vendor.
/obj/machinery/vending/drugs
	name = "\improper NanoDrug Plus"
	desc = "Medical drugs dispenser."
	icon_state = "drug"
	icon_deny = "drug-deny"
	panel_type = "panel11"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	products = list(
		/obj/item/reagent_containers/pill/patch/libital = 5,
		/obj/item/reagent_containers/pill/patch/aiuri = 5,
		/obj/item/reagent_containers/syringe/convermol = 2,
		/obj/item/reagent_containers/pill/insulin = 5,
		/obj/item/reagent_containers/cup/bottle/multiver = 2,
		/obj/item/reagent_containers/cup/bottle/syriniver = 2,
		/obj/item/reagent_containers/cup/bottle/calomel = 2,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 3,
		/obj/item/reagent_containers/cup/bottle/morphine = 4,
		/obj/item/reagent_containers/cup/bottle/potass_iodide = 1,
		/obj/item/reagent_containers/cup/bottle/salglu_solution = 3,
		/obj/item/reagent_containers/cup/bottle/toxin = 3,
		/obj/item/reagent_containers/cup/bottle/oculine = 3,
		/obj/item/reagent_containers/cup/bottle/inacusiate = 3,
		/obj/item/storage/pill_bottle/mannitol = 5,
		/obj/item/reagent_containers/syringe/antiviral = 6,
		/obj/item/reagent_containers/medigel/libital = 2,
		/obj/item/reagent_containers/medigel/aiuri = 2,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
	)
	contraband = list(
		/obj/item/reagent_containers/pill/tox = 3,
		/obj/item/reagent_containers/pill/morphine = 4,
		/obj/item/reagent_containers/pill/multiver = 6,
		/obj/item/reagent_containers/pill/patch/mender/brute = 1,
		/obj/item/reagent_containers/pill/patch/mender/burn = 1,
	)
	premium = list(
		/obj/item/reagent_containers/medigel/synthflesh = 2,
		/obj/item/storage/pill_bottle/psicodine = 2,
		/obj/item/storage/pill_bottle/sansufentanyl = 1,
		/obj/item/reagent_containers/hypospray/medipen/arithrazine = 4,
		/obj/item/reagent_containers/hypospray/medipen/hyronalin = 4,
		/obj/item/reagent_containers/hypospray/medipen/bicaridine = 2,
		/obj/item/reagent_containers/hypospray/medipen/dermaline = 2,
		/obj/item/reagent_containers/hypospray/medipen/salacid = 1,
		/obj/item/reagent_containers/hypospray/medipen/oxandrolone = 1,
		/obj/item/reagent_containers/hypospray/medipen/penacid = 2,
		/obj/item/reagent_containers/hypospray/medipen/salbutamol = 1,
		/obj/item/reagent_containers/hypospray/medipen/blood_loss = 1,
	)
	default_price = 50
	extra_price = 100
	payment_department = ACCOUNT_MED
	refill_canister = /obj/item/vending_refill/drugs

	emagvendorreplace = TRUE
	replacewith = /obj/machinery/vending/emagged/drugs

/obj/item/vending_refill/drugs
	machine_name = "NanoDrug Plus"
	icon_state = "refill_medical"
