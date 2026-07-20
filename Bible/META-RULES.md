# Metaregole Knowledge Base — Universal v3.2

> **Se un altro sviluppatore (o AI) non può capire il sistema leggendo SOLO la KB → la KB è sbagliata.**

> **Versione Unificata**: Applicabile a tutti i progetti Cascade AI (Sabot-Ecosystem, CyberLearn Hub, Auto-GSD, ecc.)

---

## REGOLA ZERO: NO KB = NO DEPLOY

**Qualsiasi modifica al codice senza aggiornamento KB è un errore di processo.**

Il sistema è considerato in stato inconsistente finché la KB non riflette il codice.

| Contesto | Enforcement |
|----------|-------------|
| CI/CD formale | Blocca merge/deploy |
| Dev locale | Il commit DEVE includere code + docs |
| Hotfix urgente | Deploy permesso, MA inserire `<!-- KB-DEBT: descrizione -->` nel modulo interessato e classificare come P0 alla sessione successiva |

> 🔴 **Se la KB non è aggiornata, la modifica è considerata NON VALIDA.**

---

## §1 — FONDAMENTO: Cos'è la KB

### 1.1 KB = Sistema (Livello Logico)

La KB non **descrive** il sistema — **È** il sistema a livello logico.

**Implicazioni operative**:
- Se il codice ≠ KB → uno dei due è sbagliato (risolvere con §1.2)
- Debugging senza KB aggiornata = tempo perso
- AI assistant devono poter operare leggendo **solo** la KB

### 1.2 Risoluzione Conflitti KB ↔ Codice

Quando si scopre una discrepanza:

| Situazione | Azione |
|------------|--------|
| Il codice è corretto, la KB no | Aggiornare la KB (drift fix) — taggare `[DRIFT-FIX]` |
| La KB è corretta, il codice no | Il codice ha un bug — fixarlo |
| Ambiguo | Documentare in DECISIONS-LOG.md, chiedere all'utente |

### 1.3 Sistema di Priorità P0–P3

Ogni modifica ha un livello di criticità che determina deadline e obblighi.

| Livello | Tipo modifica | Obbligo KB | Obbligo Commit | Deadline |
|---------|--------------|------------|----------------|----------|
| **P0** (Critico) | Anti-loop, anti-bot, routing, sicurezza, invarianti, API breaking | IMMEDIATO | IMMEDIATO | Stesso step |
| **P1** (Alto) | Feature, bug fix logico, cambio algoritmo, UX critica | OBBLIGATORIO | OBBLIGATORIO | Fine task/24h |
| **P2** (Medio) | Refactoring, performance, nuova piattaforma, cleanup, ottimizzazione | OBBLIGATORIO | CONSIGLIATO | Fine sessione/72h |
| **P3** (Basso) | Naming, commenti, typo docs, docs pura | FACOLTATIVO | FACOLTATIVO | Best effort/Next release |

**Regole di classificazione automatica**:

```
IF invariante_modified        → classify(P0)
IF new_module OR new_platform → classify(P1_min)
IF fix_anti_bot_anti_loop     → classify(P0)
IF unclassifiable             → classify(P1)   // default — mai lasciare non classificato
```

### 1.4 Simmetria Codice ↔ KB

Per ogni variabile, funzione o meccanismo critico nel codice, la KB deve usare il **nome identico**.

| ❌ Vietato in KB | ✅ Obbligatorio |
|-----------------|----------------|
| "forwarded check" | `isForwardedByBot` |
| "il controllo del loop" | `forwardedByBotCache` |
| "la funzione di ricerca" | `findRouteBySourceAcrossContexts()` |

```
IF name_changed_in_code → name_must_change_in_KB(same_commit=True)
```

---

## §2 — PROCESSO: Come Aggiornare

### 2.1 Aggiornamento Atomico

Codice e KB devono essere aggiornati nello **stesso step logico**.

```
❌ VIETATO                          ✅ CORRETTO
1. Modifico codice                  1. Modifico codice
2. "Aggiorno KB dopo"              2. Aggiornare KB subito
3. (dimenticato)                    3. Commit unico (code + docs)
```

