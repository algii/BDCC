# BDCC AI Chat launch fix v10.2

**Problem addressed:** AI Chat shows nearby NPC names, but selecting a name returns to Look Around instead of showing the chat interface.

**Changes:**
- Adds a hard `preload()` reference to the AI chat script, making it an explicit dependency for Android export.
- Explicitly registers `AINpcChatScene` via `GlobalRegistry.registerTemporaryScene()` before opening it. This does not depend on an exported directory listing recognizing new `.gd` files.
- Opens AI Chat as a **child** scene. When you close it, you return to Look Around or the slave interaction menu.
- Validates the selected NPC ID before trying to open the scene.
- Does NOT change your TF pills, species editing, v9 domination interactions, Android build workflow, or AI server code.

## Installation
1. Back up your saves and commit your working v10.1 state.
2. Extract this archive.
3. Copy the *contents* of `BDCC-main` into your local BDCC GitHub Desktop repository where `project.godot` is located, merging and replacing the three listed files.
4. Commit and Push in GitHub Desktop.
5. Rebuild with your working GitHub Actions Android workflow.
6. Install the APK. Try **Look Around > AI Chat > NPC name**. You should see **AI Chat: [name]** and **Server settings** even though the AI service is not connected yet.
7. Also test a slave's **AI Chat** entry.

**Status:** Structural checks passed. Not yet tested in Godot or on an Android device. If it still returns to Look Around, provide the game's GDScript error log; it could be a script initialization error rather than missing scene registration.
