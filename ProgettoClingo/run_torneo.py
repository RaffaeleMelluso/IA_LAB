#!/usr/bin/env python3
"""
run_torneo.py

Esegue clingo su `torneo.cl` + file turno, estrae `incontro/2` e `bye/1`, stampa
gli accoppiamenti, i bye e genera una classifica aggiornata (simulando risultati).

Uso:
  python3 run_torneo.py --turno ProgettoClingo/turno2.cl

Opzioni principali:
  --torneo     path al file torneo.cl (default: ProgettoClingo/torneo.cl)
  --turno      file turno (.cl) con fatti `giocatore/1` e `punteggio/2`
  --method     metodo di simulazione: deterministic (default) o random
  --seed       seed per random (opzionale)
  --out        scrive un file con i nuovi fatti `punteggio/2` (opzionale)

"""

import re
import subprocess
import argparse
import random
import sys
from pathlib import Path
import json


def run_clingo(torneo_file, turno_file):
    try:
        res = subprocess.run(["clingo", "--outf=2", str(torneo_file), str(turno_file), "-n", "1"], capture_output=True, text=True, check=False)
    except FileNotFoundError:
        print("Errore: clingo non trovato. Installa clingo e riprova.")
        sys.exit(1)

    # clingo usa codici di uscita diversi; se c'è output parsabile lo usiamo
    if res.returncode != 0 and not res.stdout:
        print("clingo ha restituito codice", res.returncode)
        if res.stderr:
            print(res.stderr)
        sys.exit(1)

    return res.stdout


def parse_model(output):
    """Parsa l'output JSON di clingo (--outf=2) e ritorna pairings e byes."""
    pairings = []
    byes = []
    try:
        data = json.loads(output)
        # naviga fino al primo witness (se presente)
        calls = data.get('Call', [])
        if not calls:
            return pairings, byes
        witnesses = calls[0].get('Witnesses', [])
        if not witnesses:
            return pairings, byes
        vals = witnesses[0].get('Value', [])
        for tok in vals:
            if tok.startswith('incontro'):
                m = re.match(r'incontro\(([^,]+)\s*,\s*([^\)]+)\)', tok)
                if m:
                    p1 = m.group(1)
                    p2 = m.group(2)
                    pairings.append((p1, p2))
            elif tok.startswith('bye'):
                m = re.match(r'bye\(([^\)]+)\)', tok)
                if m:
                    byes.append(m.group(1))
    except json.JSONDecodeError:
        # fallback: parse testo grezzo
        tokens = re.findall(r"(incontro\([^\)]+\))|(bye\([^\)]+\))", output)
        for a, b in tokens:
            tok = a if a else b
            if tok.startswith('incontro'):
                m = re.match(r'incontro\(([^,]+)\s*,\s*([^\)]+)\)', tok)
                if m:
                    pairings.append((m.group(1), m.group(2)))
            elif tok.startswith('bye'):
                m = re.match(r'bye\(([^\)]+)\)', tok)
                if m:
                    byes.append(m.group(1))
    return pairings, byes


def parse_scores_from_turno(turno_file):
    text = turno_file.read_text(encoding='utf-8')
    scores = {}
    for m in re.finditer(r'punteggio\(([^,\)]+)\s*,\s*([0-9]+)\)', text):
        name = m.group(1).strip()
        val = int(m.group(2))
        scores[name] = val
    # Assicura che tutti i giocatori siano presenti anche se senza punteggio
    for m in re.finditer(r'giocatore\(([^\)]+)\)', text):
        name = m.group(1).strip()
        if name not in scores:
            scores[name] = 0
    return scores


