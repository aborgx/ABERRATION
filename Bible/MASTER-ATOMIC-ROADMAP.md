# PROJECT ABERRATION — MASTER ATOMIC ROADMAP

**Versione:** 2.0  
**Data:** 16 Luglio 2026  
**Status:** ACTIVE  
**Scope:** Roadmap globale atomica per produzione LLM-assisted — allineata a WAVE5/WAVE6 aggiornati

---

## 1. Strategic Principle

Il miglior gioco possibile nasce da una vertical slice piccola ma eccellente, non da tanti sistemi medi.

Ordine di qualità:

1. Movimento e camera devono essere piacevoli anche senza nemici.
2. Un singolo nemico deve essere divertente da uccidere.
3. Tre nemici insieme devono creare pressione leggibile.
4. Una stanza deve raccontare il fantasy del predatore.
5. Solo dopo si scala a livello, boss, mutazioni e ottimizzazione.

---

## 2. Global Kill Criteria

Tagliare o rimandare qualsiasi elemento che viola almeno una condizione:

- non rafforza `player_is_predator`
- non è verificabile in una scena piccola
- richiede plugin esterni
- riduce FPS mobile senza beneficio percepito
- introduce più di due moduli nuovi in una atomic wave
- richiede asset definitivi prima di validare gameplay

---

## 3. Macro Waves (Aggiornato)

La numerazione resta compatibile con `01-VISION-BIBLE.md` e `07-PRODUCTION-BIBLE.md`.

| Wave | Goal | Output giocabile |
|------|------|------------------|
| Wave 0 | Control Layer | KB eseguibile, decisioni, mappe, repo coerente |
| Wave 1 | Foundation | Player si muove, camera segue, HUD pulsa |
| Wave 2 | Combat Feel | Un nemico muore in modo soddisfacente |
| Wave 3 | Swarm Core | 10-30 nemici accerchiano senza collidere male |
| Wave 4 | Police Vertical Slice | 10 minuti giocabili con Juggernaut prototipo |
| Wave 5 | Laboratory + Progression + Boss Assault Robot | Livello 2 completo, 35 mutazioni, 4 armi × 5 livelli, Boss 3-fasi |
| Wave 6 | Industrial Zone + Horde + Boss Predator Helicopter | Livello 3 completo, orde 50+, Boss gunship 3-fasi |
| Wave 7 | Final Boss / Ending | Sequenza finale prototipo |
| Wave 8 | Balance | Difficoltà leggibile, niente exploit principali |
| Wave 9 | Optimization | 60 FPS mobile target |
| Wave 10 | QA | Nessun P0/P1 aperto |
| Wave 11 | Release Candidate | Build, note, backup, freeze |

---

## 4. Wave 0 — Control Layer

**Purpose:** rendere il progetto governabile da worker deboli.

Atomic Waves:

- **AW0.1**: creare/validare `INDEX.md`
- **AW0.2**: creare/validare `DECISIONS-LOG.md`
- **AW0.3**: creare/validare `INTEGRATION-MAP.md`
- **AW0.4**: creare/validare `AGENT-RUNBOOK.md`
- **AW0.5**: creare/validare `MASTER-ATOMIC-ROADMAP.md`
- **AW0.6**: sincronizzare riferimenti in `07-PRODUCTION-BIBLE.md`

Exit Gate:

- [ ] Un worker può capire cosa leggere prima di agire
- [ ] Le dipendenze runtime Wave 1 sono mappate
- [ ] Le decisioni attive sono tracciate
- [ ] Ogni wave futura ha direzione atomica

---

## 5. Wave 1 — Foundation

**Purpose:** controlli base del mostro.

Atomic plan source:

- `WAVE1-ATOMIC-EXECUTION-PLAN.md`

Quality target:

- movimento rapido e ferino
- camera leggibile
- HUD minimale biologico
- test scene avviabile

Exit Gate:

- [ ] 30 secondi di playtest senza crash
- [ ] WASD/Stick muove il player
- [ ] Sprint/crouch/dash/jump funzionano
- [ ] Camera non attraversa muri semplici
- [ ] HUD visibile e pulsante

---

## 6. Wave 2 — Combat Feel

