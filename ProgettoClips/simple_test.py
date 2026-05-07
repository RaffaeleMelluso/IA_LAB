#!/usr/bin/env python3
"""
Test semplificato usando il ClipsAgent di wumpus.py
"""

import sys
from pathlib import Path

# Carica il modulo simulatore
sys.path.insert(0, str(Path(__file__).parent / "wumpus"))

from wumpus import WumpusWorld, ClipsAgent

# Percorsi
AGENT_FILE = Path(__file__).parent / "wumpus" / "agent.clp"
MAP_FILE = Path(__file__).parent / "wumpus" / "map1.json"

def main():
    print(f"[INIT] Caricamento simulatore da {MAP_FILE}")
    world = WumpusWorld.from_json(str(MAP_FILE))
    
    print(f"[INIT] Caricamento agente CLIPS da {AGENT_FILE}")
    agent = ClipsAgent(str(AGENT_FILE))
    
    print(f"[INIT] Simulatore inizializzato: griglia {world.width}x{world.height}")
    print()
    
    # Loop di esecuzione
    obs = world.reset()
    total_reward = 0
    
    for step in range(1, 50):
        # Asserisci il percept
        agent.clear_action_facts()
        agent.assert_percept(obs)
        agent.update_time_counter(obs)
        
        print(f"[STEP {step}] Pos: ({obs['x']}, {obs['y']}), "
              f"Energy: {obs['energy']}, "
              f"Breeze: {obs['breeze']}, Stench: {obs['stench']}, Glitter: {obs['glitter']}")
        
        # Esegui CLIPS e ottieni azione
        action = agent.run_and_get_action()
        print(f"        → Azione: {action}")
        
        # Esegui azione nel simulatore
        result = world.step(action)
        obs = result.obs
        total_reward += result.reward
        
        print(f"        Reward: {result.reward:+.1f}, Totale: {total_reward:+.1f}")
        
        if result.done:
            print()
            if world.has_gold:
                print(f"[FINE] ORO PRESO! Reward finale: {total_reward:+.1f}")
            elif world.dead:
                print(f"[FINE] MORTO! Reward finale: {total_reward:+.1f}")
            else:
                print(f"[FINE] QUIT. Reward finale: {total_reward:+.1f}")
            break
        
        print()
    
    print(f"\n[STATISTICHE]")
    print(f"  Step totali: {step}")
    print(f"  Reward finale: {total_reward:+.1f}")

if __name__ == "__main__":
    main()