**Ordine di aggiornamento** (dependency-aware):
1. Moduli foglia (nessun downstream) → primi
2. Moduli intermedi → secondi
3. INTEGRATION-MAP.md → dopo i moduli
4. INDEX.md → ultimo (riflette stato finale)

### 2.2 Documentazione Minima Garantita

```
update(Modifiche_Recenti)  // SEMPRE — non negoziabile

IF comportamento_changed  → update(Flusso_Interno)
IF is_bug_fix             → update(Edge_Cases)
IF assunzione_changed     → update(Critical_Knowledge)
IF firma_changed          → update(API_Reference)
IF invariante_changed     → update(Invarianti)

ASSERT count(sections_updated) >= 1
// Se 0 sezioni aggiornate → stai modificando qualcosa che non capisci abbastanza
```

### 2.3 Template Modulo v3

Ogni file modulo segue questa struttura. Le sezioni marcate `[OPT]` sono opzionali. Tutte le altre sono obbligatorie.

```markdown
<!-- template: module-v3.0 -->
# NOME_MODULO

## Overview
- **File**: `path/to/file.{js,py,ts}`
- **Tipo**: [core|service|manager|bot|util|scraper|adapter|api|model|handler|middleware|config]
- **Responsabilità**: Una riga
- **Stato**: [stable|hot|unstable|critical|experimental|deprecated|draft]
- **Dipendenze**: Elenco diretto

## API Reference
### Funzioni / Classi Esportate
| Nome | Input | Output | Side Effect | Complexity | Dipendenze |
|------|-------|--------|-------------|------------|------------|

## Flusso Interno
[Pseudo-codice con condizioni booleane esplicite — vedi §3.1]

## Invarianti
> Condizioni che DEVONO essere sempre vere. Se un'invariante cambia → P0.
- `invariante_1`: descrizione
- `invariante_2`: descrizione

## Design Rationale
- **Perché esiste**:
- **Perché implementato così**:
- **Trade-off**:
- **Cosa rompe se tolto**:

## Integrazioni
- **Upstream**: Chi lo chiama
- **Downstream**: Chi chiama lui
- **Eventi**: Eventi ascoltati/emessi

## Edge Cases
- **Caso**: [descrizione scenario]
  → **Comportamento**: [cosa succede]
  → **Si verifica se**: [condizione trigger]
  → **NON rimuovere**: [cosa protegge da regressione]
  → **Introdotto**: [data fix]

## Critical Knowledge [OPT]
[Quello che NON deve essere ignorato — assunzioni, fallback, side effect]

## Log Mapping [OPT — obbligatorio per core/manager]
| Pattern Log | Significato | Punto nel Flusso |
|-------------|-------------|-----------------|

## Modifiche Recenti
- **YYYY-MM-DD** `[TIPO]` `[Pn]` `[area]`: Descrizione
  - **Impatto**: [dove si propaga]  ← obbligatorio per P0–P1
  - **Rischio**: [basso|medio|alto] ← obbligatorio per P0–P1
```

**Tipi tag per Modifiche Recenti**: `FIX`, `FEAT`, `REFACTOR`, `DRIFT-FIX`, `EDGE-CASE`

**Rotazione**: Mantenere max 10 entry. Oltre 10, archiviare le più vecchie nel modulo stesso sotto `## Storico Modifiche [ARCHIVIO]` in fondo al file.

### 2.4 Stati Modulo

| Stato | Significato | Transizione |
|-------|-------------|-------------|
| `stable` | Nessun bug noto, non toccato di recente | ← auto dopo 48h senza modifiche |
| `hot` | Modificato nelle ultime 48h | ← ogni modifica attiva questo |
| `unstable` | Bug noti non ancora risolti | ← segnalazione bug |
| `critical` | Rischio in produzione attivo | ← richiede P0 per uscire |
| `experimental` | Nuovo, non ancora testato in produzione | ← nuovo modulo |
| `deprecated` | Obsoleto, da rimuovere | ← deprecation notice |

---

## §3 — QUALITÀ: Come Scrivere Bene

### 3.1 Zero Ambiguità

