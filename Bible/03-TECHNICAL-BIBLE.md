# VOLUME 3 — TECHNICAL BIBLE
## PROJECT ABERRATION — AI-First Game Development Bible

**Versione:** 1.0  
**Data:** 15 Luglio 2026  
**Status:** ACTIVE  
**Scope:** Godot 4.4+, Architecture, Performance, Code Standards

---

## 1. ENGINE: GODOT 4.4+

### 1.1 Perché Godot

| Vantaggio | Dettaglio |
|-----------|-----------|
| Open Source | Nessuna licenza, nessun costo |
| GDScript | Velocissimo da produrre |
| Scene System | Modulare e componibile |
| Node System | Architettura pulita |
| Export | PC, Android, iOS, Web, Linux, Mac |
| Rendering | Stylized horror perfetto |
| Community | Attiva e in crescita |

### 1.2 Perché NON Unity

| Problema | Impatto |
|----------|---------|
| Package Manager | Overhead, dipendenze |
| URP/HDRP | Complessità inutile |
| Versioni | Conflitti frequenti |
| Plugin | Costi, licenze |
| Build | Più lento |

### 1.3 Configurazione Godot

**Project Settings:**
```
Renderer: Forward+
Rendering Method: mobile
Quality Default: Medium
Anti-aliasing: FXAA
Shadows: Soft shadows, low resolution
SSAO: Off (o very low)
Bloom: Low
```

**Export Presets:**
- Windows: Desktop, OpenGL3
- Linux: Desktop, OpenGL3
- iOS: Mobile, Metal
- Android: Mobile, Vulkan

---

## 2. ARCHITETTURA

### 2.1 Principi

1. **Component Based** — Ogni entità è un insieme di componenti
2. **Event Driven** — Comunicazione via segnali
3. **Modulare** — Ogni sistema indipendente
4. **Data Driven** — Configurazione in risorse, non in codice
5. **No God Classes** — Ogni classe fa una cosa sola

### 2.2 Scene Tree

```
Root (Main)
├── World
│   ├── Terrain
│   ├── Lighting
│   ├── Props
│   └── Triggers
├── Player (Aberration)
│   ├── Body
│   ├── Camera
│   ├── AnimationPlayer
│   ├── CollisionShape
│   ├── Components/
│   │   ├── HealthComponent
│   │   ├── MovementComponent
│   │   ├── CombatComponent
│   │   ├── FrenesiaComponent
│   │   └── MutationComponent
│   └── Abilities/
│       ├── MeleeAttack
│       ├── NailLaunch
│       ├── Scream
│       └── Grab
├── Enemies
│   ├── Infantry
│   ├── Shield
│   ├── Flamethrower
│   ├── Sniper
│   ├── Engineer
│   ├── Medic
│   ├── Heavy
│   ├── Drone
│   ├── Robot
│   └── Elite
├── Managers
│   ├── GameManager
│   ├── EnemyManager
│   ├── WaveManager
│   ├── SpawnManager
│   ├── AudioManager
│   ├── VFXManager
│   └── PoolManager
├── UI
│   ├── HUD
│   ├── PauseMenu
│   ├── SettingsMenu
│   └── LoadingScreen
└── Systems
    ├── EventSystem
    ├── SaveSystem
    ├── SettingsSystem
    └── LocalizationSystem
```

### 2.3 Folder Structure

```
res://
├── scenes/
│   ├── player/
│   ├── enemies/
│   ├── levels/
│   ├── ui/
│   ├── effects/
│   └── props/
├── scripts/
│   ├── player/
│   ├── enemies/
│   ├── systems/
│   ├── managers/
│   ├── components/
│   ├── abilities/
│   └── utils/
├── resources/
│   ├── characters/
│   ├── weapons/
│   ├── mutations/
│   ├── waves/
│   └── settings/
├── assets/
│   ├── sprites/
│   ├── models/
│   ├── textures/
│   ├── audio/
│   │   ├── music/
│   │   ├── sfx/
│   │   └── voice/
│   └── fonts/
├── shaders/
│   ├── horror/
│   ├── blood/
│   └── ui/
└── data/
    ├── waves/
    ├── enemies/
    └── dialogue/
```