**Purpose:** far sentire il giocatore predatore con un solo nemico.

Atomic Waves:

- **AW2.1**: `HealthComponent` generico
- **AW2.2**: `EnemyDummy` con hurt/death state
- **AW2.3**: `CombatComponent` solo melee base
- **AW2.4**: hit detection melee con Area3D
- **AW2.5**: hit stop locale e camera shake su hit
- **AW2.6**: blood particle placeholder
- **AW2.7**: death impulse/ragdoll placeholder
- **AW2.8**: `FrenesiaComponent` solo accumulo/decay
- **AW2.9**: HUD collegato a Health/Frenesia reali
- **AW2.10**: Nail Launch prototipo a singolo projectile
- **AW2.11**: Nail penetration fino a 3 target
- **AW2.12**: Combat test room con 3 dummy

Exit Gate:

- [ ] Colpire un nemico produce feedback visivo/fisico
- [ ] Uccidere un nemico aumenta frenesia
- [ ] Nail Launch penetra bersagli in linea
- [ ] Nessun sistema AI ancora richiesto

---

## 7. Wave 3 — Swarm Core

**Purpose:** gli umani devono sembrare un gruppo intelligente, non zombie.

Atomic Waves:

- **AW3.1**: `EnemyBase` con stati idle/patrol/alert/engage/dead
- **AW3.2**: `FSMComponent` minimale
- **AW3.3**: `NavigationComponent` con `NavigationAgent3D`
- **AW3.4**: `PoolManager` per Infantry
- **AW3.5**: `SpawnManager` con max enemies
- **AW3.6**: separation avoidance locale
- **AW3.7**: boids cohesion/alignment solo per gruppi vicini
- **AW3.8**: morale value ma senza fuga complessa
- **AW3.9**: `Director` tensione solo spawn rate
- **AW3.10**: swarm test room 30 nemici

Exit Gate:

- [ ] 30 nemici si muovono senza collisioni gravi
- [ ] Spawn rispetta max enemies
- [ ] Enemy update non avviene tutto ogni frame se non necessario
- [ ] Performance editor accettabile

---

## 8. Wave 4 — Police Vertical Slice

**Purpose:** prima esperienza giocabile con inizio, arena e boss prototipo.

Atomic Waves:

- **AW4.1**: kit modulare police station grigio-box
- **AW4.2**: corridoio + stanza + barricata
- **AW4.3**: Infantry encounter
- **AW4.4**: Shield enemy prototipo
- **AW4.5**: Paralyzing Scream prototipo
- **AW4.6**: checkpoint system minimale
- **AW4.7**: Juggernaut phase 1
- **AW4.8**: Juggernaut phase 2
- **AW4.9**: Juggernaut phase 3
- **AW4.10**: audio placeholder bus + 5 SFX core
- **AW4.11**: 10 minute vertical slice playtest

Exit Gate:

- [ ] Livello 1 prototipo ha inizio e fine
- [ ] Boss leggibile in 3 fasi
- [ ] Scream rompe una formazione/scudo
- [ ] Giocatore capisce fantasy senza testo esplicativo

---

## 9. Wave 5 — Laboratory + Progression + Boss Assault Robot

**Purpose:** Livello 2 completo, progressione profonda (35 mutazioni, 4 armi × 5 livelli), Boss 3-fasi.

Atomic Waves (da `WAVE5-LABORATORY-PLAN.md`):

### Phase 1: Laboratory Modular Props
- **AW5.1**: 17 prop modulari laboratorio (wall, floor, door, window, corridor, room, containment_vat, experiment_table, server_rack, control_console, ventilation_duct, lab_shelf, lab_light, turret_prop, laser_grid, pipe_cluster, flood_water)
- **AW5.2**: `prop_library_lab.gd`

