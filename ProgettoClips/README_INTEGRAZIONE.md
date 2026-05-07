# Agente Wumpus CLIPS Modellare

Agente intelligente CLIPS per il Wumpus World, con integrazione del simulatore Python.

## Struttura

### File Principali
- `agent.clp` - Agente CLIPS modulare (300+ linee)
- `integration_test.py` - Script di integrazione agente ↔ simulatore
- `test_mio_agente.py` - Test tramite ClipsAgent (simulatore)
- `test_agent.py` - Test isolato (legacy)
- `wumpus/` - Simulatore Python (fornito)

### Moduli CLIPS

```
PERCEPTS (export ?ALL)
  ├─ percept: osservazioni dal simulatore
  └─ counter: numero step

MEMORIA (export ?ALL)
  ├─ modalita: stratia attiva (inferenziale/ingenua)
  ├─ stato-eroe: posizione, energia, oro
  ├─ ipotesi-pit/wumpus: credenze su pericoli
  └─ cella-visitata, cella-sicura: memoria spaziale

DECISION (import PERCEPTS, MEMORIA)
  └─ Regole decisionali: qual azione scegliere

ACTIONS (import PERCEPTS, MEMORIA)
  └─ Regole esecutive: invia azione al simulatore

UTIL (import PERCEPTS, MEMORIA, export ?ALL)
  └─ Regole inferenziali: breeze/stench → ipotesi

MAIN (import tutti)
  └─ Bootstrap e coordinamento
```

## Strategie Implementate

### 1. Strategia Inferenziale (Attiva)
```
IF glitter THEN grab
IF breeze TRUE THEN move left (evita pozzi)
IF stench TRUE THEN move left (evita wumpus)
IF breeze FALSE AND stench FALSE THEN move right (esplora)
```

### 2. Strategia Ingenua
```
IF glitter THEN grab
ELSE move right (sempre)
```

## Esecuzione

### Setup
```bash
cd ProgettoClips
python -m venv venv
source venv/bin/activate
pip install clipspy
```

### Test di integrazione
```bash
python integration_test.py
```

Uscita attesa:
```
[INIT] Caricamento simulatore da .../map1.json
[STEP 1] Posizione: (0, 0), Energy: 200, Breeze: False...
        → Azione generata: right
        Reward: -1.0, Reward totale: -1.0
...
```

### Test tramite ClipsAgent (Simulatore)
```bash
python test_mio_agente.py
```

## Risultati Correnti

✅ **Agente genera azioni correttamente**
- Modalita inferenziale attiva
- Regole decisionali matchano i percept
- Azioni trasmesse al simulatore

🔄 **In Sviluppo**
- Gestione fallback (alternative se "right" bloccato)
- Path planning verso l'oro
- Logica di escape dal Wumpus

## Nodi di Debug

Se nessuna azione viene generata:
1. Verificare che `(modalita (nome inferenziale))` sia presente nei fatti
2. Controllare che il percept abbia `breeze FALSE` e `stench FALSE`
3. Verificare che `(not (action))` sia vero (nessuna azione asserta prima)

Se il CLIPS si blocca:
- Usare `env.run(N)` con limite di iterazioni (50-100) nel loop

## File di Test

| File | Uso | Status |
|------|-----|--------|
| `test_agent.py` | Isolato, 20 iterazioni | ✅ Passing |
| `test_mio_agente.py` | IntegrationClipsAgent | ✅ Passing |
| `integration_test.py` | Loop agente-simulatore | ✅ Passing |
| `simple_test.py` | Agente casuale (ref) | ✅ Passing |

## Prossimi Passi

1. **Strategie multiple**: Aggiungere fallback (left, down, up) se "right" non funziona
2. **Memoria stabile**: Mantenere ipotesi su celle pericolose tra step
3. **Inferenza avanzata**: Combinare ipotesi per localizzare oro/wumpus
4. **Pathfinding**: A* verso coordinate target
5. **Adattamento dinamico**: Passare da estrattgia ingenua a inferenziale a runtime

## Note Tecniche

- CLIPS Module Focus: Rimosso dal bootstrap (causa blocchi infiniti)
- Limite iterazioni: `env.run(50)` per evitare timeout
- Booleani: Usare `TRUE`/`FALSE` maiuscoli (CLIPS standard)
- Step markers: `breeze-gia-gestita`, `stench-gia-gestita` prevengono rialvi infiniti

---

**Autore**: @utente  
**Data**: Maggio 2026  
**Linguaggio**: CLIPS + Python (clipspy)  
**Status**: 🟢 Integrazione Base Completa