---

## 3. NAMING CONVENTIONS

### 3.1 Files

| Tipo | Formato | Esempio |
|------|---------|---------|
| Scene | snake_case.tscn | player.tscn |
| Script | snake_case.gd | player.gd |
| Resource | snake_case.tres | player_stats.tres |
| Shader | snake_case.gdshader | blood_splatter.gdshader |
| Texture | snake_case.png | player_idle.png |
| Audio | snake_case.wav | claw_hit.wav |

### 3.2 Nodes

| Tipo | Formato | Esempio |
|------|---------|---------|
| Player | PascalCase | PlayerBody |
| Enemy | PascalCase + Type | InfantrySoldier |
| Manager | PascalCaseManager | EnemyManager |
| Component | PascalCaseComponent | HealthComponent |
| UI | PascalCase + UI | HUD_UI |
| Marker | snake_case | spawn_point_01 |

### 3.3 Variables

| Tipo | Formato | Esempio |
|------|---------|---------|
| Public | snake_case | move_speed |
| Private | _snake_case | _current_hp |
| Constant | UPPER_SNAKE | MAX_SPEED |
| Enum | PascalCase | EnemyState |
| Signal | snake_case | health_changed |

### 3.4 Functions

| Tipo | Formato | Esempio |
|------|---------|---------|
| Public | snake_case | take_damage() |
| Private | _snake_case | _calculate_damage() |
| Virtual | snake_case | _ready() |
| Signal | snake_case | on_health_changed() |

---

## 4. COMPONENTS

### 4.1 HealthComponent

```gdscript
class_name HealthComponent
extends Node

signal health_changed(old_value: int, new_value: int)
signal died

@export var max_health: int = 100
@onready var current_health: int = max_health

func take_damage(amount: int) -> void:
    var old_health = current_health
    current_health = clamp(current_health - amount, 0, max_health)
    health_changed.emit(old_health, current_health)
    if current_health <= 0:
        died.emit()

func heal(amount: int) -> void:
    var old_health = current_health
    current_health = clamp(current_health + amount, 0, max_health)
    health_changed.emit(old_health, current_health)
```

### 4.2 MovementComponent

```gdscript
class_name MovementComponent
extends Node

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var crouch_speed: float = 3.0
@export var jump_force: float = 7.5
@export var wall_climb_speed: float = 4.0

var current_speed: float = 0.0
var is_sprinting: bool = false
var is_crouching: bool = false
var is_wall_climbing: bool = false

func get_move_direction(input: Vector2) -> Vector2:
    return input.normalized()

func calculate_speed() -> float:
    if is_sprinting:
        return sprint_speed
    elif is_crouching:
        return crouch_speed
    else:
        return walk_speed
```

### 4.2.1 MovementComponent Runtime Contract

`MovementComponent` gestisce solo movimento orizzontale e stati locomotion.

**Invarianti:**
- `vertical_velocity_owned_by_player`: `MovementComponent.calculate_velocity(input_dir)` deve preservare `body.velocity.y`.
- `movement_speed_uses_3d_units`: velocita runtime in metri/secondo Godot 3D, non pixel/secondo 2D.
- `jump_uses_positive_y_impulse`: salto in Godot 3D usa impulso Y positivo nel `Player`.
- `dash_direction_is_stable`: durante dash, la direzione resta quella catturata all'avvio dash.
- `state_update_is_internal`: `calculate_velocity(input_dir)` chiama `update_state(input_dir)` prima di calcolare la velocita.
- `dash_signal_uses_real_old_state`: `state_changed(old_state, "dash")` usa lo stato reale precedente, non un valore hardcoded.

