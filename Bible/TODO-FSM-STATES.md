# TODO: FSM Enemy State Behaviors

## Overview

- **Priority**: P1 (Alto — KB ha design, codice non implementa)
- **Classification**: `feature` (codice mancante vs KB esistente)
- **META-RULES**: §1.2 — "La KB è corretta, il codice no → Il codice ha un bug — fixarlo"
- **KB Reference**: `04-AI-BIBLE.md §2.3` (stati implementati con pseudocodice)
- **Wave Reference**: `WAVE3-AI-PLAN.md` (Task 1: FSMComponent, Task 10: EnemyBase)
- **Status**: `implemented` (tutti gli 11 stati implementati in scripts/ai/states/)
- **Implementation date**: 2026-07-17
- **Commit**: AW3.1 — FSM enemy state behaviors
- **Note**: L'implementazione segue la AI-BIBLE §2.3. Transizioni gia gestite da UtilityAI. Stati con comportamento pieno (move_toward, nav_to, anim, timers).
- **Estimated Effort**: ~3-4 ore (11 stati, ciascuno 10-30 righe GDScript)
- **Created**: 2026-07-17

## Current State

- `FSMComponent` (scripts/ai/fsm_component.gd): ✅ Corretto — gestisce transizioni, enter/exit/process/physics_process
- `EnemyBase._setup_fsm()` (scripts/ai/enemy_base.gd): ✅ 11 stati registrati
- `create_state(name)`: ❌ Restituisce `Node.new()` vuoto — stato senza comportamento
- `UtilityAI` (scripts/ai/utility_ai.gd): ✅ Funzionante — calcola punteggi e decide azioni
- `_apply_utility_decision()` (enemy_base.gd): ✅ Transiziona FSM basato su UtilityAI
- Navigation/ Movement: ✅ Già presenti in `EnemyBase._apply_movement()` e `NavigationComponent`

## What Needs to Be Done

Sostituire `create_state(name: String) -> Node` in `enemy_base.gd` con stati che hanno **comportamento reale**. Ogni stato deve implementare `enter()`, `exit()`, `process(delta)`, `physics_process(delta)` come descritto in AI-BIBLE §2.3.

### Option A: Inline States (leggero)

Aggiungere metodi per stato direttamente in `EnemyBase.gd`. Ogni stato è una semplice funzione callback. Questo è l'approccio piu rapido e consiste nell'estendere EnemyBase con metodi per ogni stato.

**Pro**: +semplice, +veloce, meno file  
**Contro**: EnemyBase diventa piu grande, mescola infrastruttura e comportamento

### Option B: State Scripts (modulare)

Ogni stato in un file separato (`scripts/ai/states/idle_state.gd`, `patrol_state.gd`, ecc.) che estende `Node`. Ogni script implementa `enter()`, `process()`, ecc.

**Pro**: +modulare, +manutenibile, ogni stato testabile separatamente  
**Contro**: +file, richiede risorse aggiuntive

### AI-BIBLE Reference: Every State Behavior

#### 1. IDLE (`"idle"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | `velocity = Vector3.ZERO`, play anim "idle" |
| **process()** | `if can_see_player()` → transition "alert" |
| **transitions out** | → alert (player seen) |
| **physics_process** | Nessuno (fermo) |

#### 2. PATROL (`"patrol"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | `current_waypoint = get_next_waypoint()`, play anim "walk" |
| **physics_process()** | NavAgent → waypoint; `if navigation_finished` → next waypoint; `if can_see_player` → alert |
| **transitions out** | → alert (player seen) |
| **Dependencies** | `get_next_waypoint()` da implementare in EnemyBase (o passare spawn point list) |

#### 3. ALERT (`"alert"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | anim "alert", `alert_timer = 1.0` |
| **process(delta)** | `alert_timer -= delta`; look_at_player(); `if timer <= 0` → engage (if close) or patrol (if far) |
| **transitions out** | → engage (player within engage_range), → patrol (player too far) |
| **Notes** | Stato transitorio — dà al giocatore 1 secondo di preavviso |

#### 4. ENGAGE (`"engage"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | play anim "run", `call_reinforcements()` (opzionale) |
| **physics_process()** | `direction = (player.pos - enemy.pos).normalized()`; `velocity = direction * run_speed`; move_and_slide(); `if distance < attack_range` → attack; `if distance > lose_range` → retreat |
| **transitions out** | → attack (close), → retreat (far) |
| **Dependencies** | `run_speed`, `attack_range`, `lose_range` da EnemyBase |

#### 5. ATTACK (`"attack"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | `velocity = Vector3.ZERO`, play anim "attack" |
| **process(delta)** | `if can_attack → perform_attack()`; `if distance > attack_range` → engage; `if health < retreat_threshold` → retreat |
| **transitions out** | → engage (player moved away), → retreat (low health) |
| **Dependencies** | `perform_attack()` da implementare (delega a CombatComponent o arma) |

#### 6. RETREAT (`"retreat"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | anim "retreat", `retreat_point = get_retreat_point()` |
| **physics_process()** | direction = (retreat_point - pos).normalized(); velocity * retreat_speed; move_and_slide(); `if distance_to(retreat_point) < 1.0` → idle |
| **transitions out** | → idle (reached retreat point) |
| **Dependencies** | `retreat_point` da EnemyBase, `get_retreat_point()` da implementare |

