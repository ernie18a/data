"""Checks that verify.py can actually fail.

A verifier stuck on PASS is worse than none, so this hands it a correct file and
then every mis-port the reference can produce, and requires the expected verdict
from each. It also exercises the --skip path, which exists for partial exports
and would otherwise never be run.

    python selftest.py
"""
from __future__ import annotations

import csv
import subprocess
import sys
import tempfile
from pathlib import Path

from pine_supertrend import supertrend, is_na
from verify import make_demo

HERE = Path(__file__).parent
PERIOD, FACTOR = 10, 3.0

# каждый вариант это одна конкретная ошибка переноса
BROKEN = [
    ("ATR as an EMA", dict(atr_mode="ema", sticky=True)),
    ("ATR as a plain moving average", dict(atr_mode="sma", sticky=True)),
    ("bands not sticky", dict(atr_mode="rma", sticky=False)),
]


def write_csv(path, d, st, direction, atr):
    with open(path, "w", newline="", encoding="utf-8") as fh:
        w = csv.writer(fh)
        w.writerow(["time", "open", "high", "low", "close", "atr", "supertrend", "direction"])
        for i in range(len(d["close"])):
            fmt = lambda v: "" if is_na(v) else format(v, ".10f")
            w.writerow([d["time"][i], "", format(d["high"][i], ".10f"),
                        format(d["low"][i], ".10f"), format(d["close"][i], ".10f"),
                        fmt(atr[i]), fmt(st[i]),
                        "" if is_na(direction[i]) else str(int(direction[i]))])


def run(path, extra=()):
    r = subprocess.run([sys.executable, str(HERE / "verify.py"), "--csv", str(path),
                        "--period", str(PERIOD), "--factor", str(FACTOR), *extra],
                       capture_output=True, text=True, cwd=HERE)
    return r.returncode, r.stdout


def main():
    d = make_demo()
    tmp = Path(tempfile.mkdtemp())
    failures = []

    def expect(label, path, want_pass, extra=()):
        code, out = run(path, extra)
        passed = (code == 0)
        ok = (passed == want_pass)
        print("  {:<44} exit={} {}".format(label, code, "ok" if ok else "WRONG"))
        if not ok:
            failures.append(label)
            print(out)

    good_st, good_dir, good_atr, _, _ = supertrend(
        d["high"], d["low"], d["close"], FACTOR, PERIOD)
    good = tmp / "good.csv"
    write_csv(good, d, good_st, good_dir, good_atr)

    print("a correct port must PASS")
    expect("correct port", good, True)

    print("\nevery mis-port must FAIL")
    for label, kw in BROKEN:
        st, direction, atr, _, _ = supertrend(
            d["high"], d["low"], d["close"], FACTOR, PERIOD, **kw)
        bad = tmp / ("bad_" + label.replace(" ", "_") + ".csv")
        write_csv(bad, d, st, direction, atr)
        expect(label, bad, False)

    print("\nthe --skip path must still work on a correct file")
    expect("correct port with --skip 200", good, True, ("--skip", "200"))

    print()
    if failures:
        print("SELFTEST FAILED: " + "; ".join(failures))
        return 1
    print("SELFTEST PASSED, the checker accepts correct output and rejects every mis-port")
    return 0


if __name__ == "__main__":
    sys.exit(main())