**Edge Cases:**
- **Caso**: `try_dash()` chiamato due volte nello stesso frame in `player.gd:_physics_process()`.
  → **Comportamento**: La seconda chiamata viene processata prima che il dash sia terminato; `can_dash == false` a causa del cooldown appena impostato, quindi la seconda chiamata viene ignorata. Non crasha ma crea confusione sul timing del dash.
  → **Si verifica se**: Viene aggiunto un nuovo input block nel `_physics_process()` di player.gd sotto le linee di combat timers, e qualcuno aggiunge un secondo `if Input.is_action_just_pressed("dash")`.
  → **NON rimuovere**: `try_dash()` deve essere chiamato **esattamente una volta** per frame in player.gd. La posizione corretta è subito dopo `get_input_direction()` e prima del combat input.
  → **Introdotto**: 2026-07-17 (fix P1 duplicate call)

- **Caso**: `_update_animation_state()` in `player.gd` calcola `is_moving = (movement.current_state != "prowl" OR move_direction.length() > 0) AND is_on_ground`.
  → **Comportamento**: Se il player è in aria (`is_on_ground == false`), `is_moving` resta `false` anche con input → l'AnimationTree transita Idle→Fall (via `in_air`) invece di Walk. Corretto per logica (caduta non è "moving" a terra).
  → **Si verifica se**: il player salta o cade; `in_air=true` pilota la transizione Jump/Fall, `is_moving` è mascherato da `is_on_ground`.
  → **NON rimuovere**: il AND con `is_on_ground` evita che Walk giri mentre il player è in volo. Se rimosso → animazione Walk sovrapposta a Fall.
  → **Introdotto**: 2026-07-20 (cablaggio runtime AnimationTree, step 3)

- **Caso**: `is_attacking` pilotato da `CombatComponent` via segnale `melee_attack_started` → `player.gd._on_melee_attack_started()` → `animation_tree_setup.gd.trigger_attack()`.
  → **Comportamento**: `trigger_attack()` imposta `is_attacking=true`, attende ~0.05s (timer), poi resetta a `false`. La condition resta `true` solo per la durata dell'animazione attack nello state machine. Se il segnale non è connesso (es. `combat` null in `_load_rigged_model()`), l'attacco non transita e l'animazione attack non parte.
  → **Si verifica se**: `combat_component.gd.melee_attack()` è chiamato (input attacco). Connessione stabilita in `player.gd._load_rigged_model()` dopo aver creato l'AnimationTree.
  → **NON rimuovere**: la connessione segnale è l'unico trigger di `is_attacking`; non chiamare `trigger_attack()` da `_update_animation_state()` (quello pilota solo stati continui). Verificato headless: `trigger_attack()`→`is_attacking=true`→`false`; connessione `melee_attack_started`→`_on_melee_attack_started` confermata `true`.
  → **Introdotto**: 2026-07-20 (cablaggio attacco AnimationTree, step 3 completamento)

**API runtime attuale:**
| Nome | Input | Output | Side Effect | Dipendenze |
|------|-------|--------|-------------|------------|
| `get_input_direction()` | Nessuno | `Vector2` normalizzato | Legge Input Map | `Input` |
| `calculate_velocity(input_dir)` | `Vector2` | `Vector3` con Y preservata | Aggiorna stato e direzione interna | `CharacterBody3D body` |
| `try_dash(input_dir := Vector2.ZERO)` | `Vector2` opzionale | `bool` | Avvia dash, emette segnali | Stato interno |
| `update_state(input_dir)` | `Vector2` | `void` | Emette `state_changed` se cambia stato | Input Map |

**Modifiche Recenti:**
- **2026-07-20** `[FEAT]` `[P1]` `[player]`: cablaggio runtime AnimationTree in `player.gd._physics_process()` → `_update_animation_state()` — COMPLETATO (incl. `is_attacking`).
  - **Impatto**: pilota le condition `is_moving`/`is_sprinting`/`in_air`/`is_dead` dell'AnimationTree da `MovementComponent.current_state` + stato player (`is_on_ground`, `is_dead`). `is_attacking` cablato da `CombatComponent`: `melee_attack_started` → `player.gd._on_melee_attack_started()` → `animation_tree_setup.gd.trigger_attack()`. Verificato headless: `is_sprinting=true` su `current_state=="sprint"`; `trigger_attack()`→`is_attacking=true`→`false`; connessione segnale confermata `true`.
  - **Rischio**: basso — sola lettura di stato + trigger evento, nessun side effect su physics.
  - **Edge case**: `is_moving` mascherato da `is_on_ground` (vedi sopra) per evitare Walk durante Fall. `is_attacking` è event-driven (segnale), NON in `_update_animation_state()`.
