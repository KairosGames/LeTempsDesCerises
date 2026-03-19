# Guidelines

> En ayant lu ce titre vous avez déjà accepté de respecter ces conventions et avez accepté les sanctions qui résultent du non-respect de celles-ci.

## Project Structure

- game/app _contient le projet principal (ex: Godot game)_
  - addons _librairies tiers_
  - editor _outils editeur_
  - materials
    - shaders
  - prefabs
    - _ex: entities_
    - _ex: ui_
    - _ex: geometry_
  - scenes _scènes principales du projet (ex: main.tscn, boot.tscn, world.tscn)_
  - scripts
  - sources _assets bruts_
    - fonts
    - images
      - icons _symboles, souvent 2d et vectoriel (ex: settings.svg, xbox_south_button.svg, ...)_
      - textures _décoratif, souvent 3d et matriciel (ex: brick_albedo.png, brick_normal.png, brick_ao.png, ...)_
    - meshes _mailiages file as .blend, obj, gtlf, or fbx_
    - sounds
      - effects
      - musics
      - banks _pour les banque de son générées (e.g fmod, wwise)_
- sources _fichier source des assets (ex: .blend, .psd, wwise project)_
- wiki _documentation_

## Assets Format

- images doivent être vectorial .svg dès que c'est possible

## Naming Conventions

- english
- snake_case for all files

## Godot References

- ne pas référencer par chemin: "res://"
- toujours utiliser les identifiants uniques "uid://"

## Git

> ⚠️ quand git stocke quelque chose c'est pour toujours donc choisez judicieusement ce que vous importez

> ⚠️ git lfs: git ne peut manipuler facilement les gros fichiers. LFS stocke les fichiers lourds et git stocke une référence à LFS.

### Main Branch

- main _perfect branch without error or warning and always ready_
- dev _main work branch where everything is merged and source of all new branch_
- sandbox/name _each team member can create it own branch as sandbox for testing_

### Branch Naming

⏳ PREFIX-JIRA_ID-NOM_COURT

- pas d'espaces
- \- entre les composants
- snake_case pour les composants

#### Prefix

- F Feature: ajoute ou modifier quelque chose (ex: création du character, amélioration des mouvements de caméra)
- M Maintenance: ne change rien au jeu mais garde le projet en bonne santé (ex: tri de fichier, renommage)
- B Bug Fix: Corrige un bug (ex: corrige crash du jeu sur linux, ajout d'une texture manquante)

#### Jira ID

Identifiant de tache Jira lié à la tâche

#### Nom court

probablement le même que celui du ticket jira

## Code

- utiliser le gdscript comme language de programation

```gdscript
func _private_function() -> void:
	pass
```
