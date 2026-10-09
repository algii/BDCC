# BDCC AI Chat safe launch test v10.3

This patch replaces **only two** existing scripts: `Scenes/LookingAroundScene.gd` and `Modules/NpcSlaveryModule/Slavery/SlaveTalkScene.gd`. It does not change custom TF, slave domination, build workflows, or `AINpcChatScene.gd`.

## Why v10.2 may have broken Look Around

v10.2 added an eager `preload()` of the experimental AI scene into the core NPC menu. If that new script fails to load or parse, the main menu can stop functioning. v10.3 removes both eager preloads. The AI script is loaded only after clicking AI Chat; if loading fails, ordinary NPC menus remain available and an explicit in-game error text is shown.

## Install

1. Make a backup of the last working APK and your game save files.
2. If convenient, revert the single v10.2 commit in GitHub Desktop (History > right-click commit > Revert this commit); push.
3. Copy the contents of `BDCC-main/` into the project directory containing `project.godot`. Replace the two matching files.
4. Commit and push, then run the existing Android workflow.
5. Test `Look Around` first, then `Look Around > AI Chat > NPC`.
6. If the chat shows an unavailable message, share the game's GDScript error log. The AI scene itself may have a separate issue requiring a targeted fix.

## Status

Syntax and structural checks were performed; it has not been run in Godot or on Android. This is a stability/diagnostics patch, not a guaranteed complete fix for AI Chat.
