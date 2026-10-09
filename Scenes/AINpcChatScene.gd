extends "res://Scenes/SceneBase.gd"

# BDCC Custom AI v10 - self-contained text-only NPC conversations.
# The AI cannot modify quests, game variables, inventory, or relationships.

const SETTINGS_FILE = "user://bdcc_ai_chat.cfg"
const HISTORY_FILE = "user://bdcc_ai_history.json"
const MAX_MESSAGE_LENGTH = 600
const MAX_LOCAL_TURNS = 24
const MAX_SENT_TURNS = 12

var npcID:String = ""
var npc = null
var api_url:String = ""
var game_access_code:String = ""
var conversations:Dictionary = {}
var transcript:Array = []
var request_node:HTTPRequest = null
var busy:bool = false
var editing_settings:bool = false
var error_text:String = ""

func _init():
	sceneID = "AINpcChatScene"

func _initScene(_args = []):
	if(_args.size() > 0):
		npcID = str(_args[0])
	_setup()

func _setup():
	npc = GlobalRegistry.getCharacter(npcID)
	_load_settings()
	_load_history()
	if(request_node == null):
		request_node = HTTPRequest.new()
		request_node.timeout = 30.0
		request_node.body_size_limit = 16384
		add_child(request_node)
		request_node.connect("request_completed", self, "_on_chat_reply")

func _run():
	if(npc == null):
		saynn("This NPC is no longer available.")
		addButtonAt(14, "Back", "Return to the game", "back")
		return
	addCharacter(npcID)
	saynn("[b]AI Chat: " + _safe_text(npc.getName()) + "[/b]")
	saynn("Online text conversation (the NPC cannot change game state).")
	if(editing_settings):
		saynn("Paste the HTTPS address of your own AI gateway, and its game access code. Never enter your AI provider key here.")
		var address:LineEdit = addTextbox("ai_gateway_url")
		address.text = api_url
		var code:LineEdit = addTextbox("ai_gateway_code")
		code.text = game_access_code
		code.secret = true
		addButton("Save settings", "Keep gateway address and access code on this device", "save_settings")
		addButtonAt(14, "Back", "Return to conversation", "close_settings")
		return
	if(api_url == "" or game_access_code == ""):
		saynn("Set up your AI gateway first using 'Server settings'.")
	else:
		var start:int = max(0, transcript.size() - 10)
		for i in range(start, transcript.size()):
			var entry:Dictionary = transcript[i]
			var who:String = "You" if(entry.get("role", "") == "user") else npc.getName()
			saynn("[b]" + _safe_text(who) + ":[/b] " + _safe_text(str(entry.get("content", ""))))
	if(error_text != ""):
		saynn("[color=red]" + _safe_text(error_text) + "[/color]")
	if(busy):
		saynn("Waiting for the NPC to answer...")
	else:
		addBigTextbox("ai_chat_message")
		addButton("Send", "Send your message to the online AI", "send")
		addButton("Server settings", "Configure your private online AI gateway", "settings")
		if(transcript.size() > 0):
			addButton("Forget chat", "Delete this NPC's stored conversation on this device", "forget")
	addButtonAt(14, "Back", "Return to the game", "back")

func _react(_action:String, _args):
	if(_action == "back"):
		endScene()
		return
	if(_action == "settings"):
		editing_settings = true
		return
	if(_action == "close_settings"):
		editing_settings = false
		return
	if(_action == "save_settings"):
		var new_url:String = str(getTextboxData("ai_gateway_url")).strip_edges()
		if(!new_url.begins_with("https://")):
			error_text = "The gateway address must start with https://"
			return
		api_url = new_url.rstrip("/")
		game_access_code = str(getTextboxData("ai_gateway_code")).strip_edges()
		_save_settings()
		error_text = ""
		editing_settings = false
		return
	if(_action == "forget"):
		transcript.clear()
		conversations.erase(npcID)
		_save_history()
		error_text = ""
		return
	if(_action == "send"):
		_send_message()
		return