Nelle sezioni tecniche (`Flusso Interno`, `Edge Cases`, `Invarianti`) è **vietato** usare verbi vaghi.

| ❌ Vietato | ✅ Sostituzione |
|-----------|----------------|
| "gestisce" | "riceve X, produce Y, chiama Z" |
| "processa" | "per ogni elemento: [step 1, step 2, ...]" |
| "controlla" | "IF condizione → azione" |
| "filtra" | "IF condizione → SKIP" |
| "gestisce errori" | "try/catch → log(pattern) + fallback F" |

**Esempio concreto**:

```
❌  "Filtra i messaggi inoltrati"

✅  isForwarded = message.fwdFrom !== undefined
    isOutgoing = message.out AND !isForwarded
    IF isSelfMessage OR isOutgoing → SKIP (return)
```

> **Nota**: Questo vincolo si applica SOLO alle sezioni tecniche. `Overview` e `Design Rationale` possono usare linguaggio naturale discorsivo.

### 3.2 Invarianti come Contratto

Ogni modulo deve dichiarare le condizioni che **devono essere sempre vere**. Gli invarianti non sono documentazione — sono **contratti**.

```markdown
## Invarianti
- `filtro anti-loop PRIMA di route matching` → se invertito: loop infinito
- `isOutgoing = message.out AND !isForwarded` → mai solo message.out
- `chatId formato: -100{channelId}` → mai channelId nudo
```

```
IF invariante_changed:
    classify(P0)
    update_all_referencing_modules()  // IMMEDIATO
```

### 3.3 Edge Case Driven

Ogni bug fix deve produrre **almeno 1 edge case documentato** nel modulo.

```
IF is_bug_fix → ASSERT edge_cases_added >= 1
```

Il campo `NON rimuovere` è il meccanismo anti-regressione: identifica esplicitamente quale condizione protegge il sistema dal bug.

```markdown
## Edge Cases
- **Caso**: Messaggio forward cross-context con message.out=true
  → **Comportamento**: Permesso (non bloccato da anti-loop)
  → **Si verifica se**: Utente inoltra da canale in contesto diverso
  → **NON rimuovere**: `!isForwarded` nel filtro 2
  → **Introdotto**: 2025-04-12 (fix cross-context routing)
```

### 3.4 Cross-Referencing Obbligatorio

Ogni nuova interazione tra moduli deve aggiornare **sempre**:

| File | Quando aggiornare |
|------|-------------------|
| Il **modulo sorgente** (sezione Integrazioni → Downstream) | Sempre |
| Il **modulo destinazione** (sezione Integrazioni → Upstream) | Sempre |
| **INTEGRATION-MAP.md** | Se nuova chiamata tra moduli |
| **DECISIONS-LOG.md** | Se scelta architetturale significativa |
| **INDEX.md** | Se stato modulo cambia |

> ⚠️ **Se una chiamata tra moduli non è mappata in INTEGRATION-MAP.md → è considerata dipendenza nascosta (BUG di documentazione).**

### 3.5 Design Rationale Non Opzionale

```
IF priority IN [P0, P1]:
    REQUIRE design_rationale CONTAINS:
        - why_this_solution      // e non le alternative
        - what_breaks_if_removed
        - accepted_trade_off
// Se non sai rispondere → non puoi modificarlo
```

---

## §4 — ATOMICITÀ: Principio di Minima Sorpresa

### 4.1 Una Modifica = Uno Scopo

| Anti-pattern | Pattern corretto |
|--------------|------------------|
| "Fix bug + refactor + nuova feature" | 3 commit separati, ciascuno P appropriato |
| "Update docs ovunque" | Un modulo alla volta, atomico |
| "WIP: cambiato tutto" | Commit per unità logica completata |

### 4.2 Breaking Changes

```
IF is_breaking_change:
    classify(P0)
    → doc_impact(KB_modulo)
    → write(MIGRATION.md)
    → add_deprecation_notice(codice)  // se possibile
    → commit("BREAKING: descrizione [P0]")
```

---

## §5 — WORKFLOW OPERATIVO: Day-to-Day

### 5.1 Nuova Feature (P1/P2)

