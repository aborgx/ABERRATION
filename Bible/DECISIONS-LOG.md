# PROJECT ABERRATION — DECISIONS LOG

**Versione:** 1.0  
**Data:** 15 Luglio 2026  
**Status:** ACTIVE  
**Scope:** Decisioni architetturali e produttive  

---

## 2026-07-15: D001 — Godot 4.4+ come target effettivo

**Contesto:** Technical Bible, Wave 1 plan e Production Bible dichiarano Godot 4.4+, mentre `project.godot` indicava feature `4.3`.

**Opzioni considerate:**
- A. Abbassare tutta la KB a Godot 4.3.
- B. Aggiornare `project.godot` a 4.4.
- C. Lasciare il drift fino alla prima apertura editor.

**Decisione:** B. `project.godot` deve usare `config/features=PackedStringArray("4.4")`.

**Rationale:** La KB e i piani sono gia scritti per 4.4+; mantenere 4.3 avrebbe creato confusione ai worker.

**Trade-off:** Richiede Godot 4.4+ installato per validare in editor.

**Reversibilita:** Media. Se il target reale fosse 4.3, aggiornare tutte le occorrenze KB e config nello stesso commit.

---

## 2026-07-15: D002 — Atomic execution layer per worker LLM non di punta

**Contesto:** La richiesta di produzione specifica che le risorse di sviluppo saranno modelli non di punta.

**Opzioni considerate:**
- A. Lasciare solo piani lunghi e discorsivi.
- B. Spezzare ogni wave in atomic waves con input/output/verifica.
- C. Implementare tutto direttamente senza documentare granularita.

**Decisione:** B. Creare `MASTER-ATOMIC-ROADMAP.md`, `AGENT-RUNBOOK.md` e piani atomici per wave.

**Rationale:** Modelli meno forti sbagliano soprattutto per scope creep, dipendenze implicite e verifiche saltate. La pianificazione deve compensare questi limiti.

**Trade-off:** Piu documentazione upfront, meno velocita apparente.

**Reversibilita:** Bassa. Una volta avviato il workflow atomico, i worker successivi devono seguirlo per coerenza.

---

## 2026-07-15: D003 — Ownership verticale della velocita nel Player

**Contesto:** `MovementComponent` iniziale interpolava `body.velocity` verso una velocita target con Y a zero, rischiando di interferire con gravita e salto.

**Opzioni considerate:**
- A. Lasciare tutto il vettore velocity al componente.
- B. Separare ownership: MovementComponent per X/Z, Player per Y.
- C. Creare subito un CharacterMotor piu generico.

**Decisione:** B. `MovementComponent.calculate_velocity(input_dir)` preserva `body.velocity.y`.

**Rationale:** Wave 1 richiede semplicità e feel affidabile. Separare asse verticale riduce bug su jump/coyote time.

**Trade-off:** `Player` deve applicare esplicitamente X/Z dal componente.

**Reversibilita:** Media. Un futuro CharacterMotor puo assorbire questa logica, ma solo con migration documentata.

---

## 2026-07-15: D004 — Vertical slice prima di contenuto esteso

**Contesto:** Il progetto mira al miglior gioco possibile, ma la produzione dipende da worker LLM meno forti.

**Opzioni considerate:**
- A. Costruire tutti i sistemi in parallelo.
- B. Creare prima una vertical slice piccola, forte e testabile.
- C. Concentrarsi sugli asset prima del gameplay.

**Decisione:** B. Foundation -> Combat feel -> 3 nemici core -> Police Station vertical slice -> espansione.

**Rationale:** La qualità percepita del gioco dipende prima da movimento, impatto, nemici leggibili e feedback. Contenuto grande con feel debole produce un gioco peggiore.

**Trade-off:** Alcune feature di lungo termine restano bloccate finche la slice non dimostra divertimento.

**Reversibilita:** Bassa. Cambiare questo approccio riapre rischio scope creep.

---

## 2026-07-16: D006 — Protagonist Mesh Source & Pipeline

**Contesto:** Identificato il mesh sorgente per il protagonista in `E:\Giochini\Giuseppe\Mesh\zombie+character+3d+model.glb` (generato da Tripo, 13.8 MB).

**Analisi (Observer Report):**
- Vertici: 255,908 (target: ~22K) → **12× over budget**
- Triangoli: 445,650 (target: ~33K) → **13× over budget**
- Altezza: 1.0m (target: 1.95m) → **Scale 1.95× richiesto**
- Rig/Scheletro: **Nessuno** → Richiede Rigify + skinning manuale
- Animazioni: **Nessuna** → 8 base richieste (idle, walk, run, attack_1, attack_2, death, hit, alert)
- Emissive: **Nessuna** → Richiede emissive per occhi/artigli/ferite
- Texture: 1024×1024 JPEG → Target 2048×2048 PNG/WebP
- Materiale: PBR Metallic-Roughness OK, ma **manca emissive**

