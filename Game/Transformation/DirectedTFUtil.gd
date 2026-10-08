extends Reference

# Shared, opt-in transformation choices for the player and NPCs.
# Direct bodypart edits are permanent; they do not use the random TF-stage system.
const PENIS_TYPES = [
    ["humanpenis", "Human"],
    ["caninepenis", "Canine"],
    ["felinepenis", "Feline"],
    ["equinepenis", "Equine"],
    ["dragonpenis", "Dragon"],
    ["ovipositorpenis", "Ovipositor"],
]
const PENIS_LENGTHS = [5, 8, 10, 12, 15, 18, 20, 25, 30, 40, 50]

static func breast_label(size:int) -> String:
    return "Unchanged" if size == -999 else BreastsSize.breastSizeToString(size)

static func penis_label(penis_id:String) -> String:
    if(penis_id == ""):
        return "Unchanged"
    if(penis_id == "remove"):
        return "Remove"
    for entry in PENIS_TYPES:
        if(entry[0] == penis_id):
            return entry[1]
    return "Unchanged"

static func length_label(length_cm:float) -> String:
    return "Unchanged" if length_cm <= 0 else str(length_cm) + " cm"

static func apply_changes(target:BaseCharacter, breast_size:int, penis_id:String, length_cm:float) -> Array:
    var descriptions:Array = []
    if(target == null):
        return descriptions
    if(breast_size >= BreastsSize.FLAT && breast_size <= BreastsSize.O):
        if(!target.hasBodypart(BodypartSlot.Breasts)):
            var new_breasts = GlobalRegistry.createBodypart("humanbreasts")
            if(new_breasts != null):
                target.giveBodypart(new_breasts)
        if(target.hasBodypart(BodypartSlot.Breasts)):
            target.getBodypart(BodypartSlot.Breasts).setBreastSizeSafe(breast_size)
            descriptions.append("breasts " + BreastsSize.breastSizeToString(breast_size))
    if(penis_id == "remove"):
        if(target.hasBodypart(BodypartSlot.Penis)):
            target.removeBodypart(BodypartSlot.Penis)
            descriptions.append("penis removed")
    elif(penis_id != "" && GlobalRegistry.getBodypartRef(penis_id) != null):
        var new_penis = GlobalRegistry.createBodypart(penis_id)
        if(new_penis != null):
            if(target.hasBodypart(BodypartSlot.Penis)):
                var old_penis = target.getBodypart(BodypartSlot.Penis)
                new_penis.lengthCM = old_penis.lengthCM
                new_penis.ballsScale = old_penis.ballsScale
            target.giveBodypart(new_penis)
            descriptions.append("penis type " + penis_label(penis_id))
    if(length_cm > 0 && target.hasBodypart(BodypartSlot.Penis)):
        target.getBodypart(BodypartSlot.Penis).lengthCM = clamp(length_cm, 4.0, 50.0)
        descriptions.append("penis length " + str(length_cm) + " cm")
    if(!descriptions.empty()):
        target.updateAppearance()
    return descriptions
