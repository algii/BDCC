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
const THICKNESS_VALUES = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]
const FEMININITY_VALUES = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
const VAGINA_TYPES = [
    ["vagina", "Standard vagina"],
    ["vaginaEggs", "Egg-laying vagina"],
]
const COLOR_MODES = [
    ["colors", "Random body colors"],
    ["skin", "Random skin pattern and colors"],
    ["all", "Random full-body colors and patterns"],
]

# Read the playable species dynamically so modded species appear too.
static func get_species_options() -> Array:
    var options:Array = []
    for species_id in GlobalRegistry.getAllPlayableSpecies():
        var species = GlobalRegistry.getSpecies(species_id)
        if(species != null):
            options.append([species_id, str(species.getVisibleName())])
    return options

static func species_label(species_id:String) -> String:
    if(species_id == ""):
        return "Unchanged"
    for entry in get_species_options():
        if(entry[0] == species_id):
            return entry[1]
    return "Unchanged"

# Use the game's native bodypart transformation functions; do not reset
# genitalia, hair or breasts when species is changed.
static func apply_species(target:BaseCharacter, species_id:String) -> bool:
    if(!GlobalRegistry.getAllPlayableSpecies().has(species_id)):
        return false
    # Static story NPCs can have fixed, script-defined species; changing the
    # species field for them is not supported by their existing game API.
    if(!(target is DynamicCharacter) && !target.has_method("setSpecies")):
        return false
    var the_species = GlobalRegistry.getSpecies(species_id)
    if(the_species == null):
        return false
    var npc_gender = target.calculateNpcGender()
    var morph_slots:Array = [BodypartSlot.Body, BodypartSlot.Head, BodypartSlot.Arms, BodypartSlot.Legs, BodypartSlot.Ears, BodypartSlot.Horns, BodypartSlot.Tail]
    for slot in morph_slots:
        var part_id = the_species.getDefaultForSlotForNpcGender(slot, npc_gender)
        if(part_id is String && part_id != "" && GlobalRegistry.getBodypartRef(part_id) != null):
            if(target.getBodypartID(slot) != part_id):
                target.applyTFBodypart(slot, {"bodypartID": part_id})
        elif(part_id == null && !BodypartSlot.isEssential(slot) && target.hasBodypart(slot)):
            target.removeBodypart(slot, false)
    target.applyTFData({"species": [species_id]})
    if(target is DynamicCharacter):
        target.npcCustomSpeciesName = ""
    return true

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

static func thickness_label(value:int) -> String:
    return "Unchanged" if value < 0 else str(value) + "%"

static func femininity_label(value:int) -> String:
    if(value < 0):
        return "Unchanged"
    var descriptor:String = "balanced"
    if(value < 50):
        descriptor = "masculine"
    elif(value > 50):
        descriptor = "feminine"
    return str(value) + "% (" + descriptor + ")"

static func vagina_label(vagina_id:String) -> String:
    if(vagina_id == ""):
        return "Unchanged"
    if(vagina_id == "remove"):
        return "Remove vagina"
    for entry in VAGINA_TYPES:
        if(entry[0] == vagina_id):
            return entry[1]
    return "Unchanged"

static func color_label(mode:String) -> String:
    if(mode == ""):
        return "Unchanged"
    for entry in COLOR_MODES:
        if(entry[0] == mode):
            return entry[1]
    return "Unchanged"

static func apply_changes(target:BaseCharacter, breast_size:int, penis_id:String, length_cm:float, thickness:int = -1, femininity:int = -1, vagina_id:String = "", color_mode:String = "", species_id:String = "") -> Array:
    var descriptions:Array = []
    if(target == null):
        return descriptions
    # Apply species first; specific choices below can override the new form.
    if(species_id != "" && apply_species(target, species_id)):
        descriptions.append("species " + species_label(species_id))
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
    # The game stores thickness and femininity in its existing character stats.
    if(thickness >= 0 && thickness <= 150):
        target.setThickness(thickness)
        descriptions.append("thickness " + str(thickness) + "%")
    if(femininity >= 0 && femininity <= 100):
        target.setFemininity(femininity)
        descriptions.append("femininity " + str(femininity) + "%")
    # Genital slots are independent: adding a vagina does not remove a penis.
    if(vagina_id == "remove"):
        if(target.hasBodypart(BodypartSlot.Vagina)):
            target.removeBodypart(BodypartSlot.Vagina)
            descriptions.append("vagina removed")
    elif(vagina_id in ["vagina", "vaginaEggs"] && GlobalRegistry.getBodypartRef(vagina_id) != null):
        if(!target.hasBodypart(BodypartSlot.Vagina) || target.getBodypart(BodypartSlot.Vagina).id != vagina_id):
            var new_vagina = GlobalRegistry.createBodypart(vagina_id)
            if(new_vagina != null):
                target.giveBodypart(new_vagina)
                descriptions.append(vagina_label(vagina_id))
    # Only explicitly chosen randomization uses RNG. It runs once on confirmation.
    if(color_mode == "colors"):
        target.applyRandomColors()
        descriptions.append("random body colors")
    elif(color_mode == "skin"):
        target.applyRandomSkinAndColors()
        descriptions.append("random skin and colors")
    elif(color_mode == "all"):
        target.applyRandomSkinAndColorsAndParts()
        descriptions.append("random full-body skin and colors")
    if(!descriptions.empty()):
        target.updateAppearance()
    return descriptions
