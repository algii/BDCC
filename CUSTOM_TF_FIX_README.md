# BDCC Custom TF – gameplay repair

Based on the original project code in the uploaded BDCC-main ZIP.

Replaces only two scripts and adds one shared helper. **Do not roll back the working v5 Android workflow.**

## What changed
- Vanilla NPC drug actions remain as in the original game. The old experimental interception is removed.
- For NPCs, during procedural sex as a player dominant, choose **Drugs/Lube → Directed TF → Custom TF pill**, choose attributes and **Give custom TF pill**.
- For the player, use a TF pill through the regular Inventory → Consume interaction: a choice menu opens before the item is consumed.
- The standard, original NPC TFPill choice remains available and uses random transformations. Select the new **Custom TF pill** option for directed changes.
- Chosen changes are direct, permanent bodypart edits, **not temporary TF stages**. TFUndo does not reverse these edits.
- No selection consumes no pill until the final confirmation. Cancel keeps the pill.
- Other drugs keep their original behavior.

## Install
Extract the patch ZIP, copy the contents of `BDCC-main` into the local GitHub Desktop BDCC project root (the folder containing `project.godot`), replace the old DomDrugUse script, commit and push. Re-run the existing Android GitHub Action (v5) to produce the APK.

## Testing
Static patch checks were performed; **this was not compiled or runtime-tested in Godot**. Back up saved games and test first on a new save.
