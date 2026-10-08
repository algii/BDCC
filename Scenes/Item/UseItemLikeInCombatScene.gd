extends "res://Scenes/SceneBase.gd"

var savedText = ""
var uniqueItemID = ""
const DIRECTED_TF = preload("res://Game/Transformation/DirectedTFUtil.gd")
var directed_page:String = "main"
var directed_breasts:int = -999
var directed_penis:String = ""
var directed_length:float = 0.0

func _init():
	sceneID = "UseItemLikeInCombatScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		uniqueItemID = _args[0]
	
func _reactInit():
	if(uniqueItemID == null || uniqueItemID == ""):
		return
	var item: ItemBase = GM.pc.getInventory().getItemByUniqueID(uniqueItemID)
	
	if(item == null):
		setState("afteruse")
		savedText = "The item is no longer in your inventory."
		return
	if(item.id == "TFPill"):
		directed_page = "main"
		directed_breasts = -999
		directed_penis = ""
		directed_length = 0.0
		setState("directed_tf")
		return
	var intoxic = item.addsIntoxicationToPC()
	if(intoxic > 0.0 && !GM.pc.canIntoxicateMore(intoxic)):
		setState("tooToxic")
		return
		
	var currentEnemy = null
	var theFightScene = GM.main.getCurrentFightScene()
	if(theFightScene != null):
		currentEnemy = theFightScene.enemyCharacter
		
	savedText = item.useInCombatWithBuffs(GM.pc, currentEnemy)
	setState("afteruse")

func _run():
	if(state == "directed_tf"):
		saynn("Custom TF pill: choose changes for your character. Unselected bodyparts remain unchanged. These direct edits are permanent.")
		if(directed_page == "main"):
			addButton("Breasts: " + DIRECTED_TF.breast_label(directed_breasts), "Select a size", "tf_breasts")
			addButton("Penis: " + DIRECTED_TF.penis_label(directed_penis), "Choose type", "tf_penis")
			addButton("Length: " + DIRECTED_TF.length_label(directed_length), "Choose length", "tf_length")
			addButton("Consume pill with selected changes", "Apply the selected changes to your character", "tf_apply")
			addButton("Cancel without using pill", "Keep the TF pill", "endthescene")
		elif(directed_page == "breasts"):
			addButton("No change", "Leave unchanged", "tf_b_choice", [-999])
			for size in range(BreastsSize.FLAT, BreastsSize.O + 1):
				addButton(BreastsSize.breastSizeToString(size), "Select size", "tf_b_choice", [size])
			addButton("Back", "Return", "tf_back")
		elif(directed_page == "penis"):
			addButton("No change", "Leave unchanged", "tf_p_choice", [""])
			addButton("Remove penis", "Remove this bodypart", "tf_p_choice", ["remove"])
			for entry in DIRECTED_TF.PENIS_TYPES:
				if(GlobalRegistry.getBodypartRef(entry[0]) != null):
					addButton(entry[1], "Set penis type", "tf_p_choice", [entry[0]])
			addButton("Back", "Return", "tf_back")
		elif(directed_page == "length"):
			addButton("No change", "Leave unchanged", "tf_l_choice", [0.0])
			for length in DIRECTED_TF.PENIS_LENGTHS:
				addButton(str(length) + " cm", "Choose this length", "tf_l_choice", [float(length)])
			addButton("Back", "Return", "tf_back")
		return
	if(state == ""):
		# Never should be here
		addButton("Continue", "Oops", "endthescene")
		
	if(state == "afteruse"):
		saynn(savedText)
		
		addButton("Continue", "You did it", "endthescene")

	if(state == "tooToxic"):
		saynn("You're too intoxicated to use this")
			
		addButton("Continue", "Aww", "endthescene")
		return

func _react(_action: String, _args):
	if(state == "directed_tf"):
		if(_action == "tf_breasts"):
			directed_page = "breasts"
			return
		if(_action == "tf_penis"):
			directed_page = "penis"
			return
		if(_action == "tf_length"):
			directed_page = "length"
			return
		if(_action == "tf_back"):
			directed_page = "main"
			return
		if(_action == "tf_b_choice"):
			directed_breasts = int(_args[0])
			directed_page = "main"
			return
		if(_action == "tf_p_choice"):
			directed_penis = str(_args[0])
			directed_page = "main"
			return
		if(_action == "tf_l_choice"):
			directed_length = float(_args[0])
			directed_page = "main"
			return
		if(_action == "tf_apply"):
			var item = GM.pc.getInventory().getItemByUniqueID(uniqueItemID)
			if(item == null || item.id != "TFPill"):
				savedText = "The TF pill is no longer in your inventory."
			else:
				var descriptions:Array = DIRECTED_TF.apply_changes(GM.pc, directed_breasts, directed_penis, directed_length)
				item.removeXOrDestroy(1)
				savedText = "You swallow the TF pill. " + ("No compatible changes selected." if descriptions.empty() else "Changed: " + Util.join(descriptions, ", ") + ".")
			setState("afteruse")
			return
	if(_action == "endthescene"):
		endScene()
		return
	
	setState(_action)

func saveData():
	var data = .saveData()
	
	data["savedText"] = savedText
	data["uniqueItemID"] = uniqueItemID
	data["directed_page"] = directed_page
	data["directed_breasts"] = directed_breasts
	data["directed_penis"] = directed_penis
	data["directed_length"] = directed_length
	
	return data
	
func loadData(data):
	.loadData(data)
	
	savedText = SAVE.loadVar(data, "savedText", "")
	uniqueItemID = SAVE.loadVar(data, "uniqueItemID", "")
	directed_page = SAVE.loadVar(data, "directed_page", "main")
	directed_breasts = SAVE.loadVar(data, "directed_breasts", -999)
	directed_penis = SAVE.loadVar(data, "directed_penis", "")
	directed_length = SAVE.loadVar(data, "directed_length", 0.0)

func resolveCustomCharacterName(_charID):
	if(_charID == "attacker"):
		return "pc"
	
	return null