**Decisione:** Il mesh NON è production-ready. Va usato come **high-poly reference** per:
1. Retopologia manuale/assistita (255K → 22K vertici)
2. Bake maps (Normal, AO, Curvature, ID) da high-poly → low-poly
3. Rigging completo (Rigify metarig → Generate rig → Skinning)
4. Animazioni base (8 minime per Wave 1-2)
5. Emissive setup + texture upgrade 2048²
6. Scale fix 1.95×

**Priorità:** Protagonista serve per **Wave 1 (Movement)** e **Wave 2 (Combat Feel)**. Va completato **PRIMA** del batch nemici (Wave 4+).

**Integrazione piano:** Aggiunto track "Protagonist Mesh (Priority: Wave 1-2)" in `MASTER-ATOMIC-ROADMAP.md` §16.1, prima del track nemici. Aggiornati `MESH-PIPELINE-PLAN.md` e `INTEGRATION-MAP.md`.

**Rischio:** Alto se non completato in tempo per Wave 1-2. Bloccante per movement/combat feel.

---

## 2026-07-20: D007 — Godot 4.7 AnimationTree API: start_node rimosso

**Contesto:** `scripts/player/animation_tree_setup.gd` falliva in headless con `SCRIPT ERROR: Invalid assignment of property or key 'start_node'`. Il codice usava `_state_machine.start_node = "Idle"` (sintassi Godot ≤4.4) e un `@onready` hardcoded su `/root/TestAnimationsVisual/...` (path inesistente).

**Opzioni considerate:**
- A. Mantenere `start_node` come String/StringName (fallisce in 4.7).
- B. Usare `set_start_node()` (non esiste in 4.7).
- C. Usare `AnimationNodeStateMachinePlayback.start(&"Idle")` recuperato da `tree.get("parameters/playback")` dopo l'assegnazione di `tree_root`.

**Decisione:** C. In Godot 4.7 `AnimationNodeStateMachine` **non ha** la proprietà `start_node`; lo stato iniziale si imposta via `AnimationNodeStateMachinePlayback.start()`. Inoltre `@onready` hardcoded sostituito con `@export var animation_player_node: AnimationPlayer` (allineato a `EnemyAnimationSetup`).

**Rationale:** Verificato via documentazione ufficiale Godot 4.7 (librarian, 2026-07-20). Il test `test_animation_system.gd` passa 68/68 dopo il fix.

**Trade-off:** richiede che l'AnimationTree sia nell'albero scena (o `tree_root` assegnato) prima di chiamare `playback.start()`.

**Reversibilità:** Bassa — è l'API corretta per 4.7; tornare a `start_node` significherebbe retrocedere a Godot ≤4.4.

---

## 2026-07-20: D008 — Player rigging: riggare chr_player_rigged.glb + transfer animazioni (C→A)

**Contesto:** `chr_player_rigged.glb` è una mesh pulita (48.8K vertici) SENZA armature nè skinning. Le animazioni di qualità `protagonist_*.glb` (idle/walk/run/jump/attack/death) esistono con skeleton 66 ossa (`UniRigArmature`, schema mesh2motion/Mixamo). Serviva un player riggato + animato montabile in Godot.

**Opzioni considerate:**
- A. Riggare `chr_player_rigged.glb` con Rigify metarig + skinning, poi transfer animazioni `protagonist_*.glb` per bone-name.
- B. (scelta) Riggare `chr_player_rigged.glb` con armature semplice 66 ossa (`UniRigArmature` da `ProtagonistaRig_M2M.glb`) + transfer weights via DataTransfer modifier da `zombie_character` (mesh sorgente con skinning valido) + animazioni procedurali generate direttamente sull'armatura semplice.
- C. Usare direttamente `ProtagonistaRig_M2M.glb` come player mesh (scarta `chr_player_rigged.glb`).

**Decisione:** B. `pipeline/rig_final.py` importa `ProtagonistaRig_M2M.glb` (armatura semplice `UniRigArmature`, 66 ossa, `zombie_character` skinnata), importa `chr_player_rigged.glb`, allinea le mesh, copia i vertex groups (weights) da `zombie_character` → `chr_player` via `DATA_TRANSFER` modifier (`vert_mapping='NEAREST'`, fallback `POLY_NEAREST`), parenta `chr_player` all'armatura, genera 6 animazioni procedurali (idle/walk/run/jump/attack/death) e esporta `scenes/player/chr_player_rigged_anim.glb`.

