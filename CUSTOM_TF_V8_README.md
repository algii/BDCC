# BDCC Custom TF v8 — Species selection

This is an incremental **gameplay-only** patch based on v7. It does not change the Android workflow; keep your working v5 Actions YAML.

## Added
- **Species: Unchanged / choose any playable species registered in BDCC**. The list is populated from the game's species registry (including playable modded species).
- Species changes morph the character's **body, head, arms, legs, ears, horns and tail** to that species' normal bodyparts using BDCC's existing transformation functions, and set the underlying species.
- The existing breast, penis type/length, vagina, body thickness, femininity and random-color choices remain independent. Species morphing does **not** reset these choices, hair, breasts, penis or vagina.
- Works for the player and **dynamic/procedural NPCs**. Static named/story NPCs may have hard-coded species and are not supported; their species menu is hidden.
- Unchanged = do not change species, and you may still change any other trait.

## Install
1. Extract the ZIP. Copy the **contents** of `BDCC-main` into the root of your cloned `algii/BDCC` GitHub Desktop project (same folder as `project.godot`). Replace the three matching scripts.
2. In GitHub Desktop: commit changes once, then Push origin.
3. GitHub Actions > `Build BDCC Custom TF Android` > Run workflow. Download the APK from Artifacts when green.

## Test
- Try a fresh or backed-up save.
- Inventory > TF pill > Species; select one species, then Consume.
- In a procedural dominant encounter, Drugs/Lube > Directed TF > Custom TF pill > Species; then confirm.
- Test with Species alone and then Species + custom penis/vagina. Verify save/reload.

## Notes
- Permanent, direct edits, not timed TF stages; the TF Undo pill will not reverse them.
- Visuals depend on the chosen species' registered default parts and existing 3D assets.
- These files have been structurally checked, but are not runtime-tested in Godot/Android.
