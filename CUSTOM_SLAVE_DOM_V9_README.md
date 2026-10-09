# BDCC – Slave Domination Add-on (v9)

This is an additive patch for the existing BDCC project (including Custom TF v8).
It changes **no existing source files**. It adds four new Godot/GDScript files:

- `Game/NpcSlavery/SlaveActions/ActionCustomSlaveDomPlayer.gd`
- `Game/NpcSlavery/SlaveActions/ActionCustomTwoSlavesDomPlayer.gd`
- `Game/NpcSlavery/SlaveActionScenes/Prostitution/ActionCustomSlaveDomPlayerScene.gd`
- `Game/NpcSlavery/SlaveActionScenes/Prostitution/ActionCustomTwoSlavesDomPlayerScene.gd`

BDCC scans these two existing directories automatically when registering slave actions and scenes, so no changes to `GlobalRegistry.gd` are needed.

## In-game
Talk to one of your slaves and open the usual **Actions** area.

- **Let slave dominate you** – one selected slave takes the dominant role.
- **Let two slaves dominate you** – BDCC's existing second-slave picker prompts you to choose a second slave; both take the dominant role, and the player is the submissive participant.

Each new encounter has a **Cancel** button before it starts. Other bystanders won't join automatically. The base sex engine controls activity and exit rules once it begins.

For the two-slave mode, the second slave can't be busy or have hands/arms/legs fully restrained or be gagged. The main slave follows BDCC's normal action eligibility and encounter rules.

## Installation
1. Back up your saves and repository.
2. Extract this ZIP. Copy only the **contents** of `BDCC-main` into your cloned BDCC repository, alongside `project.godot`.
3. In GitHub Desktop: `Commit to main` then `Push origin`.
4. Run your **existing working Android build workflow** in GitHub Actions and download the APK under Artifacts.

## Notes
- No change to Custom TF pills, inventory, existing slave actions, or the Android workflow.
- The scripts were checked structurally, but **no complete Godot Android build or in-game test** was possible here.
- If GitHub Actions fails, send the first `SCRIPT ERROR`/`Parse Error` with a few surrounding lines.
- When installing a newly signed debug APK, Android may refuse to overwrite a differently signed installation; back up saves first.
