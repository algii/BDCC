# BDCC AI Chat v10.4 – one-line parse fix

The Android debug log reports:
- `AINpcChatScene.gd:63` – Narrowing conversion (float to int; warning treated as error)
- Consequently: AI scene registration fails, so clicking AI Chat returns to Look Around.

## Fix
Change `var start:int = max(0, transcript.size() - 10)` to
`var start:int = int(max(0, transcript.size() - 10))` in `Scenes/AINpcChatScene.gd`.
This explicitly converts the result to `int`, avoiding the compiler's narrowing warning.

## Install (based on the working v10.1 build after reverting v10.2/v10.3)
1. Extract this ZIP.
2. Open your local BDCC repository in GitHub Desktop -> Repository -> Show in Explorer.
3. Copy `BDCC-main/Scenes/AINpcChatScene.gd` from this ZIP to `<your BDCC repo>/Scenes/AINpcChatScene.gd`, replacing the old file.
4. Verify GitHub Desktop -> Changes shows ONLY `Scenes/AINpcChatScene.gd` (unless you have your own unrelated work).
5. Commit, push, and run your existing Android build workflow.
6. Test Look Around -> AI Chat -> NPC; expect the AI Chat interface with Server settings.

The game should show the chat interface without a configured online server. Actual replies still require a gateway.
This patch has not been tested on a device or compiled with Godot in this environment.
If a new issue occurs, export the latest BDCCDebug.txt and inspect the FIRST script error.