```
1. Scrivere KB del nuovo modulo (draft)
2. Implementare codice
3. Aggiornare KB (sezioni tecniche)
4. Self-review: codice vs KB align?
5. Commit: `feat: X [P1]`
```

### 5.2 Bug Fix (P0 se core, P1 se edge)

```
1. Riprodurre bug
2. Aggiornare KB: sezione Edge Cases con nuovo scenario
3. Fix codice
4. Test passa
5. Commit: `fix: X [P0/P1]`
6. IF P0: update changelog + migration se breaking
```

### 5.3 Refactoring (P2, P1 se tocca core)

```
1. Documentare stato pre-refactor in KB
2. Eseguire refactor
3. Aggiornare KB (API, Flusso, Invarianti)
4. Commit: `refactor: X [P2]`
```

### 5.4 KB Debt Recovery

```
IF found(<!-- KB-DEBT: desc -->):
    classify(P0)
    resolve(next_session)
    ASSERT kb_debt_accumulated == False
```

### 5.5 Debugging

→ Protocollo completo: **vedi §7**.

### 5.6 Checklist Pre-Commit

Prima di considerare un task completato:

- [ ] Modifica classificata (P0–P3)
- [ ] KB aggiornata nello stesso step (atomicità)
- [ ] `Modifiche Recenti` aggiornata con tag e priorità
- [ ] Almeno 1 sezione tecnica aggiornata (§2.2)
- [ ] Edge case aggiunto (se bug fix)
- [ ] Invarianti aggiornati (se toccati → P0)
- [ ] INTEGRATION-MAP.md aggiornato (se nuove chiamate tra moduli)
- [ ] Naming coerente codice ↔ KB (§1.4)
- [ ] Design Rationale aggiornato (obbligatorio per P0–P1)
- [ ] Commit unico: code + docs insieme

### 5.7 Self-Check per AI Assistant

Dopo ogni modifica di codice, verificare:

| Domanda | Se sì → Aggiornare |
|---------|---------------------|
| Ho modificato la firma di una funzione esportata? | `API Reference` |
| Ho aggiunto un import/dipendenza? | `Integrazioni` + `INTEGRATION-MAP.md` |
| Ho cambiato un invariante? | `Invarianti` (+ classificare P0) |
| Ho scoperto un caso limite non ovvio? | `Edge Cases` |
| Ho modificato il flusso logico? | `Flusso Interno` |
| Ho cambiato un'assunzione sull'ambiente? | `Critical Knowledge` |
| Ho introdotto un nuovo pattern di log? | `Log Mapping` |

### 5.8 Flusso Corretto End-to-End

> *Sintesi operativa di §2.1, §2.2 e §5.1–5.4 — riferimento rapido end-to-end.*

```
1. Identificato problema o richiesta feature
2. Classificare priorità (P0–P3)
3. Leggere modulo KB del componente coinvolto
4. Verificare che KB sia allineata al codice (§1.2)
5. Implementare fix/feature nel codice
6. Aggiornare KB:
   a. Modifiche Recenti (SEMPRE)
   b. Sezione tecnica pertinente (§2.2)
   c. Edge case (se bug fix)
   d. Invarianti (se condizioni always-true cambiate)
   e. INTEGRATION-MAP.md (se nuove chiamate)
   f. DECISIONS-LOG.md (se scelta architetturale)
7. Commit unico: code + docs
8. INDEX.md: aggiornare stato modulo se cambiato
```

---

## §6 — GIT & VERSIONAMENTO

### 6.1 Commit Convention

```
[type]: [short desc] [P]

[body: spiegazione tecnica]

[footer: refs, breaking notes]
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `security`, `config`, `BREAKING`

**Esempio**:
```
feat: add user authentication middleware [P1]

Implement JWT validation with refresh token rotation.
Supports multiple algorithms (RS256, ES256).

