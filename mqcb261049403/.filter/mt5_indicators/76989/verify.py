"""Bar for bar check of the port against Pine.

Two charts that look alike prove nothing, so this recomputes the reference from
the same OHLC rows the terminal exported. Same input on both sides, nowhere for
a difference to hide. Exits non-zero on any mismatch.

    python verify.py --csv supertrend_mt5.csv
    python verify.py --demo
"""
from __future__ import annotations

import argparse
import csv
import math
import random
import sys

from pine_supertrend import supertrend, is_na

NAN = float("nan")


# ----------------------------------------------------------------- input
def load_csv(path):
    """Read the terminal's export. OHLC is required; the rest is optional."""
    rows = []
    with open(path, newline="", encoding="utf-8-sig") as fh:
        for r in csv.DictReader(fh):
            rows.append({k.strip().lower(): (v or "").strip() for k, v in r.items() if k})
    if not rows:
        sys.exit("csv has no rows: " + path)

    def col(name, required=True):
        if name not in rows[0]:
            if required:
                sys.exit(f"csv is missing the '{name}' column (has: {', '.join(rows[0])})")
            return None
        out = []
        for r in rows:
            raw = r.get(name, "")
            try:
                out.append(float(raw))
            except ValueError:
                out.append(NAN)
        return out

    return {
        "time": [r.get("time", str(i)) for i, r in enumerate(rows)],
        "high": col("high"), "low": col("low"), "close": col("close"),
        "mt5_st": col("supertrend", False),
        "mt5_dir": col("direction", False),
        "mt5_atr": col("atr", False),
    }


def make_demo(n=3000, seed=42):
    """Fixed seed so the demo prints the same numbers on any machine."""
    rnd = random.Random(seed)
    price, high, low, close, time = 2000.0, [], [], [], []
    for i in range(n):
        price *= math.exp(rnd.gauss(0, 0.0012))          # random walk
        rng = price * abs(rnd.gauss(0, 0.0016)) + price * 0.0002
        c = price + rnd.uniform(-rng / 2, rng / 2)
        high.append(max(price, c) + rng / 2)
        low.append(min(price, c) - rng / 2)
        close.append(c)
        time.append(f"bar{i:05d}")
    return {"time": time, "high": high, "low": low, "close": close,
            "mt5_st": None, "mt5_dir": None, "mt5_atr": None}


# ----------------------------------------------------------------- compare
def compare(name, ref, got, times, tol, ref_dir=None, got_dir=None, skip=0):
    """Print one comparison block; return True when it passes."""
    diffs, first_bad, checked = [], None, 0
    for i, (a, b) in enumerate(zip(ref, got)):
        if i < skip or is_na(a) or is_na(b):
            continue
        checked += 1
        d = abs(a - b)
        diffs.append(d)
        if d > tol and first_bad is None:
            first_bad = (i, times[i], a, b, d)

    flips = None
    if ref_dir is not None and got_dir is not None:
        flips = sum(1 for i, (a, b) in enumerate(zip(ref_dir, got_dir))
                    if i >= skip and not is_na(a) and not is_na(b) and int(a) != int(b))

    if not checked:
        print(f"  {name:<34} no overlapping bars to compare")
        return False

    worst, mean = max(diffs), sum(diffs) / len(diffs)
    ok = worst <= tol and (flips in (None, 0))
    print(f"  {name:<34} bars {checked:>5} | max {worst:.10f} | mean {mean:.10f}"
          + (f" | direction differs on {flips} bars" if flips is not None else "")
          + ("   PASS" if ok else "   FAIL"))
    if first_bad:
        i, t, a, b, d = first_bad
        print(f"      first mismatch at bar {i} ({t}): reference {a:.10f} vs {b:.10f}, diff {d:.2e}")
    return ok


def main():
    ap = argparse.ArgumentParser(description="Verify the MQL5 SuperTrend against Pine semantics")
    ap.add_argument("--csv", help="CSV exported by ExportSuperTrendTV.mq5")
    ap.add_argument("--demo", action="store_true", help="run on a generated series instead")
    ap.add_argument("--period", type=int, default=10)
    ap.add_argument("--factor", type=float, default=3.0)
    ap.add_argument("--tol", type=float, default=1e-8, help="allowed absolute difference")
    ap.add_argument("--skip", type=int, default=0,
                    help="ignore this many leading bars (use after a PARTIAL export, "
                         "where the terminal had history the reference does not)")
    a = ap.parse_args()
    if not a.csv and not a.demo:
        ap.error("pass --csv <file> or --demo")

    d = load_csv(a.csv) if a.csv else make_demo()
    src = a.csv if a.csv else "generated series (seed 42)"
    print(f"\nSuperTrend  period={a.period}  factor={a.factor}  tolerance={a.tol:g}")
    print(f"source: {src}  ({len(d['close'])} bars)\n")

    ref_st, ref_dir, ref_atr, _, _ = supertrend(
        d["high"], d["low"], d["close"], a.factor, a.period)

    passed = True

    if d["mt5_st"]:
        print("MQL5 port vs Pine reference"
              + (f"  (first {a.skip} bars ignored)" if a.skip else ""))
        if d["mt5_atr"]:
            passed &= compare("ATR (Wilder/RMA)", ref_atr, d["mt5_atr"], d["time"],
                              a.tol, skip=a.skip)
        passed &= compare("SuperTrend line", ref_st, d["mt5_st"], d["time"], a.tol,
                          ref_dir, d["mt5_dir"], skip=a.skip)
    else:
        print("MQL5 columns not present - checking the reference against itself only.")
        print("Export from the terminal and re-run with --csv to prove the port.")

    # what each classic mistake actually costs
    print("\nCost of the usual conversion mistakes (vs the same reference)")
    variants = [
        ("ATR as EMA alpha=2/(n+1)", dict(atr_mode="ema", sticky=True)),
        ("ATR as a plain moving average", dict(atr_mode="sma", sticky=True)),
        ("bands not made sticky", dict(atr_mode="rma", sticky=False)),
    ]
    for label, kw in variants:
        st2, dir2, _, _, _ = supertrend(d["high"], d["low"], d["close"],
                                        a.factor, a.period, **kw)
        both = [(x, y) for x, y in zip(ref_st, st2) if not is_na(x) and not is_na(y)]
        flips = sum(1 for x, y in zip(ref_dir, dir2)
                    if not is_na(x) and not is_na(y) and int(x) != int(y))
        if not both:
            continue
        worst = max(abs(x - y) for x, y in both)
        share = 100.0 * flips / len(both)
        print(f"  {label:<34} max {worst:>10.4f} | wrong trend on {flips:>4} of "
              f"{len(both)} bars ({share:.1f}%)")

    print()
    if d["mt5_st"]:
        print("RESULT: " + ("port matches Pine bar for bar" if passed
                            else "port DOES NOT match - see the first mismatch above"))
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
