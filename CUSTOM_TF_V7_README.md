# BDCC Custom TF v7 — expanded body customization

This patch **builds on the working v6 gameplay patch**. It does not modify the Android GitHub workflow (keep working v5).

## New options (player inventory TF pill AND NPC Custom TF pill)
- Body thickness: 0–150%, in 10% increments; or unchanged.
- Femininity/masculinity: 0% (masculine) to 100% (feminine), in 10% increments; or unchanged.
- Vagina: unchanged, add a standard vagina, add egg-laying vagina, or remove.
- Skin/color: unchanged, randomize body colors, randomize base skin pattern and colors, or randomize all body and bodypart colors/patterns. The random choice is **triggered once** on pill consumption, not periodically.
- Still available from v6: breasts flat–O, penis (6 native types, remove, unchanged), penis length 5–50 cm.
- All selections are **independent**; selecting a vagina does not remove a penis. Non-selected traits stay as they are.

## Installing
1. Extract this ZIP. Copy the **contents** of `BDCC-main` over the root of your local GitHub Desktop BDCC clone (where `project.godot` exists).
2. Replace the existing three game scripts and commit/push.
3. Run the previously successful **Build BDCC Custom TF Android** workflow, download the Android artifact and install.

## Using
- Player: Inventory > TF pill > Consume; select traits > Consume with selected changes.
- NPC: Procedural encounter when playing dominant > Drugs/Lube > Directed TF > Custom TF pill; select traits > Give custom TF pill.
- The original vanilla NPC pill action still exists and stays random. Use the **Custom TF pill** action for choices.

## Notes
- Effects are *direct permanent body edits*, not staged transformations. TF Undo won't reverse them. Back up saves.
- Random colors are generated using BDCC's own methods; visual effect may vary between bodyparts and skin types.
- Confirm the edit in-game on a disposable save. The scripts were statically checked but not runtime-tested inside Godot/Android.
