import numpy as np


def generate_signals(features, signal_params):
    size = int(features.market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    entry_specs = [None] * size

    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)[:size]
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)[:size]
    n = int(signal_params.get("length", signal_params.get("pivot_length", 10)))
    if n < 1:
        n = 1
    rr_mode = str(signal_params.get("rr_mode", "Automatic (Fibonacci)"))
    custom_rr = float(signal_params.get("custom_rr", 3.0))
    if not np.isfinite(custom_rr) or custom_rr <= 0.0:
        custom_rr = 3.0
    num_tps = int(signal_params.get("num_tps", 4))
    num_tps = max(1, min(4, num_tps))

    pivot_events = [[] for _ in range(size)]
    for confirmation in range(2 * n, size):
        pivot = confirmation - n
        window = highs[pivot - n : confirmation + 1]
        if window.size == 2 * n + 1 and np.all(np.isfinite(window)):
            if highs[pivot] >= np.max(window):
                pivot_events[confirmation].append((pivot, float(highs[pivot]), 1))
        window = lows[pivot - n : confirmation + 1]
        if window.size == 2 * n + 1 and np.all(np.isfinite(window)):
            if lows[pivot] <= np.min(window):
                pivot_events[confirmation].append((pivot, float(lows[pivot]), -1))

    pivots = []
    sequences = []
    for t in range(size):
        for pivot_index, pivot_price, pivot_kind in pivot_events[t]:
            appended = False
            if pivots and pivots[-1][2] == pivot_kind:
                more_extreme = (
                    pivot_kind == 1 and pivot_price >= pivots[-1][1]
                ) or (
                    pivot_kind == -1 and pivot_price <= pivots[-1][1]
                )
                if more_extreme:
                    pivots[-1] = (pivot_index, pivot_price, pivot_kind)
            else:
                pivots.append((pivot_index, pivot_price, pivot_kind))
                appended = True
                if len(pivots) > 10:
                    pivots.pop(0)

            if not appended or len(pivots) < 3:
                continue
            p0_i, p0, t0 = pivots[-3]
            pa_i, pa, ta = pivots[-2]
            pb_i, pb, tb = pivots[-1]
            side = 1 if (t0, ta, tb) == (-1, 1, -1) else -1 if (t0, ta, tb) == (1, -1, 1) else 0
            if side == 1:
                wave = pa - p0
                ratio = (pa - pb) / wave if wave > 0.0 else -1.0
                valid = p0 < pb < pa and 0.5 <= ratio <= 1.0
            elif side == -1:
                wave = p0 - pa
                ratio = (pb - pa) / wave if wave > 0.0 else -1.0
                valid = pa < pb < p0 and 0.5 <= ratio <= 1.0
            else:
                valid = False
            if not valid:
                continue
            c = pb + (pa - p0) * 1.38
            sequences.append({
                "side": side,
                "p0": float(p0),
                "pa": float(pa),
                "pb": float(pb),
                "c": float(c),
                "c_time": None,
                "wcl_lower": None,
                "wcl_upper": None,
                "entered": False,
                "invalid": False,
                "b_index": pb_i,
            })

        for sequence in sequences:
            if sequence["invalid"] or sequence["entered"]:
                continue
            side = sequence["side"]
            p0 = sequence["p0"]
            if (side == 1 and lows[t] <= p0) or (side == -1 and highs[t] >= p0):
                sequence["invalid"] = True
                continue

            if sequence["c_time"] is None:
                reached = (side == 1 and highs[t] >= sequence["c"]) or (side == -1 and lows[t] <= sequence["c"])
                if reached:
                    sequence["c_time"] = t
                    if side == 1:
                        sequence["wcl_upper"] = sequence["c"] - (sequence["c"] - p0) * 0.500
                        sequence["wcl_lower"] = sequence["c"] - (sequence["c"] - p0) * 0.667
                    else:
                        sequence["wcl_lower"] = sequence["c"] + (p0 - sequence["c"]) * 0.500
                        sequence["wcl_upper"] = sequence["c"] + (p0 - sequence["c"]) * 0.667
                continue

            if t <= sequence["c_time"]:
                continue
            lower = sequence["wcl_lower"]
            upper = sequence["wcl_upper"]
            touched = lows[t] <= upper and highs[t] >= lower
            if not touched or long_entries[t] or short_entries[t]:
                continue

            entry = (lower + upper) * 0.5
            if rr_mode.lower() in {"custom", "custom rr"}:
                risk = abs(entry - p0)
                reward = risk * custom_rr
                targets = [entry + side * reward * fraction for fraction in (0.25, 0.50, 0.75, 1.00)]
            else:
                wave = sequence["pa"] - p0
                targets = [sequence["pb"] + wave * factor for factor in (1.38, 1.618, 1.809, 2.0)]
            if not all(np.isfinite(target) for target in targets):
                sequence["invalid"] = True
                continue
            sequence["entered"] = True
            long_entries[t] = side == 1
            short_entries[t] = side == -1
            entry_specs[t] = {
                "side": side,
                "entry": entry,
                "stop": p0,
                "targets": targets,
            }

    long_exits = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)
    position = 0
    entry = 0.0
    stop = 0.0
    targets = []
    targets_hit = 0

    for t in range(size):
        if position == 1:
            if lows[t] <= stop:
                long_exits[t] = True
                position = 0
            else:
                reached = 0
                for index, target in enumerate(targets):
                    if highs[t] >= target:
                        reached = index + 1
                targets_hit = max(targets_hit, reached)
                if targets_hit >= num_tps:
                    long_exits[t] = True
                    position = 0
                else:
                    if targets_hit >= 1:
                        stop = max(stop, entry)
                    if targets_hit >= 2:
                        stop = max(stop, targets[0])
                    if targets_hit >= 3:
                        stop = max(stop, targets[1])
        elif position == -1:
            if highs[t] >= stop:
                short_exits[t] = True
                position = 0
            else:
                reached = 0
                for index, target in enumerate(targets):
                    if lows[t] <= target:
                        reached = index + 1
                targets_hit = max(targets_hit, reached)
                if targets_hit >= num_tps:
                    short_exits[t] = True
                    position = 0
                else:
                    if targets_hit >= 1:
                        stop = min(stop, entry)
                    if targets_hit >= 2:
                        stop = min(stop, targets[0])
                    if targets_hit >= 3:
                        stop = min(stop, targets[1])

        if position == 0:
            spec = entry_specs[t]
            if spec is not None:
                position = spec["side"]
                entry = spec["entry"]
                stop = spec["stop"]
                targets = spec["targets"]
                targets_hit = 0

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "zigzag_WCL_retracement",
    "hypothesis": "確認 0-A-B 結構的 1.38 動態延伸後，WCL 回撤區中點提供反轉進場，並以點 0 與分段目標管理風險。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["length", "rr_mode", "custom_rr", "num_tps"],
    "signal_parameter_sets": [{"length": 10, "rr_mode": "Automatic (Fibonacci)", "custom_rr": 3.0, "num_tps": 4}],
}