### Phase 2: Level 2 — Laboratory Layout
- **AW5.3**: Level design: Entrance → Lab Corridors → Experiment Halls → Service Tunnels → Server Room → Boss Arena
- **AW5.4**: Build entrance (decon chamber, security checkpoint, first Flamethrower)
- **AW5.5**: Build corridor network (glass walls, vents above, turret placements)
- **AW5.6**: Build experiment halls (containment vats, tables, laser grids, Sniper positions)
- **AW5.7**: Build service tunnels (dark, pipe clusters, flood water, vertical shafts)
- **AW5.8**: Build server room (server racks, control consoles, Engineer enemies)
- **AW5.9**: Build boss arena (circular chamber, machinery platforms, weak point routes)
- **AW5.10**: Place vertical routes (vents, pipes, shafts)
- **AW5.11**: Place spawn points, cover nodes, checkpoint triggers (5 checkpoints)
- **AW5.12**: Lighting (fluorescent, emergency red, containment green)
- **AW5.13**: WorldEnvironment (fog, ambient teal, alarm ambiance)
- **AW5.14**: `level_2.gd` logic, wave triggers, cleanup, verticality validation

### Phase 3: Turret Enemy
- **AW5.15**: `turret_enemy.gd` (FSM idle→detect→aim→fire→cooldown)
- **AW5.16**: Detection cone (120°, 15m), laser sight
- **AW5.17**: Projectile fire (15 dmg), overheat (3 shots = 3s cooldown)
- **AW5.18**: Turret scene (StaticBody3D, rotating head, laser mesh)
- **AW5.19**: Destructibility (HP 80, explosion particles)

### Phase 4: Boss Assault Robot — 3-Phase Fight
- **AW5.20**: Boss arena design (circular, platforms, cover pillars)
- **AW5.21**: Phase 1 (100-60% HP): frontal laser sweep, missile volley, mechanical stomp
- **AW5.22**: Phase 2 (60-30% HP): separation into 5 flying parts (head drone, back turret, 2 arm crawlers, 2 leg walkers)
- **AW5.23**: Phase 3 (30-0% HP): self-destruct sequence, room fills with explosions, DPS race
- **AW5.24**: Weak point system (Head 2x, Back 3x, Legs 0.5x speed, Arms disarm)
- **AW5.25**: Boss scene (CharacterBody3D 4× height, metallic shader, glowing core)
- **AW5.26**: Part scenes (separate hitboxes/HP)
- **AW5.27**: Phase transitions (visual: armor crack, sparks; audio: alarm escalation; UI: phase indicator)
- **AW5.28**: Boss health bar UI (CanvasLayer, phase indicators, weak point markers)

### Phase 5: Mutation System (Progression)
- **AW5.29**: Mutation data structure (name, desc, cost, prereqs, stat_mods, ability_unlocks, visual_changes)
- **AW5.30**: 5 branches × 7 mutations = 35 total (Claws, Eyes, Jaw, Skin, Muscles)
- **AW5.31**: Stat modifiers per mutation (damage_mult, speed_mult, range_mult, cooldown_mult, armor, regen, jump_height)
- **AW5.32**: Visual changes per mutation (claw_glow, eye_color, skin_texture, body_size, aura)
- **AW5.33**: Ability unlocks (Lunge, Wall Run, Triple Jump, Blood Shield, Frenzy Mode)
- **AW5.34**: `MutationSystem` master controller, unlock processing
- **AW5.35**: `MutationTree` data structure, prereq validation, unlockable calculation
- **AW5.36**: Unlock logic (spend Frenesia, check prereqs, apply modifiers)
- **AW5.37**: Stat application (damage→CombatComponent, speed→MovementComponent, armor→take_damage, regen→_process)
- **AW5.38**: Visual application (shader params, material overrides, scene mods)
- **AW5.39**: Ability unlocks (enable/disable in CombatComponent)
- **AW5.40**: FrenesiaComponent integration (every 1000 Frenesia = 1 mutation point)
- **AW5.41**: Save/load support (SaveSystem saves unlocked mutations)

### Phase 6: Mutation UI
- **AW5.42**: Mutation screen (full-screen overlay, tree viz, branch selection)
- **AW5.43**: Mutation card (name, desc, cost, icon, effects)
- **AW5.44**: Tree visualization (5 root branches, child nodes, prerequisite lines)
- **AW5.45**: Interaction (click select, confirm unlock, locked/unlocked/available states)
- **AW5.46**: Feedback (unlock animation: particle burst, screen flash, stat preview)
- **AW5.47**: Input handling (mouse/touch, keyboard nav, ESC close)
- **AW5.48**: Player integration (open on Frenesia threshold, pause gameplay)
- **AW5.49**: Mutation points counter in HUD

