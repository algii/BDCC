extends "res://Scenes/SceneBase.gd"

var npcID = ""

func _init():
	sceneID = "ActionCustomSlaveDomPlayerScene"

func _initScene(_args = []):
	npcID = _args[0]

func resolveCustomCharacterName(_charID):
	if(_charID == "npc"):
		return npcID

func _run():
	if(state == ""):
		addCharacter(npcID)
		playAnimation(StageScene.Duo, "stand", {npc=npcID})
		saynn("You invite {npc.name} to take the lead. You will be the submissive participant.")
		addButton("Begin", "Start the encounter with your slave in the dominant role", "begin")
		addButton("Cancel", "Return without starting the encounter", "endthescene")
	elif(state == "after_sex"):
		addCharacter(npcID)
		playAnimation(StageScene.Duo, "stand", {npc=npcID})
		saynn("Your time together comes to an end.")
		addButton("Continue", "Return to your usual activities", "endthescene")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	if(_action == "begin"):
		# NPC is dominant; the player is submissive. No unrelated NPCs join.
		runScene("GenericSexScene", [npcID, "pc", SexType.DefaultSex, {SexMod.DisableDynamicJoiners: true}], "custom_dom_finished")
		setState("after_sex")
		return
	setState(_action)

func _react_scene_end(_tag, _result):
	if(_tag == "custom_dom_finished"):
		var character = GlobalRegistry.getCharacter(npcID)
		if(character != null && character.getNpcSlavery() != null):
			character.getNpcSlavery().addTired(1)

func saveData():
	var data = .saveData()
	data["npcID"] = npcID
	return data

func loadData(data):
	.loadData(data)
	npcID = SAVE.loadVar(data, "npcID", "")
