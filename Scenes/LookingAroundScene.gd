extends "res://Scenes/SceneBase.gd"

const AI_CHAT_SCENE_SCRIPT = preload("res://Scenes/AINpcChatScene.gd")

var pawnID:String = ""

func _init():
	sceneID = "LookingAroundScene"

func _run():
	if(state == ""):
		setCharactersEasyList(GM.main.IS.getPawnIDsAt(GM.pc.getLocation()))
		
		saynn("Here is what's happening around you:")
		addButtonAt(13, "AI Chat", "Choose a nearby NPC for AI chat", "ai_select")
		addButtonAt(14, "Back", "Enough looking around", "endthescene")
		
		var pcLoc:String = GM.pc.getLocation()
		var allPawns:Array = GM.main.IS.getPawnsAt(pcLoc)
		
		for pawnA in allPawns:
			var pawn:CharacterPawn = pawnA
			if(pawn.isPlayer()):
				continue
			var character:BaseCharacter = pawn.getCharacter()
			pawnID = pawn.charID
			
			var interaction:PawnInteractionBase = pawn.getInteraction()
			
			if(interaction == null):
				sayn("{pawn.name} is not doing anything.")
			else:
				sayn(interaction.getPreviewLineForPawn(pawn))
			
			addButton(character.getName(), "Focus your attention on this person", "focus", [pawn])
		
		pawnID = ""

	if(state == "ai_select"):
		saynn("Choose a nearby NPC for AI Chat:")
		setCharactersEasyList(GM.main.IS.getPawnIDsAt(GM.pc.getLocation()))
		var candidates:Array = GM.main.IS.getPawnsAt(GM.pc.getLocation())
		for candidateA in candidates:
			var candidate:CharacterPawn = candidateA
			if(candidate.isPlayer()):
				continue
			var target = candidate.getCharacter()
			if(target == null):
				continue
			addButton(target.getName(), "Start an AI Chat with this NPC", "ai_chat", [candidate.charID])
		addButtonAt(14, "Back", "Return to looking around", "")

	if(state == "focus"):
		var pcPawn:CharacterPawn = GM.main.IS.getPawn("pc")
		addButtonAt(14, "Back", "Go back to the previous menu", "")
		var pawn:CharacterPawn = GM.main.IS.getPawn(pawnID)
		
		if(pawn == null):
			saynn("Pawn not found, sorry.")
			#addButton("Back", "Enough spying", "")
			return
			
		addButton("Spy on", "See what they are up to", "spyon", [pawn])
		addButton("AI Chat", "Have a free-form online conversation with this NPC", "ai_chat")
			
		var interaction:PawnInteractionBase = pawn.getInteraction()
		if(interaction == null):
			saynn("{pawn.name} is not doing anything right now.")
			return
		
		#saynn("{pawn.name} is in a "+interaction.id+" interaction")
		if(interaction.getCurrentActionText() != ""):
			saynn(interaction.getCurrentActionText())
		
		interaction.playAnimation()
		saynn(interaction.getOutputTextFinal())
		
		if(pcPawn == null):
			return
		for action in interaction.getInterruptActionsFinal(pcPawn):
			addButton(action["name"], action["desc"], "doInterrupt", [pawn, interaction, action])

func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	if(_action == "focus"):
		pawnID = _args[0].charID
	if(_action == "ai_chat"):
		var target_id:String = pawnID
		if(_args.size() > 0):
			target_id = str(_args[0])
		if(target_id == ""):
			return
		_open_ai_chat(target_id)
		return
	if(_action == "spyon"):
		endScene()
		runScene("SpyOnPawnScene", [_args[0].charID])
		return
	if(_action == "doInterrupt"):
		#var pawn = _args[0]
		var interaction:PawnInteractionBase = _args[1]
		var action = _args[2]
		if(interaction == null || interaction.wasDeleted):
			return
		endScene()
		
		interaction.doInterruptActionFinal(GM.main.IS.getPawn("pc"), action["id"], action["args"])
		return


	setState(_action)

func resolveCustomCharacterName(_charID):
	if(_charID == "pawn" && pawnID != ""):
		return pawnID
	
	var pawn:CharacterPawn = GM.main.IS.getPawn(pawnID)
	if(pawn == null):
		return .resolveCustomCharacterName(_charID)
	var interaction:PawnInteractionBase = pawn.getInteraction()
	if(interaction == null):
		return .resolveCustomCharacterName(_charID)

	if(interaction.involvedPawns.has(_charID)):
		return interaction.involvedPawns[_charID]
	return .resolveCustomCharacterName(_charID)

func isSpyingOnInteractionsWith(_charID:String):
	if(_charID == pawnID):
		return true
	return false

func saveData():
	var data = .saveData()
	
	data["pawnID"] = pawnID

	return data
	
func loadData(data):
	.loadData(data)
	
	pawnID = SAVE.loadVar(data, "pawnID", "")

func supportsShowingPawns() -> bool:
	return true


# Register the chat scene explicitly rather than relying on directory scanning
# of .gd files in exported Godot Android PCKs. Keep this menu on the stack:
# closing AI Chat should return to where the player came from.
func _open_ai_chat(target_id:String):
	if(target_id == "" or GlobalRegistry.getCharacter(target_id) == null):
		saynn("AI Chat: This NPC is no longer available.")
		return
	var chat_scene_id = GlobalRegistry.registerTemporaryScene(AI_CHAT_SCENE_SCRIPT)
	if(chat_scene_id == null):
		Log.printerr("BDCC AI Chat: Failed to register AINpcChatScene")
		saynn("AI Chat could not be opened. Please check the game log.")
		return
	runScene(chat_scene_id, [target_id])
