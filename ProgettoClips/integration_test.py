#!/usr/bin/env python3
"""
Integration test: esegue l'agente CLIPS contro il simulatore Wumpus World
Connette l'agente al simulatore via percept/action loop
"""

import sys
import gc
from pathlib import Path

# Carica il modulo simulatore
sys.path.insert(0, str(Path(__file__).parent / "wumpus"))

from wumpus import WumpusWorld
import clips

# Percorsi
AGENT_FILE = Path(__file__).parent / "agent.clp"
MAP_FILE = Path(__file__).parent / "wumpus" / "map1.json"

def extract_action_from_clips(env: clips.Environment) -> str:
    """
    Estrae l'azione generata dal CLIPS engine.
    Ricerca il fatto con template 'action' e ritorna il valore dello slot 'move'.
    Se non trovato, ritorna 'down' (azione di fallback)
    """
    for fact in list(env.facts()):
        if fact.template.name == "action":
            action = str(fact["move"])
            fact = None
            return action
    print("[WARN] Nessuna action prodotta da CLIPS: fallback a 'down'")
    return "down"

def main():
    print(f"[INIT] Caricamento simulatore da {MAP_FILE}")
    env_sim = WumpusWorld.from_json(str(MAP_FILE))
    
    print(f"[INIT] Caricamento agente CLIPS da {AGENT_FILE}")
    env_clips = clips.Environment()
    env_clips.load(str(AGENT_FILE))
    env_clips.reset()
    # Comunico a CLIPS le dimensioni della mappa (utili per i controlli di bordo)
    env_clips.assert_string(f"(map-dims (width {env_sim.width}) (height {env_sim.height}))")
    
    print(f"[INIT] Simulatore inizializzato: griglia {env_sim.width}x{env_sim.height}")
    print(f"[INIT] Start: {env_sim.start}, Gold: {env_sim.gold}, Wumpus: {env_sim.wumpus}")
    print()
    
    # Loop di esecuzione
    step = 0
    total_reward = 0
    last_pos = None
    stuck_count = 0
    
    while not env_sim.done and step < env_sim.max_steps:
        step += 1
        
        # Ottieni osservazione dal simulatore
        obs = env_sim._obs()
        
        print(f"[STEP {step}] Posizione: ({obs['x']}, {obs['y']}), "
              f"Energy: {obs['energy']}, "
              f"Breeze: {obs['breeze']}, Stench: {obs['stench']}, Glitter: {obs['glitter']}")
        
        # Converti osservazione in fatto CLIPS
        percept_str = (
            f"(percept "
            f"(x {obs['x']}) (y {obs['y']}) "
            f"(steps {obs['steps']}) "
            f"(breeze {str(obs['breeze']).upper()}) "
            f"(stench {str(obs['stench']).upper()}) "
            f"(glitter {str(obs['glitter']).upper()}) "
            f"(energy {obs['energy']}))"
        )
        
        # Asserisci percept nel CLIPS engine
        env_clips.assert_string(percept_str)
        
        # Pulisci azioni precedenti e counter precedenti
        for fact in list(env_clips.facts()):
            if fact.template.name in ["action", "counter"]:
                fact.retract()
        fact = None
        
        # Asserisci il counter per il nuovo step
        env_clips.assert_string(f"(counter (step {step}))")
        
        # Esegui CLIPS engine per generare l'azione (massimo 50 regole per evitare infiniti)
        env_clips.run(50)
        
        # Estrai l'azione dal CLIPS
        action = extract_action_from_clips(env_clips)

        # Guardia anti-stallo: se restiamo fermi per troppi step, forziamo una direzione alternativa.
        if stuck_count >= 2:
            forced_actions = ["down", "right", "up", "left"]
            forced_action = forced_actions[step % len(forced_actions)]
            print(f"[ANTI-STALL] Posizione bloccata da {stuck_count} step, forzo azione: {forced_action}")
            action = forced_action

        print(f"        → Azione generata: {action}")
        
        # Esegui l'azione nel simulatore
        result = env_sim.step(action)
        
        # Aggiorna reward e stato
        total_reward += result.reward
        print(f"        Reward: {result.reward:+.1f}, Reward totale: {total_reward:+.1f}")

        current_pos = (result.obs.get("x"), result.obs.get("y"))
        if last_pos == current_pos:
            stuck_count += 1
        else:
            stuck_count = 0
        last_pos = current_pos
        
        # Controlla se terminato
        if result.done:
            print()
            if env_sim.has_gold:
                print(f"[FINE] ORO PRESO! Reward finale: {total_reward:+.1f}")
            elif env_sim.dead:
                print(f"[FINE] MORTO! Reward finale: {total_reward:+.1f}")
            elif result.obs.get("energy", 1) <= 0:
                print(f"[FINE] ENERGIA ESAURITA. Reward finale: {total_reward:+.1f}")
            elif action == "quit":
                print(f"[FINE] QUIT. Reward finale: {total_reward:+.1f}")
            else:
                print(f"[FINE] TERMINATO. Reward finale: {total_reward:+.1f}")
            break
        
        print()
    
    if not result.done:
        print(f"[TIMEOUT] Raggiunto max_steps ({env_sim.max_steps})")
    
    print(f"\n[STATISTICHE]")
    print(f"  Step totali: {step}")
    print(f"  Reward finale: {total_reward:+.1f}")
    print(f"  Oro preso: {env_sim.has_gold}")
    print(f"  Agente morto: {env_sim.dead}")

    # Cleanup esplicito per evitare warning di deallocazione ambiente CLIPS.
    env_clips.reset()
    env_clips.clear()
    env_sim = None
    del env_clips
    gc.collect()

if __name__ == "__main__":
    main()
