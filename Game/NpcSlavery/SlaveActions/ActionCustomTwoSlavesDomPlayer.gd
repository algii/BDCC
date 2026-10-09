extends SlaveActionBase

# Uses BDCC's existing second-slave selection UI.
func _init():
	id = "ActionCustomTwoSlavesDomPlayer"
	actionType = Action
	sceneID = "ActionCustomTwoSlavesDomPlayerScene"
	slaveMinLevel = 0
	slaveSkillsRequired = {}
	onlyShowWhenHaveRequiredSkills = false
	slaveResistChanceMult = 0.0
	endsTalkScene = true
	buttonPriority = 94
	extraSlaves = {
		"dom2": {
			name = "Second slave",
			desc = "Choose another of your slaves to take the dominant role together with the first.",
			slaveSkillsRequired = {},
			slaveMinLevel = 0,
		}
	}

func getVisibleName():
	return "Let two slaves dominate you"

func getVisibleDesc():
	return "Choose a second slave, then give both slaves the dominant role while you take the submissive role."

func fitsAsExtraSlaveAdvanced(_role, _charID):
	if(_role == "dom2"):
		var character:BaseCharacter = GlobalRegistry.getCharacter(_charID)
		if(character == null):
			return [false, "This slave is unavailable."]
		if(character.hasBoundArms() || character.hasBlockedHands() || character.isGagged() || character.hasBoundLegs()):
			return [false, "Remove the second slave's restrictive equipment first."]
	return .fitsAsExtraSlaveAdvanced(_role, _charID)