Refs: #123
BREAKING: old token format deprecated
```

### 6.2 Branching Strategy

- **main**: Production-ready, sempre deployabile
- **feature/{name}**: Feature development, rebase su main frequente
- **hotfix/{name}**: Fix critici, branch da main, merge immediato

**No long-lived feature branches** — max 3-5 giorni.

### 6.3 Git Workflow Consigliato

```bash
# 1. Verificare modifiche
# 2. Testare su ambiente target
# 3. Aggiornare KB (modulo + INTEGRATION-MAP se nuove chiamate)
# 4. Stage file modificati (code + docs insieme)
# 5. Commit con messaggio descrittivo includendo priorità
# 6. Push (se repository remoto configurato)
```

> **Regola**: Se il sistema è in produzione attiva, committare **PRIMA** del riavvio per avere un punto di rollback.

---

## §7 — DEBUGGING: Investigation Protocol

### 7.1 Protocollo Completo KB-Aware

Ogni debug inizia con la KB. Prima di qualsiasi ipotesi, seguire questo workflow:

```
1. LEGGERE LOG       → cercare pattern nel file log del progetto
2. MAPPARE SU KB     → trovare il modulo e il punto nel Flusso Interno
3. VERIFICARE CODICE → confrontare codice attuale con KB
4. IMPLEMENTARE FIX
5. AGGIORNARE KB     → aggiungere il nuovo edge case / fix
```

**Lettura KB per debug** — chiedersi:
- Quale modulo? → Vai alla sua KB
- Cosa dice la sezione "Edge Cases"?
- C'è un pattern simile in "Recent Changes"?
- Invarianti violati?

> **NON chiedere mai all'utente**: "Hai i log recenti?"  
> **MA controllare direttamente**: `read_file` su file log o `grep_search` per pattern specifici.

> **Saltare la KB = debugging incompleto.**

### 7.2 Se KB Non Aiuta → KB è Sbagliata

Non il codice — la KB. Fixare la KB prima o insieme al codice.

### 7.3 Log Analysis Checklist

- [ ] Identificare modulo coinvolto (da path/log)
- [ ] Cercare pattern ricorrenti nelle KB
- [ ] Cross-reference con INTEGRATION-MAP
- [ ] Se nuovo pattern → aggiungere a KB modulo

---

## §8 — DECISIONI & ARCHITETTURA

### 8.1 DECISIONS-LOG.md

Ogni decisione architetturale significativa deve essere loggata:

```markdown
## YYYY-MM-DD: [Titolo Decisione]

**Contesto**: Perché dovevamo decidere
**Opzioni considerate**: A, B, C
**Decisione**: X
**Rationale**: Perché X e non Y
**Trade-off**: Cosa accettiamo in cambio
**Reversibilità**: Possiamo cambiare idea? Costo?
```

### 8.2 Integration Map

Mappa visuale delle chiamate tra moduli.

```
IF new_api_exposed OR contract_changed OR endpoint_removed:
    update(INTEGRATION-MAP.md)
```

---

## §9 — MANUTENZIONE: KB Health

### 9.1 Weekly Review (15 min)

- [ ] Moduli `unstable` o `critical` — piano di stabilizzazione
- [ ] `<!-- KB-DEBT -->` — zero tolleranza
- [ ] INTEGRATION-MAP allineata?

### 9.2 Monthly Audit

- [ ] Review moduli con ultima modifica > 30gg
- [ ] Update stato da `experimental` a `stable` se pronto
- [ ] Deprecare moduli obsoleti

### 9.3 KB Drift Detection

```
IF codice != KB:
    tag(modulo, "<!-- KB-DRIFT: desc -->")
    classify(P0)
    schedule_fix(within=24h)