### Phase 7: Upgrade System
- **AW5.50**: `UpgradeSystem` master controller
- **AW5.51**: 4 weapons × 5 levels (Claws, Nail Launch, Scream, Grab)
- **AW5.52**: Level-up logic (Frenesia cost scaling, unlock with mutation points or Frenesia)
- **AW5.53**: Stat scaling (L2: +20% dmg/range, L3: +10% speed/-10% CD, L4: +1 ability, L5: +20% all + unique)
- **AW5.54**: Mutation UI integration (weapon upgrades alongside mutations)
- **AW5.55**: Save/load weapon levels

### Phase 8: Audio Integration
- **AW5.56**: Lab exploration music (tense ambient, mechanical hum, dripping)
- **AW5.57**: Lab combat music (faster tempo, alarm synths, metallic percussion)
- **AW5.58**: Lab SFX (turret fire, laser hum, glass break, airlock doors, alarms)
- **AW5.59**: SFX triggers (laser grid alarm, turret detection, containment break)
- **AW5.60**: Voice lines (lab intercom, scientist recordings)

### Phase 9: Checkpoint + Polish
- **AW5.61**: Level 2 checkpoints (Entrance, Experiment Hall, Tunnel Midway, Server Room, Pre-Boss)
- **AW5.62**: Save data update (level number, lab-specific state: laser reset, turret destroyed flags)
- **AW5.63**: Respawn logic (restore player, reset destroyed props)
- **AW5.64**: Checkpoint UI prompt ("Checkpoint Reached — Laboratory")
- **AW5.65**: Performance profiling, draw call optimization, AI LOD, visual bug fixes, juice (screen shake, hit pause, blood decals)
- **AW5.66**: Final QA (full playthrough, checkpoints, boss, mutations, audio)

**Exit Gate Wave 5:**

- [ ] Level 2 (Underground Laboratory) fully playable start to boss
- [ ] Boss Assault Robot 3-phase fight working (weak points, separation, self-destruct)
- [ ] 17 laboratory modular props
- [ ] Level 2: Entrance → Lab Corridors → Experiment Halls → Service Tunnels → Server Room → Boss
- [ ] Verticality routes: ventilation ducts, pipe clusters, wall climb
- [ ] Turret enemies with detection and firing
- [ ] Mutation system: 35 mutations across 5 branches
- [ ] Upgrade system: 4 weapons × 5 levels
- [ ] Mutation UI: tree visualization, card interaction, unlock animation
- [ ] Audio integration: lab ambiance, turret SFX, alarms
- [ ] Checkpoint system: Laboratory checkpoints
- [ ] Performance: 60 FPS mobile, 120 FPS PC
- [ ] No critical bugs
- [ ] Git history clean, commits atomic

---

## 10. Wave 6 — Industrial Zone + Horde + Boss Predator Helicopter

**Purpose:** Livello 3 completo, orde massive (50+), Boss gunship 3-fasi.

Atomic Waves (da `WAVE6-INDUSTRIAL-PLAN.md`):

### Phase 1: Industrial Modular Props
- **AW6.1**: 78+ prop modulari industriali (wall, floor, door, window, corridor, room, press, conveyor, assembly_line, robot_arm, crane, forklift, pallet_rack, storage_tank, silo, cooling_tower, transformer, substation, pipe_rack, valve_station, pump_station, compressor, flare_stack, vent_stack, scrubber, baghouse, cyclone, control_console, scada, hmi, annunciator, chart_recorder, field_instrument, workbench, tool_chest, parts_washer, drill_press, band_saw, bench_grinder, vise, anvil, forge, rack_pallet, rack_cantilever, rack_drive_in, mezzanine, dock_leveler, dock_seal, forklift, pallet_jack, reach_truck, order_picker, agv, conveyor_sortation, waste_treatment, clarifier, aeration_tank, sludge_press, hazardous_waste_storage, spill_containment, eye_wash, safety_shower, light_high_bay, light_flood, light_explosion_proof, light_obstruction, light_runway, light_stack, oil_spill, chemical_pool, steam_vent, hot_surface, moving_machinery, pinch_point, confined_space, h2s_zone, radiation_zone, asbestos_zone)
- **AW6.2**: `prop_library_industrial.gd`

