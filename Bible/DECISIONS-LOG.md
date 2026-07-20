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
