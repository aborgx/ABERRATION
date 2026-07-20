# PROJECT ABERRATION — KNOWLEDGE BASE INDEX

**Versione:** 1.0  
**Data:** 15 Luglio 2026  
**Status:** ACTIVE  
**Scope:** Entry point operativo per umani e worker LLM  

---

## 1. Read Order

Ogni worker deve leggere in questo ordine:

1. `META-RULES.md`
2. `CONTRATTO-LLM.md`
3. `INDEX.md`
4. `DECISIONS-LOG.md`
5. `INTEGRATION-MAP.md`
6. Bible volume pertinente alla wave
7. Piano wave pertinente
8. File codice coinvolti

Se un worker non puo leggere questi file, non deve modificare il progetto.

---

## 2. Active Execution Files

| File | Stato | Uso |
|------|-------|-----|
| `MASTER-ATOMIC-ROADMAP.md` | active | Roadmap globale atomica |
| `AGENT-RUNBOOK.md` | active | Protocollo per worker LLM non di punta |
| `WAVE1-ATOMIC-EXECUTION-PLAN.md` | active | Fonte esecutiva per Wave 1 |
| `WAVE1-IMPLEMENTATION-PLAN.md` | reference | Piano ampio Wave 1 |
| `WAVE1-PLAN.md` | reference | Piano sintetico Wave 1 |

---

## 3. Project State

| Area | Stato | Note |
|------|-------|------|
| Vision | stable | Pillars chiari: predatore, swarm horror, mobilita, brutalita |
| Gameplay | draft | Meccaniche definite, tuning non validato |
| Technical | parziale | Architettura definita. Wave 1/2: logica player/combat/frenesia/vfx PRESENTE. Wave 3: 4/8 moduli mancanti (enemy_base, spawn_manager, pool_manager, director). Animazione player NON cablata (player.tscn = BoxMesh placeholder) |
| AI | design | Codice FSM/utility_ai/boids/navigation PRESENTE, ma enemy_base + spawn/pool/director MANCANTI → swarm non funzionante |
| Art | design | Reference visiva presente; mesh protagonista `chr_player_rigged.glb` esiste, non montato in player.tscn |
| Audio | design | Nessuna implementazione runtime ancora |
| Production | draft | Roadmap macro presente, ora integrata con atomic roadmap |

---

## 4. Runtime State

| File | Stato | Responsabilita |
|------|-------|----------------|
| `project.godot` | active | Config Godot e input map iniziale |
| `scripts/components/movement_component.gd` | active | Movimento orizzontale e stati locomotion |
| `scripts/player/player.gd` | active | Player runtime (CharacterBody3D, movement/camera/health) — **NOTA: `Model` è BoxMesh placeholder, nessun skeleton/animazione cablato** |
| `scripts/player/camera_controller.gd` | active | Camera runtime (follow + wall avoidance) |
| `scripts/ui/hud_artery.gd` | active | HUD runtime (health/frenesia draw) |
| `scenes/player/player.tscn` | active | Scena player — **NOTA: usa MeshInstance3D+BoxMesh placeholder, non chr_player_rigged.glb** |
| `scenes/test/test_level.tscn` | active | Scena test principale |

> **[DRIFT-FIX] 2026-07-20 (P0)**: i 5 file sopra erano dichiarati `missing` ma esistono nel filesystem (verificato via glob + lettura). Corretto stato da `missing` → `active`. Lo stato "active" riflette l'esistenza del file, NON il completamento funzionale (vedi §3 e INTEGRATION-MAP §2 per lo stato reale delle wave).

---

## 5. Non-Negotiable Product Pillars

- `player_is_predator`: il giocatore deve cacciare, non sopravvivere passivamente.
- `movement_is_animal`: movimento ferino, non soldato o cover shooter.
- `humans_are_swarm`: gli umani vincono solo in massa e tattica.
- `feedback_is_constant`: ogni hit, kill, dash e stato biologico produce feedback.
- `mobile_first_logic`: ogni sistema deve reggere su iPhone prima di essere abbellito su PC.
- `no_stack_bloat`: niente plugin esterni finche Godot nativo basta.

---

## 6. Current P0/P1 Risks

| Risk | Priority | Mitigation |
|------|----------|------------|
| Worker LLM salta dipendenze | P0 | Usare `AGENT-RUNBOOK.md` + atomic plans |
| KB drift (file dichiarati missing ma esistenti / wave dichiarate completate ma incomplete) | P0 | `[DRIFT-FIX]` 2026-07-20: INDEX §4 + INTEGRATION-MAP §2 riconciliati vs filesystem reale |
| Animazione player non cablata (player.tscn = BoxMesh placeholder, AnimationTreeSetup non istanziato) | P1 | Cablare `chr_player_rigged.glb` + AnimationTree in player.tscn (vedi piano animazione) |
| Wave 3 incompleta (enemy_base, spawn_manager, pool_manager, director mancanti) | P1 | Implementare i 4 moduli prima di Swarm Core exit gate |
| Scope creep su combat/AI prima del controller | P0 | Bloccare tutto fuori Wave 1 finche Foundation Gate non passa |

---

## 7. Recent Changes

- **2026-07-15** `[FEAT]` `[P1]` `[kb]`: creato indice operativo della Knowledge Base.
  - **Impatto**: definisce read order, stato runtime e file attivi.
  - **Rischio**: basso.