### Phase 2: Level 3 — Industrial Zone Layout
- **AW6.3**: Level design: Entrance → Warehouses → Industrial Cathedrals → Open Fields → Military Base → Boss Runway
- **AW6.4**: Build entrance (security gate, destroyed checkpoint, first Heavy + Drone)
- **AW6.5**: Build warehouse section (cargo containers, catwalks, conveyors, tight corridors)
- **AW6.6**: Build industrial cathedrals (large open halls, furnaces, cranes, elevated platforms)
- **AW6.7**: Build open field section (vehicle wrecks, fuel tanks, gunship patrols, massive wave arena)
- **AW6.8**: Build military base (hangar doors, military barricades, Robot EOD/SWAT, final stand)
- **AW6.9**: Build boss runway (open runway, helicopter wreckage, Predator Helicopter arena)
- **AW6.10**: Place horde spawn points (multiple locations for 50+ enemies)
- **AW6.11**: Place cover nodes (containers, barricades, wrecks)
- **AW6.12**: Place checkpoint triggers (6 checkpoints)
- **AW6.13**: Lighting (industrial floodlights, furnace glow orange/red, emergency strobes)
- **AW6.14**: WorldEnvironment (fog/smoke, ambient orange, fire particle ambiance)
- **AW6.15**: `level_3.gd` logic, horde wave triggers, vehicle/entity cleanup

### Phase 3: Horde Manager
- **AW6.16**: `HordeManager` master controller for wave encounters
- **AW6.17**: Wave composition (Heavy 20%, Drone 15%, Robot 10%, Elite 5%, Infantry 50%)
- **AW6.18**: Spawn patterns (perimeter, flanking, airborne drop, vehicle deploy)
- **AW6.19**: Intermission (30-60s between waves, heal/loot/upgrade)
- **AW6.20**: Scaling (wave size increases with Director tension, max 200 concurrent)
- **AW6.21**: LOD AI (LOD0 0-10m full, LOD1 10-20m simplified, LOD2 20-40m patrol, LOD3 40m+ static)
- **AW6.22**: GPU instancing for repeated enemy meshes at distance
- **AW6.23**: Horde UI (wave counter, enemies remaining, next wave timer, threat level)

### Phase 4: Boss Predator Helicopter — 3-Phase Air Combat
- **AW6.24**: Boss arena design (open runway, cargo containers for cover, elevated platforms, anti-air cover)
- **AW6.25**: Phase 1 (100-60% HP): helicopter strafes from outside, MG suppression, intermittent rocket barrage, player uses cover to advance
- **AW6.26**: Phase 2 (60-30% HP): helicopter lands center, deploys 5 waves of 6 elite soldiers, helicopter turret active during deployment
- **AW6.27**: Phase 3 (30-0% HP): helicopter takes off, all weapons free, arena becomes kill box, shrinking safe zone (fire spreads), DPS race, final crash sequence
- **AW6.28**: Flight patterns (circular strafe, figure-8, hover, retreat, landing approach)
- **AW6.29**: Weapon systems (MG continuous suppression, rockets 3-shot volley AoE, turret tracking fire, rotor wash push-back AoE)
- **AW6.30**: Vulnerability windows (post-rocket hover 3s, landing 2s, turret destroyed permanent)
- **AW6.31**: Soldier deployment (fast-rope, 6 soldiers per drop, 5 drops in Phase 2)
- **AW6.32**: Boss scene (RigidBody3D, helicopter mesh, rotor animation, weapon hardpoints, spotlight)
- **AW6.33**: Phase transitions (visual: rotor sparks, smoke trails, fire; audio: engine pitch change, alarm; UI: phase indicator)
- **AW6.34**: Boss health bar UI (CanvasLayer, phase indicators, vulnerability window indicators)