def simulate_results(pairings, byes, scores, method='deterministic', seed=None):
    if method == 'random':
        rnd = random.Random(seed)
    else:
        rnd = None

    results = []  # list of (p1,p2,winner)
    new_scores = dict(scores)

    for a, b in pairings:
        sa = scores.get(a, 0)
        sb = scores.get(b, 0)
        if method == 'random':
            winner = a if rnd.random() < 0.5 else b
        else:
            # deterministic: chi ha punteggio maggiore vince; in caso di pareggio, prima alfab.
            if sa > sb:
                winner = a
            elif sb > sa:
                winner = b
            else:
                winner = a if a < b else b

        # Assegna +1 al vincitore
        new_scores.setdefault(winner, 0)
        new_scores[winner] += 1
        # Assicura che il perdente esista nella mappa
        new_scores.setdefault(a, 0)
        new_scores.setdefault(b, 0)
        results.append((a, b, winner))

    # Bye: assegna +1
    for p in byes:
        new_scores.setdefault(p, 0)
        new_scores[p] += 1

    return results, new_scores


def print_report(pairings, byes, results, old_scores, new_scores):
    # Stampa lista incontri in formato richiesto: nome1-nome2
    print("\nlista incontri:")
    if pairings:
        for a, b in pairings:
            print(f"{a}-{b}")
    else:
        print("(nessun incontro)")

    # Bye
    if byes:
        print("\nbye:")
        for p in byes:
            print(p)

    # Risultati degli incontri
    print("\nrisultati incontri:")
    if results:
        for a, b, w in results:
            loser = b if w == a else a
            print(f"{a}-{b}: {w} ha vinto contro {loser}")
    else:
        print("(nessun risultato)")

    # Classifica: ordine decrescente per punti, poi nome
    print("\nclassifica:")
    ranked = sorted(new_scores.items(), key=lambda x: (-x[1], x[0]))
    maxname = max((len(n) for n, _ in ranked), default=6)
    print(f"{'Giocatore'.ljust(maxname)}  Punti")
    print('-' * (maxname + 8))
    for name, sc in ranked:
        print(f"{name.ljust(maxname)}  {sc}")


def write_new_punteggi(out_path: Path, scores):
    lines = []
    for name, sc in sorted(scores.items()):
        lines.append(f'punteggio({name},{sc}).')
    out_path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    print(f"\nFatti punteggio scritti in: {out_path}")


def main():
    ap = argparse.ArgumentParser(description='Automatizza il turno del torneo usando clingo e stampa classifica e risultati')
    ap.add_argument('--torneo', default=None, help='Percorso al file torneo.cl')
    ap.add_argument('--turno', default=None, help='Percorso al file turno (.cl)')
    ap.add_argument('--which', '-w', choices=['1', '2'], help='Scegli quale turno: 1 o 2 (sovrascrive --turno)')
    ap.add_argument('--method', choices=['deterministic', 'random'], default='deterministic')
    ap.add_argument('--seed', type=int, default=None)
    ap.add_argument('--out', default=None, help='Percorso file per scrivere i nuovi fatti punteggio')
    args = ap.parse_args()

    base_dir = Path(__file__).resolve().parent

    # Default a file nella stessa cartella dello script se non forniti
    torneo = Path(args.torneo) if args.torneo else (base_dir / 'torneo.cl')

    # Se l'utente ha specificato --which (1 o 2) sovrascrive il file turno
    if args.which:
        turno = base_dir / f'turno{args.which}.cl'
    else:
        turno = Path(args.turno) if args.turno else (base_dir / 'turno2.cl')

    if not torneo.exists():
        print('File torneo non trovato:', torneo)
        sys.exit(1)
    if not turno.exists():
        print('File turno non trovato:', turno)
        sys.exit(1)

    print('Eseguo clingo su', torneo, '+', turno)
    out = run_clingo(torneo, turno)
    pairings, byes = parse_model(out)

    scores = parse_scores_from_turno(turno)

    # Assicura che tutti i giocatori appaiano
    # (also include players from pairings/byes)
    for a, b in pairings:
        scores.setdefault(a, 0)
        scores.setdefault(b, 0)
    for p in byes:
        scores.setdefault(p, 0)

    results, new_scores = simulate_results(pairings, byes, scores, method=args.method, seed=args.seed)

    print_report(pairings, byes, results, scores, new_scores)

    if args.out:
        write_new_punteggi(Path(args.out), new_scores)


if __name__ == '__main__':
    main()
