# PROJECT ABERRATION — AGENT RUNBOOK

**Versione:** 1.0  
**Data:** 15 Luglio 2026  
**Status:** ACTIVE  
**Scope:** Protocollo operativo per worker LLM non di punta  

---

## 1. Mission

Il worker deve produrre il miglior gioco possibile **riducendo al minimo le decisioni autonome**.

Il progetto compensa modelli meno forti con:

- piani atomici
- ownership esplicita
- read order obbligatorio
- check di fine wave
- divieto di scope creep
- verifiche minime concrete

---

## 2. Pre-Action Gate

Prima di modificare:

1. Leggere `META-RULES.md`.
2. Leggere `CONTRATTO-LLM.md`.
3. Leggere `INDEX.md`.
4. Leggere `DECISIONS-LOG.md`.
5. Leggere `INTEGRATION-MAP.md`.
6. Leggere solo il piano della wave assegnata.
7. Verificare `git status --short`.

Se `git status --short` contiene modifiche non comprese, fermarsi e riportare.

---

## 3. Worker Prompt Template

Usare questo formato quando si assegna una Atomic Wave:

```text
TASK: Execute AWX.Y from WAVE[N]-ATOMIC-EXECUTION-PLAN.md.

READ FIRST:
- META-RULES.md
- CONTRATTO-LLM.md
- INDEX.md
- DECISIONS-LOG.md
- INTEGRATION-MAP.md
- WAVE[N]-ATOMIC-EXECUTION-PLAN.md

SCOPE:
- Modify only files listed in AWX.Y.
- Do not implement future-wave systems.
- Update KB in same commit if code changes.

VERIFY:
- Run the exact verification listed in AWX.Y.
- Report failures explicitly.

STOP:
- Stop after AWX.Y is complete.
- Do not continue to AWX.Y+1.
```

---

## 4. Quality Bias

Per questo progetto, qualita significa:

| Area | Good | Bad |
|------|------|-----|
| Movement | rapido, leggibile, animale | lento, umano, floaty |
| Combat | impatto chiaro, hit stop, sangue, knockback | numeri invisibili |
| AI | pressione di gruppo leggibile | nemici che corrono dritti |
| Art | silhouette forte, outline, tre occhi | design generico |
| Audio | feedback per ogni azione | loop ambientale passivo |
| Mobile | 60 FPS stabile | effetto bello ma pesante |

Se una scelta non migliora una di queste aree, non implementarla.

---

## 5. Stop Conditions

Il worker deve fermarsi se:

- il file richiesto non esiste e la wave non autorizza a crearlo
- Godot segnala errore parser
- una modifica richiede piu di una wave
- serve cambiare un invariante
- il worker non sa quale modulo possiede una responsabilita
- una verifica non puo essere eseguita

In caso di stop, riportare:

- cosa e stato fatto
- cosa non e stato fatto
- quale file o decisione blocca
- proposta minima per sbloccare

---

## 6. Best-Game Heuristic

Ogni feature deve superare tre domande:

1. **Il giocatore la sente entro 5 secondi?**
2. **Rende piu forte una pillar: predatore, swarm, mobilita, brutalita?**
3. **Puo essere verificata in una scena piccola?**

Se una risposta e no, la feature va rimandata o tagliata.

---

## 7. Recent Changes

- **2026-07-15** `[FEAT]` `[P1]` `[process]`: creato runbook per worker LLM non di punta.
  - **Impatto**: definisce prompt template, stop conditions e quality bias.
  - **Rischio**: basso.