```

### 9.4 KB Health Metrics

| Metrica | Soglia Accettabile |
|---------|-------------------|
| Moduli con ultima review > 30gg | ≤ 3 |
| Moduli con stato `unstable` o `critical` | ≤ 2 |
| INTEGRATION-MAP allineata | Sempre ✅ |
| Ultimo entry in DECISIONS-LOG | ≤ 30gg fa |
| Moduli con `<!-- KB-DEBT -->` | 0 (risolverli è P0) |

### 9.5 Conseguenze del Non-Seguire

| Violazione | Conseguenza |
|------------|-------------|
| KB non aggiornata | Debugging 10x più lento, stato sistema inconsistente |
| Invarianti non documentati | Bug invisibili, regressioni silenzio |
| Edge cases non documentati | Stesso bug fixato due volte |
| Log non mappati su KB | Debugging cieco, pattern incomprensibili |
| Design rationale assente | Refactoring distruttivo, decisioni perse |
| Dipendenze non mappate | Side effect imprevedibili, integrazioni rotte |
| Naming non simmetrico | Confusione code↔docs, KB inutilizzabile |

---

## §10 — CONSISTENZA SEMANTICA GLOBALE

### 10.1 Regola di Coerenza Globale

Ogni cambiamento che modifica un concetto globale (versioni, numero fasi, invarianti, architettura) DEVE aggiornare TUTTE le sue occorrenze nella KB.

```
ON concept_changed(old_value, new_value):

    1. grep_all(old_value, extensions=[.md, .py, .js, .ts])

    2. FOR each match:
           IF obsolete     → update(new_value)
           IF historical   → mark_as_historical()   // lasciare ma commentare
           IF intentional  → document_reason()       // es. legacy code

    3. IF not_immediately_fixable:
           tag("<!-- KB-DRIFT: motivo -->")
           classify(P0)
           schedule_fix(within=24h)

// Violazione = P0 automatico
```

### 10.2 Test di Validità

```
IF count(distinct_values(concept)) > 1 → KB is INCONSISTENT
```

**Concetti globali da monitorare**:
- Version strings (v3.1, v5.0, v5.10)
- Numero fasi state machine (9, 11)
- Invarianti di sistema
- Nomi di meccanismi critici
- Struttura file (.gsd/runs/, kb/, etc.)

### 10.3 Tooling Support

```bash
# Cerca occorrenze di un concetto
grep -r "9 fasi" --include="*.md" kb/ .windsurf/

# Cerca version strings obsolete
grep -r "v3.1\|v5.0" --include="*.md" ./

# Cerca invarianti
grep -r "invariante\|invariant" --include="*.md" kb/
```

---

## §11 — INTENT PARSING & GESTIONE DELL'IMPLICITO

### 11.1 Regola Fondamentale

> **Analisi ≠ Comando**

Se l'input utente descrive, critica o analizza un comportamento,  
NON implica autorizzazione ad agire.

**Violazione = P0 (errore sistemico di interpretazione)**

### 11.2 Classificazione Obbligatoria dell'Input

Ogni input deve essere classificato PRIMA di qualsiasi azione:

| Tipo | Descrizione | Azione |
|------|-------------|--------|
| `COMMAND` | Richiesta esplicita (verbo imperativo o richiesta diretta) | Eseguire |
| `QUESTION` | Domanda informativa | Rispondere |
| `ANALYSIS` | Critica, osservazione, debugging | NON agire |
| `STATEMENT` | Dichiarazione neutra o intenzione | NON agire |
| `AMBIGUOUS` | Possibile comando ma non esplicito | Chiedere conferma |

### 11.3 Invarianti (Contratto §3.2)

**Invarianti**:

- `input_classification_precedes_action = True`
  → Classificazione SEMPRE eseguita prima di qualsiasi decisione operativa

- `no_action_without_explicit_command = True`
  → IF tipo != COMMAND → STOP (nessuna esecuzione)

- `analysis_does_not_trigger_execution = True`
  → Tipo ANALYSIS → vietato proporre o eseguire soluzioni

- `statement_does_not_trigger_execution = True`
  → Tipo STATEMENT → vietata qualsiasi azione o estensione

- `ambiguity_requires_confirmation = True`
  → Tipo AMBIGUOUS → obbligatorio chiedere conferma esplicita

- `no_unsolicited_behavioral_commitments = True`
  → Vietato dichiarare cambiamenti comportamentali non richiesti

- `no_scope_extension_without_command = True`
  → Vietato estendere lo scope senza richiesta esplicita

> **Se un invariante viene violato → classificazione automatica P0**

### 11.4 Flusso Interno (Deterministico §3.1)

```
tipo = classify(input)

IF tipo == COMMAND:
    EXECUTE richiesta

ELIF tipo == QUESTION:
    RETURN risposta

ELIF tipo == ANALYSIS:
    RETURN riconoscimento (NO azione)

ELIF tipo == STATEMENT:
    RETURN ack minimale (NO azione)