- **2026-07-17** `[FIX]` `[P1]` `[player]`: rimosso `try_dash()` duplicato in `player.gd:_physics_process()` — causava doppia chiamata per frame, con potenziali race condition sullo stato dash.
  - **Impatto**: `Player` chiama `movement.try_dash()` una sola volta per frame.
  - **Rischio**: basso — rimozione di codice ridondante.
  - **Edge case**: se un future worker aggiunge un nuovo input block sotto `# Apply movement`, deve verificare di non reintrodurre un secondo `try_dash()`.
- **2026-07-15** `[DRIFT-FIX]` `[P1]` `[movement]`: documentato il contratto runtime di `MovementComponent` dopo stabilizzazione del codice.
  - **Impatto**: `Player` deve applicare solo `velocity.x` e `velocity.z` dal componente; gravita e salto restano nel player.
  - **Rischio**: medio se futuri worker assumono che il componente possa modificare `velocity.y`.
- **2026-07-15** `[DRIFT-FIX]` `[P1]` `[movement]`: normalizzata scala velocita runtime da valori pixel-space a metri/secondo Godot 3D (`5.0`, `9.0`, `3.0`, dash `15.0`).
  - **Impatto**: test scene 3D giocabile su scala metrica.
  - **Rischio**: medio se piani vecchi citano ancora `300/540/180/900`.
- **2026-07-15** `[DRIFT-FIX]` `[P1]` `[movement]`: normalizzato `jump_force` a impulso Y positivo (`7.5`) per `CharacterBody3D`.
  - **Impatto**: `Player` possiede gravita e salto in scala 3D.
  - **Rischio**: medio se worker futuri copiano esempi 2D con forza negativa.

### 4.3 CombatComponent

```gdscript
class_name CombatComponent
extends Node

signal attack_started
signal attack_finished
signal damage_dealt(target: Node, amount: int)

@export var melee_damage: int = 30
@export var melee_range: float = 50.0
@export var attack_cooldown: float = 0.3

var can_attack: bool = true
var current_combo: int = 0

func perform_attack(target: Node) -> void:
    if not can_attack:
        return
    
    can_attack = false
    attack_started.emit()
    
    var damage = calculate_damage()
    target.take_damage(damage)
    damage_dealt.emit(target, damage)
    
    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true

func calculate_damage() -> int:
    return melee_damage + (current_combo * 5)
```

### 4.4 FrenesiaComponent

```gdscript
class_name FrenesiaComponent
extends Node

signal frenesia_changed(old_value: int, new_value: int)
signal frenesia_level_changed(new_level: FrenesiaLevel)

enum FrenesiaLevel { CALM, AGITATED, FURIOUS, FRENETIC, OVERFRENESIA }

@export var max_frenesia: int = 100
@export var decay_rate: float = 2.0

var current_frenesia: int = 0
var current_level: FrenesiaLevel = FrenesiaLevel.CALM

func add_frenesia(amount: int) -> void:
    var old_frenesia = current_frenesia
    current_frenesia = clamp(current_frenesia + amount, 0, max_frenesia)
    frenesia_changed.emit(old_frenesia, current_frenesia)
    _update_level()

func _process(delta: float) -> void:
    if current_frenesia > 0:
        current_frenesia = max(0, current_frenesia - decay_rate * delta)

func _update_level() -> void:
    var new_level: FrenesiaLevel
    if current_frenesia <= 20:
        new_level = FrenesiaLevel.CALM
    elif current_frenesia <= 40:
        new_level = FrenesiaLevel.AGITATED
    elif current_frenesia <= 60:
        new_level = FrenesiaLevel.FURIOUS
    elif current_frenesia <= 80:
        new_level = FrenesiaLevel.FRENETIC
    else:
        new_level = FrenesiaLevel.OVERFRENESIA
    
    if new_level != current_level:
        current_level = new_level
        frenesia_level_changed.emit(current_level)
```