#### 7. FLEE (`"flee"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | play anim "run" (panic), `flee_point = get_farthest_point_from_player()` |
| **physics_process()** | direction = AWAY from player; velocity * run_speed * 1.5; move_and_slide(); `if distance > lose_range * 2` → idle |
| **transitions out** | → idle (safe distance) |
| **Notes** | Come retreat ma prioritario e piu veloce — attivato da UtilityAI con health molto bassa |

#### 8. SEARCH (`"search"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | play anim "walk", `search_timer = 5.0` |
| **physics_process()** | move toward last known player position; `if can_see_player` → engage; `if search_timer <= 0` → patrol |
| **transitions out** | → engage (player found), → patrol (gave up) |
| **Notes** | Usato dopo che il nemico perde il giocatore — cerca nell'ultima posizione nota |

#### 9. FLANK (`"flank"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | play anim "run", `flank_point = calculate_flank_point()` |
| **physics_process()** | move toward flank position; `if distance_to(flank_point) < 2.0` → attack; `if can_see_player && flank_position_reached` → engage |
| **transitions out** | → attack (flank reached), → engage (player seen en route) |
| **Dependencies** | `calculate_flank_point()` — punto laterale rispetto a player, considerando ostacoli |

#### 10. COVER (`"cover"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | play anim "crouch_run", find nearest cover node |
| **physics_process()** | move toward cover; `if at_cover` → idle/peek; `if health_restored` → engage |
| **transitions out** | → engage (restored), → retreat (cover broken) |
| **Dependencies** | Cover nodes nel livello (gruppo "cover_points") |

#### 11. CALL_HELP (`"call_help"`)
| Aspect | Detail |
|--------|--------|
| **enter()** | play anim "call", `call_timer = 2.0` |
| **process(delta)** | `call_timer -= delta`; `if call_timer <= 0` → alert ALL nearby enemies; transition → engage |
| **transitions out** | → engage (done calling) |
| **Dependencies** | Need to iterate enemies in radius and force transition "alert" on them |

## Cross-Cutting Concerns

### Animation
Ogni stato DEVE chiamare `anim_player.play(anim_name)`. Animations disponibili (da scene/enemies):
- `idle`, `walk`, `run`, `alert`, `attack`, `retreat`, `crouch_run`, `call`, `search`
- Fallback: se AnimationPlayer non presente, skippare senza crash

### Movement Integration
- `ATTACK` e `IDLE` fermi: `velocity = Vector3.ZERO`
- `PATROL`, `ENGAGE`, `RETREAT`, `FLEE`, `SEARCH`, `FLANK` usano `move_and_slide()` direttamente nello stato
- La funzione `EnemyBase._apply_movement()` continuerà a gestire Boids + Avoidance anche durante questi stati
- **Coordinazione**: lo stato setta `velocity.x/z` e `_apply_movement()` somma Boids + Avoidance sopra. Serve un flag per evitare doppio move_and_slide()

### Perception Integration
- `can_see_player()` — gia presente in EnemyBase
- `player_distance` — gia calcolato in `_update_perception()`

### Health/Ammo
- `health` — EnemyBase
- `ammo` — EnemyBase
- `retreat_threshold` — EnemyBase
- `is_under_fire` — gia presente

### Edge Cases
- **Caso**: Player non trovato (get_tree().get_first_node_in_group("player") == null)
  → **Comportamento**: tutti gli stati che referenziano player devono fare null-check
  → **Fallback**: patrol o idle
- **Caso**: AnimationPlayer assente sul nemico
  → **Comportamento**: play_anim skippato, stato procede senza animazione
- **Caso**: Transizione durante process() per stato sbagliato
  → **Comportamento**: FSM.gia protetto da `if new_state == current_state: return`
- **Caso**: retreat_point / flank_point non trovato
  → **Comportamento**: fallback a idle o patrol

## Implementation Order Suggerita

1. **IDLE** (semplice, base) → testabile subito
2. **PATROL** (richiede waypoints) → enemy si muove
3. **ALERT** (transitorio, collega idle/patrol a engage)
4. **ENGAGE** (insegue player) → enemy combat-ready
5. **ATTACK** (danneggia player) → ciclo completo
6. **RETREAT** (sopravvivenza) → enemy non suicida
7. **SEARCH** (cerca player) → comportamento naturale
8. **COVER** (copertura) → tattica base
9. **FLANK** (aggiramento) → tattica avanzata
10. **FLEE** (panico) → comportamento estremo
11. **CALL_HELP** (coordinazione) → comportamento sociale

## Verification

- Enemy in idle → vedono player → passano ad alert
- Enemy in patrol → vedono player → alert/engage
- Enemy in engage → raggiungono attack_range → attack
- Enemy low health → retreat/flee
- Enemy perde player → search poi patrol
- Tutti gli stati → animazione corrispondente
- Nessun crash su riferimenti null (player, anim, waypoint)
- Move & Slide chiamato una sola volta per frame

## See Also

- `04-AI-BIBLE.md §2` — FSM design completo con pseudocodice
- `04-AI-BIBLE.md §2.3` — implementazione dettagliata per ogni stato
- `04-AI-BIBLE.md §3` — UtilityAI scoring
- `scripts/ai/enemy_base.gd` — EnemyBase corrente
- `scripts/ai/fsm_component.gd` — FSMComponent
- `WAVE3-AI-PLAN.md` — Wave 3 piano originale
