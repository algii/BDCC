extends SlaveActionBase

# Adds a new option; no existing action is replaced.
func _init():
	id = "ActionCustomSlaveDomPlayer"
	actionType = Action
	sceneID = "ActionCustomSlaveDomPlayerScene"
	slaveMinLevel = 0
	slaveSkillsRequired = {}
	onlyShowWhenHaveRequiredSkills = false
	# The player is requesting this interaction, so don't roll the usual resistance encounter.
	slaveResistChanceMult = 0.0
	endsTalkScene = true
	buttonPriority = 95

func getVisibleName():
	return "Let slave dominate you"

func getVisibleDesc():
	return "Invite this slave to take the dominant role while you take the submissive role."