---

## 5. OBJECT POOLING

### 5.1 Filosofia
> "Object Pooling per mantenere centinaia di nemici contemporaneamente."

### 5.2 Pool System

```gdscript
class_name PoolManager
extends Node

var pools: Dictionary = {}

func create_pool(scene: PackedScene, initial_size: int, pool_name: String) -> void:
    var pool: Array[Node] = []
    for i in range(initial_size):
        var instance = scene.instantiate()
        instance.set_process(false)
        instance.set_physics_process(false)
        instance.visible = false
        add_child(instance)
        pool.append(instance)
    pools[pool_name] = pool

func get_from_pool(pool_name: String) -> Node:
    if pools.has(pool_name):
        for node in pools[pool_name]:
            if not node.visible:
                node.visible = true
                node.set_process(true)
                node.set_physics_process(true)
                return node
    return null

func return_to_pool(node: Node) -> void:
    node.visible = false
    node.set_process(false)
    node.set_physics_process(false)
    node.get_parent().remove_child(node)
    add_child(node)
```

**Modifiche Recenti:**
- **2026-07-17** `[FEAT]` `[P1]` `[fsm-states]`: implementati tutti gli 11 stati FSM enemy (idle, patrol, alert, engage, attack, retreat, flee, search, flank, cover, call_help) in `scripts/ai/states/*.gd` segendo `04-AI-BIBLE.md §2.3`.
  - **Impatto**: EnemyBase.gd: refactor `create_state()` in `_make_state()` che carica script `.gd` e chiama `setup(enemy)`. Nuovi metodi utility: `play_anim()`, `move_toward()`, `nav_to()`, `get_retreat_point()`, `get_flank_point()`. `_physics_process()` ora esegue stato PRIMA di `_apply_movement()` per dare priorità alla direzione dello stato. `_apply_movement()` semplificato: solo avoid force + speed cap + move_and_slide.
  - **Rischio**: medio — nuovi script non testati su scena reale; `AnimationPlayer` opzionale (null-safe). `get_tree().get_nodes_in_group("spawn_points")` come fallback waypoint.
- **2026-07-17** `[FEAT]` `[P1]` `[spawning]`: Director e SpawnManager collegati — SpawnManager ora trova Director via gruppo e usa `get_spawn_rate()` e `get_enemy_types()` per spawn dinamico basato su tensione. Nuovo metodo `spawn_next_enemy()`.
  - **Impatto**: INTEGRATION-MAP.md: aggiunta freccia `SpawnManager --> Director`. Director.gd: aggiunto `add_to_group("director")`. SpawnManager.gd: rimosso `@export var spawn_rate` (sostituito da metodo dinamico).
  - **Rischio**: basso — retrocompatibile, `enemy_pool.get_from_pool()` null-check giá presente.

### 5.3 Pools Necessari

| Pool | Scene | Initial Size | Max Size |
|------|-------|--------------|----------|
| Infantry | InfantrySoldier | 50 | 100 |
| Shield | ShieldSoldier | 20 | 40 |
| Sniper | SniperSoldier | 15 | 30 |
| Flamethrower | FlamethrowerSoldier | 10 | 20 |
| Engineer | EngineerSoldier | 10 | 20 |
| Medic | MedicSoldier | 10 | 20 |
| Heavy | HeavySoldier | 10 | 20 |
| Drone | Drone | 20 | 40 |
| Robot | Robot | 5 | 10 |
| Elite | EliteSoldier | 5 | 10 |
| Nail | NailProjectile | 30 | 60 |
| Blood | BloodParticle | 100 | 200 |
| Ragdoll | Ragdoll | 30 | 60 |