### Phase 5: Helicopter Enemy (Air Patrol)
- **AW6.35**: `helicopter_enemy.gd` (FSM: patrol→approach→strafe→retreat)
- **AW6.36**: Flight path (pre-baked path following, smooth transitions)
- **AW6.37**: Detection (visual cone 180°/30m, sound detection)
- **AW6.38**: Strafe attack (approach, fire 6 shots MG, bank away)
- **AW6.39**: Retreat (after strafe, return to patrol path, 10s cooldown)
- **AW6.40**: Damage (player must Nail Launch, 60 HP per helicopter)
- **AW6.41**: Destruction (spiral down, crash, explosion AoE)
- **AW6.42**: Helicopter scene (smaller than boss, faster, scout mesh)

### Phase 6: Audio Integration
- **AW6.43**: Industrial exploration music (heavy industrial, metallic percussion, distant machinery)
- **AW6.44**: Industrial combat music (aggressive, war drums, electric guitar distortion, sirens)
- **AW6.45**: Industrial SFX (helicopter rotor, explosions, machinery, metal stress, fire)
- **AW6.46**: SFX triggers (hangar door, furnace activation, helicopter approach)
- **AW6.47**: Ambient layer (constant industrial drone, distant fire, wind through structures)
- **AW6.48**: Boss-specific audio (rotor buildup, missile lock warning, crash sequence)

### Phase 7: Checkpoint + Polish
- **AW6.49**: Level 3 checkpoints (Entrance, Warehouse Midway, Cathedral, Field, Military Base, Pre-Boss)
- **AW6.50**: Save data update (level number, industrial state: horde wave progress, destroyed fuel tanks)
- **AW6.51**: Respawn logic (restore player, reset destroyed environment)
- **AW6.52**: Checkpoint UI prompt ("Checkpoint Reached — Industrial Zone")
- **AW6.53**: Performance profiling (max horde spawn), draw call optimization, AI LOD, particle pooling
- **AW6.54**: Visual bug fixes, gameplay bug fixes, juice (screen shake, hit pause, explosion decals)
- **AW6.55**: Final QA (full playthrough, checkpoints, boss, horde waves, audio)

**Exit Gate Wave 6:**

