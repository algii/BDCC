# BDCC Custom AI Chat v10.1 — menu visibility fix

Use this patch **after v10** (or over an existing v10 installation). It is designed to make AI Chat easier to find; it does **not** connect an AI provider automatically.

Changes:
- `Look Around` now has a visible `AI Chat` selection action for nearby NPC pawns.
- `Look Around > Focus > AI Chat` still exists.
- The slave's main interaction screen shows `AI Chat` even when the NPC is away or performing an activity that otherwise hides normal buttons.
- The slave's `Talk` submenu also shows `AI Chat`.
- Includes `AINpcChatScene.gd` so the chat scene file is present if it was missed in the previous copy.
- No changes to v8 TF, v9 domination, other gameplay, the Android workflow, or the server worker.

Installation:
1. Back up saves and your working GitHub branch.
2. Open GitHub Desktop > Repository > Show in Explorer.
3. Copy the **contents** of this ZIP's `BDCC-main` folder over your BDCC project folder (where `project.godot` is).
4. Commit changes and push to your GitHub repository.
5. Rebuild using the **working** Android workflow and install the resulting APK.
6. Check `Look Around > AI Chat` or open an owned slave > `AI Chat` / `Talk > AI Chat`.
7. Configure the separately deployed online AI gateway under `AI Chat > Server settings`; without this, the menu opens but cannot return AI responses.

Scope limitations:
- Regular named story character menus are not modified; `Look Around` works with nearby **pawn** NPCs, not every scripted encounter.
- The features have not been run inside Godot/Android in this environment. GitHub's green build does not prove in-game functionality.