func _send_message():
	if(busy or npc == null):
		return
	if(api_url == "" or game_access_code == ""):
		error_text = "Configure the AI gateway first."
		return
	var message:String = str(getTextboxData("ai_chat_message")).strip_edges()
	if(message == ""):
		return
	if(message.length() > MAX_MESSAGE_LENGTH):
		message = message.substr(0, MAX_MESSAGE_LENGTH)
	var remote_history:Array = transcript.duplicate(true)
	remote_history.append({"role":"user", "content":message})
	while(remote_history.size() > MAX_SENT_TURNS):
		remote_history.pop_front()
	var payload:String = to_json({"npc_name":npc.getName(), "npc_role":_npc_role(), "messages":remote_history})
	var headers:PoolStringArray = PoolStringArray(["Content-Type: application/json", "x-game-token: " + game_access_code])
	var status:int = request_node.request(api_url, headers, true, HTTPClient.METHOD_POST, payload)
	if(status != OK):
		error_text = "Could not start network request (" + str(status) + ")."
		return
	transcript.append({"role":"user", "content":message})
	_trim_history()
	_save_history()
	error_text = ""
	busy = true

func _on_chat_reply(result:int, status_code:int, _headers:PoolStringArray, body:PoolByteArray):
	busy = false
	if(result != HTTPRequest.RESULT_SUCCESS):
		error_text = "Network failure (" + str(result) + "). Check Wi-Fi and gateway URL."
	elif(status_code != 200):
		error_text = "AI gateway responded with HTTP " + str(status_code) + "."
	else:
		var parsed:JSONParseResult = JSON.parse(body.get_string_from_utf8())
		if(parsed.error != OK or typeof(parsed.result) != TYPE_DICTIONARY or !parsed.result.has("reply")):
			error_text = "The gateway returned an invalid response."
		else:
			var reply:String = str(parsed.result["reply"]).strip_edges()
			if(reply == ""):
				error_text = "The AI returned an empty answer."
			else:
				transcript.append({"role":"assistant", "content":reply.substr(0, 1400)})
				_trim_history()
				_save_history()
				error_text = ""
	if(is_inside_tree() and !sceneEndedFlag):
		call_deferred("run")

func _npc_role() -> String:
	if(npc != null and npc.has_method("getNpcSlavery") and npc.getNpcSlavery() != null):
		return "player-owned slave"
	return "prison NPC"

func _safe_text(raw:String) -> String:
	# Prevent user- or model-generated BBCode injection in the game UI.
	return raw.replace("[", "(").replace("]", ")")

func _trim_history():
	while(transcript.size() > MAX_LOCAL_TURNS):
		transcript.pop_front()

func _load_settings():
	var settings = ConfigFile.new()
	if(settings.load(SETTINGS_FILE) == OK):
		api_url = str(settings.get_value("server", "url", ""))
		game_access_code = str(settings.get_value("server", "game_access_code", ""))

func _save_settings():
	var settings = ConfigFile.new()
	settings.set_value("server", "url", api_url)
	settings.set_value("server", "game_access_code", game_access_code)
	settings.save(SETTINGS_FILE)

func _load_history():
	conversations = {}
	var handle:File = File.new()
	if(handle.file_exists(HISTORY_FILE) and handle.open(HISTORY_FILE, File.READ) == OK):
		var parsed:JSONParseResult = JSON.parse(handle.get_as_text())
		handle.close()
		if(parsed.error == OK and typeof(parsed.result) == TYPE_DICTIONARY):
			conversations = parsed.result
	transcript = []
	if(conversations.has(npcID) and typeof(conversations[npcID]) == TYPE_ARRAY):
		transcript = conversations[npcID].duplicate(true)
	_trim_history()

func _save_history():
	conversations[npcID] = transcript.duplicate(true)
	var handle:File = File.new()
	if(handle.open(HISTORY_FILE, File.WRITE) == OK):
		handle.store_string(to_json(conversations))
		handle.close()

func saveData():
	var data = .saveData()
	data["ai_npc_id"] = npcID
	return data

func loadData(data):
	.loadData(data)
	npcID = str(SAVE.loadVar(data, "ai_npc_id", ""))
	_setup()
