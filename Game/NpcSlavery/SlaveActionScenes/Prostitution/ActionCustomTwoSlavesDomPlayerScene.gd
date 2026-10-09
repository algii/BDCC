extends "res://Scenes/SceneBase.gd"

var npcID = ""
var secondID = ""

func _init():
	sceneID = "ActionCustomTwoSlavesDomPlayerScene"

func _initScene(_args = []):
	npcID = _args[0]
	secondID = _args[1]["dom2"]

func resolveCustomCharacterName(_charID):
	if(_charID == "npc"):
		return npcID
	if(_charID == "npc2"):
		return secondID

func _run():
	if(state == ""):
		addCharacter(npcID)
		addCharacter(secondID)
		playAnimation(StageScene.Duo, "stand", {npc=npcID, pc=secondID})
		saynn("You invite {npc.name} and {npc2.name} to take the lead together. You will be the submissive participant.")
		addButton("Begin", "Start the encounter with both slaves in the dominant role", "begin")
		addButton("Cancel", "Return without starting the encounter", "endthescene")
	elif(state == "after_sex"):
		addCharacter(npcID)
		addCharacter(secondID)
		playAnimation(StageScene.Duo, "stand", {npc=npcID, pc=secondID})
		saynn("Your time together comes to an end.")
		addButton("Continue", "Return to your usual activities", "endthescene")

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	if(_action == "begin"):
		# Both NPCs are dominant; the player is the only sub.
		runScene("GenericSexScene", [[npcID, secondID], "pc", SexType.DefaultSex, {SexMod.DisableDynamicJoiners: true}], "custom_dom_finished")
		setState("after_sex")
		return
	setState(_action)

func _react_scene_end(_tag, _result):
	if(_tag == "custom_dom_finished"):
		for characterID in [npcID, secondID]:
			var character = GlobalRegistry.getCharacter(characterID)
			if(character != null && character.getNpcSlavery() != null):
				character.getNpcSlavery().addTired(1)

func saveData():
	var data = .saveData()
	data["npcID"] = npcID
	data["secondID"] = secondID
	return data

func loadData(data):
	.loadData(data)
	npcID = SAVE.loadVar(data, "npcID", "")
	secondID = SAVE.loadVar(data, "secondID", "")
