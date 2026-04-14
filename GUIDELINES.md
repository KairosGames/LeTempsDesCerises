# Guidelines

> Version 1.1.0

> En ayant lu ce titre vous avez déjà accepté de respecter ces conventions et avez accepté les sanctions qui résultent du non-respect de celles-ci.

> ⚠️ Si vous ne comprenez pas ou n'êtes pas d'accord avec ces lignes directrices, contactez immédiatement votre développeur le plus proche !

## Structure du Projet

---

- game/app _contient le projet principal (ex: Godot game)_
  - addons _librairies tiers_
  - editor _outils editeur_
  - materials _contient les materials partagés_
    - shaders _contient les shaders partagés_
  - prefabs
    - _ex: entities_
    - _ex: ui_
    - _ex: geometry_
  - scenes _scènes principales du projet (ex: main.tscn, boot.tscn, world.tscn)_
  - scripts _contient les scripts partagés_
  - sources _assets bruts partagés_
    - fonts
    - images
      - icons _symboles, souvent 2d et vectoriel (ex: settings.svg, xbox_south_button.svg, …)_
      - textures _décoratif, souvent 3d et matriciel (ex: brick_albedo.png, brick_normal.png, brick_ao.png, …)_
    - meshes _maillages en .obj ou .gtlf_
    - sounds
      - banks _pour les banque de son générées (e.g fmod, wwise)_
- sources _fichier source des assets (ex: .blend, .psd, wwise project)_
- wiki _documentation_

> Les resources doivent être stockés au plus proche de leur lieu d'utilisation dans l'arborescence de fichier et ne remonter dans l'arborescence que pour être communes à plusieurs scènes.

> ⚠️ les resources peuvent et doivent si nécessaire être stockées dans les scènes.

## Format des Assets

---

- images doivent être vectorial .svg dès que c’est possible
- images matriciel doivent avoir une résolution qui soit puissance de 2 (512, 1024, 2048, 4096)
- ne pas inclure de .blend directement dans le projet Godot, les exporter en gltf

## Godot

---

### Nomenclature des Nodes

- PascaleCase

### Nomenclature des fichiers

- english
- snake_case for all files

### References dans Godot

- ne pas référencer par chemin: “res://”
- toujours utiliser les identifiants uniques “uid://”

### Code

---

#### Languages

- ? utiliser le gdscript comme language de programation

#### Conventions

```gdscript
# nom_de_classe.gd # Fichier en snake_case
class_name PascalCase # Nom de classe en PascalCase

signal health_updated # snake_case et au passé

@export var max_health: float # variable publique en snake_case
var health: float: # variable publique en snake_case
	set(value):
		health = value
		health_updated.emit()

const CONSTANTE: String # variable constante en UPPPER_CASE

var _private_snake_case: int  # variable privée en snake_case préfixé par '_'

func public_function() -> bool:
	return true

func _private_function() -> void:
	pass # ne pas specifier le pass si ce n'est pas nécessaire

func _on_snake_cased() -> void:
	pass

# UPPPER_CASE pour les membre de l'énumération
# _COUNT_ est optionel et entouré de underscore si présent
# NONE est optionel
enum Element { NONE, FIRE, WATER, WIND, _COUNT_ }

class Stat: #
	var a: int
```

## Git

---

> ⚠️🔥 ne jamais renommer un fichier pour changer la case (ex: Fichier.txt -> fichier.txt) 🔥⚠️

> quand git stocke quelque chose c’est pour toujours donc choisissez judicieusement ce que vous importez

### Large File Storage

> git large file storage: git ne peut manipuler facilement les gros fichiers. LFS stocke les fichiers lourds et git stocke une référence à LFS.

Doivent être stocké en LFS:

- \*.mp4
- \*.png
- \*.bnk

> cette liste peut être amenée à grandir avec le temps

### Branches Principales

- main _branche parfaite sans erreur ni avertissement et toujours prête créée à partir des versions stables de dev_
- dev _branche de travail principale où tout est fusionné et source de toute nouvelle branche_
- f/\* _branche de feature basée sur dev_
- m/\* _branche de maintenance basée sur dev_
- b/\* _branche de bugfix basée sur dev_

### MR/PR Review

Pour que le travail des différents membres soit ajouté à la branche principale (dev):

- il doit se trouver dans un branche de feature, maintenance, ou bugfix
- doit demander à être merge (Pull Request).
- la PR sera validée par un des dev et pourra faire l’objet d’une demande de modification avant de pouvoir être mergé.

### Nomenclature des Branches

prefix/short-and-descriptive_name

- english only
- ‘/’ entre les composants
- kebab-case pour les composants (pas d’espaces)

#### Prefixes

- ‘f’ pour Feature: ajoute ou modifier quelque chose (ex: création du character, amélioration des mouvements de caméra)
- ‘m’ pour Maintenance: ne change rien au jeu mais garde le projet en bonne santé (ex: tri de fichier, renommage)
- ‘b’ pour Bug Fix: Corrige un bug (ex: corrige crash du jeu sur linux, ajout d’une texture manquante)

#### Exemples

- f/character-controller
- f/camera-prototype
- m/migrate-event-manager-signals-to-game-manager
- b/fix-missing-textures
- b/fix-pause-menu-crash

### Nomenclature des Commit

Structure: ACTION OBJECT

Examples:

- create character prefab
- create character controller
- create fps camera
- rename StaticManager to EventManager
