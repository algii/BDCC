extends SexActivityBase

var usedItemID:String = ""
var usedUniqueItemID:String = ""
var timePassed:int = 0
var pillVariants:Array = []

const DIRECTED_TF = preload("res://Game/Transformation/DirectedTFUtil.gd")
var directed_page:String = "main"
var directed_breasts:int = -999
var directed_penis:String = ""
var directed_length:float = 0.0
var directed_thickness:int = -1
var directed_femininity:int = -1
var directed_vagina:String = ""
var directed_color:String = ""

func _init():
	id = "DomDrugUse"
	startedByDom = true
	startedBySub = false
	
	activityName = "Drug use"
	activityDesc = "Use drugs"
	activityCategory = ["Drugs/Lube"]

func getGoals():
	return {
		SexGoal.UseTFDrug: 1.0,
	}

func getSupportedSexTypes():
	return {
		SexType.DefaultSex: true,
		SexType.StocksSex: true,
		SexType.SlutwallSex: true,
		SexType.BitchsuitSex: true,
	}

func getActivityBaseScore(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var mult = 1.0
	if(_domInfo.getChar().getCharacterType() == CharacterType.Nurse):
		mult = 2.0
	return 0.0 + _domInfo.fetishScore({Fetish.DrugUse: 0.5}) * mult

func getTags(_indx:int):
	return [SexActivityTag.OrderedToDoSomething]

func getPossibleDrugsInfo(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var thedrugs:Array = []
	if(_domInfo.getChar().isPlayer()):
		for item in GM.pc.getInventory().getItemsWithTag(ItemTag.SexEngineDrug):
			if(_sexEngine.disableTFPills && ItemTag.TFItem in item.getTags()):
				continue
			if(item.has_method("getSexEngineInfo")):
				thedrugs.append({
					id = item.id,
					item = item,
					info = item.getSexEngineInfo(_sexEngine, _domInfo, _subInfo),
				})
		return thedrugs
	
	for itemID in GlobalRegistry.getItemIDsByTag(ItemTag.SexEngineDrug):
		var item = GlobalRegistry.getItemRef(itemID)
		if(_sexEngine.disableTFPills && ItemTag.TFItem in item.getTags()):
			continue
		if(item.has_method("getSexEngineInfo")):
			thedrugs.append({
				id = itemID,
				info = item.getSexEngineInfo(_sexEngine, _domInfo, _subInfo),
			})
	
	return thedrugs
	
func getPossibleCanApplyInfo(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var thedrugs:Array = []
	for itemID in GlobalRegistry.getItemIDsByTag(ItemTag.SexEngineCanApply):
		var item = GlobalRegistry.getItemRef(itemID)
		if(_sexEngine.disableTFPills && ItemTag.TFItem in item.getTags()):
			continue
		if(item.has_method("getSexEngineInfo")):
			thedrugs.append({
				id = itemID,
				info = item.getSexEngineInfo(_sexEngine, _domInfo, _subInfo),
			})
	
	return thedrugs
	
func getDrugInfo(itemID, uniqueItemID):
	var item
	if(uniqueItemID != ""):
		item = getDom().getInventory().getItemByUniqueID(uniqueItemID)
	else:
		item = GlobalRegistry.getItemRef(itemID)
		if(item == null):
			return null
	
	return item.getSexEngineInfo(getSexEngine(), getDomInfo(), getSubInfo())

func getStartActions(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var possibleDrugsInfo = getPossibleDrugsInfo(_sexEngine, _domInfo, _subInfo)
	addDrugButtons(possibleDrugsInfo, _sexEngine, _domInfo, _subInfo, false)
	
	var possibleCanApplyInfo = getPossibleCanApplyInfo(_sexEngine, _domInfo, _subInfo)
	addDrugButtons(possibleCanApplyInfo, _sexEngine, _domInfo, _subInfo, true)

	# Keep ALL vanilla drug actions intact. Add one separate, opt-in action.
	if(_domInfo.getChar().isPlayer() && !_subInfo.getChar().isPlayer() && !_sexEngine.disableTFPills):
		for pill in GM.pc.getInventory().getItemsWithTag(ItemTag.SexEngineDrug):
			if(pill.id == "TFPill"):
				addStartAction(["customtf", "TFPill", false, pill], "Custom TF pill", "Give this NPC a TF pill and choose specific body changes (permanent)", 1.0, {A_CATEGORY: getCategory()+["Directed TF"]})

func addDrugButtons(possibleDrugsInfo:Array, _sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo, _isCanApply:bool = false):
	var dom:BaseCharacter = _domInfo.getChar()
	var sub:BaseCharacter = _subInfo.getChar()
	
	for itemEntry in possibleDrugsInfo:
		var itemID = itemEntry["id"]
		var drugInfo = itemEntry["info"]
		var item = itemEntry["item"] if itemEntry.has("item") else null # Only if pc
		
		if(!dom.isPlayer()):
			if(drugInfo.has("maxUsesByNPC")):
				var maxUses = drugInfo["maxUsesByNPC"]
				var currentUses = _domInfo.getMemory("USEDDRUG_"+str(itemID), 0)
				if(currentUses >= maxUses):
					continue

		var desc = drugInfo["desc"]
		if(dom.isPlayer() && item != null && item.canCombine()):
			desc = "Amount left: "+ str(dom.getInventory().getAmountOf(itemID))+"\n"+desc
		
		var drugFetishScore:float = 1.0
		
		if(!_isCanApply):
			if(drugInfo.has("sexgoal")):
				drugFetishScore = _domInfo.goalsScore({drugInfo["sexgoal"]: 1.0}, _subInfo.charID)
			else:
				drugFetishScore = clamp(_domInfo.fetishScore({Fetish.DrugUse: 1.0}) + 0.5, 0.0, 1.0) / 10.0

		var drugSubcategory:Array = item.getSexEngineSubcategory() if(item != null) else []
		if((_isCanApply || !dom.isOralBlocked()) && (!drugInfo.has("canUseOnDom") || drugInfo["canUseOnDom"])):
			var useonselfScore:float = max(drugInfo["scoreOnSelf"], 0.0) * drugFetishScore
			addStartAction(["useonself", itemID, _isCanApply, item], drugInfo["name"], desc, useonselfScore, {A_CATEGORY: getCategory()+["Self" if !_isCanApply else "Apply self"]+drugSubcategory})
		if((_isCanApply || !sub.isOralBlocked()) && (!drugInfo.has("canUseOnSub") || drugInfo["canUseOnSub"])):
			if(_subInfo.canDoActions() && _sexEngine.getSexTypeID() != SexType.SlutwallSex && !_isCanApply):
				var offertosubScore:float = max(drugInfo["scoreOnSub"], 0.0)*(1.0 - _domInfo.getAngerScore()) * drugFetishScore
				#print("OFFER TO SUB: "+itemID+": " +str(offertosubScore))
				addStartAction(["offertosub", itemID, _isCanApply, item], drugInfo["name"], desc, offertosubScore, {A_CATEGORY: getCategory()+["Offer to sub"]+drugSubcategory})
			
			var forcetosubScore:float = max(drugInfo["scoreOnSub"], 0.0)*(_domInfo.getAngerScore() if !_isCanApply else 1.0) * drugFetishScore
			#print("FORCE ON SUB: "+itemID+": " +str(forcetosubScore))
			addStartAction(["forcetosub", itemID, _isCanApply, item], drugInfo["name"], desc, forcetosubScore, {A_CATEGORY: getCategory()+["Force on sub" if !_isCanApply else "Apply on sub"]+drugSubcategory})

func pcCanSeeText(ifcan, ifcant = "some pill"):
	if(GM.pc.isBlindfolded()):
		return ifcant
	return ifcan

func startActivity(_args):
	state = ""
	if(_args.size() > 3 && _args[0] == "customtf"):
		var pill = _args[3]
		if(pill == null || !getDom().isPlayer() || getSub().isPlayer()):
			endActivity()
			return
		usedItemID = "TFPill"
		usedUniqueItemID = pill.uniqueID
		directed_page = "main"
		directed_breasts = -999
		directed_penis = ""
		directed_length = 0.0
		directed_thickness = -1
		directed_femininity = -1
		directed_vagina = ""
		directed_color = ""
		setState("directed_tf_menu")
		addText("{dom.You} {dom.youVerb('prepare')} a custom TF pill for {sub.you}. Choose changes below, then give the pill.")
		return
	
	if(_args[0] == "forcetosub"):
		timePassed = 0
		#endActivity()
		var itemID = _args[1]
		var item = _args[3]
		usedUniqueItemID = item.uniqueID if item != null else ""
		var drugInfo = getDrugInfo(itemID, usedUniqueItemID)
		usedItemID = itemID
		var _isCanApply = _args[2]
		
		if(!_isCanApply):
			setState("forcing")
		else:
			setState("forcingCanApply")
		
		#if(getDom().isPlayer()):
		#	if(item != null):
		#		item.removeXOrDestroy(1)
			#getDom().getInventory().removeXOfOrDestroy(itemID, 1)
		if(!getDom().isPlayer()):
			getDomInfo().increaseMemory("USEDDRUG_"+str(itemID))
		
		if(drugInfo == null):
			endActivity()
			return
		
		var text = RNG.pick([
			"{dom.You} {dom.youVerb('produce')} "+pcCanSeeText(drugInfo["usedName"])+" and {dom.youVerb('try', 'tries')} to force it into {sub.your} mouth!",
		])
		if(getSexType() == SexType.SlutwallSex):
			text = RNG.pick([
				"{dom.You} {dom.youVerb('produce')} "+pcCanSeeText(drugInfo["usedName"])+" and {dom.youVerb('slide')} it into {sub.your} asshole! The pill begins to dissolve inside.",
			])
		if(_isCanApply):
			text = RNG.pick([
				"{dom.You} {dom.youVerb('produce')} "+pcCanSeeText(drugInfo["usedName"], "something")+" and {dom.youVerb('begin')} applying it on {sub.you}!",
			])
		
		if(getSub().isPlayer() && itemID == "TFPill"):
			text += " [color=#"+Color.cyan.to_html()+"]This pill might do something to your body[/color]"

		if(_isCanApply):
			addText(text)
		else:
			addText(text)
			react(SexReaction.ForcingDrug)
	
	if(_args[0] == "useonself"):
		timePassed = 0
		#endActivity()
		var itemID = _args[1]
		var item = _args[3]
		usedUniqueItemID = item.uniqueID if item != null else ""
		var drugInfo = getDrugInfo(itemID, usedUniqueItemID)
		usedItemID = itemID
		var _isCanApply = _args[2]
		
		if(!_isCanApply):
			setState("domabouttotake")
		else:
			setState("domabouttotakeCanApply")
		
		#if(getDom().isPlayer()):
			#if(item != null):
			#	item.removeXOrDestroy(1)
			#getDom().getInventory().removeXOfOrDestroy(itemID, 1)
		if(!getDom().isPlayer()):
			getDomInfo().increaseMemory("USEDDRUG_"+str(itemID))
		
		if(drugInfo == null):
			endActivity()
			return
		
		var text = RNG.pick([
			"{dom.You} {dom.youVerb('produce')} "+pcCanSeeText(drugInfo["usedName"])+" and {dom.youAre} about to put it into {dom.yourHis} mouth.",
		])
		if(_isCanApply):
			text = RNG.pick([
				"{dom.You} {dom.youVerb('produce')} "+pcCanSeeText(drugInfo["usedName"], "something")+" and {dom.youVerb('begin')} applying it on {dom.yourself}.",
			])
		addText(text)
	
	if(_args[0] == "offertosub"):
		state = "offering"
		timePassed = 0
		#endActivity()
		var itemID = _args[1]
		var item = _args[3]
		usedUniqueItemID = item.uniqueID if item != null else ""
		var drugInfo = getDrugInfo(itemID, usedUniqueItemID)
		usedItemID = itemID

		
		if(drugInfo == null):
			endActivity()
			return
		
		var customDomSay:String = ""
		
		var text:String = RNG.pick([
			"{dom.You} {dom.youVerb('produce')} "+pcCanSeeText(drugInfo["usedName"])+" and {dom.youVerb('offer')} it to {sub.you}.",
		])
		if(getSub().isBlindfolded()):
			text += RNG.pick([
				" {sub.YouHe} can only guess what drug that is.",
			])
		elif(getSub().isPlayer() && itemID == "TFPill"):
			text += " [color=#"+Color.cyan.to_html()+"]This pill might do something to your body[/color]"

			generatePillVariants(itemID)
			if(!pillVariants.empty()):
				var tfNames:Array = []
				for tfID in pillVariants:
					var tf:TFBase = GlobalRegistry.getTransformationRef(tfID)
					if(tf != null):
						var pillName:String = tf.getPillName()
						tfNames.append("a "+pillName)
				customDomSay = "It's either "+Util.humanReadableList(tfNames, "or")+". "
				customDomSay += RNG.pick([
					"But I'm not gonna say which.",
					"But I don't remember which.",
					"Try your luck.",
					"Just try it and see what happens.",
					"C'mon, it will be fun.",
				])
		addText(text)
		if(customDomSay == ""):
			react(SexReaction.OfferingDrug)
		else:
			talkText(DOM_0, customDomSay)
	
func processTurn():
	if(getState() == "directed_tf_menu"):
		return
	timePassed += 1
	
	if(timePassed > 1):
		endActivity()
		if(getState() == "offering"):
			addText("{sub.You} ignored {dom.your} offer.")
			getDomInfo().addAnger(0.25)
			return
		
		if(getState() in ["forcing", "forcingCanApply"]):
			var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
			
			var itemRef = GlobalRegistry.getItemRef(usedItemID) if usedUniqueItemID == "" else getDom().getInventory().getItemByUniqueID(usedUniqueItemID)
			if(itemRef == null || drugInfo == null):
				return
			if(usedItemID == "TFPill" && pillVariants.size() > 0):
				itemRef = GlobalRegistry.createItem(usedItemID)
				var thePick:String = RNG.pick(pillVariants)
				itemRef.setTFID(thePick)
				
			if(usedItemID == "TFPill"):
				fetishAffect(SUB_0, Fetish.TFReceiving, 10.0)
				fetishAffect(DOM_0, Fetish.TFGiving, 10.0)
			else:
				fetishAffect(SUB_0, Fetish.DrugUse, 3.0)
				fetishAffect(DOM_0, Fetish.DrugUse, 3.0)
			
			var pillResultText = ""
			var result = itemRef.useInSex(getSub())
			if(result != null && result.has("text") && result["text"]!=""):
				pillResultText = " "+result["text"]
			
			sendSexEvent(SexEvent.DrugSwallowed, DOM_0, SUB_0, {forced=true,itemID=usedItemID})
			if(drugInfo.has("sexgoal")):
				satisfyGoal(drugInfo["sexgoal"])
			
			var text = RNG.pick([
				"{dom.You} {dom.youVerb('force')} {sub.you} to swallow "+pcCanSeeText(drugInfo["usedName"])+"!"+pillResultText,
			])
			if(getSexType() == SexType.SlutwallSex):
				text = RNG.pick([
					"The pill dissolves inside {sub.your} butt, it was "+pcCanSeeText(drugInfo["usedName"], "an unknown one")+"!"+pillResultText,
				])
			if(getState() == "forcingCanApply"):
				text = RNG.pick([
					"{dom.You} {dom.youVerb('finish', 'finishes')} applying "+pcCanSeeText(drugInfo["usedName"], "something")+" on {sub.youHim}!"+pillResultText,
				])
			if(usedUniqueItemID != ""):
				getDom().getInventory().getItemByUniqueID(usedUniqueItemID).removeXOrDestroy(1)
			addText(text)
			return
		
		if(getState() in ["domabouttotake", "domabouttotakeCanApply"]):
			var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
			
			var itemRef = GlobalRegistry.getItemRef(usedItemID) if usedUniqueItemID == "" else getDom().getInventory().getItemByUniqueID(usedUniqueItemID)
			if(itemRef == null || drugInfo == null):
				return
			
			var pillResultText:String = ""
			var result = itemRef.useInSex(getDom())
			if(result != null && result.has("text") && result["text"]!=""):
				pillResultText = " "+result["text"]
			
			if(usedItemID == "TFPill"):
				fetishAffect(DOM_0, Fetish.TFGiving, 5.0)
			else:
				fetishAffect(DOM_0, Fetish.DrugUse, 2.0)
			
			var text = RNG.pick([
				"{dom.You} {dom.youVerb('swallow')} "+pcCanSeeText(drugInfo["usedName"])+"!"+pillResultText,
			])
			if(state == "domabouttotakeCanApply"):
				text = RNG.pick([
					"{dom.You} {dom.youVerb('finish', 'finishes')} applying "+pcCanSeeText(drugInfo["usedName"], "something")+" on {dom.yourself}!"+pillResultText,
				])
			if(usedUniqueItemID != ""):
				getDom().getInventory().getItemByUniqueID(usedUniqueItemID).removeXOrDestroy(1)
			addText(text)
			return

func getSubSpitOutChance(baseChance:float, domAngerRemoval:float) -> float:
	var theChance = baseChance - getDomInfo().getAngerScore()*domAngerRemoval
	if(getSub().isBitingBlocked()):
		theChance *= 0.5
	
	return max(theChance, 5.0)

func getActions(_indx:int):
	if(getState() == "directed_tf_menu"):
		if(_indx == DOM_0 && getDom().isPlayer()):
			_directed_add_actions()
		return
	if(_indx == SUB_0):
		if(getState() == "offering"):
			var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
			var theObeyScore:float = getSubInfo().personalityScore({PersonalityStat.Naive: 0.2, PersonalityStat.Subby: 0.2}) + getSubInfo().fetishScore({Fetish.DrugUse: 1.0})
			if(!getSub().isBlindfolded()):
				theObeyScore = (max(0.0, theObeyScore) + drugInfo["scoreSubScore"]) * getSubInfo().getComplyScore()
			if(getSubInfo().shouldFullyObey()):
				theObeyScore = 10000.0
			var theResistScore:float = 1.0 - clamp(theObeyScore, 0.0, 1.0)
			addAction("eatit", theObeyScore, "Take pill", "Eat the offered pill")
			addAction("noteatit", theResistScore, "Decline pill", "You don't wanna eat that pill")
		
		if(getState() == "forcing" && getSexType() != SexType.SlutwallSex):
			var theResistScore:float = 0.1 + getSubInfo().getResistScore()*(0.2 - getSubInfo().fetishScore({Fetish.DrugUse: 1.0}))
			var theObeyScore:float = 1.0 - clamp(theResistScore, 0.0, 1.0)
			if(getSubInfo().shouldFullyObey()):
				theResistScore = 0.0
				theObeyScore = 10000.0
			addAction("swallowforced", theObeyScore, "Swallow pill", "Swallow the pill in your mouth")
			addAction("spitpillout", theResistScore, "Spit pill out", "You really don't wanna swallow that", {A_CHANCE: getSubSpitOutChance(100.0, 60.0)})
	
		if(getState() == "forcingCanApply"):
			var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
			addAction("resistForceCanApply", (1.0-max(0.0, drugInfo["scoreSubScore"])), "Stop them", "Try to prevent them from doing this to you", {A_CHANCE: getResistChance(SUB_0, DOM_0, RESIST_HANDS_FOCUS, 70.0, 30.0)})

		if(getState() == "domabouttotake"):
			addAction("resistdometake", getResistScore(SUB_0), "Stop them", "Try to prevent them from taking the drug", {A_CHANCE: getResistChance(SUB_0, DOM_0, RESIST_HANDS_FOCUS, 70.0, 30.0)})
		if(getState() == "domabouttotakeCanApply"):
			addAction("resistForceCanApply", getResistScore(SUB_0), "Stop them", "Try to prevent them from applying that thing", {A_CHANCE: getResistChance(SUB_0, DOM_0, RESIST_HANDS_FOCUS, 70.0, 30.0)})

func doAction(_indx:int, _id:String, _action:Dictionary):
	if(getState() == "directed_tf_menu"):
		if(_indx == DOM_0 && getDom().isPlayer()):
			_directed_handle_action(_id)
		return
	if(_id == "spitpillout"):
		if(RNG.chance(getSubSpitOutChance(100.0, 60.0))):
			getDomInfo().addAnger(0.3)
			endActivity()
			var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
			if(drugInfo.has("sexgoal")):
				failGoal(drugInfo["sexgoal"])
			addText("{sub.You} {sub.youVerb('manage', 'managed')} to spit the pill out!")
			reactSub(SexReaction.Resisting, [50])
			fetishUp(SUB_0, Fetish.DrugUse, -10.0)
			return
		
		getDomInfo().addAnger(0.1)
		addText("{sub.You} {sub.youVerb('try', 'tries')} to spit the pill out but {sub.youVerb('fail')}.")
		fetishUp(SUB_0, Fetish.DrugUse, -20.0)
		
	if(_id == "noteatit"):
		endActivity()
		
		var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
		if(drugInfo.has("sexgoal")):
			failGoal(drugInfo["sexgoal"])
		
		addText("{sub.You} {sub.youVerb('refuse')} to take the offered pill.")
		if(!getDom().isPlayer() && RNG.chance(100.0 * getDomInfo().personalityScore({PersonalityStat.Impatient: 0.5, PersonalityStat.Mean: 0.2}))):
			getDomInfo().addAnger(0.2)
			addText("That made {dom.you} angry.")
		reactSub(SexReaction.RefusingToSwallowDrug)
		
	if(_id in ["eatit", "swallowforced"]):
		endActivity()
		var drugInfo = getDrugInfo(usedItemID, usedUniqueItemID)
		if(drugInfo.has("sexgoal")):
			satisfyGoal(drugInfo["sexgoal"])
		
		#if(getDom().isPlayer() && _id == "eatit"):
		#	getDom().getInventory().removeXOfOrDestroy(usedItemID, 1)
		if(!getDom().isPlayer() && _id == "eatit"):
			getDomInfo().increaseMemory("USEDDRUG_"+str(usedItemID))
		
		var itemRef = GlobalRegistry.getItemRef(usedItemID) if usedUniqueItemID == "" else getDom().getInventory().getItemByUniqueID(usedUniqueItemID)
		if(itemRef == null || drugInfo == null):
			return
		if(usedItemID == "TFPill" && pillVariants.size() > 0):
			itemRef = GlobalRegistry.createItem(usedItemID)
			var thePick:String = RNG.pick(pillVariants)
			itemRef.setTFID(thePick)
			fetishUp(SUB_0, Fetish.TFReceiving, 10.0)
		else:
			fetishUp(SUB_0, Fetish.DrugUse, 5.0)
		
		var pillResultText = ""
		var result = itemRef.useInSex(getSub())
		if(result != null && result.has("text") && result["text"]!=""):
			pillResultText = " "+result["text"]
		
		sendSexEvent(SexEvent.DrugSwallowed, DOM_0, SUB_0, {forced=false,itemID=usedItemID})
		
		addText("{sub.You} {sub.youVerb('obey')} and {sub.youVerb('swallow')} "+pcCanSeeText(drugInfo["usedName"])+"!"+pillResultText)
		if(usedUniqueItemID != ""):
			getDom().getInventory().getItemByUniqueID(usedUniqueItemID).removeXOrDestroy(1)
	
	if(_id == "resistdometake"):
		if(RNG.chance(getResistChance(SUB_0, DOM_0, RESIST_HANDS_FOCUS, 70.0, 30.0))):
			getDomInfo().addAnger(0.3)
			endActivity()
			addText("{sub.You} {sub.youVerb('manage', 'managed')} to make {dom.youHim} drop the pill, losing it!")
			fetishUp(SUB_0, Fetish.DrugUse, -10.0)
			return
		
		getDomInfo().addAnger(0.1)
		if(usedUniqueItemID != ""):
			getDom().getInventory().getItemByUniqueID(usedUniqueItemID).removeXOrDestroy(1)
		addText("{sub.You} {sub.youVerb('try', 'tries')} to stop {dom.youHim} from taking the pill but {sub.youVerb('fail')}.")
		reactSub(SexReaction.Resisting, [50])
	
	if(_id == "resistForceCanApply"):
		if(RNG.chance(getResistChance(SUB_0, DOM_0, RESIST_HANDS_FOCUS, 70.0, 30.0))):
			getDomInfo().addAnger(0.3)
			endActivity()
			addText("{sub.You} {sub.youVerb('manage', 'managed')} to make {dom.youHim} screw up the applying process!")
			return
		
		getDomInfo().addAnger(0.1)
		if(usedUniqueItemID != ""):
			getDom().getInventory().getItemByUniqueID(usedUniqueItemID).removeXOrDestroy(1)
		addText("{sub.You} {sub.youVerb('try', 'tries')} to stop {dom.youHim} but {sub.youVerb('fail')}.")
		reactSub(SexReaction.Resisting, [50])

func _directed_add_actions():
	if(directed_page == "main"):
		addAction("custom_breasts", 1.0, "Breasts: " + DIRECTED_TF.breast_label(directed_breasts), "Select a breast size")
		addAction("custom_penis", 1.0, "Penis: " + DIRECTED_TF.penis_label(directed_penis), "Select a penis type")
		addAction("custom_length", 1.0, "Length: " + DIRECTED_TF.length_label(directed_length), "Choose penis length")
		addAction("custom_thickness", 1.0, "Thickness: " + DIRECTED_TF.thickness_label(directed_thickness), "Choose body thickness")
		addAction("custom_femininity", 1.0, "Femininity: " + DIRECTED_TF.femininity_label(directed_femininity), "Choose masculinity/femininity")
		addAction("custom_vagina", 1.0, "Vagina: " + DIRECTED_TF.vagina_label(directed_vagina), "Choose vagina type, add or remove")
		addAction("custom_color", 1.0, "Colors: " + DIRECTED_TF.color_label(directed_color), "Choose random colors/skin")
		addAction("custom_apply", 1.0, "Give custom TF pill", "Consume one pill and apply these changes to this NPC")
		addAction("custom_cancel", 1.0, "Cancel", "Return without consuming the pill")
	elif(directed_page == "breasts"):
		addAction("custom_b_-999", 1.0, "No change", "Leave breasts unchanged")
		for size in range(BreastsSize.FLAT, BreastsSize.O + 1):
			addAction("custom_b_" + str(size), 1.0, BreastsSize.breastSizeToString(size), "Set breast size")
		addAction("custom_back", 1.0, "Back", "Return")
	elif(directed_page == "penis"):
		addAction("custom_p_keep", 1.0, "No change", "Leave penis unchanged")
		addAction("custom_p_remove", 1.0, "Remove penis", "Remove penis bodypart")
		for entry in DIRECTED_TF.PENIS_TYPES:
			if(GlobalRegistry.getBodypartRef(entry[0]) != null):
				addAction("custom_p_" + entry[0], 1.0, entry[1], "Choose this bodypart type")
		addAction("custom_back", 1.0, "Back", "Return")
	elif(directed_page == "length"):
		addAction("custom_l_0", 1.0, "No change", "Leave length unchanged")
		for length in DIRECTED_TF.PENIS_LENGTHS:
			addAction("custom_l_" + str(length), 1.0, str(length) + " cm", "Choose length")
		addAction("custom_back", 1.0, "Back", "Return")
	elif(directed_page == "thickness"):
		addAction("custom_t_-1", 1.0, "No change", "Leave thickness unchanged")
		for value in DIRECTED_TF.THICKNESS_VALUES:
			addAction("custom_t_" + str(value), 1.0, str(value) + "%", "Set thickness")
		addAction("custom_back", 1.0, "Back", "Return")
	elif(directed_page == "femininity"):
		addAction("custom_f_-1", 1.0, "No change", "Leave femininity unchanged")
		for value in DIRECTED_TF.FEMININITY_VALUES:
			addAction("custom_f_" + str(value), 1.0, DIRECTED_TF.femininity_label(value), "Set femininity / masculinity")
		addAction("custom_back", 1.0, "Back", "Return")
	elif(directed_page == "vagina"):
		addAction("custom_v_keep", 1.0, "No change", "Leave vagina unchanged")
		addAction("custom_v_remove", 1.0, "Remove vagina", "Remove vagina")
		for entry in DIRECTED_TF.VAGINA_TYPES:
			if(GlobalRegistry.getBodypartRef(entry[0]) != null):
				addAction("custom_v_" + entry[0], 1.0, entry[1], "Choose this vagina type")
		addAction("custom_back", 1.0, "Back", "Return")
	elif(directed_page == "color"):
		addAction("custom_col_keep", 1.0, "No change", "Keep current colors")
		for entry in DIRECTED_TF.COLOR_MODES:
			addAction("custom_col_" + entry[0], 1.0, entry[1], "Randomize colors once when pill is used")
		addAction("custom_back", 1.0, "Back", "Return")

func _directed_handle_action(action_id:String):
	if(action_id == "custom_breasts"):
		directed_page = "breasts"
	elif(action_id == "custom_penis"):
		directed_page = "penis"
	elif(action_id == "custom_length"):
		directed_page = "length"
	elif(action_id == "custom_thickness"):
		directed_page = "thickness"
	elif(action_id == "custom_femininity"):
		directed_page = "femininity"
	elif(action_id == "custom_vagina"):
		directed_page = "vagina"
	elif(action_id == "custom_color"):
		directed_page = "color"
	elif(action_id == "custom_back"):
		directed_page = "main"
	elif(action_id.begins_with("custom_b_")):
		directed_breasts = int(action_id.substr(len("custom_b_")))
		directed_page = "main"
	elif(action_id.begins_with("custom_p_")):
		var selected_id:String = action_id.substr(len("custom_p_"))
		if(selected_id == "keep"):
			directed_penis = ""
		elif(selected_id == "remove"):
			directed_penis = "remove"
		else:
			for entry in DIRECTED_TF.PENIS_TYPES:
				if(entry[0] == selected_id):
					directed_penis = selected_id
		directed_page = "main"
	elif(action_id.begins_with("custom_l_")):
		directed_length = float(action_id.substr(len("custom_l_")))
		directed_page = "main"
	elif(action_id.begins_with("custom_t_")):
		directed_thickness = int(action_id.substr(len("custom_t_")))
		directed_page = "main"
	elif(action_id.begins_with("custom_f_")):
		directed_femininity = int(action_id.substr(len("custom_f_")))
		directed_page = "main"
	elif(action_id.begins_with("custom_v_")):
		var selected_id:String = action_id.substr(len("custom_v_"))
		if(selected_id == "keep"):
			directed_vagina = ""
		elif(selected_id == "remove"):
			directed_vagina = "remove"
		else:
			for entry in DIRECTED_TF.VAGINA_TYPES:
				if(entry[0] == selected_id):
					directed_vagina = selected_id
		directed_page = "main"
	elif(action_id.begins_with("custom_col_")):
		var selected_id:String = action_id.substr(len("custom_col_"))
		directed_color = "" if selected_id == "keep" else selected_id
		directed_page = "main"
	elif(action_id == "custom_cancel"):
		endActivity()
	elif(action_id == "custom_apply"):
		var item = getDom().getInventory().getItemByUniqueID(usedUniqueItemID)
		if(item == null || item.id != "TFPill"):
			addText("The TF pill is no longer in your inventory. No changes were applied.")
			endActivity()
			return
		var descriptions:Array = DIRECTED_TF.apply_changes(getSub(), directed_breasts, directed_penis, directed_length, directed_thickness, directed_femininity, directed_vagina, directed_color)
		item.removeXOrDestroy(1)
		satisfyGoal(SexGoal.UseTFDrug)
		sendSexEvent(SexEvent.DrugSwallowed, DOM_0, SUB_0, {forced=false, itemID="TFPill"})
		if(descriptions.empty()):
			addText("{sub.You} {sub.youVerb('swallow')} the TF pill, but no compatible changes were selected.")
		else:
			addText("{sub.You} {sub.youVerb('swallow')} the TF pill. Custom changes applied: " + Util.join(descriptions, ", ") + ".")
		endActivity()

func generatePillVariants(theItemID:String):
	pillVariants = []
	
	if(theItemID == "TFPill"):
		for _i in 3:
			var newTFID:String = TFUtil.generateTFIDForAPill(pillVariants)
			if(newTFID != ""):
				pillVariants.append(newTFID)

func saveData():
	var data = .saveData()
	
	data["usedItemID"] = usedItemID
	data["usedUniqueItemID"] = usedUniqueItemID
	data["timePassed"] = timePassed
	data["pillVariants"] = pillVariants
	data["directed_page"] = directed_page
	data["directed_breasts"] = directed_breasts
	data["directed_penis"] = directed_penis
	data["directed_length"] = directed_length
	data["directed_thickness"] = directed_thickness
	data["directed_femininity"] = directed_femininity
	data["directed_vagina"] = directed_vagina
	data["directed_color"] = directed_color

	return data
	
func loadData(data):
	.loadData(data)
	
	usedItemID = SAVE.loadVar(data, "usedItemID", "")
	usedUniqueItemID = SAVE.loadVar(data, "usedUniqueItemID", "")
	timePassed = SAVE.loadVar(data, "timePassed", 0)
	pillVariants = SAVE.loadVar(data, "pillVariants", [])
	directed_page = SAVE.loadVar(data, "directed_page", "main")
	directed_breasts = SAVE.loadVar(data, "directed_breasts", -999)
	directed_penis = SAVE.loadVar(data, "directed_penis", "")
	directed_length = SAVE.loadVar(data, "directed_length", 0.0)
	directed_thickness = SAVE.loadVar(data, "directed_thickness", -1)
	directed_femininity = SAVE.loadVar(data, "directed_femininity", -1)
	directed_vagina = SAVE.loadVar(data, "directed_vagina", "")
	directed_color = SAVE.loadVar(data, "directed_color", "")