---

## 6. NAVIGATION

### 6.1 Filosofia
> "Navigation per centinaia di nemici. LOD AI per performance."

### 6.2 Navigation Setup

**Godot Navigation:**
- NavigationRegion3D per ogni livello
- NavigationAgent3D per ogni nemico
- Bake navigation mesh per ogni area

**Parameters:**
```
Agent Radius: 0.5
Agent Height: 1.8
Max Climb: 0.3
Max Slope: 45
Cell Size: 0.2
```

### 6.3 Flow Fields

Per gestire centinaia di nemici senza sovraccaricare:
- Calcola flow field una volta per gruppo
- I nemici seguono il flow field
- Aggiorna flow field ogni 0.5 secondi
- LOD: nemici lontani usano flow field semplificato

---

## 7. LOD SYSTEM

### 7.1 LOD Levels

| LOD | Distanza | Dettaglio |
|-----|----------|-----------|
| LOD0 | 0-10m | Full detail, full AI |
| LOD1 | 10-20m | Reduced animation, simplified AI |
| LOD2 | 20-40m | Minimal animation, patrol only |
| LOD3 | 40m+ | Static, no AI |

### 7.2 LOD Implementation

```gdscript
class_name LODComponent
extends Node3D

@export var lod_distances: Array[float] = [10.0, 20.0, 40.0]
var current_lod: int = 0

func _process(_delta: float) -> void:
    var camera = get_viewport().get_camera_3d()
    if camera == null:
        return
    
    var distance = global_position.distance_to(camera.global_position)
    
    if distance < lod_distances[0]:
        _set_lod(0)
    elif distance < lod_distances[1]:
        _set_lod(1)
    elif distance < lod_distances[2]:
        _set_lod(2)
    else:
        _set_lod(3)

func _set_lod(lod: int) -> void:
    if lod == current_lod:
        return
    
    current_lod = lod
    
    match lod:
        0:
            # Full detail
            pass
        1:
            # Reduced detail
            pass
        2:
            # Minimal detail
            pass
        3:
            # Static
            pass
```

---

## 8. PERFORMANCE BUDGET

### 8.1 Target

| Metrica | Target |
|---------|--------|
| FPS (PC) | 120 FPS |
| FPS (iPhone) | 60 FPS |
| FPS (Android) | 60 FPS |
| Draw Calls | < 500 |
| Triangles | < 500k |
| Texture Memory | < 512MB |
| Audio Channels | < 32 |
| Active Enemies | 200+ |

### 8.2 Optimization Strategies

**Rendering:**
- GPU Instancing per oggetti identici
- LOD per tutti gli oggetti
- Occlusion Culling
- Texture Atlas
- Shader leggeri

**AI:**
- LOD AI (nemici lontani = AI semplificato)
- Flow Fields per gruppi
- Object Pooling per nemici
- State Machine leggera
- Utility AI solo per nemici vicini

**Physics:**
- Simplified collision shapes
- Ragdoll LOD
- Particles LOD
- Audio LOD

**Memory:**
- Streaming per livelli
- Texture streaming
- Audio compression
- Object pooling

---

## 9. SAVE SYSTEM

### 9.1 Filosofia
> "Un solo JSON. Fine."

### 9.2 Save Data

```json
{
  "version": "1.0",
  "timestamp": "2026-07-15T10:30:00Z",
  "player": {
    "health": 85,
    "frenesia": 45,
    "position": {"x": 10.5, "y": 0.0, "z": 5.2},
    "mutations": ["claw_long", "eye_sense"],
    "current_level": 1,
    "checkpoint": "office_3"
  },
  "stats": {
    "enemies_killed": 156,
    "damage_dealt": 15600,
    "damage_taken": 3200,
    "play_time": 5400
  },
  "settings": {
    "difficulty": "normal",
    "audio_volume": 0.8,
    "sensitivity": 1.0
  }
}
```

