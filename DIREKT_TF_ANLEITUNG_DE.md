# BDCC – gezielte NPC-Transformationen (direkt im Spielcode)

Dieses Paket ist der vollstaendige, vom Nutzer hochgeladene BDCC-Quellcode, mit einer gezielten Aenderung der vorhandenen Datei `Game/SexEngine/SexActivity/DomDrugUse.gd`.

## Funktionen

- Wenn der Spieler einem NPC im prozeduralen Sex-System eine `TFPill` gibt und diese geschluckt wird, erscheint ein Auswahlmenue.
- Brustgroesse: von flach bis O-Cup
- Penistyp: erhalten, entfernen, menschlich, Hund, Katze, Pferd, Drache oder Ovipositor
- Penislaenge: erhalten oder 5 bis 50 cm (Auswahlwerte)
- Mehrere Einstellungen kombinierbar. Nicht ausgewaehlte Merkmale bleiben unveraendert.
- NPCs werden mit den bestehenden Godot-BDCC-Koerpermodellen aktualisiert.
- Unveraendert: originale Grafik, Story und sonstige Spielmechaniken.

## Wichtig

- Dieses ZIP ist **KEINE APK**. Es ist ein komplettes Godot-3.6.2-Quellcodeprojekt mit eingebauter Aenderung.
- Es basiert auf der vom Nutzer gelieferten GitHub-Archivversion (Commit `13df5378dbd24c9d1cef012db3ff89457f334130`, 2026-08-04; das archivierte CHANGELOG zeigt 0.3.0). Es wird NICHT garantiert, dass dies die neueste offiziell veroeffentlichte Version ist.
- Die Spielaenderung wurde statisch geprueft, aber nicht in Godot kompiliert oder auf einem Smartphone getestet. Spielstaende vorher sichern.
- Betrifft das prozedurale Sexsystem. Nicht automatisch alle Story-Dialoge oder Skript-Szenen.

## APK aus dem Projekt bauen

1. ZIP entpacken und den Inhalt des Ordners `BDCC-main` in ein GitHub-Repository legen.
2. Im GitHub-Repository auf **Actions** -> **Build BDCC Custom TF Android** -> **Run workflow** gehen.
3. Nach erfolgreichem Build die Datei **BDCC-Custom-TF-Android-APK** aus den Workflow-Artifacts laden.
4. Darin liegt `BDCC_Custom_TF.apk`, sofern der Build erfolgreich war.

Voraussetzungen: GitHub Actions muss aktiviert sein, Upload aller Quelldateien, mindestens ein erfolgreicher Android-Build. Die Workflow-Datei verwendet den Godot-CI-Container mit Godot 3.6.2; der tatsächliche Export wurde hier nicht getestet.

**Installationshinweis:** Der Workflow verwendet die separate Android-Paketkennung `org.rahimew.bdcc.directedtf`, damit das originale BDCC installiert bleiben kann. Die vorhandenen Spielstaende werden dadurch nicht automatisch uebernommen. Vorher ein Backup / Save-Export im Originalspiel erstellen.

Urheber: BDCC/RahiMew und Mitwirkende; Originalprojekt https://github.com/Alexofp/BDCC. Alle sonstigen Inhalte aus dem vom Nutzer bereitgestellten Quellarchiv.
