from pathlib import Path
import sys

from clips import Environment


BASE_DIR = Path(__file__).resolve().parent
AGENT_FILE = BASE_DIR / "agent.clp"


def main() -> int:
    env = Environment()
    env.load(str(AGENT_FILE))
    env.reset()

    env.assert_string(
        "(percept (x 0) (y 0) (steps 1) (breeze FALSE) (stench FALSE) (glitter FALSE) (energy 200))"
    )
    env.assert_string("(counter (step 1))")

    env.run(20)

    print("Fatti action presenti dopo l'esecuzione:")
    for fact in env.facts():
        if fact.template.name == "action":
            print(fact)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