- [ ] Level 3 (Industrial Zone) fully playable start to boss
- [ ] Boss Predator Helicopter (gunship d'attacco) 3-phase fight working (strafe/rocket, land/deploy, all-out/crash)
- [ ] 78+ industrial modular props
- [ ] Level 3: Entrance → Warehouses → Industrial Cathedrals → Open Fields → Military Base → Boss Runway
- [ ] Horde Manager: Massive wave encounters (50+ enemies), intermissions, scaling
- [ ] Helicopter enemies: Air patrol, strafe attack, crash
- [ ] Verticality: Catwalks, cranes, containers, elevated platforms
- [ ] Destructible environment: Fuel tanks (explosive), cranes (collapse), furnaces (damage zone)
- [ ] Audio integration: Industrial ambiance, helicopter rotors, massive explosions
- [ ] Checkpoint system: Industrial Zone checkpoints
- [ ] Performance: 60 FPS mobile, 120 FPS PC (with 50+ enemies)
- [ ] No critical bugs
- [ ] Git history clean, commits atomic

---

## 11. Wave 7 — Final Boss / Ending

**Purpose:** Sequenza finale prototipo.

Atomic Waves:

- **AW7.1**: Final boss design lock
- **AW7.2**: Final boss phase 1
- **AW7.3**: Final boss phase 2
- **AW7.4**: Final boss phase 3
- **AW7.5**: Ending sequence
- **AW7.6**: Credits

---

## 12. Wave 8 — Balance

- **AW8.1**: Player damage/time-to-kill pass
- **AW8.2**: Enemy accuracy/morale pass
- **AW8.3**: Boss difficulty pass
- **AW8.4**: Mutation economy pass
- **AW8.5**: Exploit pass

---

## 13. Wave 9 — Optimization

- **AW9.1**: Profiling baseline
- **AW9.2**: Enemy update budget
- **AW9.3**: Draw call budget
- **AW9.4**: Particles budget
- **AW9.5**: Audio channels budget
- **AW9.6**: Mobile export smoke test

---

## 14. Wave 10 — QA

- **AW10.1**: Crash pass
- **AW10.2**: Save/load pass
- **AW10.3**: Input pass
- **AW10.4**: Regression pass
- **AW10.5**: Full campaign pass

---

## 15. Wave 11 — Release Candidate

- **AW11.1**: Build freeze
- **AW11.2**: Release notes
- **AW11.3**: Backup
- **AW11.4**: Final verification
- **AW11.5**: RC tag

---

## 16. Parallel Track: Protagonist Mesh (Priority: Wave 1-2)

**Da `MESH-PIPELINE-PLAN.md` — BLOCCANTE per Wave 1-2**

| Giorno | Attività | Output |
|--------|----------|--------|
| 1 | Retopologia 255K → 22K vertici | `chr_player_lowpoly.blend` |
| 2 | UV Unwrap + Bake maps (Normal, AO, Curvature, ID) | Texture set 2048² |
| 3 | Rigging (Rigify metarig → Generate rig) | `chr_player_rigged.blend` |
| 4 | Skinning (Auto + manual fix) | Vertex weights puliti |
| 5 | Animazioni base (8) | idle, walk, run, attack_1, attack_2, death, hit, alert |
| 6 | Emissive setup + texture upgrade 2048² | PBR + emissive ready |
| 7 | Scale fix 1.95× + export glTF | `chr_player.glb` + LODs + collision |
| 8 | QA in Godot: movement, camera, combat feel | Giocabile in-editor |

**Deadline:** Prima di Wave 1 Task 1 (Movement) — il protagonista serve per testare movement, camera, combat feel.

---

## 17. Parallel Track: Mesh Pipeline (13 Enemies)

**Da `MESH-PIPELINE-PLAN.md` — Eseguibile in parallelo a Wave 4-6**

| Giorno | Attività | Output |
|--------|----------|--------|
| 1 | Finalizza 13 prompt + concept art (PNG 1024²) | `concepts/enemies/*.png` |
| 2 | Batch API generation (Tripo 10 + Meshy 3) | `pipeline/raw/*.glb` |
| 3 | Blender cleanup + decimate + UV + LODs + collision | `pipeline/clean/*/` |
| 4 | Auto-rig (Rigify 10 umani, custom 4 hardware) | `pipeline/rigged/*/` |
| 5 | Bake maps (Normal, AO, Curvature, ID) | `pipeline/textures/*/` |
| 6 | Material setup + export GLB + LODs + collision | `pipeline/game_ready/*/` |
| 7 | Copia in `scenes/enemies/`, genera `.tscn` standard | `scenes/enemies/chr_enemy_*/` |
| 8 | Godot import + test animazioni + LOD switching | Giocabile in-editor |
| 9 | QA: scale, pivot, animazioni, LOD, collisioni | Checklist completa |

**Ordine produzione consigliato:**
1. Infantry, Shield, Juggernaut (Wave 4)
2. Flamethrower, Sniper, Engineer, Medic, Turret (Wave 5)
3. Assault Robot (Wave 5 Boss)
4. Heavy, Drone, Robot, Elite (Wave 6)
5. Predator Helicopter (Wave 6 Boss)

**Dipendenze cross-wave:**
- Wave 4 richiede: Infantry, Shield, Juggernaut mesh pronti prima di AW4.7
- Wave 5 richiede: Flamethrower, Sniper, Engineer, Medic, Turret mesh prima di AW5.4; Assault Robot mesh prima di AW5.20
- Wave 6 richiede: Heavy, Drone, Robot, Elite mesh prima di AW6.4; Predator Helicopter mesh prima di AW6.24

---

## 17. Recent Changes

- **2026-07-16** `[FEAT]` `[P0]` `[planning]`: Aggiornamento completo roadmap per allineamento WAVE5/WAVE6 + Mesh Pipeline
  - **Impatto**: Wave 5 ora include Laboratory completo + Progression (35 mutazioni, 4 armi × 5 livelli) + Boss Assault Robot 3-fasi; Wave 6 include Industrial Zone completo + Horde Manager + Boss Predator Helicopter 3-fasi; aggiunto track parallelo Mesh Pipeline 13 nemici
  - **Rischio**: medio (dipendenze mesh → wave ordinate)

- **2026-07-15** `[FEAT]` `[P1]` `[production]`: creata roadmap atomica master per compensare worker LLM non di punta.
  - **Impatto**: definisce strategia vertical slice, kill criteria e atomic waves per l'intero progetto.
  - **Rischio**: basso.