ELIF tipo == AMBIGUOUS:
    RETURN richiesta_chiarimento

ELSE:
    RETURN errore_classificazione
```

**Vietato in ANALYSIS e STATEMENT**:
- Proporre soluzioni
- Dichiarare cambiamenti comportamentali
- Avviare processi
- Estendere il scope

### 11.5 Pattern di Errore Ricorrente

```
// VIETATO
Utente identifica problema → AI propone/implementa soluzione automaticamente

// CORRETTO
Utente identifica problema → AI riconosce → attende comando esplicito
```

### 11.6 Test di Validità (Pre-Action Gate)

*(Gate pratico — derivato dagli invarianti §11.3)*

```
IF NOT explicit_user_request → STOP
IF inferring_need            → STOP
IF extending_scope           → STOP
```

### 11.7 Edge Cases

- **Caso**: Input analitico interpretato come comando
  → **Comportamento errato**: esecuzione non richiesta
  → **Comportamento corretto**: nessuna azione
  → **NON rimuovere**: controllo tipo input prima di execution
  → **Introdotto**: 2026-04-23 (fix implicito)

### 11.8 Design Rationale

- **Perché esiste**: prevenire esecuzioni non autorizzate da ambiguità semantica
- **Perché implementato così**: invarianti espliciti + flusso deterministico eliminano interpretazioni soggettive
- **Trade-off**: riduzione proattività vs aumento controllo e prevedibilità
- **Cosa rompe se tolto**: comportamento autonomo non controllato, escalation implicita

---

## Appendice A — Auto-GSD Project

**Meccanismi critici** (sempre P0 se modificati):
- Checkpoint interattivo (FASE 5) — unico punto di controllo umano
- Retry logic (max 3 tentativi) → ESCALATE
- Fresh session per task — no context accumulation
- State machine 11 fasi — transizioni rigide (INIT, DISCOVERY, REQUIREMENTS, DESIGN, TASKS, CHECKPOINT, SETUP_RUN, DISPATCH, EXECUTE, VERIFY, REPLAN, VALIDATE)
- File-based persistence — `.gsd/runs/{timestamp}/`

**Invarianti:**
- `version_string_consistent = True` — versione deve essere coerente tra SKILL.md, AUTO-GSD-MODULE.md, MANUALE.md, DEVELOPER-HANDBOOK.md, MANUALE-AUTO-GSD.md
- Version string incoerente → P0 automatico
- State machine 11 fasi — transizioni rigide
- Memory integrity — lessons.json, patterns.json, errors.json aggiornati atomicamente

**Struttura file critica**:
- `state.json` — Source of truth stato run
- `tasks.json` — Queue con dependencies
- `log.md` — Human-readable trace
- `session.log` — Append-only tool calls log
- `.lock` — Crash recovery (PID, timestamp)

**Pattern di ricerca**:
```
[CHECKPOINT]                    → Decisioni checkpoint Y/N/S
[DISPATCH]                      → Selezione task ready
[EXECUTE]                       → Invocazione @kiro-impl
[VERIFY]                        → Validazione risultato
[RETRY {n}/3]                   → Tentativo recovery
[ESCALATE]                      → Max attempts raggiunto
[RUN COMPLETED]                 → Tutti task done
```

---

## Appendice B — Template (per altri progetti)

**Meccanismi critici** (sempre P0 se modificati):
- [Da compilare per progetto specifico]

**File log**: [Pattern logging progetto]

**Pattern di ricerca comuni**:
```
[EXAMPLE-START]                 → Inizio operazione
[EXAMPLE-COMPLETE]              → Completamento
[EXAMPLE-ERROR]                 → Errore gestito
[EXAMPLE-RETRY]                 → Retry attempt
```

---

> **Se un altro sviluppatore (o AI) non può capire il sistema leggendo SOLO la KB → la KB è sbagliata.**

---

**Ultima modifica**: 2026-05-11  
**Autore**: Cascade AI Assistant  
**Stato**: ✅ Approvato e in vigore  
**Versione**: 3.3 Universal (Integrated — META-RULES.md + META-RULES-UNIVERSAL.md)

