import numpy as np

def generate_signals(features, signal_params):
    size = int(features.market.size)
    highs = np.asarray(features.market.highs, dtype=float).reshape(-1)
    lows = np.asarray(features.market.lows, dtype=float).reshape(-1)

    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    pivot_window = max(1, int(signal_params.get("pivot_window", 10)))
    retracement_min = float(signal_params.get("retracement_min", 0.500))
    retracement_max = float(signal_params.get("retracement_max", 1.000))
    target_mode = str(signal_params.get("target_mode", "Automatic (Fibonacci)"))
    custom_rr = float(signal_params.get("custom_rr", 3.0))
    num_tps = min(4, max(1, int(signal_params.get("num_tps", 4))))

    pivots = []
    seen_structures = set()
    structure = None
    position = 0

    def make_targets(side, p0, pA, pB, entry):
        if target_mode.lower().startswith("custom"):
            reward = abs(entry - p0) * custom_rr
            return np.asarray(
                [entry + side * reward * fraction for fraction in (0.25, 0.50, 0.75, 1.0)],
                dtype=float,
            )
        wave_0A = pA - p0
        return np.asarray(
            [pB + wave_0A * ratio for ratio in (1.38, 1.618, 1.809, 2.0)],
            dtype=float,
        )

    for t in range(size):
        center = t - pivot_window
        if center >= pivot_window and center + pivot_window < size:
            high_window = highs[center - pivot_window:center + pivot_window + 1]
            low_window = lows[center - pivot_window:center + pivot_window + 1]
            if np.isfinite(highs[center]) and np.isfinite(high_window).all():
                if highs[center] >= np.max(high_window):
                    pivots.append((float(highs[center]), 1, center))
            if np.isfinite(lows[center]) and np.isfinite(low_window).all():
                if lows[center] <= np.min(low_window):
                    pivots.append((float(lows[center]), -1, center))
            if len(pivots) > 20:
                del pivots[:-20]

        if len(pivots) >= 3:
            (p0, type0, index0), (pA, typeA, indexA), (pB, typeB, indexB) = pivots[-3:]
            key = (index0, indexA, indexB, type0, typeA, typeB)
            side = 1 if (type0, typeA, typeB) == (-1, 1, -1) else (
                -1 if (type0, typeA, typeB) == (1, -1, 1) else 0
            )
            wave_0A = pA - p0
            ratio = (pA - pB) / wave_0A if wave_0A != 0.0 else np.nan
            valid = (
                key not in seen_structures
                and side != 0
                and ((side == 1 and pB > p0) or (side == -1 and pB < p0))
                and np.isfinite(ratio)
                and retracement_min <= ratio <= retracement_max
            )
            if valid:
                seen_structures.add(key)
                if position == 0:
                    structure = {
                        "side": side,
                        "p0": p0,
                        "pA": pA,
                        "pB": pB,
                        "a_broken": False,
                        "extreme": np.nan,
                        "extreme_index": -1,
                        "bc_touched": False,
                        "c_reached": False,
                        "entry": np.nan,
                        "stop": np.nan,
                        "targets": None,
                        "target_stage": 0,
                        "closed": False,
                        "invalidated": False,
                    }

        current = structure
        if current is None or current["closed"]:
            continue

        side = current["side"]
        p0 = current["p0"]
        pA = current["pA"]
        pB = current["pB"]

        if not current["invalidated"] and (
            (side == 1 and lows[t] < p0) or (side == -1 and highs[t] > p0)
        ):
            current["invalidated"] = True
            if position == side:
                if side == 1:
                    long_exits[t] = True
                else:
                    short_exits[t] = True
                position = 0
                current["closed"] = True
            continue

        if current["invalidated"]:
            continue

        if not current["c_reached"]:
            if not current["a_broken"]:
                if side == 1 and highs[t] > pA:
                    current["a_broken"] = True
                    current["extreme"] = highs[t]
                    current["extreme_index"] = t
                elif side == -1 and lows[t] < pA:
                    current["a_broken"] = True
                    current["extreme"] = lows[t]
                    current["extreme_index"] = t

            if current["a_broken"] and not current["bc_touched"]:
                if side == 1 and highs[t] > current["extreme"]:
                    current["extreme"] = highs[t]
                    current["extreme_index"] = t
                elif side == -1 and lows[t] < current["extreme"]:
                    current["extreme"] = lows[t]
                    current["extreme_index"] = t

                range_be = current["extreme"] - pB
                level_500 = current["extreme"] - range_be * 0.500
                level_667 = current["extreme"] - range_be * 0.667
                zone_top = max(level_500, level_667)
                zone_bottom = min(level_500, level_667)
                touched = (
                    t > current["extreme_index"]
                    and lows[t] <= zone_top
                    and highs[t] >= zone_bottom
                )
                if touched:
                    current["bc_touched"] = True
                    if position == 0:
                        entry = (zone_top + zone_bottom) * 0.5
                        current["entry"] = entry
                        current["stop"] = p0
                        current["targets"] = make_targets(side, p0, pA, pB, entry)
                        position = side
                        if side == 1:
                            long_entries[t] = True
                        else:
                            short_entries[t] = True

            fib138 = pB + (pA - p0) * 1.38
            if (side == 1 and highs[t] >= fib138) or (side == -1 and lows[t] <= fib138):
                current["c_reached"] = True

        if position != side or not np.isfinite(current["entry"]):
            continue

        stop_hit = (
            (side == 1 and lows[t] <= current["stop"])
            or (side == -1 and highs[t] >= current["stop"])
        )
        if stop_hit:
            if side == 1:
                long_exits[t] = True
            else:
                short_exits[t] = True
            position = 0
            current["closed"] = True
            continue

        targets = current["targets"]
        for target_index in range(current["target_stage"], num_tps):
            reached = (
                (side == 1 and highs[t] >= targets[target_index])
                or (side == -1 and lows[t] <= targets[target_index])
            )
            if reached:
                current["target_stage"] = target_index + 1

        if current["target_stage"] >= num_tps:
            if side == 1:
                long_exits[t] = True
            else:
                short_exits[t] = True
            position = 0
            current["closed"] = True
            continue

        if current["target_stage"] >= 1:
            if side == 1:
                current["stop"] = max(current["stop"], current["entry"])
            else:
                current["stop"] = min(current["stop"], current["entry"])
        if current["target_stage"] >= 2:
            if side == 1:
                current["stop"] = max(current["stop"], targets[0])
            else:
                current["stop"] = min(current["stop"], targets[0])
        if current["target_stage"] >= 3:
            if side == 1:
                current["stop"] = max(current["stop"], targets[1])
            else:
                current["stop"] = min(current["stop"], targets[1])

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "zigzag_BC_retracement",
    "hypothesis": "A 突破後的趨勢延續，回撤至 B-E 的 0.500-0.667 區間可提供順勢 BC 入場。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": [
        "pivot_window",
        "retracement_min",
        "retracement_max",
        "target_mode",
        "custom_rr",
        "num_tps",
    ],
    "signal_parameter_sets": [
        {
            "pivot_window": 10,
            "retracement_min": 0.500,
            "retracement_max": 1.000,
            "target_mode": "Automatic (Fibonacci)",
            "custom_rr": 3.0,
            "num_tps": 4,
        }
    ],
}