### 9.3 Save/Load

```gdscript
class_name SaveSystem
extends Node

const SAVE_PATH = "user://savegame.json"

func save_game(data: Dictionary) -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var json = JSON.new()
    json.parse(file.get_as_text())
    file.close()
    return json.data

func delete_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
```

---

## 10. CODE STYLE

### 10.1 GDScript Guidelines

```gdscript
# 1. Class declaration
class_name EnemyBase
extends CharacterBody3D

# 2. Signals
signal health_changed(new_health: int)
signal died

# 3. Constants
const MAX_HEALTH := 100
const MOVE_SPEED := 300.0

# 4. Enums
enum State { IDLE, PATROL, ENGAGE, ATTACK, RETREAT }

# 5. Exported variables
@export var health := MAX_HEALTH
@export var damage := 10

# 6. Private variables
var _current_state: State = State.IDLE
var _target: Node3D = null

# 7. Onready variables
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# 8. Built-in functions
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

# 9. Public functions
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)

# 10. Private functions
func _update_state() -> void:
    pass

# 11. Signal callbacks
func _on_health_changed(new_health: int) -> void:
    pass
```

### 10.2 Comments

```gdscript
# Single line comment

## Documentation comment
## Used for classes and public functions

# TODO: Something to do
# FIXME: Something broken
# HACK: Temporary workaround
```

---

## 11. GIT WORKFLOW

### 11.1 Branches

```
main (release)
├── develop (integration)
│   ├── feature/movement-system
│   ├── feature/combat-system
│   ├── feature/enemy-ai
│   └── bugfix/camera-clip
└── hotfix/critical-bug
```

### 11.2 Commit Messages

```
feat: add movement system
fix: camera clipping through walls
refactor: extract combat component
test: add enemy AI tests
docs: update technical bible
```

### 11.3 Code Review

- Tutte le PR devono essere reviewate
- Minimo 1 approvazione
- Tests passanti
- No conflict con develop
- Performance test su mobile

---

## 12. TESTING

### 12.1 Test Types

| Tipo | Scopo | Frequency |
|------|-------|-----------|
| Unit | Test singole funzioni | Ogni commit |
| Integration | Test sistemi insieme | Ogni PR |
| Performance | Test FPS/memory | Ogni build |
| Playtest | Test gameplay | Ogni milestone |
| Regression | Test che nulla si rompa | Ogni release |

### 12.2 Test Cases

**Movement:**
- [ ] Player si muove in tutte le direzioni
- [ ] Sprint funziona
- [ ] Crouch funziona
- [ ] Dash ha i-frame
- [ ] Jump è fluido
- [ ] Wall climb funziona
- [ ] Wall jump funziona
- [ ] Camera segue correttamente

**Combat:**
- [ ] Melee infligge danno
- [ ] Combo funziona
- [ ] Grab funziona
- [ ] Finisher funziona
- [ ] Nail Launch penetra
- [ ] Scream ha area effect
- [ ] Feedback visivo/sonoro/fisico

**Enemies:**
- [ ] Spawn corretto
- [ ] AI states funzionano
- [ ] Morale system funziona
- [ ] Formazioni funzionano
- [ ] LOD funziona
- [ ] Pooling funziona

---

## 13. CRITERI DI COMPLETAMENTO TECHNICAL

### 13.1 Architettura
- [ ] Scene tree definito
- [ ] Folder structure creata
- [ ] Naming conventions applicate
- [ ] Components implementati
- [ ] Signals definiti

### 13.2 Performance
- [ ] 120 FPS PC
- [ ] 60 FPS iPhone
- [ ] 60 FPS Android
- [ ] < 500 draw calls
- [ ] < 500k triangles

### 13.3 Code Quality
- [ ] Style guide seguito
- [ ] Comments aggiunti
- [ ] Git workflow definito
- [ ] Tests scritti
- [ ] Documentation aggiornata

---

*Fine Volume 3 — Technical Bible*
*Prossimo: Volume 4 — AI Bible*