**Rationale:** Blender 5.2 LTS converte le armature Rigify in EMPTY `rig.001` all'export GLB → Godot vede `NO_SKELETON`. L'opzione A fallisce sistematicamente (verificato: 4 tentativi, tutti con armature perse all'export). L'opzione B usa armature SEMPLICI (non Rigify) che sopravvivono all'export GLB. Inoltre `parent_set(ARMATURE_AUTO)` su mesh importata da GLB fallisce silenziosamente (0 weights) → DataTransfer da mesh sorgente skinnata è l'unico path affidabile dato che `chr_player` e `zombie_character` hanno topologie diverse (48.8K vs 246K vertici).

**Trade-off:** le animazioni sono procedurali semplici (keyframe su ossa principali), non mocap/Cascadeur. Qualità sufficiente per Wave 1-2; upgrade successivo possibile con retargeting mocap su `UniRigArmature`.

**Reversibilità:** Media. Il glb finale è indipendente; si può riggare `chr_player_rigged.glb` da zero con schema diverso se necessario, ma richiede re-run pipeline Blender.

---

## 2026-07-20: D009 — Caricamento GLB runtime in player.gd (fix P0 scene non utilizzabili)

**Contesto:** Dopo il completamento Fase A (rigging + montaggio + cablaggio AnimationTree), l'utente riportava che le scene di test (`test_level.tscn`, `test_anim_floor.tscn`) mostravano una barra rossa di caricamento infinita e il player assente (a volte solo luce visibile, a volte mesh grigia non texturizzata). Screenshot confermavano: nessun errore visibile, viewport vuoto o geometria raw grigia.

**Opzioni considerate:**
- A. (scelta) Caricare il GLB a runtime con `GLTFDocument.new()` + `GLTFState.new()` + `append_from_file(path, state)` + `generate_scene(state)`. API Godot 4.7 ufficiale per istanziare `.glb`/`.gltf` a runtime.
- B. Convertire il `.glb` in `.tscn` via editor e `preload()` della scena. Richiede step manuale editor, meno robusto per pipeline automatizzata.
- C. Importare il GLB come `PackedScene` con `ResourceLoader.load(path, "PackedScene")`. Fallisce: `.glb` non è `PackedScene` nativa.

**Decisione:** A. `player.gd._load_rigged_model()` ora usa `GLTFDocument` + `GLTFState` per istanziare `chr_player_rigged_anim.glb`. Aggiunto `_apply_fallback_materials()` che assegna `StandardMaterial3D` grigio (0.6,0.65,0.7) alle superfici senza materiale (la mesh sorgente `chr_player_rigged.glb` è untextured → il GLB esportato non ha PBR materials).

**Rationale:** `preload()`/`load()` su `.glb` crudo ritorna `GLTFDocument`/`Resource`, NON `PackedScene` → `.instantiate()` fallisce silenziosamente → `Model` vuoto → Godot mostra spinner di caricamento infinito. L'API `GLTFDocument` è l'unica via corretta per GLB runtime in Godot 4.7. Il fallback materiale evita il grigio raw (estetica, non bloccante).

**Trade-off (risolto 2026-07-20):** inizialmente materiali grigi (fallback). Poi `pipeline/rig_final.py` aggiornato per creare `chr_player_mat` (Principled BSDF) con texture da `Mesh/ProtagonistaRig_M2M_*` (basecolor/normal/rm) e assegnarlo a `chr_player` prima dell'export. GLB rigenerato (5.2 MB, 66 ossa, 6 anim, materiale PBR presente). Verificato headless: `chr_player_mat` presente, albedo (1,1,1,1), nessun fallback grigio. Funzionalità gameplay non impattata.

**Reversibilità:** Alta. Il fix è in `player.gd` (load runtime) + `rig_final.py` (materiale). Il GLB è rigenerabile. Se si vuole PBR diverso, si aggiorna il pipeline Blender separatamente.

**Verifica:** headless `test_player_mount.gd` → GLB_INST ✓, ANIMPLAYER ✓, ANIMTREE active=true ✓, SKELETON 66 ossa ✓.


**Verifica:** Blender headless (`verify_anim.py`) → ARMATURE 66 ossa, HAS_WEIGHTS=True, 6 NLA tracks. Godot headless → Skeleton3D 66 ossa, AnimationPlayer 6 anim, AnimationTree `active=true`.

## Recent Changes

- **2026-07-16** `[FEAT]` `[P0]` `[design]`: **CORE DESIGN PRINCIPLE — Protagonist is the ONLY monster**.
  - **Contesto**: Durante generazione prompt per nemici, il modello ha proposto nemici zombificati/mutati.
  - **Correzione**: L'unico mostro è IL PROTAGONISTA (Aberration). Tutti i nemici sono **umani perfetti**: poliziotti, soldati, scienziati, medici, ingegneri, droni/robot militari industriali.
  - **Horror source**: Il mostro (protagonista) caccia umani. Gli umani hanno paura, sudore, radio, fatica, disciplina, professionalità.
  - **Impatto**: TUTTI i prompt, concept art, mesh 3D, animazioni, AI, audio per nemici devono riflettere umanità realistica. Palette C.O.S. (blu/grigi scuri) + pelle realistica + equipaggiamento tattico. Sangue SOLO su ferite/morti.
  - **Rischio**: Critico se violato — rompe l'identità visiva e narrativa del gioco.

- **2026-07-15** `[FEAT]` `[P1]` `[kb]`: creato decision log iniziale.
  - **Impatto**: chiarisce versioning, atomic workflow e ownership movement.
  - **Rischio**: basso.
