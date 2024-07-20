/*Narcolepsy
 * Slight reduction to stealth
 * Reduces resistance
 * Greatly reduces stage speed
 * No change to transmissibility
 * Fatal level
 * Bonus: Causes drowsiness and sleep.
*/
/datum/symptom/narcolepsy
	name = "Narcolepsy"
	desc = "The virus causes a hormone imbalance, making the host sleepy and narcoleptic."
	illness = "Aurora Snorealis"
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = 0
	level = 7
	symptom_delay_min = 30
	symptom_delay_max = 85
	severity = 4
	var/yawning = FALSE
	threshold_descs = list(
		"Transmission 4" = "Causes the host to periodically emit a yawn that tries to infect bystanders within 6 meters of the host.",
		"Stage Speed 10" = "Causes narcolepsy more often, increasing the chance of the host falling asleep.",
	)

/datum/symptom/narcolepsy/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalTransmittable() >= 4) //yawning (mostly just some copy+pasted code from sneezing, with a few tweaks)
		yawning = TRUE
	if(A.totalStageSpeed() >= 10) //act more often
		symptom_delay_min = 20
		symptom_delay_max = 45

/datum/symptom/narcolepsy/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return

	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(50))
				to_chat(M, span_warning("You feel tired."))
		if(2)
			if(prob(50))
				to_chat(M, span_warning("You feel very tired."))
		if(3)
			if(prob(50))
				to_chat(M, span_warning("You try to focus on staying awake."))

			M.adjust_drowsiness_up_to(10 SECONDS, 140 SECONDS)

		if(4)
			if(prob(50))
				if(yawning)
					to_chat(M, span_warning("You try and fail to suppress a yawn."))
				else
					to_chat(M, span_warning("You nod off for a moment.")) //you can't really yawn while nodding off, can you?

			M.adjust_drowsiness_up_to(20 SECONDS, 140 SECONDS)

			if(yawning)
				M.emote("yawn")
				A.airborne_spread(6)

		if(5)
			if(prob(50))
				to_chat(M, span_warning("[pick("So tired...","You feel very sleepy.","You have a hard time keeping your eyes open.","You try to stay awake.")]"))

			M.adjust_drowsiness_up_to(80 SECONDS, 140 SECONDS)

			if(yawning)
				M.emote("yawn")
				A.airborne_spread(6)



/datum/symptom/insomnia
	name = "Insomnia"
	desc = "The virus alters brain patterns within the host, suppressing the brain's natural sleep functionality."
	stealth = -1
	resistance = 0
	stage_speed = 0
	transmittable = 2
	level = 12
	symptom_delay_min = 30
	symptom_delay_max = 85
	threshold_descs = list(
		"Resistance 8" = "The stamina drain no longer occurs.",
	)
	var/stamdrain = TRUE

/datum/symptom/insomnia/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 8)
		stamdrain = FALSE

/datum/symptom/insomnia/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage >= 4)
		ADD_TRAIT(M, TRAIT_SLEEPIMMUNE, DISEASE_TRAIT)
	else
		REMOVE_TRAIT(M, TRAIT_SLEEPIMMUNE, DISEASE_TRAIT)
	return TRUE

/datum/symptom/insomnia/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return

	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(50))
				to_chat(M, span_notice("You suddenly find it difficult to blink."))

		if(5)
			if(stamdrain && (M.getStaminaLoss() < 20))
				M.adjustStaminaLoss(2.5)
