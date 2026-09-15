import numpy as np


def iter_signal_parameter_sets():
    for rr_mode in ("Automatic (Fibonacci)", "Custom RR"):
        for num_tps in (1, 2, 3, 4):
            for custom_rr in (2.0, 3.0, 4.0):
                yield {
                    "num_tps": num_tps,
                    "rr_mode": rr_mode,
                    "custom_rr": custom_rr,
                }


def generate_signals(features, signal_params):
    market = features.market
    size = int(market.size)
    long_entries = np.zeros(size, dtype=np.bool_)
    long_exits = np.zeros(size, dtype=np.bool_)
    short_entries = np.zeros(size, dtype=np.bool_)
    short_exits = np.zeros(size, dtype=np.bool_)

    if size == 0:
        return long_entries, long_exits, short_entries, short_exits

    highs = np.asarray(market.highs, dtype=np.float64)
    lows = np.asarray(market.lows, dtype=np.float64)
    if highs.ndim != 1 or lows.ndim != 1 or highs.size != size or lows.size != size:
        return long_entries, long_exits, short_entries, short_exits

    try:
        num_tps = int(signal_params.get("num_tps", 4))
        rr_mode = str(signal_params.get("rr_mode", "Automatic (Fibonacci)"))
        custom_rr = float(signal_params.get("custom_rr", 3.0))
    except (AttributeError, TypeError, ValueError):
        return long_entries, long_exits, short_entries, short_exits

    if num_tps not in (1, 2, 3, 4):
        return long_entries, long_exits, short_entries, short_exits
    if rr_mode not in ("Automatic (Fibonacci)", "Custom RR"):
        return long_entries, long_exits, short_entries, short_exits
    if not np.isfinite(custom_rr) or custom_rr <= 0.0:
        return long_entries, long_exits, short_entries, short_exits

    pivot_length = 10
    pivots = []
    processed_b_indices = set()
    sequences = []
    position_sequence = None
    entry_bar = -1
    fib_ratios = (1.38, 1.618, 1.809, 2.0)

    for t in range(size):
        exited_this_bar = False
        entry_candidate = None

        if t >= 2 * pivot_length:
            center = t - pivot_length
            high_window = highs[center - pivot_length : center + pivot_length + 1]
            low_window = lows[center - pivot_length : center + pivot_length + 1]
            if np.all(np.isfinite(high_window)) and np.all(np.isfinite(low_window)):
                if highs[center] >= np.max(high_window):
                    pivots.insert(0, (center, highs[center], 1))
                if lows[center] <= np.min(low_window):
                    pivots.insert(0, (center, lows[center], -1))
                if len(pivots) > 10:
                    del pivots[10:]

        if len(pivots) >= 3:
            p_b, b_b, type_b = pivots[0][1], pivots[0][0], pivots[0][2]
            p_a, type_a = pivots[1][1], pivots[1][2]
            p_0, type_0 = pivots[2][1], pivots[2][2]

            if b_b not in processed_b_indices:
                processed_b_indices.add(b_b)
                direction = (
                    1
                    if type_0 == -1 and type_a == 1 and type_b == -1
                    else -1
                    if type_0 == 1 and type_a == -1 and type_b == 1
                    else 0
                )
                wave_0a = p_a - p_0
                valid_setup = direction != 0 and np.isfinite(wave_0a) and wave_0a != 0.0

                if valid_setup:
                    retracement = (p_a - p_b) / wave_0a
                    valid_setup = (
                        np.isfinite(retracement)
                        and ((direction == 1 and p_b > p_0) or (direction == -1 and p_b < p_0))
                        and retracement >= 0.500
                        and retracement <= 1.000
                    )

                if valid_setup:
                    real_stop = p_0
                    if rr_mode == "Automatic (Fibonacci)":
                        initial_targets = tuple(p_b + wave_0a * ratio for ratio in fib_ratios)
                    else:
                        initial_risk = abs(p_b - real_stop)
                        reward = initial_risk * custom_rr
                        initial_targets = tuple(
                            p_b + reward * fraction * direction
                            for fraction in (0.25, 0.50, 0.75, 1.0)
                        )

                    if all(np.isfinite(value) for value in initial_targets):
                        sequences.append(
                            {
                                "p0": p_0,
                                "pA": p_a,
                                "pB": p_b,
                                "direction": direction,
                                "wave_0a": wave_0a,
                                "real_stop": real_stop,
                                "fib138": p_b + wave_0a * 1.38,
                                "targets": list(initial_targets),
                                "a_broken": False,
                                "extreme": p_a,
                                "extreme_index": b_b,
                                "bc_touched": False,
                                "zone_top": np.nan,
                                "zone_bottom": np.nan,
                                "c_reached": False,
                                "invalidated": False,
                                "bc_closed": False,
                                "bc_active": False,
                                "bc_entry": np.nan,
                                "stop": real_stop,
                                "tp_hit": [False, False, False, False],
                            }
                        )

        for sequence in reversed(sequences):
            direction = sequence["direction"]
            if sequence["invalidated"]:
                continue

            zero_broken = (
                direction == 1 and lows[t] < sequence["p0"]
            ) or (
                direction == -1 and highs[t] > sequence["p0"]
            )
            if zero_broken:
                sequence["invalidated"] = True
                if position_sequence is sequence:
                    if direction == 1:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    sequence["bc_active"] = False
                    sequence["bc_closed"] = True
                    position_sequence = None
                    entry_bar = -1
                    exited_this_bar = True
                continue

            for target_index, target in enumerate(sequence["targets"]):
                if not sequence["tp_hit"][target_index]:
                    target_hit = (
                        direction == 1 and highs[t] >= target
                    ) or (
                        direction == -1 and lows[t] <= target
                    )
                    if target_hit:
                        sequence["tp_hit"][target_index] = True

            if not sequence["a_broken"]:
                a_break = (
                    direction == 1 and highs[t] > sequence["pA"]
                ) or (
                    direction == -1 and lows[t] < sequence["pA"]
                )
                if a_break:
                    sequence["a_broken"] = True
                    sequence["extreme"] = highs[t] if direction == 1 else lows[t]
                    sequence["extreme_index"] = t

            if sequence["a_broken"] and not sequence["c_reached"]:
                if not sequence["bc_touched"]:
                    new_extreme = (
                        direction == 1 and highs[t] > sequence["extreme"]
                    ) or (
                        direction == -1 and lows[t] < sequence["extreme"]
                    )
                    if new_extreme:
                        sequence["extreme"] = highs[t] if direction == 1 else lows[t]
                        sequence["extreme_index"] = t

                    width = sequence["extreme"] - sequence["pB"]
                    level_500 = sequence["extreme"] - width * 0.500
                    level_667 = sequence["extreme"] - width * 0.667
                    sequence["zone_top"] = max(level_500, level_667)
                    sequence["zone_bottom"] = min(level_500, level_667)

                    if (
                        t > sequence["extreme_index"]
                        and np.isfinite(sequence["zone_top"])
                        and np.isfinite(sequence["zone_bottom"])
                    ):
                        zone_touched = (
                            direction == 1
                            and lows[t] <= sequence["zone_top"]
                            and highs[t] >= sequence["zone_bottom"]
                        ) or (
                            direction == -1
                            and highs[t] >= sequence["zone_bottom"]
                            and lows[t] <= sequence["zone_top"]
                        )
                        if zone_touched:
                            sequence["bc_touched"] = True

                if (
                    sequence["bc_touched"]
                    and not sequence["bc_closed"]
                    and position_sequence is None
                    and entry_candidate is None
                    and not exited_this_bar
                ):
                    entry_candidate = sequence

            if not sequence["c_reached"]:
                c_hit = (
                    direction == 1 and highs[t] >= sequence["fib138"]
                ) or (
                    direction == -1 and lows[t] <= sequence["fib138"]
                )
                if c_hit:
                    sequence["c_reached"] = True

            if position_sequence is sequence and t > entry_bar:
                stop_hit = (
                    direction == 1 and lows[t] <= sequence["stop"]
                ) or (
                    direction == -1 and highs[t] >= sequence["stop"]
                )
                final_target_hit = sequence["tp_hit"][num_tps - 1]

                if stop_hit or final_target_hit:
                    if direction == 1:
                        long_exits[t] = True
                    else:
                        short_exits[t] = True
                    sequence["bc_active"] = False
                    sequence["bc_closed"] = True
                    position_sequence = None
                    entry_bar = -1
                    exited_this_bar = True
                else:
                    if sequence["tp_hit"][0]:
                        sequence["stop"] = (
                            max(sequence["stop"], sequence["bc_entry"])
                            if direction == 1
                            else min(sequence["stop"], sequence["bc_entry"])
                        )
                    if sequence["tp_hit"][1]:
                        sequence["stop"] = (
                            max(sequence["stop"], sequence["targets"][0])
                            if direction == 1
                            else min(sequence["stop"], sequence["targets"][0])
                        )
                    if sequence["tp_hit"][2]:
                        sequence["stop"] = (
                            max(sequence["stop"], sequence["targets"][1])
                            if direction == 1
                            else min(sequence["stop"], sequence["targets"][1])
                        )

            if (
                not sequence["bc_active"]
                and entry_candidate is not sequence
                and not sequence["invalidated"]
            ):
                real_stop_hit = (
                    direction == 1 and lows[t] <= sequence["real_stop"]
                ) or (
                    direction == -1 and highs[t] >= sequence["real_stop"]
                )
                if real_stop_hit:
                    sequence["invalidated"] = True
                    sequence["bc_closed"] = True

        if entry_candidate is not None and not exited_this_bar:
            sequence = entry_candidate
            direction = sequence["direction"]
            entry = (sequence["zone_top"] + sequence["zone_bottom"]) * 0.5
            if np.isfinite(entry):
                sequence["bc_entry"] = entry
                sequence["stop"] = sequence["real_stop"]
                if rr_mode == "Custom RR":
                    risk = abs(entry - sequence["real_stop"])
                    reward = risk * custom_rr
                    sequence["targets"] = [
                        entry + reward * fraction * direction
                        for fraction in (0.25, 0.50, 0.75, 1.0)
                    ]
                if all(np.isfinite(value) for value in sequence["targets"]):
                    sequence["bc_active"] = True
                    position_sequence = sequence
                    entry_bar = t
                    if direction == 1:
                        long_entries[t] = True
                    else:
                        short_entries[t] = True

    return long_entries, long_exits, short_entries, short_exits


STRATEGY = {
    "strategy_id": "PivotBreakRetrace",
    "hypothesis": "10 根確認樞紐形成 0-A-B 後，A 突破並回撤至 0.500–0.667 動態 BC 區間時順勢進場，沿用來源的 Fibonacci／Custom RR 目標與移動停損。",
    "position": "both",
    "generate_signals": generate_signals,
    "signal_parameter_names": ["num_tps", "rr_mode", "custom_rr"],
    "signal_parameter_sets": iter_signal_parameter_sets,
}